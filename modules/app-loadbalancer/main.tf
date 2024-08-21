resource "aws_lb" "myapp-lb" {
  name               = "myapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = [var.pub_subnet1_id, var.pub_subnet2_id]

  enable_deletion_protection = false

  tags = {
    Name = "myapp-lb"
  }
}

resource "aws_lb_target_group" "tg-group" {
  name = "tg-group"
  port = "80"
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/v1/status"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "myapp-lb-tg"
  }


}


resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.myapp-lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg-group.arn
      }
    }
  }
}