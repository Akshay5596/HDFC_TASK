# Application Load Balancer (ALB)
resource "aws_lb" "api_lb" {
  name               = "dummy-data-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.lb_sg.id]

  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  enable_deletion_protection = false
}

# Listener for ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_group.arn
  }
}

# Target Group for Blue Deployment
resource "aws_lb_target_group" "blue_group" {
  name     = "blue-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Target Group for Green Deployment
resource "aws_lb_target_group" "green_group" {
  name     = "green-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Weighted Forwarding for Blue-Green Deployment
resource "aws_lb_listener_rule" "blue_green_switch" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue_group.arn
        weight = var.blue_weight  # Set to 100 for full Blue, 0 for full Green
      }

      target_group {
        arn    = aws_lb_target_group.green_group.arn
        weight = var.green_weight  # Set to 100 for full Green, 0 for full Blue
      }
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}
