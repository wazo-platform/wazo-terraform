output "instances_ids" {
  value = local.instances.*.id
}

output "instances_public_ips" {
  value = local.instances.*.public_ip
}

output "instances_private_ips" {
  value = local.instances.*.private_ip
}

output "security_group_ids" {
  value = local.security_group_ids
}

output "keypair_name" {
  value = aws_key_pair.wazo.key_name
}
