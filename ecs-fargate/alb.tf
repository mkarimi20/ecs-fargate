resource "aws_alb" "task_lb" {
  name            = var.name_prefix
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.ecs_service.id]
}

resource "aws_alb_target_group" "task" {
  name        = "${var.name_prefix}-${var.task_container_port}"
  port        = var.task_container_port
  protocol    = var.task_container_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.task_container_protocol
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.task_lb.id
  port              = var.task_container_port
  protocol          = var.task_container_protocol

  default_action {
    target_group_arn = aws_alb_target_group.task.id
    type             = "forward"
  }
}