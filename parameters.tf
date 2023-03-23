resource aws_ssm_parameter "subnet_ids" {
  count = length(aws_subnet.subnet)
  type = "String"
  name = "${local.parameter_base_path}${aws_subnet.subnet[count.index].tags.PARAM_NAME}"
  value = aws_subnet.subnet[count.index].id
}

resource aws_ssm_parameter "vpc_id" {
  type = "String"
  name = "${local.parameter_base_path}vpc-id"
  value = aws_vpc.custom_vpc.id
}

resource aws_ssm_parameter "route_table" {
  type = "String"
  name = "${local.parameter_base_path}rt-id"
  value = aws_route_table.public_rt.id
}

resource aws_ssm_parameter "igw" {
  type = "String"
  name = "${local.parameter_base_path}igw-id"
  value = aws_internet_gateway.igw.id
}