terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_use_path_style          = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}

locals {
  environment = terraform.workspace
  instance_count = {
    dev     = 1
    staging = 2
    prod    = 3
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "app-${local.environment}-${random_id.suffix.hex}"
  
  tags = {
    Environment = local.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_instance" "app_servers" {
  count         = local.instance_count[local.environment]
  ami           = "ami-12345678"
  instance_type = local.environment == "prod" ? "t3.medium" : "t2.micro"

  tags = {
    Name        = "app-${local.environment}-${count.index + 1}"
    Environment = local.environment
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "environment" {
  value = local.environment
}

output "bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}

output "instance_count" {
  value = length(aws_instance.app_servers)
}
