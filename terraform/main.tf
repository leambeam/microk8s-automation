# cPouta VM deployment - Creates Ubuntu and Rocky Linux VMs with security groups, network ports, and floating IPs

# Security Groups
resource "openstack_networking_secgroup_v2" "ubuntu_security_group" {
  name        = "ubuntu_security_group"
  description = "Security group for Ubuntu"
}

resource "openstack_networking_secgroup_rule_v2" "ubuntu_security_group_rule" {
  count             = length(var.ubuntu_security_group_ports)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ubuntu_security_group_ports[count.index]
  port_range_max    = var.ubuntu_security_group_ports[count.index]
  security_group_id = openstack_networking_secgroup_v2.ubuntu_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.ubuntu_security_group]
}

resource "openstack_networking_secgroup_v2" "rocky_security_group" {
  name        = "rocky_security_group"
  description = "Security group for Rocky"
}

resource "openstack_networking_secgroup_rule_v2" "rocky_security_group_rule" {
  count             = length(var.rocky_security_group_ports)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.rocky_security_group_ports[count.index]
  port_range_max    = var.rocky_security_group_ports[count.index]
  security_group_id = openstack_networking_secgroup_v2.rocky_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.rocky_security_group]
}

# SSH Key pairs
resource "openstack_compute_keypair_v2" "ubuntu_ssh_key" {
  name       = "ubuntu_key_pair"
  public_key = file("../keys/ubuntu_key.pub")
}

resource "openstack_compute_keypair_v2" "rocky_ssh_key" {
  name       = "rocky_key_pair"
  public_key = file("../keys/rocky_key.pub")
}

# Network ports
resource "openstack_networking_port_v2" "ubuntu_private_network_port" {
  network_id         = var.private_network_id
  security_group_ids = [openstack_networking_secgroup_v2.ubuntu_security_group.id]
}

resource "openstack_networking_port_v2" "rocky_private_network_port" {
  network_id         = var.private_network_id
  security_group_ids = [openstack_networking_secgroup_v2.rocky_security_group.id]
}

# Find the image IDs
data "openstack_images_image_v2" "ubuntu_image" {
  name        = var.ubuntu_image
  most_recent = true
}

data "openstack_images_image_v2" "rocky_image" {
  name        = var.rocky_image
  most_recent = true
}

# VM instances
resource "openstack_compute_instance_v2" "ubuntu_vm" {
  name              = "ubuntu-vm"
  flavor_name       = var.ubuntu_instance
  key_pair          = openstack_compute_keypair_v2.ubuntu_ssh_key.name
  availability_zone = "nova"

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu_image.id
    source_type           = "image"
    volume_size           = 80
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true # change to false if you want to preserve your volume
  }

  network {
    port = openstack_networking_port_v2.ubuntu_private_network_port.id
  }
}

resource "openstack_compute_instance_v2" "rocky_vm" {
  name              = "rocky-vm"
  flavor_name       = var.rocky_instance
  key_pair          = openstack_compute_keypair_v2.rocky_ssh_key.name
  availability_zone = "nova"

  block_device {
    uuid                  = data.openstack_images_image_v2.rocky_image.id
    source_type           = "image"
    volume_size           = 80
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true # change to false if you want to preserve your volume
  }

  network {
    port = openstack_networking_port_v2.rocky_private_network_port.id
  }
}

# Floating IPs
resource "openstack_networking_floatingip_v2" "ubuntu_floating_ip" {
  pool       = var.public_network_name
  depends_on = [openstack_compute_instance_v2.ubuntu_vm]
}

resource "openstack_networking_floatingip_v2" "rocky_floating_ip" {
  pool       = var.public_network_name
  depends_on = [openstack_compute_instance_v2.rocky_vm]
}

# Floating IP associations
resource "openstack_networking_floatingip_associate_v2" "ubuntu_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.ubuntu_floating_ip.address
  port_id     = openstack_networking_port_v2.ubuntu_private_network_port.id
  depends_on  = [openstack_compute_instance_v2.ubuntu_vm]
}

resource "openstack_networking_floatingip_associate_v2" "rocky_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.rocky_floating_ip.address
  port_id     = openstack_networking_port_v2.rocky_private_network_port.id
  depends_on  = [openstack_compute_instance_v2.rocky_vm]
}