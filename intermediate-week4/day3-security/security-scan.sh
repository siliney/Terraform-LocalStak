#!/bin/bash

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

# Generate Summary Report
echo -e "\n📊 Generating Summary Report"
echo "----------------------------"
cat > "$REPORT_DIR/security-summary-$DATE.md" << EOL
# Security Scan Summary - $DATE

## Scan Results
- **Image Scan**: $([ -f "$REPORT_DIR/image-scan-$DATE.json" ] && echo "✅ Completed" || echo "❌ Failed")
- **Terraform Scan**: $([ -f "$REPORT_DIR/terraform-scan-$DATE.json" ] && echo "✅ Completed" || echo "❌ Failed")
- **Secrets Scan**: $([ -f "$REPORT_DIR/secrets-scan-$DATE.json" ] && echo "✅ Completed" || echo "❌ Failed")

## Recommendations
1. Review all HIGH and CRITICAL vulnerabilities
2. Update base images to latest versions
3. Implement security policies in CI/CD pipeline
4. Regular security scanning schedule

## Next Steps
- [ ] Fix critical vulnerabilities
- [ ] Update security policies
- [ ] Implement automated remediation
- [ ] Schedule regular scans
EOL

echo "✅ Security scan completed!"
echo "📁 Reports saved in: $REPORT_DIR/"
echo "📋 Summary: $REPORT_DIR/security-summary-$DATE.md"
