provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_instance" "xivo" {
    ami = "${lookup(var.amazon_amis, var.region)}"
    instance_type = "${var.instance_type}"
    subnet_id = "${var.subnet_id}"
    key_name = "${var.key_name}"
    tags {
        Name = "xivo-test-ha${count.index}"
    }
    user_data = "${file(\"files/cloud-init.txt\")}"

    provisioner "remote-exec" {
        inline = [
        "wget --no-check-certificate https://raw.githubusercontent.com/sboily/xivo-aws/master/xivo_install_aws",
        "sudo bash /home/admin/xivo_install_aws"
        ]

        connection {
            user = "admin"
            private_key = "${var.private_key}"
        }
    }
}

variable "access_key" {
    description = "AWS access key."
}

variable "secret_key" {
    description = "AWS secret key."
}

variable "region" {
    description = "The AWS region to create things in."
    default = "us-east-1"
}

variable "key_name" {
    description = "Name of the keypair to use in EC2."
}

variable "subnet_id" {
    description = "Name of your subnet ID to use in EC2."
}

variable "private_key" {
    description = "Path to your private key."
}

variable "instance_type" {
    description = "Instance type in AWS."
    default = "t2.micro"
} 

variable "amazon_amis" {
    description = "Amazon Linux Debian AMIs"
    default = {
        us-east-1 = "ami-8b9a63e0"
    }
}
