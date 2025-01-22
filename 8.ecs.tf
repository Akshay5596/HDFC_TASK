resource "aws_ecs_cluster" "app_cluster" {
  name = "dummy-data-cluster"  # Your desired cluster name
}


# Declare ECS Task Definition
resource "aws_ecs_task_definition" "app_task" {
  family                   = "dummy-data-task"
  network_mode             = "awsvpc"
  requires_compatibilities  = ["FARGATE"]

  cpu                      = "256"
  memory                   = "512"

  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name         = "dummy-data-api"
    image        = "node:latest"         # image tag will be change as per deployment 
    essential    = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    memory              = 512
    memoryReservation    = 256
  }])
}

resource "aws_ecs_service" "app_service" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGET"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue_group.arn  # Ensure this references the correct target group
    container_name   = "dummy-data-api"
    container_port   = 3000
  }

  depends_on = [
    aws_lb.api_lb,          # Ensure the ALB is created first
    aws_lb_target_group.blue_group  # Ensure the target group is created first
  ]
}
