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

resource "null_resource" "xivo" {

    triggers {
        cluster_instance_ids = "${join(",", openstack_compute_instance_v2.xivo.*.id)}"
    }

    provisioner "local-exec" {
        command = "rm -f private_ips.txt ; echo 0:${openstack_compute_instance_v2.xivo.0.network.0.fixed_ip_v4} > private_ips.txt ; echo 1:${openstack_compute_instance_v2.xivo.1.network.0.fixed_ip_v4} >> private_ips.txt"
    }

}

output "ips" {
   value = "${openstack_compute_instance_v2.xivo.0.access_ip_v4} ${openstack_compute_instance_v2.xivo.1.access_ip_v4}"
}
