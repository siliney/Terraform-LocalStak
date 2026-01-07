# Week 6: Workspaces & CI/CD
## Complete Learning Guide

### 🎯 Learning Objectives
By the end of this week, you will:
- Master Terraform workspaces for environment management
- Implement remote state storage and locking
- Set up automated validation and testing
- Create production-ready CI/CD pipelines
- Understand state management best practices

---

## Day 1-3: Workspaces

### Understanding Terraform Workspaces
Workspaces allow you to manage multiple environments (dev, staging, prod) with the same configuration but separate state files.

**Benefits of Workspaces:**
- **Environment Isolation**: Separate state for each environment
- **Code Reuse**: Same configuration for multiple environments
- **Safety**: Prevents accidental cross-environment changes
- **Organization**: Clear separation of concerns

### Lab 6.1: Basic Workspaces
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
  region = var.aws_region
}

# Variables that change per workspace
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Locals for workspace-specific values
locals {
  workspace_config = {
    dev = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 2
      environment   = "development"
    }
    staging = {
      instance_type = "t3.small"
      min_size      = 2
      max_size      = 4
      environment   = "staging"
    }
    prod = {
      instance_type = "t3.medium"
      min_size      = 3
      max_size      = 10
      environment   = "production"
    }
  }

  # Get current workspace config
  current_config = local.workspace_config[terraform.workspace]
  
  # Common tags
  common_tags = {
    Environment = local.current_config.environment
    Workspace   = terraform.workspace
    ManagedBy   = "terraform"
    Project     = "terraform-learning"
  }
}

# VPC with workspace-specific naming
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${terraform.workspace}-vpc"
  })
}

# Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${terraform.workspace}-public-${count.index + 1}"
  })
}

# Auto Scaling Group with workspace-specific sizing
resource "aws_autoscaling_group" "web" {
  name                = "${terraform.workspace}-web-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  
  min_size         = local.current_config.min_size
  max_size         = local.current_config.max_size
  desired_capacity = local.current_config.min_size

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-web-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${terraform.workspace}-web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = local.current_config.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = local.current_config.environment
    workspace   = terraform.workspace
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${terraform.workspace}-web-server"
    })
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Security Group
resource "aws_security_group" "web" {
  name_prefix = "${terraform.workspace}-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${terraform.workspace}-web-sg"
  })
}

# Outputs
output "workspace_info" {
  description = "Current workspace information"
  value = {
    workspace     = terraform.workspace
    environment   = local.current_config.environment
    instance_type = local.current_config.instance_type
    min_size      = local.current_config.min_size
    max_size      = local.current_config.max_size
  }
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}
```

```bash
# user_data.sh
#!/bin/bash
apt-get update
apt-get install -y apache2

# Create environment-specific web page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Workspace Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .${environment} { background-color: #f0f8ff; }
    </style>
</head>
<body class="${environment}">
    <h1>Welcome to ${environment} Environment</h1>
    <p><strong>Workspace:</strong> ${workspace}</p>
    <p><strong>Server:</strong> $(hostname)</p>
    <p><strong>Date:</strong> $(date)</p>
    <p><strong>Environment:</strong> ${environment}</p>
</body>
</html>
EOF

systemctl start apache2
systemctl enable apache2
```

### Workspace Commands
```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# Show current workspace
terraform workspace show

# Apply to current workspace
terraform apply

# Switch and apply to different workspace
terraform workspace select staging
terraform apply

# Delete workspace (must be empty)
terraform workspace select default
terraform workspace delete dev
```

## Day 4-5: Remote State

### Understanding Remote State
Remote state storage provides:
- **Collaboration**: Multiple team members can work together
- **Locking**: Prevents concurrent modifications
- **Security**: State stored securely in the cloud
- **Backup**: Automatic versioning and backup

### Lab 6.2: S3 Backend Configuration
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Lab 6.3: Setting up Remote State Infrastructure
```hcl
# bootstrap/main.tf - Run this first to create backend resources
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name for the Terraform state bucket"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

