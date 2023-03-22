#############################################

#Creating Virtual Private Cloud:

#############################################
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.custom_vpc
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
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

resource "aws_subnet" "public_subnet" {
  count             = var.custom_vpc == "15.0.0.0/16" ? 2 : 0
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = element(local.subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public-Subnet-${count.index}"
  }
}


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

  tags = {
    "Name" = "Internet-Gateway"
  }
}

#############################################

# Creating Public Route Table:

#############################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    "Name" = "Public-RouteTable"
  }
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

# Creating Public Route Table Association:

#############################################

resource "aws_route_table_association" "public_rt_association" {
  count          = var.custom_vpc == "15.0.0.0/16" ? 3 : 0
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id), count.index)
}