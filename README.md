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

    terraform init https://github.com/sboily/xivo-aws

Create a terraform.tfvars with your value:

    access_key = ""
    secret_key = ""
    key_name = ""
    subnet_id = ""
    private_key = ""
    vpc_id = ""

Launch this command:

    terraform plan
    terraform apply

At this end to getting informations:

    terraform show
    
To remove instance:

    terraform plan -destroy
    terraform destroy
    
Have fun!
