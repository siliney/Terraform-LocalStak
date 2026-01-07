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
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    ec2      = "http://localhost:4566"
  }
}

# S3 Bucket for data storage
resource "aws_s3_bucket" "data_bucket" {
  bucket = "company-data-${random_id.suffix.hex}"
}

# DynamoDB table for user data
resource "aws_dynamodb_table" "users" {
  name           = "users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Environment = "development"
    Project     = "terraform-learning"
  }
}

# EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name        = "terraform-web-server"
    Environment = "development"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Outputs
output "bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.users.name
}

output "instance_id" {
  value = aws_instance.web_server.id
}
