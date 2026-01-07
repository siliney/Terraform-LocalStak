# Week 2: Multiple Resources & Dependencies
## Complete Learning Guide

### 🎯 Learning Objectives
By the end of this week, you will:
- Create multiple AWS resources in a single configuration
- Understand implicit and explicit resource dependencies
- Work with different AWS resource types (S3, IAM, EC2)
- Practice resource relationships and data flow

---

## Day 1-3: Multi-Resource Setup

### Understanding Resource Dependencies
When you create multiple resources, Terraform automatically figures out the order based on dependencies. For example, if an EC2 instance needs an IAM role, Terraform creates the role first.

**Types of Dependencies:**
- **Implicit**: Terraform detects automatically (using resource attributes)
- **Explicit**: You specify using `depends_on`

### Lab 2.1: S3 Bucket with IAM Policy
```hcl
# Create S3 bucket
resource "aws_s3_bucket" "app_data" {
  bucket = "my-app-data-${random_id.bucket_suffix.hex}"
}

# Create random suffix to ensure unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create IAM policy for S3 access
resource "aws_iam_policy" "s3_access" {
  name        = "s3-app-access"
  description = "Policy for S3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.app_data.arn}/*"
      }
    ]
  })
}

# Create IAM role
resource "aws_iam_role" "app_role" {
  name = "app-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "app_policy_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}
```

### Lab 2.2: EC2 Instance with Security Group
```hcl
# Create security group first
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web server"

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
}

# Create EC2 instance (depends on security group)
resource "aws_instance" "web_server" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.app_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "terraform-web-server"
  }
}

# Create instance profile for IAM role
resource "aws_iam_instance_profile" "app_profile" {
  name = "app-instance-profile"
  role = aws_iam_role.app_role.name
}
```

## Day 4-5: Resource Dependencies

### Understanding Dependency Graph
Terraform creates a dependency graph to determine the order of resource creation:

```bash
# Visualize dependencies
terraform graph | dot -Tpng > dependencies.png
```

### Lab 2.3: Explicit Dependencies
```hcl
# Sometimes you need explicit dependencies
resource "aws_s3_bucket_object" "config_file" {
  bucket = aws_s3_bucket.app_data.bucket
  key    = "config/app.json"
  content = jsonencode({
    database_url = aws_db_instance.app_db.endpoint
    app_version  = "1.0.0"
  })

  # Explicit dependency - wait for database to be ready
  depends_on = [aws_db_instance.app_db]
}

# RDS Database
resource "aws_db_instance" "app_db" {
  identifier     = "app-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp2"
  
  db_name  = "appdb"
  username = "admin"
  password = "changeme123!"
  
  skip_final_snapshot = true
  
  tags = {
    Name = "app-database"
  }
}
```

## Day 6-7: Practice Project

### Lab 2.4: Complete Web Application Stack
```hcl
# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${var.environment}-public-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.app_name}-${var.environment}-alb"
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.app_name}-${var.environment}-alb-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-alb-sg"
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_data.bucket
}
```

## Commands to Practice
```bash
# Initialize and apply
terraform init
terraform plan
terraform apply

# Check dependencies
terraform graph | dot -Tpng > dependencies.png

# Show state
terraform show
terraform state list

# Clean up
terraform destroy
```

## Common Issues & Solutions

**Issue**: Circular dependencies
**Solution**: Use data sources or split into separate configurations

**Issue**: Resource creation order
**Solution**: Use explicit `depends_on` when needed

**Issue**: Resource naming conflicts
**Solution**: Use random_id or timestamps for unique names

## Validation Checklist
- [ ] Multiple resources created successfully
- [ ] Dependencies resolved correctly
- [ ] Resources can reference each other
- [ ] Outputs show expected values
- [ ] Clean destroy works properly
