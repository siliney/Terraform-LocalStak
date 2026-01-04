# Week 1: Terraform Basics & Hello World

## 📚 Complete Learning Guide
**👉 [Detailed Step-by-Step Tutorial](DETAILED_GUIDE.md)** - Complete beginner's guide with explanations

## Learning Objectives
- [ ] Understand Terraform syntax (HCL)
- [ ] Learn basic workflow: init → plan → apply → destroy
- [ ] Work with outputs and functions
- [ ] Set up LocalStack environment

## Exercises

### Day 1-2: Hello Terraform
**📖 [Read the detailed guide first](DETAILED_GUIDE.md#day-1-2-understanding-terraform-fundamentals)**

```bash
cd beginner-week1/day1-hello
terraform init
terraform plan
terraform apply
terraform output
```

### Day 3-4: LocalStack Setup
**📖 [Follow the LocalStack tutorial](DETAILED_GUIDE.md#day-3-4-introduction-to-localstack)**

```bash
cd beginner-week1/day3-localstack
docker-compose up -d
terraform init
terraform apply
```

### Day 5-7: First AWS Resource
**📖 [Learn about resources and state](DETAILED_GUIDE.md#day-5-7-understanding-resources-and-state)**

```bash
cd beginner-week1/day5-s3
terraform init
terraform apply
aws --endpoint-url=http://localhost:4566 s3 ls
```

## 🎯 Week Completion Checklist
- [ ] Successfully ran first Terraform configuration
- [ ] LocalStack running and accessible
- [ ] Created S3 bucket in LocalStack
- [ ] Understand basic Terraform workflow (init → plan → apply)
- [ ] Know how to check Terraform state

**Next:** [Week 2: Multiple Resources & Dependencies](../beginner-week2/README.md)
