locals {
  name           = "mod-action-dev"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  user_data_app1 = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>This is App 1</h1><p>Hostname: $(hostname)</p>" > /var/www/html/index.html
  EOT

  user_data_app2 = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>This is App 2</h1><p>Hostname: $(hostname)</p>" > /var/www/html/index.html
  EOT
}

module "vpc" {
  source = "../../modules/vpc"

  name                = local.name
  vpc_cidr            = local.vpc_cidr
  public_subnet_cidrs = local.public_subnets
  aws_region          = var.aws_region

  tags = {
    Environment = "dev"
    Project     = "mod-action"
  }
}

module "compute" {
  source = "../../modules/compute"

  name        = local.name
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnet_ids

  enable_alb  = false

  # total instances (will alternate user data 1/2)
  instance_count     = 4
  instance_type      = "t3.micro"
  user_data_app1     = local.user_data_app1
  user_data_app2     = local.user_data_app2
  ingress_cidrs_http = ["0.0.0.0/0"]

  tags = {
    Environment = "dev"
    Project     = "mod-action"
  }
}
