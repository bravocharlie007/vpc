resource "random_id" "root_deployment_id" {
  byte_length = 6
}

# Have 3 accounts
# One deployer account, one dev account, one dev account
# have terraform code to do: if env=prod select prod environment
locals {
#  subnets                = ["PublicSubnet01", "PublicSubnet02"]
  project_name           = "ec2deployer"
  replace_string         = "REPLACEME"
  localized_project_name = "${local.project_name}-${local.replace_string}-${local.upper_env}"
  project_component      = "network-infrastructure"
  upper_env              = upper(var.environment)
  base_vpc_ip            = "10.0.0.0"
  base_private_subnet_ip = "10.0.1.0"
  vpc_mask               = 16
  subnet_mask            = 27
  vpc_cidr               = "${local.base_vpc_ip}/${local.vpc_mask}"
  private_subnet_cidr    = "${local.base_private_subnet_ip}/${local.subnet_mask}"
  public_subnet_cidr     = "${local.base_vpc_ip}/${local.subnet_mask}"
  timestamp              = timestamp()
  vpc_type               = "vpc"
  subnet_type            = "subnet"
  igw_type               = "igw"
  nacl_type              = "nacl"
  route_table_type       = "route-table"
  subnet_cidrs = cidrsubnets("15.0.0.0/16", 8,4,4)
  parameter_base_path = "${var.parameter_base_path_prefix}${var.environment}${var.parameter_base_path_suffix}"


  common_tags            = tomap({
    "PROJECT_NAME"      = local.project_name,
    "PROJECT_COMPONENT" = local.project_component,
    "ENVIRONMENT"       = local.upper_env,
    "ROOT_DEPLOYMENT_ID"     = random_id.root_deployment_id.hex
    "MODULE_DEPLOYMENT_ID" = random_id.root_deployment_id.hex
    #    "TIMESTAMP"         = local.timestamp
  })
  to_tag = ["vpc", "igw", "route-table"]

  tags = {
    for type in local.to_tag : type => merge(
      tomap(
        {
          "Name" = replace(local.localized_project_name, local.replace_string, type),
          "NAME" = replace(local.localized_project_name, local.replace_string, type),
          "TYPE" = type
        }
      ),
      local.common_tags
    )
  }


  subnets = [
    {
      map_public_ip_on_launch = true
      tags                    = {
        "Name"        = replace(local.localized_project_name, local.replace_string, "PublicSubnet01"),
        "NAME"        = replace(local.localized_project_name, local.replace_string, "PublicSubnet01"),
        "TYPE"        = "Subnet",
        "PARAM_NAME"= "public-subnet-01"
        "SUBNET_TYPE" = "Public"
      }
    },
    {
      map_public_ip_on_launch = true
      tags                    = {
        "Name"        = replace(local.localized_project_name, local.replace_string, "PublicSubnet02"),
        "NAME"        = replace(local.localized_project_name, local.replace_string, "PublicSubnet02"),
        "PARAM_NAME"= "public-subnet-02"
        "TYPE"        = "Subnet",
        "SUBNET_TYPE" = "Public"
      }
    },
    {
      map_public_ip_on_launch = false
      tags                    = {
        "Name"        = replace(local.localized_project_name, local.replace_string, "PrivateSubnet02"),
        "NAME"        = replace(local.localized_project_name, local.replace_string, "PrivateSubnet02"),
        "PARAM_NAME"= "private-subnet-01"
        "TYPE"        = "Subnet",
        "SUBNET_TYPE" = "Private"
      }
    }
  ]
#  subnet_tags = merge(
#    tomap({
#      "Name" = replace(local.localized_project_name, local.replace_string, "${local.subnet_sub_type}-${local.subnet_type}"),
#      "NAME"        = replace(local.localized_project_name, local.replace_string, "${local.subnet_sub_type}-${local.subnet_type}"),
#      "TYPE"        = local.subnet_type,
#      "SUBNET_TYPE" = local.subnet_sub_type
#    }),
#    local.common_tags
#    )

#  public_subnet_tags = merge(
#    tomap({
#      "Name" = replace(local.localized_project_name, local.replace_string, "${local.subnet_sub_type}-${local.subnet_type}"),
#      "NAME"        = replace(local.localized_project_name, local.replace_string, "${local.subnet_sub_type}-${local.subnet_type}"),
#      "TYPE"        = local.subnet_type,
#      "SUBNET_TYPE" = local.subnet_sub_type
#    }),
#    local.common_tags
#  )
#  private_subnet_tags = merge(
#    tomap({
#      "Name" = replace(local.localized_project_name, local.replace_string, "${local.private_subnet_type}-${local.subnet_type}"),
#      "NAME"        = replace(local.localized_project_name, local.replace_string, "${local.private_subnet_type}-${local.subnet_type}"),
#      "TYPE"        = local.subnet_type,
#      "SUBNET_TYPE" = local.private_subnet_type
#    }),
#    local.common_tags
#  )

  vpc_tags = merge(
    tomap({
      "Name" = replace(local.localized_project_name, local.replace_string, local.vpc_type),
      "NAME" = replace(local.localized_project_name, local.replace_string, local.vpc_type),
      "TYPE" = local.vpc_type
    }),
    local.common_tags
  )

  igw_tags = merge(
    tomap({
      "Name" = replace(local.localized_project_name, local.replace_string, local.igw_type),
      "NAME" = replace(local.localized_project_name, local.replace_string, local.igw_type),
      "TYPE" = local.igw_type
    }),
    local.common_tags
  )
}
