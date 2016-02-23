# xivo-aws

This repo install and configure XiVO as a HA service on AWS (Amazon Cloud). The login for the
web interface is superpass by default.

Requirements
------------

- Terraform
- AWS account

Launch
------

Install terraform (https://www.terraform.io/downloads.html)

Init the terraform infrastructure.

    terraform init github.com/sboily/xivo-aws xivo-terraform
    cd xivo-terraform

Create a terraform.tfvars with your value:

    access_key = ""
    secret_key = ""
    subnet_id = ""
    vpc_id = ""
    key_name = "" # The key Name you would like to use to connect to the EC2
    private_key = "" # Path of your amazon private key to connect to the EC2

Launch this command:

    terraform plan
    terraform apply

At this end to getting informations:

    terraform show
    
To remove instance:

    terraform plan -destroy
    terraform destroy

Please remove private_ips.txt if you relaunch your instances.
    
Have fun!
