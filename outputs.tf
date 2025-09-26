#output "public_subnet_ids" {
#  value = {
#    for k, v in aws_subnet.public_subnet: k => v.id
#  }
#}

#
#output "private_subnet_ids" {
#  value = aws_subnet.private_subnet[*].id
#}
#
#
output "subnet_id_list" {
  value = aws_subnet.subnet[*].id
}

output "subnet_id_map" {
  value = {
    for subnet in aws_subnet.subnet : element(split("-", subnet.tags.Name), 1) => subnet.id
  }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = slice(aws_subnet.subnet[*].id, 0, 2)
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = slice(aws_subnet.subnet[*].id, 2, length(aws_subnet.subnet))
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID for private subnets"
  value       = aws_nat_gateway.nat_gw.id
}

output "public_rt_id" {
  description = "Public route table ID"
  value       = aws_route_table.public_rt.id
}

output "private_rt_id" {
  description = "Private route table ID"
  value       = aws_route_table.private_rt.id
}

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "root_deployment_id" {
  value = random_id.root_deployment_id.hex
}

output "kms_key_id" {
  description = "KMS key ID used for SSM parameter encryption"
  value       = aws_kms_key.ssm_key.key_id
}

# Security Group Outputs
output "default_security_group_id" {
  description = "Default security group ID"
  value       = aws_default_security_group.default.id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}