provider "aws" {
  region = "ap-northeast-2"
  profile = "default"
}

variable "ec2_id" {
  type = list(string)
    default = ["i-091629b426f90c817", "i-0a77c8ae255b84658"]
}

resource "aws_lb" "alb-daniel-nginx" {
  name               = "alb-daniel-nginx"
  internal           = false
  load_balancer_type = "application"

  # Public 서브넷 설정
  subnets = ["subnet-0c4da672cb8ca557b", "subnet-09c72ccc583b5b8ae"]

  # EC2에서 생성된 Security Group으로 설정한다
  security_groups = ["sg-09f10cb5fd32d5d0b"]
}

resource "aws_lb_target_group" "tg-daniel-nginx" {
  name     = "tg-daniel-nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0835e68a89fedca6a"
}

resource "aws_lb_target_group_attachment" "attach-target-group" {
  count = length(var.ec2_id)
  target_group_arn = aws_lb_target_group.tg-daniel-nginx.arn
  target_id        = var.ec2_id[count.index]
  port             = 80
}

resource "aws_lb_listener" "attach-alb-listener" {
  load_balancer_arn = aws_lb.alb-daniel-nginx.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg-daniel-nginx.arn
    type = "forward"
  }
}