terraform {
  required_version = ">= 1.3.6, < 2.0.0"

  required_providers {
    aws = {
      version = ">= 3.0.0"
      source  = "hashicorp/aws"
    }
  }

  # backend "s3" {
  #   bucket = "398090104120-root-tfstate"
  #   key    = "aws-account-398090104120/terraform.tfstate"
  #  region = "eu-central-1"
  # }

}

provider "aws" {
  region = var.region
}