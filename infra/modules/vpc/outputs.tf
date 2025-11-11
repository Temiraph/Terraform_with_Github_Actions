output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "public_subnet_cidrs" {
  value = [for s in aws_subnet.public : s.cidr_block]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}