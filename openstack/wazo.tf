provider "openstack" {
  user_name     = "${var.user_name}"
  password      = "${var.password}"
  tenant_name   = "${var.tenant_name}"
  domain_name   = "${var.domain_name}"
  auth_url      = "${var.auth_url}"
  endpoint_type = "${var.endpoint_type}"
}

resource "openstack_compute_instance_v2" "wazo" {
  name              = "wazo-test-ha${count.index}"
  region            = "${var.region}"
  image_id          = "${var.image_id}"
  flavor_id         = "${var.flavor_id}"
  key_pair          = "${var.key_pair}"
  availability_zone = "${var.availability_zone}"

  count = "${var.count}"

  security_groups = [
    "default"
  ]

  user_data = "${file("files/cloud-init.txt")}"

  network {
    name = "${var.network}"
  }

  connection {
    user        = "jenkins"
    private_key = "${file("${var.key_file}")}"
    agent       = false
  }

  provisioner "local-exec" {
    command = "echo ${count.index}:${self.network.0.fixed_ip_v4} >> private_ips.txt"
  }

  provisioner "local-exec" {
    command = "bin/auto-retry ssh -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no -i ${var.key_file} jenkins@${self.network.0.fixed_ip_v4} /usr/bin/cloud-init status --wait"
  }

  provisioner "file" {
    source      = "private_ips.txt"
    destination = "/tmp/private_ips.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "wget --no-check-certificate https://raw.githubusercontent.com/wazo-platform/wazo-terraform/master/bin/wazo_install_aws -O /tmp/wazo_install_aws",
      "sudo bash /tmp/wazo_install_aws"
    ]
  }

}

output "ips" {
  value = "${join(" ", openstack_compute_instance_v2.wazo.*.access_ip_v4)}"
}
