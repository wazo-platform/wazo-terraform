terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
    }
  }
}
