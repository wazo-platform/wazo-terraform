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
    security_groups = [
        "${aws_security_group.xivo.id}"
    ]
    user_data = "${file(\"files/cloud-init.txt\")}"

    provisioner "remote-exec" {
        inline = [
        "echo FINISH"
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

variable "vpc_id" {
    description = "VPC ID"
}

variable "amazon_amis" {
    description = "Amazon Linux Debian AMIs"
    default = {
        us-east-1 = "ami-8b9a63e0"
    }
}

resource "aws_security_group" "xivo" {
    name = "xivo"
    description = "XiVO"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        self = true
    }
}
