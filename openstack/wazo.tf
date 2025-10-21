terraform {
  required_version = ">= 1.11.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }
  }
}

provider "openstack" {
  user_name     = var.user_name
  password      = var.password
  tenant_name   = var.tenant_name
  domain_name   = var.domain_name
  auth_url      = var.auth_url
  endpoint_type = var.endpoint_type
}

resource "openstack_compute_instance_v2" "wazo" {
  name              = "wazo-test-ha${count.index}"
  region            = var.region
  image_id          = var.image_id
  flavor_id         = var.flavor_id
  key_pair          = var.key_pair
  availability_zone = var.availability_zone

  count = var.instance_nb

  security_groups = [
    "default"
  ]

  user_data = templatefile("../files/cloud-init.txt", { hostname = "wazo" })

  network {
    name = var.network
  }

  connection {
    user        = "jenkins"
    host        = self.network.0.fixed_ip_v4
    private_key = file("${var.key_file}")
    agent       = false
  }

  provisioner "local-exec" {
    command = "echo ${count.index}:${self.network.0.fixed_ip_v4} >> ../private_ips.txt"
  }

  provisioner "local-exec" {
    command = "../bin/auto-retry ssh -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no -i ${var.key_file} jenkins@${self.network.0.fixed_ip_v4} /usr/bin/cloud-init status --wait"
  }

  provisioner "file" {
    source      = "../private_ips.txt"
    destination = "/tmp/private_ips.txt"
  }

  provisioner "file" {
    source      = "../bin/wazo_install_aws"
    destination = "/tmp/wazo_install_aws"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/wazo_install_aws"
    ]
  }

}

output "ips" {
  value = join(" ", openstack_compute_instance_v2.wazo.*.access_ip_v4)
}
