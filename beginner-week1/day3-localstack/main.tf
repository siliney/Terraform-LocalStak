terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"
  
  # LocalStack endpoints
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
  
  # Skip credentials validation for LocalStack
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Test resource - S3 bucket
resource "aws_s3_bucket" "test" {
  bucket = "localstack-test-bucket"
}

output "bucket_name" {
  value = aws_s3_bucket.test.bucket
}

output "localstack_endpoint" {
  value = "http://localhost:4566"
}
