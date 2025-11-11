variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

provider "aws" {
  region = var.aws_region

  # Helpful default tags applied to all resources
  default_tags {
    tags = {
      Project     = "cicd-terraform"
      Environment = "dev"
      ManagedBy   = "Temi"
    }
  }
}
