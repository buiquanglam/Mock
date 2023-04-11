terraform {
  required_version = ">= 0.12.24"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }
  #save tfstate to s3 bucket
  backend "s3" {
    bucket = "packer-tuankn"
    key    = "infra/terraform.tfstate"
    region = "eu-west-2"
  }
}
