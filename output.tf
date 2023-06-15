output "public_dns_01" {
  description = "Public dns"
  value = "http://${aws_instance.milber_ec2_infra_squad-01.public_dns}:8080"
}

output "public_dns_02" {
  description = "Public dns"
  value = "http://${aws_instance.milber_ec2_infra_squad-02.public_dns}:8080"
}

output "dns_load_balancer" {
  description = "Public dns"
  value = "http://${aws_lb.milber_app_lb.dns_name}:80"
}

