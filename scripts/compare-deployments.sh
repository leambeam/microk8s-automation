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
  bash scripts/compare-deployments.sh ==> output: unknown_deployment_date.txt

  Comparing deployments:

  diff compare-deployments/terraform_deployment_date.txt compare-deployments/heat_deployment_date.txt > compare-deployments/results

'


# Generic parameters
DEPLOYMENT_TYPE="${1:-"unknown"}"
TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
FILENAME="${DEPLOYMENT_TYPE}_deployment_${TIMESTAMP}.txt"

# Define resource base names
VM_BASE_NAME="vm"
SEC_GROUP_BASE_NAME="security_group"
KEY_PAIR_BASE_NAME="key-pair"

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
  echo -e "\n${VM_BASE_NAME}-1:"
  openstack server show "${VM_BASE_NAME}-1" 2>/dev/null || echo "${VM_BASE_NAME}-1 not found"
  echo -e "\n${VM_BASE_NAME}-2:"
  openstack server show "${VM_BASE_NAME}-2" 2>/dev/null || echo "${VM_BASE_NAME}-2 not found"
  
  echo -e "\n=== ATTACHED VOLUMES ==="
  openstack volume list --status in-use 2>/dev/null || echo "None of the volumes are in use"
  
  echo -e "\n=== SPECIFIC SECURITY GROUPS ==="
  echo -e "\n${SEC_GROUP_BASE_NAME}_1:"
  openstack security group show "${SEC_GROUP_BASE_NAME}_1" 2>/dev/null || echo "${SEC_GROUP_BASE_NAME}_1 not found"
  echo -e "\n${SEC_GROUP_BASE_NAME}_2:"
  openstack security group show "${SEC_GROUP_BASE_NAME}_2" 2>/dev/null || echo "${SEC_GROUP_BASE_NAME}_2 not found"
  
  echo -e "\n=== SECURITY GROUP RULES ==="
  echo -e "\n${SEC_GROUP_BASE_NAME}_1 rules:"
  openstack security group rule list "${SEC_GROUP_BASE_NAME}_1" 2>/dev/null || echo "${SEC_GROUP_BASE_NAME}_1 not found"
  echo -e "\n${SEC_GROUP_BASE_NAME}_2 rules:"
  openstack security group rule list "${SEC_GROUP_BASE_NAME}_2" 2>/dev/null || echo "${SEC_GROUP_BASE_NAME}_2 not found"
  
  echo -e "\n=== SPECIFIC KEYPAIRS ==="
  echo -e "\n${KEY_PAIR_BASE_NAME}-1:"
  openstack keypair show "${KEY_PAIR_BASE_NAME}-1" 2>/dev/null || echo "${KEY_PAIR_BASE_NAME}-1 not found"
  echo -e "\n${KEY_PAIR_BASE_NAME}-2:"
  openstack keypair show "${KEY_PAIR_BASE_NAME}-2" 2>/dev/null || echo "${KEY_PAIR_BASE_NAME}-2 not found"
  
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