# S3 bucket for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "shared"
    Purpose     = "terraform-state"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "shared"
    Purpose     = "terraform-state-locking"
  }
}

# IAM policy for Terraform state access
resource "aws_iam_policy" "terraform_state_policy" {
  name        = "TerraformStateAccess"
  description = "Policy for Terraform state bucket and DynamoDB table access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_state_lock.arn
      }
    ]
  })
}

# Outputs
output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "backend_config" {
  description = "Backend configuration for other Terraform projects"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
  }
}
```

### Workspace-Specific Remote State
```hcl
# backend-with-workspaces.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "workspaces/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Workspace-specific state files
    workspace_key_prefix = "env"
  }
}

# This creates state files like:
# env/dev/workspaces/terraform.tfstate
# env/staging/workspaces/terraform.tfstate
# env/prod/workspaces/terraform.tfstate
```

## Day 6-7: CI/CD Pipeline

### Lab 6.4: GitHub Actions Workflow
```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  TF_VERSION: 1.6.0
  AWS_REGION: us-east-1

jobs:
  validate:
    name: Validate Terraform
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Terraform Format Check
      run: terraform fmt -check -recursive

    - name: Terraform Init
      run: terraform init -backend=false

    - name: Terraform Validate
      run: terraform validate

    - name: Run tflint
      uses: terraform-linters/setup-tflint@v4
      with:
        tflint_version: latest
    
    - name: Init tflint
      run: tflint --init

    - name: Run tflint
      run: tflint -f compact

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'config'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'

    - name: Run tfsec
      uses: aquasecurity/tfsec-action@v1.0.3
      with:
        soft_fail: true

  plan-dev:
    name: Plan (Development)
    runs-on: ubuntu-latest
    needs: [validate, security]
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Terraform Init
      run: terraform init

    - name: Select Dev Workspace
      run: |
        terraform workspace select dev || terraform workspace new dev

    - name: Terraform Plan
      run: terraform plan -no-color -out=tfplan
      
    - name: Save Plan
      uses: actions/upload-artifact@v3
      with:
        name: tfplan-dev
        path: tfplan

    - name: Comment Plan on PR
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      with:
        script: |
          const fs = require('fs');
          const { execSync } = require('child_process');
          
          try {
            const plan = execSync('terraform show -no-color tfplan', { encoding: 'utf8' });
            const comment = `## Terraform Plan (Development)
            
            \`\`\`
            ${plan}
            \`\`\`
            
            Plan saved as artifact: tfplan-dev`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
          } catch (error) {
            console.error('Error creating comment:', error);
          }

  deploy-dev:
    name: Deploy (Development)
    runs-on: ubuntu-latest
    needs: [validate, security]
    if: github.ref == 'refs/heads/develop'
    environment: development
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Terraform Init
      run: terraform init

    - name: Select Dev Workspace
      run: |
        terraform workspace select dev || terraform workspace new dev

    - name: Terraform Apply
      run: terraform apply -auto-approve

    - name: Output Infrastructure Info
      run: terraform output -json > infrastructure-output.json

    - name: Upload Infrastructure Output
      uses: actions/upload-artifact@v3
      with:
        name: infrastructure-output-dev
        path: infrastructure-output.json

  deploy-prod:
    name: Deploy (Production)
    runs-on: ubuntu-latest
    needs: [validate, security]
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Terraform Init
      run: terraform init

    - name: Select Prod Workspace
      run: |
        terraform workspace select prod || terraform workspace new prod

    - name: Terraform Plan
      run: terraform plan -out=tfplan

    - name: Manual Approval Required
      uses: trstringer/manual-approval@v1
      with:
        secret: ${{ github.TOKEN }}
        approvers: ${{ secrets.PROD_APPROVERS }}
        minimum-approvals: 2
        issue-title: "Production Deployment Approval Required"
        issue-body: |
          Please review the Terraform plan and approve this production deployment.
          
          **Branch:** ${{ github.ref }}
          **Commit:** ${{ github.sha }}
          **Author:** ${{ github.actor }}

    - name: Terraform Apply
      run: terraform apply tfplan

    - name: Create Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: v${{ github.run_number }}
        release_name: Production Release v${{ github.run_number }}
        draft: false
        prerelease: false
