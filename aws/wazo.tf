provider "aws" {
  region = var.region
}

resource "aws_key_pair" "wazo" {
  key_name   = "wazo-terraform"
  public_key = file(var.public_key_path)
}

data "aws_ami" "wazo" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = [var.amazon_ami_name_filter]
  }
}

resource "aws_instance" "wazo" {
  ami           = data.aws_ami.wazo.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.wazo.key_name
  count         = var.nb_instances
  tags = {
    Name = "wazo-test-ha${count.index}"
  }
  security_groups = [
    "${aws_security_group.wazo.id}"
  ]
  user_data = file("../files/cloud-init.txt")
  connection {
    host        = self.public_ip
    user        = "root"
    type        = "ssh"
    private_key = file(var.private_key_path)
  }

  provisioner "local-exec" {
    command = "echo ${count.index}:${self.private_ip} >> private_ips.txt"
  }

  provisioner "file" {
    source      = "private_ips.txt"
    destination = "/tmp/private_ips.txt"
  }

  provisioner "file" {
    source      = "../bin/wazo_install_aws"
    destination = "/tmp/wazo_install_aws"
  }

  provisioner "file" {
    source      = "../bin/wazo_ctl_ha"
    destination = "/tmp/wazo_ctl_ha"
  }

  provisioner "file" {
    source      = "../bin/wazo_wizard"
    destination = "/tmp/wazo_wizard"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/wazo_install_aws",
    ]
  }
}

resource "aws_security_group" "wazo" {
  name        = "Wazo"
  description = "Wazo rules"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9486
    to_port     = 9486
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9497
    to_port     = 9497
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5060
    to_port     = 5060
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Wazo rules"
  }
}

output "ips" {
  value = join(" ", aws_instance.wazo.*.public_ip)
}
