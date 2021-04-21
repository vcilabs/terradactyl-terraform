
terraform {
  required_version = ">= 0.15"
  required_providers {
    null = {
      version = "~> 3.0"
      source  = "hashicorp/null"
    }
  }
}
