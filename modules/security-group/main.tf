resource "aws_security_group" "rds_sg" {
  name        = "my-aurora-rds-sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.rds_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds-security-group"
    Environment = "${var.app_env}-rds-security-group"
  }
}


resource "aws_security_group" "bastion-sg" {
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
    Name = "${var.app_name}-bastion-host-security-group"
    Environment = "${var.app_env}-bastion-host-security-group"
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
    Name = "${var.app_name}-alb-security-group"
    Environment = "${var.app_env}-alb-security-group"
  }
}  

resource "aws_security_group" "ecs_sg" {  
  vpc_id = var.vpc_id  

  ingress {  
    from_port   = 0  
    to_port     = 0  
    protocol    = "tcp"  
    cidr_blocks = var.ecs_ingress_cidr_blocks  
  }  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "${var.app_name}-ecs-security-group"
    Environment = "${var.app_env}-ecs-security-group"
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
    Name = "${var.app_name}-service-security-group"
    Environment = "${var.app_env}-service-security-group"
  }
}