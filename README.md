# Install Wazo with Terraform

This repo install and configure Wazo as a HA service on AWS (Amazon Cloud).
The login for the web interface is **wazo** by default.

## Requirements

- Terraform >= 1.0
- AWS account

## Launch

Install [terraform](https://www.terraform.io/downloads.html)

Enter the AWS module directory and init the terraform infrastructure:

    cd modules/aws
    terraform init

Create a terraform.tfvars with your values:

    subnet_id        = ""
    public_key_path  = "" # Path to your SSH public key file
    private_key_path = "" # Path to your SSH private key file

By default the latest development version of Wazo is installed, from the master
branch of wazo-ansible. To install a released version instead, set
`wazo_version` and the install will use the matching `wazo-<version>` tag:

    wazo_version = "24.16"

If the instances are not directly reachable, provisioning can go through an SSH
jumphost. Set `bastion_host` and the instances will be reached on their private
IP through it:

    bastion_host = "jump.example.com"

The other jumphost settings are optional, omit them to keep the defaults:

    bastion_user             = "admin"                    # defaults to root
    bastion_port             = 2222                       # defaults to 22
    bastion_private_key_path = "~/.ssh/jumphost_ed25519"  # defaults to private_key_path
    bastion_host_key         = "ssh-ed25519 AAAA..."      # defaults to no host verification

Note that the jumphost must be allowed to reach the instances on port 22: add
its CIDR to `additional_allowed_cidr_ranges` if it is outside the subnet.

Launch this command:

    terraform plan -var-file=terraform.tfvars
    terraform apply -var-file=terraform.tfvars

At this end to getting informations:

    terraform show

To remove instance:

    terraform plan -destroy -var-file=terraform.tfvars
    terraform destroy -var-file=terraform.tfvars

Please remove private_ips.txt if you relaunch your instances.

Have fun!