```

### Lab 6.5: Advanced Pipeline Features
```yaml
# .github/workflows/terraform-advanced.yml
name: Advanced Terraform Pipeline

on:
  schedule:
    - cron: '0 2 * * *'  # Daily drift detection
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'dev'
        type: choice
        options:
        - dev
        - staging
        - prod
      action:
        description: 'Action to perform'
        required: true
        default: 'plan'
        type: choice
        options:
        - plan
        - apply
        - destroy

jobs:
  drift-detection:
    name: Drift Detection
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    strategy:
      matrix:
        workspace: [dev, staging, prod]
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.6.0

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Terraform Init
      run: terraform init

    - name: Select Workspace
      run: terraform workspace select ${{ matrix.workspace }}

    - name: Check for Drift
      run: |
        terraform plan -detailed-exitcode -no-color > drift-report-${{ matrix.workspace }}.txt
        exit_code=$?
        if [ $exit_code -eq 2 ]; then
          echo "DRIFT_DETECTED=true" >> $GITHUB_ENV
          echo "Drift detected in ${{ matrix.workspace }} workspace"
        else
          echo "DRIFT_DETECTED=false" >> $GITHUB_ENV
          echo "No drift detected in ${{ matrix.workspace }} workspace"
        fi

    - name: Create Drift Issue
      if: env.DRIFT_DETECTED == 'true'
      uses: actions/github-script@v7
      with:
        script: |
          const fs = require('fs');
          const driftReport = fs.readFileSync('drift-report-${{ matrix.workspace }}.txt', 'utf8');
          
          github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: `Infrastructure Drift Detected - ${{ matrix.workspace }}`,
            body: `## Infrastructure Drift Report
            
            Drift has been detected in the **${{ matrix.workspace }}** environment.
            
            ### Terraform Plan Output:
            \`\`\`
            ${driftReport}
            \`\`\`
            
            Please review and take appropriate action.`,
            labels: ['infrastructure', 'drift', '${{ matrix.workspace }}']
          });

  manual-deployment:
    name: Manual Deployment
    runs-on: ubuntu-latest
    if: github.event_name == 'workflow_dispatch'
    environment: ${{ github.event.inputs.environment }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.6.0

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Terraform Init
      run: terraform init

    - name: Select Workspace
      run: |
        terraform workspace select ${{ github.event.inputs.environment }} || \
        terraform workspace new ${{ github.event.inputs.environment }}

    - name: Terraform Plan
      if: github.event.inputs.action == 'plan'
      run: terraform plan -no-color

    - name: Terraform Apply
      if: github.event.inputs.action == 'apply'
      run: terraform apply -auto-approve

    - name: Terraform Destroy
      if: github.event.inputs.action == 'destroy'
      run: terraform destroy -auto-approve
```

## Best Practices

1. **Workspace Management**
   - Use consistent naming conventions
   - Document workspace purposes
   - Implement proper access controls

2. **Remote State**
   - Always use remote state for teams
   - Enable state locking
   - Implement proper backup strategies

3. **CI/CD Pipeline**
   - Validate before planning
   - Require approvals for production
   - Implement drift detection
   - Use environment protection rules

## Commands to Practice
```bash
# Workspace operations
terraform workspace list
terraform workspace new dev
terraform workspace select dev
terraform apply

# Remote state migration
terraform init -migrate-state

# Pipeline testing
git push origin feature-branch  # Triggers validation
git push origin develop         # Triggers dev deployment
git push origin main           # Triggers prod deployment
```

## Validation Checklist
- [ ] Can manage multiple environments with workspaces
- [ ] Successfully implement remote state storage
- [ ] Create automated validation pipelines
- [ ] Set up production-ready CI/CD workflows
- [ ] Understand state management best practices
