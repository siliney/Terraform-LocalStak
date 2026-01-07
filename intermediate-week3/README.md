# Week 3: Variables & Outputs

## 📚 Complete Learning Guide
**👉 [Detailed Step-by-Step Tutorial](DETAILED_GUIDE.md)** - Complete guide with explanations

## Learning Objectives
- [ ] Use input variables effectively for flexible configurations
- [ ] Implement variable validation and type constraints
- [ ] Work with local values for computed expressions
- [ ] Organize outputs properly for resource information
- [ ] Master variable files for different environments

## Exercises

### Day 1-3: Variables Introduction
**📖 [Read the detailed guide first](DETAILED_GUIDE.md#day-1-3-variables-introduction)**

```bash
cd intermediate-week3/day1-variables
terraform init
terraform apply
terraform apply -var="environment=staging"
```

### Day 4-5: Advanced Variables
**📖 [Variable Validation & Complex Types](DETAILED_GUIDE.md#day-4-5-advanced-variables)**

```bash
cd intermediate-week3/day4-advanced-vars
terraform init
terraform apply -var-file="staging.tfvars"
terraform apply -var-file="prod.tfvars"
```

### Day 6-7: Local Values & Functions
**📖 [Local Values & Built-in Functions](DETAILED_GUIDE.md#day-6-7-local-values--functions)**

```bash
cd intermediate-week3/day6-locals
terraform init
terraform console  # Test functions interactively
terraform apply
```

## Key Concepts Covered
- Variable types and validation
- Environment-specific configurations
- Local values and expressions
- Built-in functions (string, collection, date/time)
- Output organization and sensitivity
- Variable files and best practices

## Validation
- [ ] Can create flexible, reusable configurations
- [ ] Understand variable validation and types
- [ ] Successfully use local values and functions
- [ ] Organize outputs effectively
