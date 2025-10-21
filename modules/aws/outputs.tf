output "instances_ids" {
  value = aws_instance.wazo.*.id
}

output "instances_public_ips" {
  value = aws_instance.wazo.*.public_ip
}

output "instances_private_ips" {
  value = aws_instance.wazo.*.private_ip
}

output "security_group_id" {
  value = aws_security_group.wazo.id
}

output "security_group_arn" {
  value = aws_security_group.wazo.arn
}

output "keypair_name" {
  value = aws_key_pair.wazo.key_name
}
