terraform {
  required_version = ">= 1.0"
}

output "greeting" {
  value = "Hello, Terraform World!"
}

output "timestamp" {
  value = timestamp()
}
