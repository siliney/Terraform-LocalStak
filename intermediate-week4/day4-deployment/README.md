# Day 4: Complete Deployment Automation

## Objective
Create a comprehensive deployment pipeline that integrates monitoring, logging, security, and infrastructure management.

## Lab 4: Full Stack Deployment

### Step 1: Master Deployment Script
```bash
#!/bin/bash
# deploy-complete-stack.sh

set -e

echo "🚀 Complete DevOps Stack Deployment"
echo "==================================="

ENVIRONMENT=${1:-dev}
VERSION=${2:-latest}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Pre-deployment checks
log "Running pre-deployment checks..."

# Check required tools
for tool in docker terraform aws; do
    if ! command -v $tool &> /dev/null; then
        error "$tool is not installed"
    fi
done
success "All required tools are available"

# Step 1: Deploy Infrastructure
log "Deploying infrastructure with Terraform..."
cd ../beginner-week1
terraform init
terraform plan -out=tfplan
terraform apply tfplan
success "Infrastructure deployed"

# Step 2: Start LocalStack
log "Starting LocalStack..."
cd ../
docker-compose up -d localstack
sleep 10
success "LocalStack started"

# Step 3: Deploy Monitoring
log "Deploying monitoring stack..."
cd day1-monitoring
docker-compose up -d
sleep 15
success "Monitoring stack deployed"

# Step 4: Deploy Logging
log "Deploying logging stack..."
cd ../day2-logging
docker-compose -f docker-compose.elk.yml up -d
sleep 20
success "Logging stack deployed"

# Step 5: Run Security Scan
log "Running security scans..."
cd ../day3-security
./security-scan.sh ../
success "Security scans completed"

# Step 6: Health Checks
log "Running health checks..."

# Check LocalStack
if curl -f http://localhost:4566/_localstack/health &> /dev/null; then
    success "LocalStack health check passed"
else
    error "LocalStack health check failed"
fi

# Check Prometheus
if curl -f http://localhost:9090/-/healthy &> /dev/null; then
    success "Prometheus health check passed"
else
    warning "Prometheus health check failed"
fi

# Check Grafana
if curl -f http://localhost:3000/api/health &> /dev/null; then
    success "Grafana health check passed"
else
    warning "Grafana health check failed"
fi

# Check Elasticsearch
if curl -f http://localhost:9200/_cluster/health &> /dev/null; then
    success "Elasticsearch health check passed"
else
    warning "Elasticsearch health check failed"
fi

# Final Summary
log "Deployment Summary"
echo "=================="
echo "🌐 Access Points:"
echo "  LocalStack: http://localhost:4566"
echo "  Prometheus: http://localhost:9090"
echo "  Grafana: http://localhost:3000 (admin/admin123)"
echo "  Kibana: http://localhost:5601"
echo ""
echo "📊 Monitoring:"
echo "  Node Exporter: http://localhost:9100"
echo "  Elasticsearch: http://localhost:9200"
echo ""
echo "🔒 Security:"
echo "  Security reports: day3-security/security-reports/"
echo ""
success "🎉 Complete stack deployment finished!"
```

### Step 2: Environment Configuration
```yaml
# environments/dev.yml
environment: dev
region: us-east-1
instance_type: t3.micro
monitoring:
  retention_days: 7
  alert_threshold: 80
logging:
  retention_days: 3
  log_level: debug
security:
  scan_schedule: "0 2 * * *"
  vulnerability_threshold: HIGH
```

### Step 3: Terraform Integration
```hcl
# terraform-integration.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Monitoring containers
resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  image = docker_image.prometheus.image_id
  name  = "prometheus-${var.environment}"
  
  ports {
    internal = 9090
    external = 9090
  }
  
  volumes {
    host_path      = "${path.cwd}/day1-monitoring/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
  }
}

# Grafana container
resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  image = docker_image.grafana.image_id
  name  = "grafana-${var.environment}"
  
  ports {
    internal = 3000
    external = 3000
  }
  
  env = [
    "GF_SECURITY_ADMIN_PASSWORD=admin123"
  ]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

output "monitoring_urls" {
  value = {
    prometheus = "http://localhost:9090"
    grafana    = "http://localhost:3000"
  }
}
```

## Commands to Run
```bash
# Make deployment script executable
chmod +x deploy-complete-stack.sh

# Deploy complete stack
./deploy-complete-stack.sh dev

# Check all services
docker ps

# Test endpoints
curl http://localhost:4566/_localstack/health
curl http://localhost:9090/-/healthy
curl http://localhost:3000/api/health
curl http://localhost:9200/_cluster/health

# View logs
docker-compose logs -f
```

## Validation Checklist
- [ ] All infrastructure deployed via Terraform
- [ ] LocalStack running and accessible
- [ ] Monitoring stack (Prometheus/Grafana) operational
- [ ] Logging stack (ELK) collecting logs
- [ ] Security scans completed successfully
- [ ] All health checks passing
- [ ] Services accessible via web interfaces
