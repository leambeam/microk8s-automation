output "floating_ip_1" {
  description = "Floating IP address 1"
  value       = openstack_networking_floatingip_v2.floating_ip_1.address
}

output "floating_ip_2" {
  description = "Floating IP address 2"
  value       = openstack_networking_floatingip_v2.floating_ip_2.address
}