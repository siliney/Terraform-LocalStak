# 🛠️ Prerequisites Installation Guide

Before starting your Terraform + LocalStack learning journey, you need to install the required tools. Follow the instructions for your operating system.

## 📋 Required Tools

- **Docker Desktop** - For running LocalStack
- **Git** - For version control
- **Terraform** - Infrastructure as Code tool
- **AWS CLI** - For testing LocalStack resources
- **Text Editor** - VS Code recommended

---

## 🐳 Docker Desktop Installation

### Windows
1. Download [Docker Desktop for Windows](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe)
2. Run the installer
3. Enable WSL 2 integration if using WSL
4. Restart your computer
5. Verify: `docker --version`

### macOS
1. Download [Docker Desktop for Mac](https://desktop.docker.com/mac/main/amd64/Docker.dmg)
2. Drag Docker to Applications folder
3. Launch Docker Desktop
4. Verify: `docker --version`

### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

---

## 🔧 Terraform Installation

### Windows (using Chocolatey)
```powershell
# Install Chocolatey first if not installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Terraform
choco install terraform
```

### Windows (Manual)
1. Download from [Terraform Downloads](https://developer.hashicorp.com/terraform/downloads)
2. Extract to `C:\terraform`
3. Add `C:\terraform` to PATH
4. Verify: `terraform version`

### macOS (using Homebrew)
```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux (Ubuntu/Debian)
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update && sudo apt install terraform
```

**Verify Installation:**
```bash
terraform version
# Expected output: Terraform v1.6.x
```

---

## 🌐 AWS CLI Installation

### Windows
```powershell
# Download and run MSI installer
# https://awscli.amazonaws.com/AWSCLIV2.msi
```

### macOS
```bash
# Using Homebrew
brew install awscli

# Or download installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### Linux
```bash
# Download and install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Verify Installation:**
```bash
aws --version
# Expected output: aws-cli/2.x.x
```

---

## 📝 Git Installation

### Windows
1. Download [Git for Windows](https://git-scm.com/download/win)
2. Run installer with default settings
3. Verify: `git --version`

### macOS
```bash
# Using Homebrew
brew install git

# Or use Xcode Command Line Tools
xcode-select --install
```

### Linux
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git

# CentOS/RHEL
sudo yum install git
```

**Configure Git:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 💻 VS Code Installation (Recommended)

### All Platforms
1. Download from [VS Code website](https://code.visualstudio.com/)
2. Install with default settings

### Recommended Extensions
```bash
# Install via command line
code --install-extension HashiCorp.terraform
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode.vscode-json
```

**Or install via VS Code:**
- HashiCorp Terraform
- Remote - Containers
- JSON

---

## ✅ Verification Checklist

Run these commands to verify all tools are installed:

```bash
# Docker
docker --version
docker compose version

# Terraform
terraform version

# AWS CLI
aws --version

# Git
git --version

# Optional: VS Code
code --version
```

**Expected Output:**
```
Docker version 24.x.x
Docker Compose version v2.x.x
Terraform v1.6.x
aws-cli/2.x.x Python/3.x.x
git version 2.x.x
1.x.x (VS Code version)
```

---

## 🚀 Quick Start Test

Once everything is installed, test your setup:

```bash
# Clone the learning repository
git clone https://github.com/siliney/Terraform-LocalStak.git
cd Terraform-LocalStak

# Start LocalStack
docker compose up -d

# Test LocalStack
curl http://localhost:4566/_localstack/health

# Test Terraform
cd beginner-week1/day1-hello
terraform init
terraform plan
```

If all commands run without errors, you're ready to start learning! 🎉

---

## 🆘 Troubleshooting

### Docker Issues
- **Windows**: Enable WSL 2 integration in Docker Desktop settings
- **Linux**: Add user to docker group: `sudo usermod -aG docker $USER`
- **Permission denied**: Restart terminal or log out/in

### Terraform Issues
- **Command not found**: Check PATH environment variable
- **Provider issues**: Run `terraform init` in project directory

### LocalStack Issues
- **Port 4566 in use**: Stop other services or change port in docker-compose.yml
- **Container won't start**: Check Docker Desktop is running

### Need Help?
- Check the [GitHub Issues](https://github.com/siliney/Terraform-LocalStak/issues)
- Review the troubleshooting section in LEARNING_GUIDE.md
- Join the community discussions

---

**Next Step:** Once all prerequisites are installed, start with [Week 1: Terraform Basics](beginner-week1/README.md) 🚀
