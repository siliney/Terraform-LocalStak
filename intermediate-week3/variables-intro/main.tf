variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-learning"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

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
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project_name}-${var.environment}-${random_id.suffix.hex}"
  
  tags = local.common_tags
}

resource "aws_instance" "app_servers" {
  count         = var.instance_count
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-server-${count.index + 1}"
  })
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.app_servers[*].id
}
