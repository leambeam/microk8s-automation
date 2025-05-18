#!/bin/bash
set -e # Exit on the first non zero return code

## Terraform
TERRAFORM_DIR="terraform/"
TERRAFORM_VAR_FILE="default-vars.tfvars"

## Heat
HEAT_DIR="heat/"
HEAT_TEMPLATE="${HEAT_DIR}main.yaml"
HEAT_VARS="${HEAT_DIR}default-vars.yaml"
HEAT_STACK="vm-stack"

## Ansible
ANSIBLE_DIR="ansible/"
ANSIBLE_INVENTORY="${ANSIBLE_DIR}inventory.yml"
ANSIBLE_PLAYBOOK="${ANSIBLE_DIR}microk8s-deployment.yml"

## Image
IMAGE_DIR="rocky-image"
IMAGE_FILE="${IMAGE_DIR}/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
IMAGE_URL="https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
IMAGE_NAME="Rocky-9.5"

## SSH Keys
KEYS_DIR="keys"
UBUNTU_KEY="${KEYS_DIR}/ubuntu_key"
ROCKY_KEY="${KEYS_DIR}/rocky_key"

# Display usage information
show_usage() {
  echo "Infrastructure Management Script"
  echo "Run it from the root directory of this project"
  echo ""
  echo "Usage: $0 <component> [command]"
  echo ""
  echo "Components and Commands:"
  echo "  terraform"
  echo "    --deploy    - Initialize, plan, and apply Terraform configuration"
  echo "    --destroy   - Destroy Terraform resources"
  echo ""
  echo "  heat"
  echo "    --deploy    - Create Heat stack and show floating IPs"
  echo "    --destroy   - Delete Heat stack"
  echo "    --update    - Update existing Heat stack"
  echo "    --network   - List internal and external network IDs"
  echo ""
  echo "  ansible"
  echo "    --deploy    - Run Ansible playbook"
  echo ""
  echo "  image         - Import Rocky Linux 9 image to OpenStack"
  echo ""
  echo "  keygen        - Generate SSH keys for Ubuntu and Rocky VMs"
  echo ""
  echo "  --help        - Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 terraform --deploy   # Deploy infrastructure using Terraform"
  echo "  $0 heat --network       # List network IDs"
  echo "  $0 image                # Import Rocky Linux image to OpenStack"
}

