#!/bin/bash

: '
Script for comparing Terraform and Heat deployments. 
Meant to be executed from the root of this project i.e. "bash scripts/compare-deployments.sh".
Mind variables if you updated them in Heat or Terraform files as they are somewhat hardcoded here.

Usage:
  bash scripts/compare-deployments.sh [deployment_type]

Examples:

  Running script:

  bash scripts/compare-deployments.sh terraform ==> output: terraform_deployment_date.txt
  bash scripts/compare-deployments.sh heat ==> output: heat_deployment_date.txt
  bash scripts/compare-deployments.sh manual ==> output: manual_deployment_date.txt
  bash scripts/compare-deployments.sh ==> output: unknown_deployment_date.txt

  Comparing deployments:

  diff compare-deployments/terraform_deployment_date.txt compare-deployments/heat_deployment_date.txt > compare-deployments/results
  diff3 compare-deployments/terraform_deployment_date.txt compare-deployments/heat_deployment_date.txt compare-deployments/manual_deployment_date.txt 

'

# Generic parameters
DEPLOYMENT_TYPE="${1:-"unknown"}"
TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
FILENAME="${DEPLOYMENT_TYPE}_deployment_${TIMESTAMP}.txt"

# Define resource base names according to new naming conventions
UBUNTU_VM="ubuntu-vm"
ROCKY_VM="rocky-vm"
UBUNTU_SEC_GROUP="ubuntu_security_group"
ROCKY_SEC_GROUP="rocky_security_group"
UBUNTU_KEY_PAIR="ubuntu_key_pair"
ROCKY_KEY_PAIR="rocky_key_pair"

# Create output directory if it doesn't exist
mkdir -p "compare-deployments"
FULL_PATH="compare-deployments/$FILENAME"

# Run commands and redirect output to the specified file
{
  echo "=== DEPLOYMENT INFO ===" 
  echo "Date: $(date)"
  echo "Deployment Type: ${DEPLOYMENT_TYPE}"
  echo "User: $(openstack token issue -f value -c user_id)"
  echo "Project: $(openstack token issue -f value -c project_id)"
  
  echo -e "\n=== SPECIFIC INSTANCES ==="
  echo -e "\n${UBUNTU_VM}:"
  openstack server show "${UBUNTU_VM}" 2>/dev/null || echo "${UBUNTU_VM} not found"
  echo -e "\n${ROCKY_VM}:"
  openstack server show "${ROCKY_VM}" 2>/dev/null || echo "${ROCKY_VM} not found"
  
  echo -e "\n=== ATTACHED VOLUMES ==="
  openstack volume list --status in-use 2>/dev/null || echo "None of the volumes are in use"
  
  echo -e "\n=== SPECIFIC SECURITY GROUPS ==="
  echo -e "\n${UBUNTU_SEC_GROUP}:"
  openstack security group show "${UBUNTU_SEC_GROUP}" 2>/dev/null || echo "${UBUNTU_SEC_GROUP} not found"
  echo -e "\n${ROCKY_SEC_GROUP}:"
  openstack security group show "${ROCKY_SEC_GROUP}" 2>/dev/null || echo "${ROCKY_SEC_GROUP} not found"
  
  echo -e "\n=== SECURITY GROUP RULES ==="
  echo -e "\n${UBUNTU_SEC_GROUP} rules:"
  openstack security group rule list "${UBUNTU_SEC_GROUP}" 2>/dev/null || echo "${UBUNTU_SEC_GROUP} not found"
  echo -e "\n${ROCKY_SEC_GROUP} rules:"
  openstack security group rule list "${ROCKY_SEC_GROUP}" 2>/dev/null || echo "${ROCKY_SEC_GROUP} not found"
  
  echo -e "\n=== SPECIFIC KEYPAIRS ==="
  echo -e "\n${UBUNTU_KEY_PAIR}:"
  openstack keypair show "${UBUNTU_KEY_PAIR}" 2>/dev/null || echo "${UBUNTU_KEY_PAIR} not found"
  echo -e "\n${ROCKY_KEY_PAIR}:"
  openstack keypair show "${ROCKY_KEY_PAIR}" 2>/dev/null || echo "${ROCKY_KEY_PAIR} not found"
  
  echo -e "\n=== ACTIVE PORTS ==="
  openstack port list --status ACTIVE
  
  echo -e "\n=== FLOATING IPS ==="
  openstack floating ip list
  
  echo -e "\n=== NETWORKS ==="
  openstack network list
  
  echo -e "\n=== ROUTERS ==="
  openstack router list
  
  echo -e "\n=== DEPLOYMENT INFO END ==="
  echo "Generated on: $(date)"
} > "$FULL_PATH"

echo "OpenStack ${DEPLOYMENT_TYPE} deployment information saved to: $FULL_PATH"