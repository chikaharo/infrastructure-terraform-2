resource "aws_security_group" "rds_sg" {
  name        = "my-aurora-rds-sg"
  description = "Security group for RDS instance"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # allow access from vpc
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {  
    Name = "myapp-rds_sg"  
  }  
}


resource "aws_security_group" "bastion-sg" {
  description = "EC2 Bastion Host Security Group"
  name = "bastion-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.bastion_ingress_ip]
    description = "Open to SSH from Public Internet"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    description = "IPv6 route Open to Public Internet"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "IPv4 route Open to Public Internet"
  }

  tags = {  
    Name = "myapp-bastion_sg"  
  }  
}

resource "aws_security_group" "alb_sg" {  
  vpc_id = var.vpc_id  

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {  
    Name = "alb_sg"  
  }  
}  

resource "aws_security_group" "ecs_sg" {  
  vpc_id = var.vpc_id  

  ingress {  
    from_port   = 0  
    to_port     = 0  
    protocol    = "tcp"  
    cidr_blocks = ["10.0.0.0/16"]  
  }  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "IPv4 route Open to Public Internet"
  }

  tags = {  
    Name = "alb_sg"  
  }  
}  

resource "aws_security_group" "service_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "myapp-service-sg"
  
  }
}