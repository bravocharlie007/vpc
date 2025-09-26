#############################################
# Security Groups - Basic Templates
# Note: These are basic security groups for common use cases
# The compute workspace should create more specific security groups
#############################################

# Default security group for VPC (restrictive)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.custom_vpc.id

  # No ingress rules - completely restrictive by default

  # Allow all outbound traffic (can be restricted further)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "default-sg")
      "TYPE" = "Security Group"
    }
  )
}

# Security group for ALB/NLB (public facing)
resource "aws_security_group" "alb_sg" {
  name_prefix = "${local.project_name}-${var.environment}-alb-"
  vpc_id      = aws_vpc.custom_vpc.id
  description = "Security group for Application Load Balancer"

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
      "Name" = replace(local.localized_project_name, local.replace_string, "alb-sg")
      "TYPE" = "Security Group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for EC2 instances (private)
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${local.project_name}-${var.environment}-ec2-"
  vpc_id      = aws_vpc.custom_vpc.id
  description = "Security group for EC2 instances"

  # SSH from bastion host (update CIDR as needed)
  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.custom_vpc] # Only from VPC
  }

  # HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # HTTPS from ALB
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
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
      "Name" = replace(local.localized_project_name, local.replace_string, "ec2-sg")
      "TYPE" = "Security Group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for RDS (database)
resource "aws_security_group" "rds_sg" {
  name_prefix = "${local.project_name}-${var.environment}-rds-"
  vpc_id      = aws_vpc.custom_vpc.id
  description = "Security group for RDS database"

  # MySQL/Aurora from EC2
  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # PostgreSQL from EC2
  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # No outbound rules needed for RDS typically

  tags = merge(
    local.common_tags,
    {
      "Name" = replace(local.localized_project_name, local.replace_string, "rds-sg")
      "TYPE" = "Security Group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}