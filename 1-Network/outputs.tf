output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.aws_network.vpc_id
}

output "public_subnets" {
  description = "List of IDs of Public subnets"
  value       = module.aws_network.public_subnets
}

output "private_subnets" {
  description = "List of IDs of Private subnets"
  value       = module.aws_network.private_subnets
}