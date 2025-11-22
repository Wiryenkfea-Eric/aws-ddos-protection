output "vpc_id" {
  description = "VPC identifier"
  value       = data.aws_vpc.default.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = data.aws_subnets.default.ids
}
