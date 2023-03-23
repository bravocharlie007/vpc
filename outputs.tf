#output "public_subnet_ids" {
#  value = {
#    for k, v in aws_subnet.public_subnet: k => v.id
#  }
#}
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}
#
#output "private_subnet_ids" {
#  value = aws_subnet.private_subnet[*].id
#}
#
#
output "subnet_ids" {
#  value = aws_subnet.private_subnet.tags.Name
  value = {
    for subnet in aws_subnet.public_subnet: element(split("-", subnet.tags.Name), 1) => subnet.id
}
}

output "azs" {
  value = data.aws_availability_zones.azs.names
}
