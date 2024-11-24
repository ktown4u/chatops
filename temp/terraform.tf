terraform {
  required_version = ">=0.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.3.0"
    }
  }
  backend "s3" {
    bucket = "ktown4u-terraform-backend"
    key    = "assistance/porunga"
    region = "ap-northeast-2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      service = "assistance"
      env     = "prod"
    }
  }
}


