
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    null = {
      version = "~> 3.0"
      source  = "hashicorp/null"
    }
  }
}
