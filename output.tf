output "public_dns_01" {
  description = "Public dns"
  value = "http://${aws_instance.milber_ec2_infra_squad-01.public_dns}:8080"
}

output "public_dns_02" {
  description = "Public dns"
  value = "http://${aws_instance.milber_ec2_infra_squad-02.public_dns}:8080"
}
