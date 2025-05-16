output "ubuntu_floating_ip" {
  description = "Ubuntu floating IP address"
  value       = openstack_networking_floatingip_v2.ubuntu_floating_ip.address
}

output "rocky_floating_ip" {
  description = "Rocky floating IP address"
  value       = openstack_networking_floatingip_v2.rocky_floating_ip.address
}