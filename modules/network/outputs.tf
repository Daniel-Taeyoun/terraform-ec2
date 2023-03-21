output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this.id, "")
}

output "public_subnets" {
  description = "List of IDs of Public subnets"
  value       = aws_subnet.sbn-tf-daniel-public[*].id
}

output "private_subnets" {
  description = "List of IDs of Private subnets"
  value       = aws_subnet.sbn-tf-daniel-private[*].id
}