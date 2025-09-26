# Gaming PC Security Guide

## Overview

This guide addresses the specific security challenges of hosting a gaming PC in the cloud for multiple users (you and your brothers) without knowing their IP addresses in advance. The solution provides multiple secure access methods while maintaining strong security controls.

## Security Challenges & Solutions

### 🚨 Challenge: Unknown User IP Addresses
**Problem**: Your brothers' IP addresses may change frequently or be unknown in advance.

**Solutions Implemented**:

1. **VPN Gateway Access** (Most Secure)
2. **Temporary Security Group Rules** (Moderate Security)
3. **AWS Systems Manager Session Manager** (Administrative Access)

## Security Architecture

### 1. VPN Gateway Solution (Recommended)

**How it works:**
- Creates a site-to-site VPN between your home network and AWS
- Your brothers connect to your home network first, then access the gaming PC
- All traffic is encrypted and authenticated

**Setup Steps:**
1. Update `terraform.tfvars` with your home public IP:
   ```hcl
   gaming_vpn_public_ip = "YOUR_PUBLIC_IP"  # Get from whatismyipaddress.com
   ```

2. Configure your home router/firewall for VPN:
   - Enable IPsec VPN on your router
   - Use the connection details from AWS VPN Connection
   - Configure routing for gaming subnet (15.0.100.0/24)

**Security Benefits:**
- ✅ All traffic encrypted
- ✅ Centralized access control at your home network
- ✅ No need to know individual IP addresses
- ✅ Can control access times and users from home router

### 2. Temporary Security Group Rules (Alternative)

**How it works:**
- Pre-configured security group that starts empty
- Add temporary rules when brothers want to play
- Remove rules after gaming sessions

**Usage:**
```bash
# Add temporary RDP access for brother's IP
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 3389 \
  --cidr 1.2.3.4/32 \
  --region us-east-1

# Remove access after session
aws ec2 revoke-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 3389 \
  --cidr 1.2.3.4/32 \
  --region us-east-1
```

**Security Benefits:**
- ✅ Time-limited access
- ✅ IP-specific access control
- ✅ Audit trail of access changes
- ⚠️ Requires manual management

### 3. AWS Systems Manager Session Manager

**How it works:**
- Secure shell access without opening SSH/RDP ports
- Access through AWS console or CLI
- All sessions logged and auditable

**Usage:**
```bash
# Connect to gaming PC via Session Manager
aws ssm start-session --target i-1234567890abcdef0 --region us-east-1
```

**Security Benefits:**
- ✅ No inbound ports required
- ✅ All sessions logged in CloudTrail
- ✅ Multi-factor authentication supported
- ✅ Fine-grained IAM permissions

## Gaming PC Security Configuration

### Network Placement
- **Gaming Subnet**: Dedicated public subnet (15.0.100.0/24)
- **Security Groups**: Multi-layered security group protection
- **Route Tables**: Direct internet routing for gaming performance

### Security Groups Applied

1. **Gaming PC Security Group**:
   - RDP (3389): VPN network only (10.0.0.0/8)
   - Steam: TCP/UDP 27015-27030
   - Epic Games: HTTPS 443
   - Custom ports: Configurable via variables

2. **Temporary Access Security Group**:
   - Empty by default
   - Manually managed rules for known IPs
   - Time-limited access

### IAM Configuration
- **Instance Profile**: Attached to gaming PC
- **Session Manager**: Secure administrative access
- **CloudWatch**: Monitoring and logging

## Secure Access Workflow

### Option 1: VPN Access (Recommended)
1. Brothers connect to your home VPN/network
2. Access gaming PC via private IP through VPN tunnel
3. All traffic encrypted and logged
4. Access control managed at home router level

### Option 2: Temporary IP Access
1. Brother provides current public IP
2. Admin adds temporary rule to security group
3. Brother connects directly for gaming session
4. Admin removes rule after session ends

### Option 3: Session Manager (Admin Only)
1. Admin logs into AWS console
2. Uses Session Manager to connect to gaming PC
3. Sets up gaming session or troubleshoots issues
4. All actions logged in CloudTrail

## Security Best Practices

### 🔐 Access Control
- **Use VPN when possible** for encrypted access
- **Limit RDP access** to known IP ranges or VPN
- **Enable MFA** on AWS accounts
- **Regular access reviews** of security group rules

### 📊 Monitoring
- **VPC Flow Logs**: Monitor network traffic
- **CloudTrail**: Track all AWS API calls
- **CloudWatch**: Monitor instance performance
- **Session Manager logs**: Track administrative access

### 🔄 Operational Security
- **Regular updates**: Keep Windows gaming PC updated
- **Antivirus**: Install and maintain antivirus software
- **Backup**: Regular snapshots of gaming PC volumes
- **Access auditing**: Review who accessed when

## Cost Considerations

### VPN Gateway Costs
- **VPN Connection**: ~$36/month per connection
- **Data Transfer**: $0.05/GB for VPN traffic
- **Customer Gateway**: No additional cost

### Alternative: Client VPN
For lower cost, consider AWS Client VPN:
- **Endpoint**: ~$72/month (24/7)
- **Connection hours**: $0.05/hour per connection
- Better for occasional gaming sessions

## Quick Setup Commands

### 1. Deploy Gaming Infrastructure
```bash
# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars

# Update your public IP in terraform.tfvars
# Set enable_gaming_setup = true

# Deploy via Terraform Cloud or locally
terraform plan
terraform apply
```

### 2. Configure Home Router VPN
```bash
# Get VPN connection details
aws ec2 describe-vpn-connections --region us-east-1

# Configure your router with:
# - Pre-shared keys from AWS
# - AWS VPN gateway public IPs
# - Route 15.0.100.0/24 through VPN tunnel
```

### 3. Manage Temporary Access
```bash
# Get security group ID
terraform output gaming_temp_access_security_group_id

# Add temporary access (replace with actual values)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 3389 \
  --cidr BROTHER_IP/32
```

## Troubleshooting

### VPN Connection Issues
- Check home router VPN configuration
- Verify AWS VPN connection status
- Test connectivity with ping/traceroute

### Gaming Performance Issues
- Monitor CloudWatch metrics
- Check network latency
- Consider instance type upgrades

### Security Group Access Issues
- Verify IP addresses in rules
- Check rule directions (ingress/egress)
- Review CloudTrail for denied connections

## Security Recommendations Summary

1. **🏆 Best**: Use VPN Gateway for secure, encrypted access
2. **🥈 Good**: Temporary security group rules with IP restrictions
3. **🥉 Admin**: Session Manager for administrative access only

Choose the VPN solution for the best balance of security and usability for gaming with your brothers!