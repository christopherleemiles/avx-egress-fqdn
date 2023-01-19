data "http" "myip" {
  url = "http://ifconfig.me"
}

### INSTANCES 


#SG for Instance 1 in Spoke VPC1
resource "aws_security_group" "vpc1_allow_10_space" {
  name        = "allow_10_space1"
  description = "Allow all traffic from 10.0.0.0/8 space"
  vpc_id      = module.mc-spoke_aws.vpc.vpc_id


  ingress {
    description = "10 space"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo_allow_10_space"
  }
}

#SG for Bastion Host in SpokeVPC1

resource "aws_security_group" "vpc1_allow_10_space_and_pub" {
  name        = "allow_10_space_and_pub1"
  description = "Allow all traffic from 10.0.0.0/8 space and Public IP for Demo"
  vpc_id      = module.mc-spoke_aws.vpc.vpc_id


  ingress {
    description = "10 space"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo_allow_10_space_and_pub"
  }
}


### Subnet For Bastion Host ###

resource "aws_subnet" "Public-Bastion-Subnet" {
  vpc_id                  = module.mc-spoke_aws.vpc.vpc_id
  cidr_block              = "10.88.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"
}

resource "aws_subnet" "Private-Workload-Subnet" {
  vpc_id                  = module.mc-spoke_aws.vpc.vpc_id
  cidr_block              = "10.88.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-southeast-2a"
}


### Associate Bastion Subnet to public RT ###


data "aws_route_table" "AVX-Public-RT-1a" {
  subnet_id = module.mc-spoke_aws.vpc.public_subnets[0].subnet_id
}


resource "aws_route_table_association" "Bastion-subnet-assocation" {
  subnet_id      = aws_subnet.Public-Bastion-Subnet.id
  route_table_id = data.aws_route_table.AVX-Public-RT-1a.id
}

### Associate Private Workload subnet to private RT ###

data "aws_route_table" "AVX-Private-RT-1a" {
  subnet_id = module.mc-spoke_aws.vpc.private_subnets[0].subnet_id
}

resource "aws_route_table_association" "Priv-workload-subnet-assocation" {
  subnet_id      = aws_subnet.Private-Workload-Subnet.id
  route_table_id = data.aws_route_table.AVX-Private-RT-1a.id
}


### Test VMs Inside AWS Spoke 1 VPC ###

resource "aws_instance" "test_instance1" {
  ami                    = "ami-0c18f3cdeea1c220d"
  instance_type          = "t2.micro"
  key_name               = "ap-southeast-2-keypair"
  vpc_security_group_ids = [aws_security_group.vpc1_allow_10_space.id]
  subnet_id              = aws_subnet.Private-Workload-Subnet.id
  tags = {
    Name        = "demo-test-vm1"
    Environment = "demo"
  }
}


resource "aws_instance" "demo-bastion-host" {
  ami                    = "ami-0c18f3cdeea1c220d"
  instance_type          = "t2.micro"
  key_name               = "ap-southeast-2-keypair"
  vpc_security_group_ids = [aws_security_group.vpc1_allow_10_space_and_pub.id]
  subnet_id              = aws_subnet.Public-Bastion-Subnet.id
  tags = {
    Name        = "apse2-Demo-Test-Bastion"
    Environment = "demo"
  }
}



