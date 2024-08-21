provider "aws" {  
  region = "ap-northeast-1"  # Tokyo region  
}

resource "aws_vpc" "myapp-vpc" {  
  cidr_block = "10.0.0.0/16"

  enable_dns_support = true 
  enable_dns_hostnames = true
  
  tags = {
    Name = "myapp-vpc"
  }
}  

module "subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id 
    azs = ["ap-northeast-1a", "ap-northeast-1b", "ap-northeast-1c"]
}

module "security-group" {
  source = "./modules/security-group"
  vpc_id = aws_vpc.myapp-vpc.id
  bastion_ingress_ip = "104.28.222.0/24"
}

module "route53" {
  source = "./modules/route53"
  domain_name = "example.com"
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
  vpc_id = aws_vpc.myapp-vpc.id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  frontend_endpoint = module.s3.frontend_website.website_endpoint
  domain_name = "example.com"
  acm_certificate_arn = module.route53.aws_acm_certificate.arn
  route53_zone_id = module.route53.route53_zone_id
}

module "s3" {
    source = "./modules/s3"
}

module "bastion" {
  source = "./modules/bastion"
  subnet_id = module.subnet.public-subnet-1.id
  bastion_sg_id = module.security-group.bastion-sg.id
}

module "app-loadbalancer" {
  source = "./modules/app-loadbalancer"
  pub_subnet1_id = module.subnet.public-subnet-1.id
  pub_subnet2_id = module.subnet.public-subnet-2.id
  vpc_id = aws_vpc.myapp-vpc.id 
  sg_id = module.security-group.alb_sg.id
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "ecs" {
  source = "./modules/ecs"
  subnet_id = module.subnet.public-subnet-2.id
  ecs_sg_id = module.security-group.ecs_sg.id
  alb_sg_id = module.security-group.alb_sg.id
  tg_group_arn = module.app-loadbalancer.ecs_tg.arn
  ecs_task_execution_role = module.iam.ecs_task_execution_role
  cloudwatch_log_group_id = module.cloudwatch.cloudwatch_log_group.id
  ecr_repository_url = module.ecr.ecr_repository.repository_url
  alb_listener = module.app-loadbalancer.alb_listener
  app_name = "myapp"
  app_environment = "app-env"
}

module "rds" {
  source = "./modules/rds"
  db_instance_class = "db.t2.micro"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.11.0"
  avail_zone = "ap-northeast-1a"
  rds_sg_id = module.security-group.rds_sg.id
  desired_read_replicas = 2
  master_username = "admin"
  master_password = "password"
  aws_s3_bucket_id = module.s3.s3_bucket_aurora.id
  rds_db_subnet_group_name = module.subnet.rds_db_subnet_group.name
  vpc_zone_identifier = module.subnet.rds_db_subnet_group.subnet_ids
  replica_scale_max = 2
  replica_scale_min = 1
}