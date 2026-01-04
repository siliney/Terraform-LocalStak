# Week 6: Workspaces & CI/CD

## Learning Objectives
- [ ] Use Terraform workspaces
- [ ] Implement remote state
- [ ] Set up automated validation
- [ ] Create CI/CD pipelines

## Exercises

### Day 1-3: Workspaces
```bash
cd advanced-week6/day1-workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace select dev
terraform apply
```

### Day 4-5: Remote State
```bash
cd advanced-week6/day4-remote-state
terraform init
terraform apply
```

### Day 6-7: CI/CD Pipeline
```bash
cd advanced-week6/day6-cicd
# Check .github/workflows/terraform.yml
```
