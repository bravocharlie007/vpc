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
  #  value = aws_subnet.private_subnet.tags.Name
  value = {
    for subnet in aws_subnet.subnet : element(split("-", subnet.tags.Name), 1) => subnet.id
  }
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "rt_id" {
  value = aws_route_table.public_rt.id
}

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}