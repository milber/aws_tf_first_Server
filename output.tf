output "public_dns" {
  description = "Public dns"
  value = "http://${aws_instance.milber_ec2_infra_squad.public_dns}:8080"
}

output "public_ipV4" {
  description = "ip V$"
  value = aws_instance.milber_ec2_infra_squad.public_ip
}
