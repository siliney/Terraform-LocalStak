#!/bin/bash

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
for tool in docker terraform; do
    if ! command -v $tool &> /dev/null; then
        error "$tool is not installed"
    fi
done
success "All required tools are available"

# Step 1: Start LocalStack
log "Starting LocalStack..."
cd ../../
docker-compose up -d localstack
sleep 10
success "LocalStack started"

# Step 2: Deploy Infrastructure
log "Deploying infrastructure with Terraform..."
cd beginner-week1
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
success "Infrastructure deployed"

# Step 3: Deploy Monitoring
log "Deploying monitoring stack..."
cd ../intermediate-week4/day1-monitoring
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
    warning "LocalStack health check failed"
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
