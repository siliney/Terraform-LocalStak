# Week 2: Multiple Resources & Dependencies

## 📚 Complete Learning Guide
**👉 [Detailed Step-by-Step Tutorial](DETAILED_GUIDE.md)** - Complete guide with explanations

## Learning Objectives
- [ ] Create multiple AWS resources in a single configuration
- [ ] Understand implicit and explicit resource dependencies
- [ ] Work with different resource types (S3, IAM, EC2, VPC)
- [ ] Practice resource relationships and data flow

## Exercises

### Multi-Resource Setup
**📖 [Read the detailed guide first](DETAILED_GUIDE.md#day-1-3-multi-resource-setup)**

```bash
cd beginner-week2/multi-resource
terraform init
terraform plan
terraform apply
```

### Resource Dependencies
**📖 [Understanding Dependencies](DETAILED_GUIDE.md#day-4-5-resource-dependencies)**

```bash
cd beginner-week2/dependencies
terraform init
terraform apply
terraform graph | dot -Tpng > dependencies.png
```

### Practice Project
**📖 [Complete Web Stack](DETAILED_GUIDE.md#day-6-7-practice-project)**

```bash
cd beginner-week2/practice-project
terraform init
terraform apply
```

## Key Concepts Covered
- Resource dependencies (implicit vs explicit)
- Multi-resource configurations
- AWS networking basics (VPC, subnets, security groups)
- IAM roles and policies
- Load balancers and EC2 instances

## Validation
- [ ] Can create multiple related resources
- [ ] Understand dependency resolution
- [ ] Successfully deploy complete web application stack
