

resource aws_ssm_parameter "subnet_ids" {
  count = length(aws_subnet.public_subnet)
  type = "String"
  name = "${local.parameter_base_path}${aws_subnet.public_subnet[count.index].tags.PARAM_NAME}"
  value = aws_subnet.public_subnet[count.index].id
}