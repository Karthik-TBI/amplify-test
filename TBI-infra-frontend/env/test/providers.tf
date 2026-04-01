#############################################
# env/test/providers.tf
# Per-environment AWS provider (us-west-2)
# Values for 'region' come from env/test/terraform.tfvars
#############################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}