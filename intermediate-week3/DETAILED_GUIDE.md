# Week 3: Variables & Outputs
## Complete Learning Guide

### 🎯 Learning Objectives
By the end of this week, you will:
- Master input variables for flexible configurations
- Implement variable validation and type constraints
- Use local values for computed expressions
- Create meaningful outputs for resource information
- Organize configurations with variable files

---

## Day 1-3: Variables Introduction

### Understanding Terraform Variables
Variables make your Terraform configurations flexible and reusable. Instead of hardcoding values, you can parameterize your infrastructure.

**Benefits of Variables:**
- **Reusability**: Same code for dev/staging/prod
- **Flexibility**: Easy to change values without editing code
- **Security**: Sensitive values can be passed securely
- **Maintainability**: Centralized configuration management

### Lab 3.1: Basic Variables
```hcl
# variables.tf
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "terraform-learning"
    ManagedBy = "terraform"
  }
}
```

### Lab 3.2: Using Variables in Resources
```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  monitoring = var.enable_monitoring
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  tags = merge(var.tags, {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  })
}

resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-"
  
  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-web-sg"
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
```

### Variable Input Methods
```bash
# Method 1: Command line
terraform apply -var="environment=staging" -var="instance_type=t3.small"

# Method 2: Environment variables
export TF_VAR_environment=staging
export TF_VAR_instance_type=t3.small
terraform apply

# Method 3: Variable files
terraform apply -var-file="staging.tfvars"

# Method 4: terraform.tfvars (auto-loaded)
terraform apply
```

## Day 4-5: Advanced Variables

### Variable Validation
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  
  validation {
    condition = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "Instance type must be t2 or t3 family."
  }
}

variable "database_config" {
  description = "Database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
    multi_az       = bool
  })
  
  validation {
    condition = var.database_config.allocated_storage >= 20
    error_message = "Database storage must be at least 20 GB."
  }
}
```

### Complex Variable Types
```hcl
# Complex object variable
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
    subnets = list(object({
      cidr_block        = string
      availability_zone = string
      public           = bool
    }))
  })
  
  default = {
    cidr_block = "10.0.0.0/16"
    subnets = [
      {
        cidr_block        = "10.0.1.0/24"
        availability_zone = "us-east-1a"
        public           = true
      },
      {
        cidr_block        = "10.0.2.0/24"
        availability_zone = "us-east-1b"
        public           = false
      }
    ]
  }
}

# Using complex variables
resource "aws_vpc" "main" {
  cidr_block = var.vpc_config.cidr_block
  
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.vpc_config.subnets)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_config.subnets[count.index].cidr_block
  availability_zone       = var.vpc_config.subnets[count.index].availability_zone
  map_public_ip_on_launch = var.vpc_config.subnets[count.index].public
  
  tags = {
    Name = "${var.environment}-subnet-${count.index + 1}"
    Type = var.vpc_config.subnets[count.index].public ? "public" : "private"
  }
}
```

### Variable Files
```hcl
# dev.tfvars
environment = "dev"
instance_type = "t2.micro"
enable_monitoring = false

database_config = {
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  multi_az       = false
}

vpc_config = {
  cidr_block = "10.0.0.0/16"
  subnets = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      public           = true
    }
  ]
}
```

```hcl
# prod.tfvars
environment = "prod"
instance_type = "t3.large"
enable_monitoring = true

database_config = {
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.large"
  allocated_storage = 100
  multi_az       = true
}

vpc_config = {
  cidr_block = "10.0.0.0/16"
  subnets = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      public           = true
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
      public           = true
    },
    {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
      public           = false
    },
    {
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-east-1b"
      public           = false
    }
  ]
}
```

## Day 6-7: Local Values & Functions

### Local Values
Local values help you avoid repeating expressions and make your code more readable.

```hcl
# locals.tf
locals {
  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Project     = "terraform-learning"
    ManagedBy   = "terraform"
    CreatedAt   = timestamp()
  }
  
  # Computed values
  name_prefix = "${var.environment}-${var.project_name}"
  
  # Conditional logic
  instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"
  
  # Complex computations
  public_subnets = [
    for subnet in var.vpc_config.subnets : subnet
    if subnet.public == true
  ]
  
  private_subnets = [
    for subnet in var.vpc_config.subnets : subnet
    if subnet.public == false
  ]
  
  # String manipulation
  bucket_name = lower(replace("${local.name_prefix}-data-bucket", "_", "-"))
}
```

### Using Built-in Functions
```hcl
# String functions
resource "aws_s3_bucket" "data" {
  bucket = local.bucket_name
  
  tags = merge(local.common_tags, {
    Name = title(replace(local.bucket_name, "-", " "))
  })
}

# Collection functions
resource "aws_security_group_rule" "web_ingress" {
  count = length(var.allowed_ports)
  
  type              = "ingress"
  from_port         = var.allowed_ports[count.index]
  to_port           = var.allowed_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.web.id
}

# Date/time functions
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/${local.name_prefix}"
  retention_in_days = var.environment == "prod" ? 30 : 7
  
  tags = merge(local.common_tags, {
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })
}

# Conditional expressions
resource "aws_instance" "web" {
  count = var.environment == "prod" ? 2 : 1
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type
  
  # Use conditional for different configurations
  user_data = var.environment == "prod" ? file("user_data_prod.sh") : file("user_data_dev.sh")
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-${count.index + 1}"
  })
}
```

### Outputs
```hcl
# outputs.tf
output "vpc_info" {
  description = "VPC information"
  value = {
    id         = aws_vpc.main.id
    cidr_block = aws_vpc.main.cidr_block
    arn        = aws_vpc.main.arn
  }
}

output "instance_details" {
  description = "EC2 instance details"
  value = {
    for idx, instance in aws_instance.web : idx => {
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      dns_name   = instance.public_dns
    }
  }
}

output "s3_bucket_info" {
  description = "S3 bucket information"
  value = {
    name   = aws_s3_bucket.data.bucket
    arn    = aws_s3_bucket.data.arn
    region = aws_s3_bucket.data.region
  }
  sensitive = false
}

# Sensitive output
output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}
```

## Commands to Practice
```bash
# Using different variable methods
terraform plan -var="environment=dev"
terraform plan -var-file="dev.tfvars"

# Check variable values
terraform console
> var.environment
> local.common_tags

# Apply with specific variables
terraform apply -var-file="prod.tfvars"

# View outputs
terraform output
terraform output vpc_info
terraform output -json
```

## Best Practices

1. **Variable Organization**
   - Group related variables
   - Use descriptive names
   - Add meaningful descriptions

2. **Validation**
   - Validate critical variables
   - Use appropriate type constraints
   - Provide clear error messages

3. **Defaults**
   - Provide sensible defaults
   - Use environment-specific defaults
   - Document when no default is appropriate

4. **Sensitive Data**
   - Mark sensitive outputs
   - Use environment variables for secrets
   - Never commit sensitive values

## Validation Checklist
- [ ] Variables properly defined with types
- [ ] Validation rules working correctly
- [ ] Local values computed properly
- [ ] Outputs provide useful information
- [ ] Different environments work with variable files
