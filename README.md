# microk8s-automation

## Guide

For complete instructions on using this repository, refer to this [guide](https://wimma-capstone.pages.labranet.jamk.fi/support-material/3.%20OPS/Production%20Platform/Guides%20and%20technologys/IaC/introduction/):

## Further development

IaC tools in the context of Wimma Capstone and CSC have huge potential and can be further researched and developed.

### GitLab

1. **Terraform Backend:** In production environments, Terraform state files should be managed remotely, meaning the state file is stored and updated in a remote location. This allows multiple users to collaborate on infrastructure deployment and prevents accidental deletion of state files from local machines. See more information [here](https://docs.gitlab.com/user/infrastructure/iac/terraform_state/)

2. **GitLab CI/CD:** [Link](https://docs.gitlab.com/ci/). A good pipeline for this project should have multiple separate stages for Heat, Terraform, and Ansible deployments. It would also be beneficial to add functionality that will allow passing infrastructure provisioning outputs (floating IPs) to the Ansible inventory. The main concern in pipeline implementation for this configuration is management of OpenStack RC files, as storing multiple variables in GitLab CI variables and sourcing them is not ideal. I recommend looking into external secrets managers, [they can be connected to GitLab](https://docs.gitlab.com/ci/secrets/). Moreover, GitLab should release their own solution at some point, check out the document [here](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/secret_manager/).

### OpenTofu

A new tool emerged when Terraform faced the backlash for the update of their licence. OpenTofu is essentially a fork of Terraform (1.5.x) with a different license. It is now taking a different direction, adding features not present in the original Terraform. While I do not know how mature it is and whether it is adopted by big players yet, the community appears to support it and development seems active.

1. Official website: [Link](https://opentofu.org/)
2. OpenStack provider: [Link](https://search.opentofu.org/provider/terraform-provider-openstack/openstack/latest)

### Ansible

You can also try using Ansible with OpenStack (i.e., for infrastructure deployment). See OpenStack collection [here](https://docs.ansible.com/ansible/latest/collections/openstack/cloud/index.html).

### Heat

Current configurations in both Terraform and Heat are quite linear with no space for proper scaling. Resource Groups can be used to improve this. In short, you can create a template for a resource (e.g., Nova Server) once and then specify the number of resources you want deployed (i.e., five Nova Servers), instead of declaring them multiple times. Read more [here](https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Heat::ResourceGroup)

### CSC

1. **Security roles:** You can try using granular permissions for OpenStack authentication. However, this is not currently available: [Link](https://docs.csc.fi/cloud/pouta/application-credentials/#using-roles)
2. **Billing changes:** CSC will change how billing units work. You might need to consider this in the future: [Link](https://csc.fi/en/blog/mapping-out-the-future-of-billing-unit/)