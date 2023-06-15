provider "aws" {
  region = "us-east-2"
  shared_config_files      = ["/Users/milber_tw/.aws/conf"]
  shared_credentials_files = ["/Users/milber_tw/.aws/credentials"]
}

resource "aws_security_group" "milber-infra-squad-sg" {
    name = "milber-infra-squad-sg"

    ingress {
      security_groups = [aws_security_group.milber_alb_sg.id]
      description = "Access to 8080 form exterior"
      from_port = 8080
      to_port = 8080
      protocol = "TCP"
    }

  }            


data "aws_subnet" "az_a" {
  availability_zone = "us-east-2a"
  vpc_id = aws_security_group.milber-infra-squad-sg.vpc_id
}

data "aws_subnet" "az_b" {
  availability_zone = "us-east-2b"
  vpc_id = aws_security_group.milber-infra-squad-sg.vpc_id
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
              echo "Hello Terraform!!!  server     0000002" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

}

resource "aws_security_group" "milber_alb_sg" {
    name = "milber_alb_sg"

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Access to 80 form exterior"
      from_port = 80
      to_port = 80
      protocol = "TCP"
    }

    egress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Access to 80 of internal servers"
      from_port = 80
      to_port = 80
      protocol = "TCP"
    }

}

resource "aws_lb" "milber_app_lb" {
  load_balancer_type = "application"
  name = "milber-Lb"
  security_groups = [aws_security_group.milber_alb_sg.id]
  subnets = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

resource  "aws_lb_target_group" "milber_is_tg" {
  name = "milber-is-tg"
  port = 80
  vpc_id = aws_security_group.milber-infra-squad-sg.vpc_id
  protocol = "HTTP"

  health_check {
    enabled = true
    matcher = 200
    path    = "/"
    port    = 8080
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "servidor_1" {
  target_group_arn  = aws_lb_target_group.milber_is_tg.arn
  target_id         = aws_instance.milber_ec2_infra_squad-01.id
  port              = 8080
}

resource "aws_lb_target_group_attachment" "servidor_2" {
  target_group_arn  = aws_lb_target_group.milber_is_tg.arn
  target_id         = aws_instance.milber_ec2_infra_squad-02.id
  port              = 8080
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.milber_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn  = aws_lb_target_group.milber_is_tg.arn
    type              = "forward"
  } 
}

