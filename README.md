# microk8s-automation

## Goal

Have an automated setup of microk8s on CSC CPouta VM.

## Plans for now

- [x] Create the POC of Heat template that will deploy the VM from Ubuntu image
- [x] Create the POC of Ansible playbook that will install microk8s on the deployed VM and deploy PrestaShop there
- [ ] Create the POC of Heat template that will deploy a custom image - Rocky
- [ ] Create the POC of Ansible playbook that will install Docker on Rocky and deploy PrestaShop
- [ ] Create the POC of GitLab CI/CD that will glue all of the automation together and handle secrets
- [ ] Make a more sophisticated version