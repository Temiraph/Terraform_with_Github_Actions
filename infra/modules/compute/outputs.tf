output "instance_public_ips" {
  value       = [for i in aws_instance.web : i.public_ip]
  description = "Public IPs of the EC2 instances"
}

output "security_group_ec2_id" {
  value       = aws_security_group.ec2_public.id
  description = "EC2 security group ID (public HTTP)"
}
