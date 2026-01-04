terraform {
  required_version = ">= 1.0"
}

output "greeting" {
  value = "Hello, Terraform World!"
}

output "current_time" {
  value = timestamp()
}

output "random_number" {
  value = random_integer.example.result
}

resource "random_integer" "example" {
  min = 1
  max = 100
}
