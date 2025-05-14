variable "security_group_ports_1" {
  type        = list(number)
  description = "List of ports to open in security group 1 (SSH, HTTP, HTTPS)"
  default     = [22, 80, 443]
}

variable "security_group_ports_2" {
  type        = list(number)
  description = "List of ports to open in security group 2 (SSH, HTTP, HTTPS)"
  default     = [22, 80, 443]
}

variable "instance_type" {
  type        = string
  description = "Flavor type for VMs"
  default     = "standard.medium"
  validation {
    condition     = contains(["standard.tiny", "standard.small", "standard.medium", "standard.large"], var.instance_type)
    error_message = "Valid values are standard.tiny, standard.small, standard.medium, or standard.large."
  }
}

variable "pouta_image_1" {
  type    = string
  default = "Ubuntu-24.04"
}

variable "pouta_image_2" {
  type    = string
  default = "Rocky-9.5"
}

# Referenced from *.tfvars file
variable "private_network_id" {
  type        = string
  description = "ID of the private Neutron network"
  sensitive   = true
}

# Referenced from *.tfvars file
variable "public_network_id" {
  type        = string
  description = "ID of the public Neutron network for floating IPs"
  sensitive   = true
}

variable "public_network_name" {
  type        = string
  description = "Name of the public network for floating IPs"
  default     = "public"
}