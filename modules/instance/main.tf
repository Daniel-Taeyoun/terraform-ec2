resource "aws_security_group" "nginx" {
  vpc_id = var.vpc_id
  name_prefix = var.security_group_prefix_name

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "scg-ec2-${var.service_name}"
  }
}

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
    Name = "ec2-${var.service_name}"
  }
}