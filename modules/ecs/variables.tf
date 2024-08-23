variable subnet_id {}
variable ecs_sg_id {}
variable alb_sg_id {}
variable tg_group_arn {}
variable ecs_task_execution_role {}
variable cloudwatch_log_group_id {}
variable ecr_repository_url {}
variable alb_listener {}
variable desired_count {}
variable ecs_max_capacity {}
variable ecs_min_capacity {}
variable instance_type {}
variable container_port {}
variable host_port {}
variable app_environment {}
variable app_name {}
variable aws_region {}
variable cpu {
    default = 256
}
variable memory {
    default = 512
}
variable image_id {
    default =  "ami-00c79d83cf718a893"
}
variable service_launch_type {
    default = "FARGATE"
}
variable service_scheduling_strategy {
    default = "REPLICA"
}
variable task_network_mode {
    default = "awsvpc"
}
variable ecs_task_family {}