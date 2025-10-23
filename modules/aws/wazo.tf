provider "aws" {
  region = var.region
}

locals {
  private_ips_file = "/tmp/${substr(uuid(), 0, 8)}"
  instance_name    = var.names_prefix == "" ? "wazo-stack" : "${var.names_prefix}-wazo-stack"
  keypair_name     = var.names_prefix == "" ? "wazo-terraform" : "${var.names_prefix}-wazo-terraform"
  sg_name          = var.names_prefix == "" ? "wazo" : "${var.names_prefix}-wazo"
  allowed_ingress = concat(
    var.public_stacks ? ["0.0.0.0/0"] : [],
    var.additional_allowed_cidr_ranges,
  )
}

resource "aws_key_pair" "wazo" {
  key_name   = local.keypair_name
  public_key = file(var.public_key_path)
}

data "aws_ami" "wazo" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = [var.amazon_ami_name_filter]
  }

  filter {
    name   = "architecture"
    values = [var.amazon_ami_architecture]
  }
}

data "aws_subnet" "this" {
  id = var.subnet_id
}

data "template_cloudinit_config" "wazo" {
  count = var.nb_instances
  dynamic "part" {
    for_each = concat(
      ["${path.module}/files/cloud-init.yml"],
      var.cloud_config_files,
    )
    iterator = filename
    content {
      content_type = "text/cloud-config"
      content      = templatefile(filename.value, {hostname = "${local.instance_name}-${count.index}"})
      merge_type   = "list(append)+dict(recurse_list)+str()"
    }
  }
}

resource "aws_instance" "wazo" {
  ami           = data.aws_ami.wazo.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.wazo.key_name
  count         = var.nb_instances
  tags = {
    Name = "${local.instance_name}-${count.index}"
  }
  security_groups = [
    "${aws_security_group.wazo.id}"
  ]
  user_data_base64 = data.template_cloudinit_config.wazo[count.index].rendered
  connection {
    host        = var.public_stacks ? self.public_ip : self.private_ip
    user        = "root"
    type        = "ssh"
    private_key = file(var.private_key_path)
  }

  provisioner "local-exec" {
    command = "echo ${count.index}:${self.private_ip} >> ${local.private_ips_file}"
  }

  provisioner "file" {
    source      = local.private_ips_file
    destination = "/tmp/private_ips.txt"
  }

  provisioner "file" {
    source      = "${path.module}/bin/wazo_install_aws"
    destination = "/tmp/wazo_install_aws"
  }

  provisioner "file" {
    source      = "${path.module}/bin/wazo_ctl_ha"
    destination = "/tmp/wazo_ctl_ha"
  }

  provisioner "file" {
    source      = "${path.module}/bin/wazo_wizard"
    destination = "/tmp/wazo_wizard"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/wazo_install_aws",
    ]
  }
}

resource "aws_security_group" "wazo" {
  name        = local.sg_name
  description = "Wazo stack rules"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress,
    )
  }
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress,
    )
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress,
    )
  }
  ingress {
    from_port = 9486
    to_port   = 9486
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress,
    )
  }
  ingress {
    from_port = 9497
    to_port   = 9497
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress,
    )
  }
  ingress {
    from_port = 5060
    to_port   = 5060
    protocol  = "udp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress,
    )
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.this.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.sg_name
  }
}
