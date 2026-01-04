# Week 1: Terraform Basics & Hello World

## Learning Objectives
- [ ] Understand Terraform syntax (HCL)
- [ ] Learn basic workflow: init → plan → apply → destroy
- [ ] Work with outputs and functions
- [ ] Set up LocalStack environment

## Exercises

### Day 1-2: Hello Terraform
```bash
cd beginner-week1/day1-hello
terraform init
terraform plan
terraform apply
terraform output
```

### Day 3-4: LocalStack Setup
```bash
cd beginner-week1/day3-localstack
docker-compose up -d
terraform init
terraform apply
```

### Day 5-7: First AWS Resource
```bash
cd beginner-week1/day5-s3
terraform init
terraform apply
aws --endpoint-url=http://localhost:4566 s3 ls
```
