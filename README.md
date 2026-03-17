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
    vpc_id           = ""
    public_key_path  = "" # Path to your SSH public key file
    private_key_path = "" # Path to your SSH private key file

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
