data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  # If both app1 and app2 user-data are set, alternate them across instances
  use_two_userdatas = length(trim(var.user_data_app1, " ")) > 0 && length(trim(var.user_data_app2, " ")) > 0
}

# Security group for EC2 (public HTTP access for learning)
resource "aws_security_group" "ec2_public" {
  name        = "${var.name}-ec2-public-sg"
  description = "EC2 SG allowing HTTP from the internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from allowed CIDRs"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs_http
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-ec2-public-sg" })
}

# EC2 Instances across the provided subnets
resource "aws_instance" "web" {
  count                       = var.instance_count
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids      = [aws_security_group.ec2_public.id]
  associate_public_ip_address = true

  user_data = local.use_two_userdatas ? (count.index % 2 == 0 ? var.user_data_app1 : var.user_data_app2) : var.user_data

  tags = merge(var.tags, { Name = "${var.name}-web-${count.index + 1}" })
}
