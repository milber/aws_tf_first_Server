provider "aws" {
  region = "us-east-2"
  shared_config_files      = ["/Users/milber_tw/.aws/conf"]
  shared_credentials_files = ["/Users/milber_tw/.aws/credentials"]
}

data "aws_subnet" "az_a" {
  availability_zone = "us-east-2a"
  vpc_id = "vpc-066a31f1234c3ce43"
}

data "aws_subnet" "az_b" {
  availability_zone = "us-east-2b"
  vpc_id = "vpc-066a31f1234c3ce43"
}

resource "aws_security_group" "milber-infra-squad-sg" {
    name = "milber-infra-squad-sg"

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Access to 8080 form exterior"
      from_port = 8080
      to_port = 8080
      protocol = "TCP"
    }

  }            


resource "aws_instance" "milber_ec2_infra_squad-01" {
  ami           = "ami-0a695f0d95cefc163"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.az_b.id

  vpc_security_group_ids = [aws_security_group.milber-infra-squad-sg.id]

  tags = {
    Name = "milber_ec2_infra_squad-01"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello Terraform!!!   server 01" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

}

resource "aws_instance" "milber_ec2_infra_squad-02" {
  ami           = "ami-0a695f0d95cefc163"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.az_a.id

  vpc_security_group_ids = [aws_security_group.milber-infra-squad-sg.id]

  tags = {
    Name = "milber_ec2_infra_squad-02"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello Terraform!!!  server     02" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

}