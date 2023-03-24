resource "aws_lb" "alb-tch-devops-nginx" {
  name               = "alb-${var.service_name}-nginx"
  internal           = false
  load_balancer_type = "application"

  # Public 서브넷 설정
  subnets = var.elb_subnet_ids

  # EC2에서 생성된 Security Group으로 설정한다
  security_groups = var.elb_security_groups
}

resource "aws_lb_target_group" "tg-daniel-nginx" {
  name     = "tg-${var.service_name}-nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "attach-target-group" {
  count = length(var.target_group_instance_ids)
  target_group_arn = aws_lb_target_group.tg-daniel-nginx.arn
  target_id        = var.target_group_instance_ids[count.index]
  port             = 80
}

resource "aws_lb_listener" "attach-alb-listener" {
  load_balancer_arn = aws_lb.alb-tch-devops-nginx.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg-daniel-nginx.arn
    type = "forward"
  }
}