resource "aws_ssm_parameter" "subnet_ids" {
  count  = length(aws_subnet.subnet)
  type   = "String"
  name   = "${local.parameter_base_path}${aws_subnet.subnet[count.index].tags.PARAM_NAME}"
  value  = aws_subnet.subnet[count.index].id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}${aws_subnet.subnet[count.index].tags.PARAM_NAME}"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "vpc_id" {
  type   = "String"
  name   = "${local.parameter_base_path}vpc-id"
  value  = aws_vpc.custom_vpc.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}vpc-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "route_table_public" {
  type   = "String"
  name   = "${local.parameter_base_path}public-rt-id"
  value  = aws_route_table.public_rt.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}public-rt-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "route_table_private" {
  type   = "String"
  name   = "${local.parameter_base_path}private-rt-id"
  value  = aws_route_table.private_rt.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}private-rt-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "igw" {
  type   = "String"
  name   = "${local.parameter_base_path}igw-id"
  value  = aws_internet_gateway.igw.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}igw-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "nat_gateway" {
  type   = "String"
  name   = "${local.parameter_base_path}nat-gateway-id"
  value  = aws_nat_gateway.nat_gw.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}nat-gateway-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

# Security Group SSM Parameters
resource "aws_ssm_parameter" "alb_sg" {
  type   = "String"
  name   = "${local.parameter_base_path}alb-security-group-id"
  value  = aws_security_group.alb_sg.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}alb-security-group-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "ec2_sg" {
  type   = "String"
  name   = "${local.parameter_base_path}ec2-security-group-id"
  value  = aws_security_group.ec2_sg.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}ec2-security-group-id"
      "TYPE" = "SSM Parameter"
    }
  )
}

resource "aws_ssm_parameter" "rds_sg" {
  type   = "String"
  name   = "${local.parameter_base_path}rds-security-group-id"
  value  = aws_security_group.rds_sg.id
  key_id = aws_kms_key.ssm_key.key_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.parameter_base_path}rds-security-group-id"
      "TYPE" = "SSM Parameter"
    }
  )
}