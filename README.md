# 🚀 Terraform + LocalStack Learning Repository

> **Complete guide for learning Infrastructure as Code with Terraform and LocalStack**

[![Terraform](https://img.shields.io/badge/Terraform-1.14+-623CE4?logo=terraform)](https://terraform.io)
[![LocalStack](https://img.shields.io/badge/LocalStack-4.12+-FF9900?logo=amazon-aws)](https://localstack.cloud)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://docker.com)

## 🎯 What You'll Learn

- **Terraform Fundamentals**: Infrastructure as Code principles and practices
- **LocalStack Integration**: Test AWS services locally without costs
- **Hands-on Exercises**: Progressive learning from basics to advanced
- **Best Practices**: Production-ready IaC development

## 🚀 Quick Start

### Prerequisites
📋 **[Complete Installation Guide](PREREQUISITES.md)** - Follow detailed setup instructions for your OS

**Required Tools:**
- Docker Desktop
- Terraform
- Git
- AWS CLI
- Text editor (VS Code recommended)

### Setup
```bash
# Clone repository
git clone https://github.com/siliney/Terraform-LocalStak.git
cd Terraform-LocalStak

# Start LocalStack
docker-compose up -d

# Verify LocalStack is running
curl http://localhost:4566/_localstack/health
```

## 📚 Learning Path

### 🎯 Beginner (Week 1-2)
- [ ] **Hello Terraform**: Basic syntax and outputs
- [ ] **LocalStack Setup**: Local AWS environment
- [ ] **First Resource**: Create S3 bucket
- [ ] **Terraform Workflow**: init → plan → apply → destroy

### 🔧 Intermediate (Week 3-4)
- [ ] **Multiple Resources**: S3 + DynamoDB + EC2
- [ ] **Variables & Outputs**: Parameterized configurations
- [ ] **Resource Dependencies**: Understanding relationships
- [ ] **State Management**: Local vs remote state

### 🏗️ Advanced (Week 5-6)
- [ ] **Modules**: Reusable infrastructure components
- [ ] **Workspaces**: Environment management
- [ ] **Remote State**: Team collaboration
- [ ] **CI/CD Integration**: Automated deployments

## 🛠️ Project Structure

```
Terraform-LocalStak/
├── README.md                 # This file
├── LEARNING_GUIDE.md         # Detailed learning guide
├── docker-compose.yml        # LocalStack setup
├── examples/                 # Practice exercises
│   ├── 01-hello-world/      # Basic Terraform
│   ├── 02-s3-bucket/        # AWS S3 with LocalStack
│   ├── 03-multi-resource/   # Multiple AWS services
│   └── 04-variables/        # Variables and outputs
├── exercises/               # Hands-on challenges
└── solutions/              # Exercise solutions
```

## 🧪 Example: S3 Bucket with LocalStack

```hcl
# Configure Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider for LocalStack
provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"
  
  endpoints {
    s3 = "http://localhost:4566"
  }
}

# Create S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket"
}

# Output bucket name
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
```

**Run it:**
```bash
terraform init
terraform plan
terraform apply
```

## 🔧 Essential Commands

### Terraform Commands
```bash
terraform init      # Initialize project
terraform fmt       # Format code
terraform validate  # Validate syntax
terraform plan      # Preview changes
terraform apply     # Create resources
terraform destroy   # Remove resources
terraform show      # View current state
```

### LocalStack Commands
```bash
# Start/Stop LocalStack
docker-compose up -d
docker-compose down

# Check LocalStack health
curl http://localhost:4566/_localstack/health

# Use AWS CLI with LocalStack
aws --endpoint-url=http://localhost:4566 s3 ls
```

## 🎓 Learning Resources

### Documentation
- [Terraform Documentation](https://terraform.io/docs)
- [LocalStack Documentation](https://docs.localstack.cloud)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws)

### Community
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)
- [LocalStack Slack](https://localstack.cloud/contact/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

## 🤝 Contributing

Found an issue or want to improve the learning materials?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is for educational purposes. Feel free to use and modify for your learning journey.

---

⭐ **Star this repository** if it helps your Terraform learning journey!

**Happy Infrastructure Coding!** 🚀
