output "ecs_tg" {
    value = aws_lb_target_group.tg-group
}
output "alb" {
    value = aws_lb.myapp-lb
}
output "alb_listener" {
    value = aws_lb_listener.lb_listener
}