# Check if enough arguments are provided
if [ $# -lt 1 ]; then
  show_usage
  exit 1
fi

# Parse component (first argument)
COMPONENT=$1
shift

# Function to check if action is provided
check_action() {
  local component=$1
  
  if [ $# -lt 1 ]; then
    echo "Error: No action specified for ${component}"
    show_usage
    exit 1
  fi
}

# Handle operation result
handle_result() {
  if [ $? -eq 0 ]; then
    echo "$1 completed successfully"
  else
    echo "$1 failed with exit code $?"
    exit 1
  fi
  echo ""
}

# Ensure that directory exists
check_directory() {
  if [ ! -d "$1" ]; then
    echo "Creating directory: $1"
    mkdir -p "$1"
  fi
}

# Execute operations based on component and action or just a component
case $COMPONENT in
  terraform)
    check_action "${COMPONENT}"
    
    case $1 in
      --deploy)
        # Run Terraform deployment commands inside the terraform/ directory and supply them with variables
        terraform -chdir=${TERRAFORM_DIR} init
        terraform -chdir=${TERRAFORM_DIR} plan -var-file="${TERRAFORM_VAR_FILE}" 
        terraform -chdir=${TERRAFORM_DIR} apply -var-file="${TERRAFORM_VAR_FILE}"
        handle_result "Terraform deployment"
        ;;
      --destroy)
        # Run Terraform destroy command inside the terraform/ directory and supply it with variables
        terraform -chdir=${TERRAFORM_DIR} destroy -var-file="${TERRAFORM_VAR_FILE}"
        handle_result "Terraform destruction"
        ;;
      --help)
        show_usage
        exit 0
        ;;
      *)
        echo "Unknown action: $1 for component: ${COMPONENT}"
        show_usage
        exit 1
        ;;
    esac
    ;;
    
  heat)
    check_action "${COMPONENT}"
    
    case $1 in
      --deploy)
        # Validate the template
        openstack --debug orchestration template validate -f json -t ${HEAT_TEMPLATE} -e ${HEAT_VARS}
        
        # Create the stack
        openstack stack create -t ${HEAT_TEMPLATE} -e ${HEAT_VARS} ${HEAT_STACK}
        
        # Wait for stack to allocate and associate floating ips
        echo "Waiting for stack deployment to complete"
        sleep 60
        
        # Get floating ips
        ubuntu=$(openstack stack output show ${HEAT_STACK} ubuntu_floating_ip -f value -c output_value)
        rocky=$(openstack stack output show ${HEAT_STACK} rocky_floating_ip -f value -c output_value)
        
        echo "Ubuntu floating ip: ${ubuntu}"
        echo "Rocky floating ip: ${rocky}"
        
        # Check the stack's status
        openstack stack show ${HEAT_STACK} -f yaml -c "stack_status"
        handle_result "Heat stack deployment"
        ;;
      --update)
        # Validate the template
        openstack --debug orchestration template validate -f json -t ${HEAT_TEMPLATE} -e ${HEAT_VARS}

        # Update the stack
        openstack stack update -t ${HEAT_TEMPLATE} -e ${HEAT_VARS} ${HEAT_STACK}

        handle_result "Heat stack update"
        ;;
      --network)
        external=$(openstack network list --external --format value --column ID)
        internal=$(openstack network list --internal --format value --column ID)

        echo "Public network id: ${external}"
        echo "Private network id: ${internal}"

        handle_result "Network information retrieval"
        ;;
      --destroy)
        openstack stack delete ${HEAT_STACK}
        handle_result "Heat stack deletion"
        ;;
      --help)
        show_usage
        exit 0
        ;;
      *)
        echo "Unknown action: $1 for component: ${COMPONENT}"
        show_usage
        exit 1
        ;;
    esac
    ;;
    
  ansible)
    check_action "${COMPONENT}"
    
    case $1 in
      --deploy)
        # Run the ansible playbook with inventory
        ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK}
        handle_result "Ansible deployment"
        ;;
      --help)
        show_usage
        exit 0
        ;;
      *)
        echo "Unknown action: $1 for component: ${COMPONENT}"
        show_usage
        exit 1
        ;;
    esac
    ;;
    
  image)
    
    # Ensure the rocky-image directory exists
    check_directory "${IMAGE_DIR}"
    
    # Check if the image file already exists
    if [ ! -f "${IMAGE_FILE}" ]; then
      wget ${IMAGE_URL} -P ${IMAGE_DIR}
      handle_result "Image download"
    else
      echo "Image file already exists, skipping download"
    fi
    
    # Create the OpenStack image
    openstack image create --progress --disk-format qcow2 --file "${IMAGE_FILE}" --private ${IMAGE_NAME}
    handle_result "OpenStack image creation"
    ;;
  keygen)
    
    # Ensure the keys directory exists
    check_directory "${KEYS_DIR}"
    
    # Generate two keypairs without passphrases
    ssh-keygen -t rsa -f ${UBUNTU_KEY} -N "" -C "Ubuntu VM Key"
    ssh-keygen -t rsa -f ${ROCKY_KEY} -N "" -C "Rocky VM Key"
    
    # Set permissions (600 for private keys is meant for their recreation involving write operation, switch to 400 if you do not plan to create them again)
    chmod 600 ${UBUNTU_KEY}
    chmod 600 ${ROCKY_KEY}
    chmod 644 ${UBUNTU_KEY}.pub
    chmod 644 ${ROCKY_KEY}.pub
    
    handle_result "SSH key generation"
    ;;
  --help)
    show_usage
    exit 0
    ;;
  *)
    echo "Unknown component: $COMPONENT"
    show_usage
    exit 1
    ;;
esac