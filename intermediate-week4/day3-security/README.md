# Day 3: Security Scanning & Policies

## Objective
Implement comprehensive security scanning and policy enforcement for infrastructure and containers.

## Lab 3: Security Pipeline

### Step 1: Security Scanning Script
```bash
#!/bin/bash
# security-scan.sh

set -e

echo "🔒 DevOps Security Scanning Suite"
echo "================================="

SCAN_DIR=${1:-.}
REPORT_DIR="security-reports"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p "$REPORT_DIR"

# Container Image Security Scanning
echo "📦 Container Image Security Scan"
echo "-------------------------------"
if command -v trivy &> /dev/null; then
    trivy image --format json --output "$REPORT_DIR/image-scan-$DATE.json" \
          --severity HIGH,CRITICAL localstack/localstack:latest
    trivy image --format table localstack/localstack:latest
else
    echo "❌ Trivy not installed, installing..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

# Terraform Security Scan
echo -e "\n🏗️ Terraform Security Scan"
echo "---------------------------"
if command -v tfsec &> /dev/null; then
    tfsec "$SCAN_DIR" --format json --out "$REPORT_DIR/terraform-scan-$DATE.json"
    tfsec "$SCAN_DIR"
else
    echo "❌ tfsec not installed"
fi

# Secrets Detection
echo -e "\n🔐 Secrets Detection"
echo "-------------------"
if command -v gitleaks &> /dev/null; then
    gitleaks detect --source "$SCAN_DIR" \
             --report-format json \
             --report-path "$REPORT_DIR/secrets-scan-$DATE.json" || true
else
    echo "❌ Gitleaks not installed"
fi

echo "✅ Security scan completed!"
echo "📁 Reports saved in: $REPORT_DIR/"
```

### Step 2: Security Policy as Code
```rego
# security-policy.rego
package terraform.security

# Deny S3 buckets without encryption
deny[msg] {
    input.resource_type == "aws_s3_bucket"
    not input.config.server_side_encryption_configuration
    msg := "S3 bucket must have encryption enabled"
}

# Require security groups to have specific rules
deny[msg] {
    input.resource_type == "aws_security_group"
    rule := input.config.ingress[_]
    rule.from_port == 22
    rule.cidr_blocks[_] == "0.0.0.0/0"
    msg := "SSH access should not be open to the world"
}

# Ensure IAM policies follow least privilege
deny[msg] {
    input.resource_type == "aws_iam_policy"
    statement := input.config.policy.Statement[_]
    statement.Effect == "Allow"
    statement.Action[_] == "*"
    statement.Resource == "*"
    msg := "IAM policy should not allow all actions on all resources"
}
```

### Step 3: Docker Security Best Practices
```dockerfile
# Dockerfile.secure
FROM alpine:3.18

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Copy application files
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Run application
CMD ["./app"]
```

## Commands to Run
```bash
# Make script executable
chmod +x security-scan.sh

# Run security scan
./security-scan.sh

# Install security tools
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
go install github.com/aquasecurity/tfsec/cmd/tfsec@latest

# Scan Terraform files
tfsec ../beginner-week1/

# Build secure Docker image
docker build -f Dockerfile.secure -t secure-app .
```

## Validation
- [ ] Security scanning script runs successfully
- [ ] Trivy scans container images
- [ ] tfsec scans Terraform code
- [ ] Security policies defined
- [ ] Reports generated in security-reports/
