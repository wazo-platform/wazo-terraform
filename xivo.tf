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
    count = "${var.count}"
    tags {
        Name = "xivo-test-ha${count.index}"
    }
    security_groups = [
        "${aws_security_group.xivo.id}"
    ]
    user_data = "${file(\"files/cloud-init.txt\")}"
    connection {
        user = "root"
        private_key = "${var.private_key}"
    }

    provisioner "local-exec" {
        command = "echo ${count.index}:${self.private_ip} >> private_ips.txt"
    }

    provisioner "file" {
        source = "private_ips.txt"
        destination = "/tmp/private_ips.txt"
    }

    provisioner "remote-exec" {
        inline = [
            "wget --no-check-certificate https://raw.githubusercontent.com/sboily/xivo-aws/master/bin/xivo_install_aws -O /tmp/xivo_install_aws",
            "bash /tmp/xivo_install_aws"
        ]
    }
}

resource "aws_security_group" "xivo" {
    name = "XiVO"
    description = "XiVO rules"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 9486
        to_port = 9486
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 9497
        to_port = 9497
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 5060
        to_port = 5060
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "XiVO rules"
    }
}

output "ips" {
   value = "${aws_instance.xivo.0.public_ip} ${aws_instance.xivo.1.public_ip}"
}
