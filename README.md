# Install Wazo with Terraform

This repo install and configure Wazo as a HA service on AWS (Amazon Cloud) .
The login for the web interface is **wazo** by default.

Requirements
------------

- Terraform >= 0.6.16
- AWS account

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


Launch this command:

    terraform plan -var-file=terraform.tfvars modules/aws
    terraform apply modules/aws

At this end to getting informations:

    terraform show modules/aws

To remove instance:

    terraform plan -destroy modules/aws
    terraform destroy modules/aws

Please remove private_ips.txt if you relaunch your instances.

Have fun!
