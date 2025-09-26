#############################################

# KMS Key for SSM Parameter Encryption:

#############################################

resource "aws_kms_key" "ssm_key" {
  description             = "KMS key for SSM parameter encryption in ${var.environment} environment"
  deletion_window_in_days = 7

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "ssm-kms-key")
      "TYPE" = "KMS"
    }
  )
}

resource "aws_kms_alias" "ssm_key_alias" {
  name          = "alias/${local.project_name}-${var.environment}-ssm"
  target_key_id = aws_kms_key.ssm_key.key_id
}

#############################################

#Creating Virtual Private Cloud:

#############################################
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.custom_vpc
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags.vpc
}

#############################################

# Creating Public subnet:

#############################################
#resource "aws_subnet" "public_subnet" {
#  count             = var.custom_vpc == "15.0.0.0/16" ? 2 : 0
#  vpc_id            = aws_vpc.custom_vpc.id
#  availability_zone = data.aws_availability_zones.azs.names[count.index]
#  cidr_block        = element(cidrsubnets(var.custom_vpc, 4, 4, 8), count.index)
#  map_public_ip_on_launch = element([true, true, false], count.index)
#  tags = {
#    "Name" = "${aws_subnet.subnet[count.index].map_public_ip_on_launch == true ? "Public" : "Private"}-Subnet-${count.index}"
#  }
#}

resource "aws_subnet" "subnet" {
  count                   = length(local.subnets)
  vpc_id                  = aws_vpc.custom_vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = element(local.subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  tags = merge(
    local.subnets[count.index].tags,
    local.common_tags
  )
}

#resource "aws_subnet" "public_subnet" {
#  for_each = local.subnets
#  vpc_id            = each.value.vpc_id
#  availability_zone = each.value.availability_zone
#  cidr_block        = each.value.cidr_block
#  map_public_ip_on_launch = each.value.map_public_ip_on_launch
#  tags = {
#    "Name" = each.key
#  }
#}


#resource "aws_subnet" "private_subnet" {
#  count             = var.custom_vpc == "15.0.0.0/16" ? 1 : 0
#  vpc_id            = aws_vpc.custom_vpc.id
#  availability_zone = data.aws_availability_zones.azs.names[3]
#  cidr_block        = element(local.subnet_cidrs, 3)
#  map_public_ip_on_launch = false
#  tags = {
#    "Name" = "Private-Subnet-${count.index}"
#  }
#}

#############################################

# Creating Internet Gateway:

#############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = local.tags.igw
}

#############################################

# Creating NAT Gateway for Private Subnets:

#############################################

resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "nat-eip")
      "TYPE" = "EIP"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet[0].id # Place NAT Gateway in first public subnet

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "nat-gateway")
      "TYPE" = "NAT Gateway"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

#############################################

# Creating Public Route Table:

#############################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = local.tags.route-table
}

#############################################

# Creating Private Route Table:

#############################################

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "private-route-table")
      "TYPE" = "route-table"
    }
  )
}

#############################################

# Creating Public Route:

#############################################

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#############################################

# Creating Private Route (NAT Gateway):

#############################################

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

#############################################

# Creating Public Route Table Associations:

#############################################

resource "aws_route_table_association" "public_rt_association" {
  count          = 2 # Only for the first 2 subnets (public subnets)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.subnet[count.index].id
}

#############################################

# Creating Private Route Table Associations:

#############################################

resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.subnet) - 2 # For remaining subnets (private subnets)
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.subnet[count.index + 2].id
}

#resource "aws_route_table_association" "public_rt_association" {
#  count          = length(aws_subnet.public_subnet)
#  route_table_id = aws_route_table.public_rt.id
##  subnet_id      = element(concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id), count.index)
#  subnet_id      = aws_subnet.public_subnet[*].id
#
#}
#resource "aws_route_table_association" "public_rt_association" {
#  for_each = aws_subnet.public_subnet
#  route_table_id = aws_route_table.public_rt.id
#  #  subnet_id      = element(concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id), count.index)
#  subnet_id      = each.value.id
#
#}