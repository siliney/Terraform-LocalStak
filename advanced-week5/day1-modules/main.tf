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
    s3 = "http://localhost:4566"
  }
}

module "data_bucket" {
  source = "./modules/s3-bucket"
  
  bucket_name = "my-data-bucket-${random_id.suffix.hex}"
  tags = {
    Environment = "dev"
    Purpose     = "data-storage"
  }
}

module "logs_bucket" {
  source = "./modules/s3-bucket"
  
  bucket_name = "my-logs-bucket-${random_id.suffix.hex}"
  tags = {
    Environment = "dev"
    Purpose     = "logging"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "data_bucket_name" {
  value = module.data_bucket.bucket_name
}

output "logs_bucket_name" {
  value = module.logs_bucket.bucket_name
}
