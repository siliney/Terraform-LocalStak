# 🚀 Terraform + LocalStack Learning Repository

> **Complete 6-week program for mastering Infrastructure as Code with Terraform and LocalStack**

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)](https://terraform.io)
[![LocalStack](https://img.shields.io/badge/LocalStack-3.0+-FF9900?logo=amazon-aws)](https://localstack.cloud)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://docker.com)

## 🎯 What You'll Learn

Transform from beginner to Terraform expert in 6 weeks with hands-on projects, real-world scenarios, and production-ready practices.

- **Infrastructure as Code**: Master Terraform fundamentals and advanced patterns
- **LocalStack Integration**: Develop and test AWS services locally without costs
- **Production Practices**: Learn state management, modules, and CI/CD workflows
- **DevOps Skills**: Monitoring, security, and deployment automation

## 🚀 Quick Start

### Prerequisites
📋 **[Complete Installation Guide](PREREQUISITES.md)**

**Required Tools:**
- Docker Desktop
- Terraform 1.6+
- Git
- AWS CLI
- VS Code (recommended)

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

## 📚 Learning Path (6 Weeks)

### 🎯 **Beginner Level (Weeks 1-2)**

#### **Week 1: Terraform Basics & Hello World**
📖 **[Complete Guide](beginner-week1/DETAILED_GUIDE.md)**
- Day 1-2: Understanding Terraform fundamentals
- Day 3-4: LocalStack setup and configuration  
- Day 5-7: First AWS resources (S3, outputs, functions)

#### **Week 2: Multiple Resources & Dependencies**
📖 **[Complete Guide](beginner-week2/DETAILED_GUIDE.md)**
- Day 1-3: Multi-resource configurations (S3 + IAM + EC2)
- Day 4-5: Resource dependencies and relationships
- Day 6-7: Complete web application stack

### 🔧 **Intermediate Level (Weeks 3-4)**

#### **Week 3: Variables & Outputs**
📖 **[Complete Guide](intermediate-week3/DETAILED_GUIDE.md)**
- Day 1-3: Input variables and flexible configurations
- Day 4-5: Variable validation and complex types
- Day 6-7: Local values and built-in functions

#### **Week 4: Production Monitoring & Security**
📖 **[Complete Guide](intermediate-week4/README.md)**
- Day 1: Monitoring setup (Prometheus/Grafana)
- Day 2: Logging & observability (ELK stack)
- Day 3: Security scanning and policies
- Day 4: Complete deployment automation

### 🏗️ **Advanced Level (Weeks 5-6)**

#### **Week 5: Modules & Reusability**
📖 **[Complete Guide](advanced-week5/DETAILED_GUIDE.md)**
- Day 1-3: Creating reusable Terraform modules
- Day 4-5: Using Terraform Registry modules
- Day 6-7: Complex module composition

#### **Week 6: Workspaces & CI/CD**
📖 **[Complete Guide](advanced-week6/DETAILED_GUIDE.md)**
- Day 1-3: Terraform workspaces for environment management
- Day 4-5: Remote state storage and team collaboration
- Day 6-7: Production CI/CD pipelines with GitHub Actions

## 🛠️ Repository Structure

```
Terraform-LocalStak/
├── README.md                    # This guide
├── PREREQUISITES.md             # Installation instructions
├── docker-compose.yml           # LocalStack setup
│
├── beginner-week1/              # Week 1: Terraform Basics
│   ├── DETAILED_GUIDE.md       # Complete tutorial
│   ├── day1-hello/             # Hello World
│   └── day5-s3/                # First AWS resource
│
├── beginner-week2/              # Week 2: Multiple Resources
│   ├── DETAILED_GUIDE.md       # Complete tutorial
│   └── day1-multi-resource/    # Multi-resource setup
│
├── intermediate-week3/          # Week 3: Variables & Outputs
│   ├── DETAILED_GUIDE.md       # Complete tutorial
│   ├── day1-variables/         # Variables introduction
│   └── day4-advanced-vars/     # Advanced variables
│
├── intermediate-week4/          # Week 4: Monitoring & Security
│   ├── README.md               # Week overview
│   ├── day1-monitoring/        # Prometheus/Grafana
│   ├── day2-logging/           # ELK stack
│   ├── day3-security/          # Security scanning
│   └── day4-deployment/        # Complete automation
│
├── advanced-week5/              # Week 5: Modules
│   ├── DETAILED_GUIDE.md       # Complete tutorial
│   └── day1-modules/           # First module
│
└── advanced-week6/              # Week 6: Workspaces & CI/CD
    ├── DETAILED_GUIDE.md       # Complete tutorial
    ├── day1-workspaces/        # Environment management
    └── day6-cicd/              # CI/CD pipelines
```

## 🧪 Example: Complete Infrastructure Stack

```hcl
# Configure Terraform with LocalStack
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
  
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

# VPC and networking
module "vpc" {
  source = "./modules/vpc"
  
  name               = "learning-vpc"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Web application
module "web_app" {
  source = "./modules/web-server"
  
  name       = "learning-app"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  
  instance_type = "t3.micro"
  min_size      = 2
  max_size      = 5
}

output "application_url" {
  value = "http://${module.web_app.load_balancer_dns_name}"
}
```

## 🔧 Essential Commands

### Daily Terraform Workflow
```bash
terraform fmt       # Format code
terraform validate  # Validate syntax
terraform plan      # Preview changes
terraform apply     # Create resources
terraform destroy   # Clean up resources
```

### LocalStack Management
```bash
# Start LocalStack
docker-compose up -d

# Check services
curl http://localhost:4566/_localstack/health

# Use AWS CLI with LocalStack
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Advanced Operations
```bash
# Workspace management
terraform workspace new dev
terraform workspace select prod

# State management
terraform state list
terraform state show aws_instance.web

# Module operations
terraform get -update
terraform init -upgrade
```

## 🎓 Learning Outcomes

After completing this 6-week program, you'll have:

### **Technical Skills**
- ✅ Terraform fundamentals and advanced patterns
- ✅ AWS services integration with LocalStack
- ✅ Infrastructure as Code best practices
- ✅ Module development and composition
- ✅ State management and team collaboration
- ✅ CI/CD pipeline implementation

### **Production Experience**
- ✅ Monitoring and observability setup
- ✅ Security scanning and compliance
- ✅ Multi-environment management
- ✅ Automated deployment workflows
- ✅ Real-world troubleshooting skills

### **Portfolio Projects**
- ✅ Complete web application infrastructure
- ✅ Reusable Terraform modules library
- ✅ Production-ready CI/CD pipelines
- ✅ Monitoring and security implementations

## 🤝 Contributing

Improve the learning experience for everyone:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Submit a pull request

## 📄 License

This project is for educational purposes. Free to use and modify for learning.

---

⭐ **Star this repository** if it helps your Infrastructure as Code journey!

**Ready to become a Terraform expert?** Start with [Week 1](beginner-week1/DETAILED_GUIDE.md) 🚀
