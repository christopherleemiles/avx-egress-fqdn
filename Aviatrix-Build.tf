
#Build Aviatrix Transit module - AWS
module "mc-transit_aws" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.2"


  cloud   = "AWS"
  name    = "avx-apse1-demo-transit"
  region  = "ap-southeast-2"
  cidr    = "10.188.0.0/16"
  account = var.aws_acct
}

#Build Aviatrix Transit module - Azure
module "mc-transit_azure" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.2"


  cloud   = "Azure"
  name    = "avx-ause-demo-transit"
  region  = "Australia East"
  cidr    = "10.189.0.0/16"
  account = var.azure_acct
}


#Aviatrix Transit Peering
module "mc-transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.8"

  transit_gateways = [
    module.mc-transit_aws.transit_gateway.gw_name,
    module.mc-transit_azure.transit_gateway.gw_name,
  ]
}


module "mc-spoke_aws" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.2"

  cloud      = "AWS"
  name       = "avx-apse1-demo-spoke"
  region     = "ap-southeast-2"
  cidr       = "10.88.0.0/16"
  account    = var.aws_acct
  transit_gw = module.mc-transit_aws.transit_gateway.gw_name
}

module "mc-spoke_azure" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.2"

  cloud      = "Azure"
  name       = "avx-ause-demo-spoke"
  region     = "Australia East"
  cidr       = "10.89.0.0/16"
  account    = var.azure_acct
  transit_gw = module.mc-transit_azure.transit_gateway.gw_name
}



