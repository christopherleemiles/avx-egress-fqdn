terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = ">= 2.24.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
  }

  required_version = ">= 1.1.0"
}


provider "azurerm" {
  features {}
}
