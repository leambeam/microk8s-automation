# Default variables are referenced from default-vars.tfvars file

variable "ubuntu_security_group_ports" {
  type        = list(number)
  description = "List of ports to open in Ubuntu security group (SSH, HTTP, HTTPS)"
}

variable "rocky_security_group_ports" {
  type        = list(number)
  description = "List of ports to open in Rocky security group (SSH, HTTP, HTTPS)"
}

# See all flavors: https://docs.csc.fi/cloud/pouta/vm-flavors-and-billing/
variable "ubuntu_instance" {
  type        = string
  description = "Flavor type for Ubuntu"
  validation {
    condition     = contains(["standard.tiny", "standard.small", "standard.medium", "standard.large"], var.ubuntu_instance)
    error_message = "Valid values are standard.tiny, standard.small, standard.medium, or standard.large."
  }
  # VCPUs: 1 | RAM: 0.9 | Billing/h: 0.25 (standard.tiny)
  # VCPUs: 2 | RAM: 1.9 | Billing/h: 0.5  (standard.small)
  # VCPUs: 3 | RAM: 3.9 | Billing/h: 1    (standard.medium)
  # VCPUs: 4 | RAM: 7.8 | Billing/h: 2    (standard.large)
}

# See all flavors: https://docs.csc.fi/cloud/pouta/vm-flavors-and-billing/
variable "rocky_instance" {
  type        = string
  description = "Flavor type for Rocky"
  validation {
    condition     = contains(["standard.tiny", "standard.small", "standard.medium", "standard.large"], var.rocky_instance)
    error_message = "Valid values are standard.tiny, standard.small, standard.medium, or standard.large."
  }
  # VCPUs: 1 | RAM: 0.9 | Billing/h: 0.25 (standard.tiny)
  # VCPUs: 2 | RAM: 1.9 | Billing/h: 0.5  (standard.small)
  # VCPUs: 3 | RAM: 3.9 | Billing/h: 1    (standard.medium)
  # VCPUs: 4 | RAM: 7.8 | Billing/h: 2    (standard.large)
}

variable "ubuntu_image" {
  type        = string
  description = "Ubuntu image"
}

variable "rocky_image" {
  type        = string
  description = "Rocky image"
}

variable "private_network_id" {
  type        = string
  description = "ID of the private Neutron network for ports"
  sensitive   = true
}

variable "public_network_id" {
  type        = string
  description = "ID of the public Neutron network for floating IPs"
  sensitive   = true
}

variable "public_network_name" {
  type        = string
  description = "Name of the public network for floating IPs"
}