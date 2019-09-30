# Install Wazo with Terraform

This repo install and configure Wazo as a HA service on AWS (Amazon Cloud) or Openstack. The login for the
web interface is **wazo** by default.

Requirements
------------

- Terraform >= 0.6.16
- AWS account
- Openstack account

Launch
------

Install terraform (https://www.terraform.io/downloads.html)

Init the terraform infrastructure.

    terraform init github.com/wazo-platform/wazo-terraform wazo-terraform
    cd wazo-terraform

Create a terraform.tfvars with your value:

aws
---

    access_key = ""
    secret_key = ""
    subnet_id = ""
    vpc_id = ""
    key_name = "" # The key Name you would like to use to connect to the EC2
    private_key = "" # Path of your amazon private key to connect to the EC2

openstack
---------

    user_name = ""
    password = ""
    tenant_name = ""
    auth_url = "http://keystone:5000/v3"
    key_pair = ""
    key_file = ""
    network = ""


Launch this command:

    terraform plan -var-file=terraform.tfvars <aws|openstack>
    terraform apply <aws|openstack>

At this end to getting informations:

    terraform show <aws|openstack>

To remove instance:

    terraform plan -destroy <aws|openstack>
    terraform destroy <aws|openstack>

Please remove private_ips.txt if you relaunch your instances.

Have fun!
