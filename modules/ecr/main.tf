resource "aws_ecr_repository" "aws-ecr" {
  name = "myapp-ecr"
  tags = {
    Name        = "myapp-ecr"
  }
}
