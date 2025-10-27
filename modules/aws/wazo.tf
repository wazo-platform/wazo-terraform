provider "aws" {
  region = var.region
}

locals {
  private_ips_file = "/tmp/${substr(uuid(), 0, 8)}"
  instance_name    = var.names_prefix == "" ? "wazo-stack" : "${var.names_prefix}-wazo-stack"
  keypair_name     = var.names_prefix == "" ? "wazo-terraform" : "${var.names_prefix}-wazo-terraform"
  sg_name          = var.names_prefix == "" ? "wazo" : "${var.names_prefix}-wazo"
  allowed_ingress_public = concat(
    var.public_stacks ? ["0.0.0.0/0"] : [],
    var.additional_allowed_cidr_ranges,
  )
  allowed_ingress_private = var.additional_allowed_cidr_ranges
  sip_ports = [
    {
      port     = 5060
      protocol = "tcp"
    },
    {
      port     = 5060
      protocol = "udp"
    },
    {
      port     = 8067
      protocol = "tcp"
    },
    {
      port     = 9498
      protocol = "tcp"
    },
  ]
  webrtc_ports = [
    {
      port     = 3478
      protocol = "udp"
    },
    {
      port     = 19302
      protocol = "udp"
    },
    {
      port     = 5349
      protocol = "udp"
    },
    {
      port     = 443
      protocol = "udp"
    },
  ]
  stack_ports = [
    {
      port     = 80
      protocol = "tcp"
    },
    {
      port     = 443
      protocol = "tcp"
    },
    {
      port     = 123
      protocol = "udp"
    },
    {
      port     = 8667
      protocol = "tcp"
    },
    {
      port     = 8642
      protocol = "tcp"
    },
    {
      port     = 9486
      protocol = "tcp"
    },
    {
      port     = 9497
      protocol = "tcp"
    },
  ]
  private_stack_ports = [
    {
      port     = 5038
      protocol = "tcp"
    },
    {
      port     = 5039
      protocol = "tcp"
    },
  ]
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
      var.enable_root_password ? ["${path.module}/files/cloud-init-root-password.yml"] : []
    )
    iterator = filename
    content {
      content_type = "text/cloud-config"
      content = templatefile(filename.value, {
        hostname      = "${local.instance_name}-${count.index}",
        root_password = var.root_password,
      })
      merge_type = "list(append)+dict(recurse_list)+str()"
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
  security_groups  = var.custom_security_group_id == null ? [aws_security_group.wazo.0.id] : [var.custom_security_group_id]
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
      "bash -x /tmp/wazo_install_aws ${var.ha_mode ? "-h" : ""}",
    ]
  }
}

resource "aws_security_group" "wazo" {
  count       = var.custom_security_group ? 0 : 1
  name        = local.sg_name
  description = "Wazo stack rules"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress_public,
    )
  }
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = concat(
      [data.aws_subnet.this.cidr_block],
      local.allowed_ingress_private,
    )
  }
  dynamic "ingress" {
    for_each = local.sip_ports
    content {
      from_port = ingress.value["port"]
      to_port   = ingress.value["port"]
      protocol  = ingress.value["protocol"]
      cidr_blocks = concat(
        [data.aws_subnet.this.cidr_block],
        local.allowed_ingress_public,
      )
    }
  }
  dynamic "ingress" {
    for_each = local.webrtc_ports
    content {
      from_port = ingress.value["port"]
      to_port   = ingress.value["port"]
      protocol  = ingress.value["protocol"]
      cidr_blocks = concat(
        [data.aws_subnet.this.cidr_block],
        local.allowed_ingress_public,
      )
    }
  }
  dynamic "ingress" {
    for_each = local.stack_ports
    content {
      from_port = ingress.value["port"]
      to_port   = ingress.value["port"]
      protocol  = ingress.value["protocol"]
      cidr_blocks = concat(
        [data.aws_subnet.this.cidr_block],
        local.allowed_ingress_public,
      )
    }
  }
  dynamic "ingress" {
    for_each = local.private_stack_ports
    content {
      from_port = ingress.value["port"]
      to_port   = ingress.value["port"]
      protocol  = ingress.value["protocol"]
      cidr_blocks = concat(
        [data.aws_subnet.this.cidr_block],
        local.allowed_ingress_private,
      )
    }
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
