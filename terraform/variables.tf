variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-github-ci-demo"
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "github-ci-demo"
    ManagedBy   = "Terraform"
    CreatedDate = "2024"
  }
}
