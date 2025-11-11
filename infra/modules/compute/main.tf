data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  use_two_userdatas = length(trim(var.user_data_app1, " ")) > 0 && length(trim(var.user_data_app2, " ")) > 0
}

# Security group for the ALB (public HTTP)
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB security group"
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

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

# Security group for EC2 (only ALB -> instances on 80)
resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2-sg"
  description = "EC2 security group allowing HTTP from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-ec2-sg" })
}

# Application Load Balancer across the provided public subnets
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  vpc_id      = var.vpc_id
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
  }

  tags = merge(var.tags, { Name = "${var.name}-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Spread instances across subnets; alternate user data when provided
resource "aws_instance" "web" {
  count                       = var.instance_count
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  user_data = local.use_two_userdatas ? (count.index % 2 == 0 ? var.user_data_app1 : var.user_data_app2) : var.user_data

  tags = merge(var.tags, { Name = "${var.name}-web-${count.index + 1}" })
}

# Register instances with the ALB target group
resource "aws_lb_target_group_attachment" "this" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
