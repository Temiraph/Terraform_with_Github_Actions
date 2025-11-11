output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "Public DNS name of the ALB"
}

output "instance_public_ips" {
  value       = [for i in aws_instance.web : i.public_ip]
  description = "Public IPs of the EC2 instances"
}

output "security_group_alb_id" {
  value = aws_security_group.alb.id
}

output "security_group_ec2_id" {
  value = aws_security_group.ec2.id
}