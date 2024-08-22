resource "aws_ecr_repository" "aws-ecr" {
  name = var.ecr_name
  tags = {
    Name = "${var.app_name}-bastion-host-root-volume"
    Environment = "${var.app_env}-bastion-host-root-volume"
  }
}
