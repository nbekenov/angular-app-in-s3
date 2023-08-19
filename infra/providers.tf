terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      version = ">= 4.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev"

  default_tags {
    tags = local.default_tags
  }
}