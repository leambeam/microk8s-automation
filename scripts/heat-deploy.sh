openstack stack create -t heat/main.yaml -e heat/default-vars.yaml vm-stack

# Wait for stack to allocate and assosiate floating ips
sleep 60

openstack stack output show vm-stack ubuntu_floating_ip -f value -c output_value
openstack stack output show vm-stack rocky_floating_ip -f value -c output_value