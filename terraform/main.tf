# Security Groups
resource "openstack_networking_secgroup_v2" "security_group_1" {
  name        = "security_group_1"
  description = "Security group for Ubuntu VM"
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_1" {
  count             = length(var.security_group_ports_1)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.security_group_ports_1[count.index]
  port_range_max    = var.security_group_ports_1[count.index]
  security_group_id = openstack_networking_secgroup_v2.security_group_1.id
  depends_on        = [openstack_networking_secgroup_v2.security_group_1]
}

resource "openstack_networking_secgroup_v2" "security_group_2" {
  name        = "security_group_2"
  description = "Security group for Rocky VM"
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_2" {
  count             = length(var.security_group_ports_2)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.security_group_ports_2[count.index]
  port_range_max    = var.security_group_ports_2[count.index]
  security_group_id = openstack_networking_secgroup_v2.security_group_2.id
  depends_on        = [openstack_networking_secgroup_v2.security_group_2]
}

# SSH Key pairs
resource "openstack_compute_keypair_v2" "ssh_key_1" {
  name       = "key-pair-1"
  public_key = file("../keys/key1.pub")
}

resource "openstack_compute_keypair_v2" "ssh_key_2" {
  name       = "key-pair-2"
  public_key = file("../keys/key2.pub")
}

# Private network ports
resource "openstack_networking_port_v2" "private_network_port_1" {
  network_id         = var.private_network_id
  security_group_ids = [openstack_networking_secgroup_v2.security_group_1.id]
}

resource "openstack_networking_port_v2" "private_network_port_2" {
  network_id         = var.private_network_id
  security_group_ids = [openstack_networking_secgroup_v2.security_group_2.id]
}

# Find the image IDs
data "openstack_images_image_v2" "vm_image_1" {
  name        = var.pouta_image_1
  most_recent = true
}

data "openstack_images_image_v2" "vm_image_2" {
  name        = var.pouta_image_2
  most_recent = true
}

# VM instances
resource "openstack_compute_instance_v2" "vm_1" {
  name              = "vm-1"
  flavor_name       = var.instance_type
  key_pair          = openstack_compute_keypair_v2.ssh_key_1.name
  availability_zone = "nova"
  
  block_device {
    uuid                  = data.openstack_images_image_v2.vm_image_1.id
    source_type           = "image"
    volume_size           = 80
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true # change to false if you want to preserve your volume
  }

  network {
    port = openstack_networking_port_v2.private_network_port_1.id
  }
}

resource "openstack_compute_instance_v2" "vm_2" {
  name              = "vm-2"
  flavor_name       = var.instance_type
  key_pair          = openstack_compute_keypair_v2.ssh_key_2.name
  availability_zone = "nova"

  block_device {
    uuid                  = data.openstack_images_image_v2.vm_image_2.id
    source_type           = "image"
    volume_size           = 80
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true # change to false if you want to preserve your volume
  }

  network {
    port = openstack_networking_port_v2.private_network_port_2.id
  }
}

# Floating IPs
resource "openstack_networking_floatingip_v2" "floating_ip_1" {
  pool       = var.public_network_name
  depends_on = [openstack_compute_instance_v2.vm_1]
}

resource "openstack_networking_floatingip_v2" "floating_ip_2" {
  pool       = var.public_network_name
  depends_on = [openstack_compute_instance_v2.vm_2]
}

# Floating IP associations
resource "openstack_networking_floatingip_associate_v2" "association_1" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip_1.address
  port_id     = openstack_networking_port_v2.private_network_port_1.id
  depends_on  = [openstack_compute_instance_v2.vm_1]
}

resource "openstack_networking_floatingip_associate_v2" "association_2" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip_2.address
  port_id     = openstack_networking_port_v2.private_network_port_2.id
  depends_on  = [openstack_compute_instance_v2.vm_2]
}
