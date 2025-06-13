# Provider configuration for OpenStack
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Provider configuration
provider "openstack" {
  # Authentication details will be sourced from the Openstack *.rc file
}