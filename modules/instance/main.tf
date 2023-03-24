locals {
  http_port = 80
  ssh_port = 22
  tcp_protocol = "tcp"
  any_port = 0
  any_protocol = "-1"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_security_group" "nginx" {
  vpc_id = var.vpc_id
  name = "scg-ec2-${var.service_name}"
  tags = {
    Name = "scg-ec2-${var.service_name}"
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.nginx.id
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.tcp_protocol

  cidr_blocks       = local.all_ips
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.nginx.id
  from_port         = local.ssh_port
  to_port           = local.ssh_port
  protocol          = local.tcp_protocol

  cidr_blocks       = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.nginx.id
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
}

## TODO : count.index 수정 필요
resource "aws_instance" "ec2-daniel" {
  count = length(var.subnet_id)

  ami           = var.ami_id
  instance_type = var.instance_type
#  key_name      = "DevOps_Key"
  subnet_id     = var.subnet_id[count.index]

  vpc_security_group_ids = [aws_security_group.nginx.id]
  associate_public_ip_address = false

  depends_on = [aws_security_group.nginx]

  user_data = <<-EOT
  #!/bin/bash
  sudo apt-get update -y
  sudo apt install -y docker.io
  sudo systemctl start docker
  sudo docker run --name nginx -p 80:80 -d nginx:latest
  EOT
  tags = {
    Name = "ec2-${var.service_name}-${count.index + 1}"
  }
}