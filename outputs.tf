output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}


output "subnet_ids" {
  value = aws_subnet.private_subnet.tags.Name
}

output "azs" {
  value = data.aws_availability_zones.azs.names
}