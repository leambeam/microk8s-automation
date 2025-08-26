# microk8s-automation

This is a mirror of the GitLab repository containing the delivery of my Bachelor's thesis titled 'Using Infrastructure as Code for Building a MicroK8s Environment on the CSC Cloud Platform for the [Wimma Capstone](https://wimma-capstone.jamk.fi/) project. 

## Objectives

1. Investigate which IaC tools are compatible with the [CSC cloud](https://csc.fi/en/) (built on OpenStack).
2. Develop a proof of concept (deploy PrestaShop e-commerce solution on MicroK8s hosted on the infrastructure provisioned with IaC).
3. Create educational materials on IaC.

## Results

1. I tested Heat (native OpenStack IaC tool) and Terraform for the infrastructure provisioning. I then used Ansible to install MicroK8s on VMs that were already provisioned and deploy the PrestaShop Helm chart on them.
2. I created Heat and Terraform templates that both result in identical deployments of OpenStack resources such as Nova servers, Neutron security groups, Nova key pairs, and Neutron ports. I also created an Ansible playbook that performs the MicroK8s PrestaShop deployments on VMs with Rocky and Ubuntu images.
3. I created a step-by-step guide with multiple deployment strategies.
4. I created auxiliary scripts for provisioning and comparing infrastructure (i.e. comparing Heat and Terraform deployments).
5. I outlined ideas for further development (see them in the original repository).

## Links

1. Full Thesis: [Using Infrastructure as Code for Building a MicroK8s Environment on the CSC Cloud Platform](https://www.theseus.fi/handle/10024/894422)
2. Original repository: [microk8s-automation](https://gitlab.labranet.jamk.fi/presta-shop-development-release-x/microk8s-automation)
3. Guide: [Infrastructure as Code (IaC)](https://wimma-capstone.pages.labranet.jamk.fi/support-material/3.%20OPS/Production%20Platform/Guides%20and%20technologys/IaC/introduction/)
4. PrestaShop Helm chart repository: [prestashop-helm](https://github.com/leambeam/prestashop-helm)