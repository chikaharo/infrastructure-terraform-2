resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  tags = {
    Name        = "${var.app_name}-ecs"
    Environment = "${var.app_environment}-ecs"
  }

}

resource "aws_ecs_task_definition" "aws_ecs_task" {
  family                   = "main-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${var.ecr_repository_url}:latest",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${var.cloudwatch_log_group_id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.app_name}-"
        }
      },
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.host_port}
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION
  cpu   = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_execution_role.arn
  task_role_arn            = var.ecs_task_execution_role.arn
  
  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws_ecs_task.family
}


resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task.family}:${max(aws_ecs_task_definition.aws_ecs_task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = var.desired_count
  force_new_deployment = true

  network_configuration {
    subnets          = [var.subnet_id]
    assign_public_ip = false
    security_groups = [
      var.ecs_sg_id,
      var.alb_sg_id
    ]
  }

  load_balancer {
    target_group_arn = var.tg_group_arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = var.container_port
  }

  depends_on = [var.alb_listener]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.aws-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_launch_configuration" "main" {
  name          = "main-lc"
  image_id      = "ami-00c79d83cf718a893"
  instance_type = var.instance_type
  security_groups = [var.ecs_sg_id]
}
