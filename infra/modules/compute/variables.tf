variable "name" {
  description = "Name for compute resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where EC2 instances and ALB will live (public subnets here)"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnets for high availability."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ingress_cidrs_http" {
  description = "CIDR blocks allowed to reach the ALB over HTTP (port 80)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "user_data" {
  description = "User data script to bootstrap instances (base64 not required)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}
# Optional: when both are set, instances will alternate App1/App2 user data.
variable "user_data_app1" {
  description = "User data for App 1 (optional)"
  type        = string
  default     = ""
}

variable "user_data_app2" {
  description = "User data for App 2 (optional)"
  type        = string
  default     = ""
}
