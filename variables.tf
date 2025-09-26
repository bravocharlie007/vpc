variable "custom_vpc" {
  description = "VPC for testing environment"
  type        = string
  default     = "15.0.0.0/16"
}

variable "instance_tenancy" {
  description = "it defines the tenancy of VPC. Whether it's default or dedicated"
  type        = string
  default     = "default"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "parameter_base_path_prefix" {
  type      = string
  default   = "/application/ec2deployer/"
  sensitive = true
}

variable "parameter_base_path_suffix" {
  type    = string
  default = "/resource/terraform/"
}

# Gaming PC Configuration
variable "enable_gaming_setup" {
  description = "Enable gaming PC specific security and networking setup"
  type        = bool
  default     = true
}

variable "gaming_vpn_public_ip" {
  description = "Public IP address for VPN endpoint (your home router's public IP)"
  type        = string
  default     = "1.1.1.1"  # Placeholder - replace with actual IP
  sensitive   = true
}

variable "gaming_custom_ports" {
  description = "Custom gaming ports to open (TCP and UDP)"
  type = object({
    tcp_ports = list(number)
    udp_ports = list(number)
  })
  default = {
    tcp_ports = [7777, 7778, 7779]
    udp_ports = [7777, 7778, 7779] 
  }
}