openstack stack create -t heat/main.yaml -e heat/default-vars.yaml vm-stack

# Wait for stack to allocate and assosiate floating ips
sleep 60


ubuntu=$(openstack stack output show vm-stack ubuntu_floating_ip -f value -c output_value)
rocky=$(openstack stack output show vm-stack rocky_floating_ip -f value -c output_value)

echo "Ubuntu floating ip: ${ubuntu}"
echo "Rocky floating ip: ${rocky}"


openstack stack show vm-stack -f yaml -c "stack_status"