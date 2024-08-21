output "rds_sg" {
    value = aws_security_group.rds_sg
}

output "bastion-sg" {
    value = aws_security_group.bastion-sg
}

output "alb_sg" {
    value = aws_security_group.alb_sg
}

output "ecs_sg" {
    value = aws_security_group.ecs_sg
}