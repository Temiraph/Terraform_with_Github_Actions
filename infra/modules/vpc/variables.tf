variable "name" {
  description = "Name for VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets (e.g., [\"10.0.1.0/24\", \"10.0.2.0/24\"])"
  type        = list(string)
}

variable "aws_region" {
  description = "Region to place subnets for AZs"
  type        = string
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}