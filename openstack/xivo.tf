provider "openstack" {
    user_name = "${var.user_name}"
    password = "${var.password}"
    tenant_name = "${var.tenant_name}"
    domain_name = "${var.domain_name}"
    auth_url  = "${var.auth_url}"
}

resource "openstack_compute_instance_v2" "xivo" {
    name = "xivo-test-ha${count.index}"
    region = "${var.region}"
    image_id = "${var.image_id}"
    flavor_id = "${var.flavor_id}"
    key_pair = "${var.key_pair}"

    count = "${var.count}"

    security_groups = [
        "default"
    ]

    user_data = "${file(\"files/cloud-init.txt\")}"

    network {
        name = "${var.network}"
    }

    connection {
        user = "root"
        key_file = "${var.key_file}"
    }

    provisioner "local-exec" {
        command =  "echo ${count.index}:${self.network.0.fixed_ip_v4} >> private_ips.txt ; sleep 2"
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

output "ips" {
   value = "${join(\" \",openstack_compute_instance_v2.xivo.*.access_ip_v4)}"
}
