# EC2 Deployer VPC Infrastructure

This Terraform project creates a foundational AWS Virtual Private Cloud (VPC) infrastructure for the "EC2 Deployer" project, designed to support multi-environment deployments with proper network segmentation and parameter store integration.

## Project Overview

The project provisions a complete VPC setup with public and private subnets, internet connectivity, and integrates with AWS Systems Manager Parameter Store for cross-workspace dependency management. It's designed as part of a larger "EC2 Deployer" ecosystem that appears to manage EC2 instances across multiple environments.

## Architecture

### Infrastructure Components

The Terraform configuration creates the following AWS resources:

- **VPC**: Custom Virtual Private Cloud with configurable CIDR block (default: `15.0.0.0/16`)
- **Subnets**: 
  - 2 Public subnets (PublicSubnet01, PublicSubnet02)
  - 1 Private subnet (PrivateSubnet01)
  - Distributed across multiple availability zones in `us-east-1`
- **Internet Gateway**: Provides internet access for public subnets
- **Route Table**: Single public route table with default route to IGW
- **Route Table Associations**: Links all subnets to the public route table
- **SSM Parameters**: Stores resource IDs for cross-workspace consumption

### Network Design

```
VPC (15.0.0.0/16)
├── PublicSubnet01  (15.255.0.0/24)  - AZ: us-east-1a
├── PublicSubnet02  (15.240.0.0/20)  - AZ: us-east-1b  
└── PrivateSubnet01 (15.224.0.0/20)  - AZ: us-east-1c
    │
    └── Internet Gateway
        └── 0.0.0.0/0 → IGW
```

**Note**: Currently all subnets (including the "private" one) are associated with the public route table, making them effectively public subnets.

## Workspace Dependencies

### Terraform Cloud Integration

The project is configured to use Terraform Cloud with:
- **Organization**: `EC2-DEPLOYER-DEV`
- **Workspace**: `vpc`

### Cross-Workspace Communication

The infrastructure stores critical resource identifiers in AWS Systems Manager Parameter Store under the path:
```
/application/ec2deployer/{environment}/resource/terraform/
```

**Exported Parameters:**
- `vpc-id`: VPC identifier
- `public-subnet-01`: First public subnet ID
- `public-subnet-02`: Second public subnet ID  
- `private-subnet-01`: Private subnet ID
- `rt-id`: Route table ID
- `igw-id`: Internet Gateway ID

These parameters enable other Terraform workspaces (likely EC2 deployment modules) to reference this network infrastructure.

## Configuration

### Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `custom_vpc` | VPC CIDR block | `15.0.0.0/16` | string |
| `instance_tenancy` | VPC tenancy (default/dedicated) | `default` | string |
| `environment` | Deployment environment | `dev` | string |
| `parameter_base_path_prefix` | SSM parameter path prefix | `/application/ec2deployer/` | string (sensitive) |
| `parameter_base_path_suffix` | SSM parameter path suffix | `/resource/terraform/` | string |

### Environment Support

The project supports multiple environments through the `environment` variable, which affects:
- Resource naming conventions
- SSM parameter paths
- Resource tagging

## Outputs

The module exposes the following outputs for consumption by other modules:

- `vpc_id`: The VPC identifier
- `subnet_id_list`: List of all subnet IDs
- `subnet_id_map`: Map of subnet names to IDs
- `igw_id`: Internet Gateway ID
- `rt_id`: Route Table ID
- `root_deployment_id`: Unique deployment identifier

## Usage

### Prerequisites

1. AWS credentials configured
2. Terraform Cloud access to `EC2-DEPLOYER-DEV` organization
3. Appropriate AWS permissions for VPC, subnet, and SSM operations

### Deployment

```bash
terraform init
terraform plan
terraform apply
```

### Accessing Outputs

Other workspaces can reference this infrastructure through:

1. **Terraform Remote State** (if using same Terraform Cloud org)
2. **SSM Parameter Store** (recommended for cross-account access)

Example parameter retrieval:
```hcl
data "aws_ssm_parameter" "vpc_id" {
  name = "/application/ec2deployer/dev/resource/terraform/vpc-id"
}
```

## Security Considerations & Concerns

⚠️ **SECURITY CONCERNS IDENTIFIED:**

### 1. Network Architecture Issues
- **All subnets are effectively public**: The "private" subnet is associated with the public route table, giving it internet access
- **No NAT Gateway**: Private subnets should use NAT Gateway for outbound internet access, not direct IGW routing
- **Missing network ACLs**: No custom Network ACLs for additional security layers

### 2. Hardcoded Values
- **Fixed CIDR blocks**: Hardcoded subnet calculations in `locals.tf` (line 28) may cause conflicts
- **Region dependency**: Hardcoded to `us-east-1` without flexibility

### 3. Provider Version Constraints
- **Outdated AWS provider**: Using AWS provider version `4.0.0` (released in 2022), missing security updates and features
- **Version pinning**: While good for consistency, the version is significantly outdated

### 4. Parameter Store Security
- **Sensitive parameter exposure**: The `parameter_base_path_prefix` is marked sensitive but may contain predictable patterns
- **Cross-account access**: Parameters stored without encryption specification

### 5. Terraform State Management
- **Commented credentials**: AWS access keys are commented out but present in code (lines 17-18 in providers.tf)

### Recommendations

1. **Fix network architecture**: Create proper private subnets with NAT Gateway
2. **Update provider versions**: Upgrade to latest AWS provider for security patches
3. **Implement least privilege**: Add proper IAM roles and policies
4. **Enable encryption**: Use KMS encryption for SSM parameters
5. **Remove sensitive comments**: Clean up commented credential references
6. **Add network ACLs**: Implement additional network security layers

## Tags and Naming Convention

Resources are tagged with a comprehensive tagging strategy:
- `PROJECT_NAME`: ec2deployer
- `PROJECT_COMPONENT`: network-infrastructure  
- `ENVIRONMENT`: Environment (uppercased)
- `ROOT_DEPLOYMENT_ID`: Random 6-byte hex identifier
- `TYPE`: Resource type identifier

## Development History

Based on git history, this project:
- Was created over 2 years ago
- Has undergone iterative development with commented-out code indicating evolution
- Added root deployment ID tracking for better resource management
- Shows signs of transitioning from count-based to for_each patterns (commented code)

---

*Last Updated: Generated automatically from Terraform configuration analysis*