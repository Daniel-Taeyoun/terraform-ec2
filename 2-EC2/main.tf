variable "aws_region" {
  type = map(string)
  default = {
    "develop" : "ap-northeast-2"
    "stage" : "ap-northeast-2"
    "main" : "ap-northeast-1"
  }
}
variable "vpc_id_daniel" {
  default = "vpc-0835e68a89fedca6a"
}

variable "subnet_id_daniel" {
  type = list(string)
  default = ["subnet-04877697587e94e41", "subnet-0b9bfefbadbe30063"]
}

provider "aws" {
  region = var.aws_region[terraform.workspace]
  profile = "default"
}

resource "aws_security_group" "nginx" {
  vpc_id = var.vpc_id_daniel
  name_prefix = "scg-daniel-"

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
    Name = "scg-ec2-daniel"
  }
}

resource "aws_instance" "ec2-daniel" {
  count = length(var.subnet_id_daniel)

  ami           = "ami-0e38c97339cddf4bd"
  instance_type = "t2.micro"
  key_name      = "DevOps_Key"
  subnet_id     = var.subnet_id_daniel[count.index]

  vpc_security_group_ids = [aws_security_group.nginx.id]
  associate_public_ip_address = false

  depends_on = [aws_security_group.nginx]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo docker run --name nginx -p 80:80 -d nginx:latest
              EOF

  tags = {
    Name = "ec2-daniel"
  }
}