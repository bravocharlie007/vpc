# Gaming PC Security Configuration
# Addresses secure access for gaming PC without knowing client IPs in advance

#############################################
# VPN Gateway for Secure Gaming Access
#############################################

# Customer Gateway (configured with actual VPN endpoint)
resource "aws_customer_gateway" "gaming_vpn" {
  count      = var.enable_gaming_setup ? 1 : 0
  bgp_asn    = 65000
  ip_address = var.gaming_vpn_public_ip
  type       = "ipsec.1"
  
  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-vpn-cgw")
      "TYPE" = "Customer Gateway"
      "Purpose" = "Gaming PC Access"
    }
  )
}

# VPN Gateway for secure connections
resource "aws_vpn_gateway" "gaming_vgw" {
  count  = var.enable_gaming_setup ? 1 : 0
  vpc_id = aws_vpc.custom_vpc.id
  
  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-vgw")
      "TYPE" = "VPN Gateway"
      "Purpose" = "Gaming PC Access"
    }
  )
}

# VPN Connection
resource "aws_vpn_connection" "gaming_vpn" {
  count               = var.enable_gaming_setup ? 1 : 0
  customer_gateway_id = aws_customer_gateway.gaming_vpn[0].id
  type               = "ipsec.1"
  vpn_gateway_id     = aws_vpn_gateway.gaming_vgw[0].id
  static_routes_only = true
  
  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-vpn-connection")
      "TYPE" = "VPN Connection"
      "Purpose" = "Gaming PC Access"
    }
  )
}

#############################################
# Gaming-Specific Security Groups
#############################################

# Security group for gaming PC instances
resource "aws_security_group" "gaming_pc_sg" {
  count       = var.enable_gaming_setup ? 1 : 0
  name_prefix = "${local.project_name}-${var.environment}-gaming-pc-"
  vpc_id      = aws_vpc.custom_vpc.id
  description = "Security group for gaming PC instances"

  # RDP access from VPN network only
  ingress {
    description = "RDP from VPN"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # VPN network range
  }

  # Gaming ports (Steam, Epic Games, etc.)
  ingress {
    description = "Steam TCP"
    from_port   = 27015
    to_port     = 27030
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Steam UDP"
    from_port   = 27015
    to_port     = 27030
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Epic Games Store
  ingress {
    description = "Epic Games HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom gaming ports (configurable via variables)
  dynamic "ingress" {
    for_each = var.gaming_custom_ports.tcp_ports
    content {
      description = "Custom Gaming Port TCP ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.gaming_custom_ports.udp_ports
    content {
      description = "Custom Gaming Port UDP ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-pc-sg")
      "TYPE" = "Security Group"
      "Purpose" = "Gaming PC"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Temporary access security group (for brothers with unknown IPs)
resource "aws_security_group" "gaming_temp_access" {
  count       = var.enable_gaming_setup ? 1 : 0
  name_prefix = "${local.project_name}-${var.environment}-gaming-temp-"
  vpc_id      = aws_vpc.custom_vpc.id
  description = "Temporary access for gaming sessions - manually managed"

  # This will be empty by default - rules added manually when needed
  # Example: aws ec2 authorize-security-group-ingress --group-id sg-xxx --protocol tcp --port 3389 --cidr 1.2.3.4/32

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-temp-access")
      "TYPE" = "Security Group"
      "Purpose" = "Temporary Gaming Access"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

#############################################
# Gaming PC Subnet (Public for gaming traffic)
#############################################

resource "aws_subnet" "gaming_subnet" {
  count                   = var.enable_gaming_setup ? 1 : 0
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "15.0.100.0/24"  # Dedicated gaming subnet
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-subnet")
      "TYPE" = "Subnet"
      "SUBNET_TYPE" = "Gaming"
      "PARAM_NAME" = "gaming-subnet"
    }
  )
}

# Route table association for gaming subnet
resource "aws_route_table_association" "gaming_subnet_association" {
  count          = var.enable_gaming_setup ? 1 : 0
  subnet_id      = aws_subnet.gaming_subnet[0].id
  route_table_id = aws_route_table.public_rt.id
}

#############################################
# Gaming PC Instance Profile for Systems Manager
#############################################

# IAM role for gaming PC (Session Manager access)
resource "aws_iam_role" "gaming_pc_role" {
  count = var.enable_gaming_setup ? 1 : 0
  name  = "${local.project_name}-${var.environment}-gaming-pc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-pc-role")
      "TYPE" = "IAM Role"
      "Purpose" = "Gaming PC"
    }
  )
}

# Attach Systems Manager policy for secure access
resource "aws_iam_role_policy_attachment" "gaming_pc_ssm" {
  count      = var.enable_gaming_setup ? 1 : 0
  role       = aws_iam_role.gaming_pc_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for gaming PC
resource "aws_iam_instance_profile" "gaming_pc_profile" {
  count = var.enable_gaming_setup ? 1 : 0
  name  = "${local.project_name}-${var.environment}-gaming-pc-profile"
  role  = aws_iam_role.gaming_pc_role[0].name

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "gaming-pc-profile")
      "TYPE" = "Instance Profile"
    }
  )
}