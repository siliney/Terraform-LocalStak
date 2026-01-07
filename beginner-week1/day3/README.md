# Day 3-4: LocalStack Setup

## Objective
Set up LocalStack for local AWS development and test basic AWS services.

## Lab: LocalStack Configuration

### Step 1: LocalStack Docker Compose
```yaml
# docker-compose.yml (already exists in root)
version: '3.8'

services:
  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      - SERVICES=s3,ec2,iam,lambda,dynamodb
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
    volumes:
      - localstack_data:/tmp/localstack

volumes:
  localstack_data:
```

### Step 2: Test LocalStack Connection
```bash
# Start LocalStack (from repository root)
cd ../../
docker-compose up -d

# Check LocalStack health
curl http://localhost:4566/_localstack/health

# Test AWS CLI with LocalStack
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Step 3: Basic Terraform with LocalStack
```hcl
# main.tf
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
```

## Commands to Run
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply

# Verify bucket was created
aws --endpoint-url=http://localhost:4566 s3 ls

# Clean up
terraform destroy
```

## Validation
- [ ] LocalStack container running
- [ ] Health check returns 200 OK
- [ ] Terraform can connect to LocalStack
- [ ] S3 bucket created successfully
- [ ] AWS CLI can list LocalStack resources
