provider "aws" {  
  region = var.aws_region  
}

resource "aws_vpc" "myapp-vpc" {  
  cidr_block = var.vpc_cidr_block

  enable_dns_support = true 
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
    Environment = "${var.app_env}-vpc"
  }
}  

data "aws_availability_zones" "available" {}  

module "subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id 
    azs = data.aws_availability_zones.available.names
    app_name = var.app_name
    app_env = var.app_env
}

module "security-group" {
  source = "./modules/security-group"
  vpc_id = aws_vpc.myapp-vpc.id
  app_name = var.app_name
  app_env = var.app_env
}

module "route53" {
  source = "./modules/route53"
  domain_name = var.domain_name
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
  vpc_id = aws_vpc.myapp-vpc.id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  frontend_endpoint = module.s3.frontend_website.website_endpoint
  domain_name = var.domain_name
  acm_certificate_arn = module.route53.aws_acm_certificate.arn
  route53_zone_id = module.route53.route53_zone_id
  app_name = var.app_name
  app_env = var.app_env
}

module "s3" {
    source = "./modules/s3"
}

module "bastion" {
  source = "./modules/bastion"
  subnet_id = module.subnet.public-subnets[0].id
  bastion_sg_id = module.security-group.bastion-sg.id
  app_name = var.app_name
  app_env = var.app_env
}

module "app-loadbalancer" {
  source = "./modules/app-loadbalancer"
  public_subnet_ids = module.subnet.public-subnet-ids
  vpc_id = aws_vpc.myapp-vpc.id 
  sg_id = module.security-group.alb_sg.id
  app_name = var.app_name
  app_env = var.app_env
}

module "ecr" {
  source = "./modules/ecr"
  app_name = var.app_name
  app_env = var.app_env
}

module "iam" {
  source = "./modules/iam"
  app_env = var.app_env
  app_name = var.app_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  db_instance_id = module.rds.db_instance_id
  app_env = var.app_env
  app_name = var.app_name
}

module "ecs" {
  source = "./modules/ecs"
  subnet_id = module.subnet.public-subnets[1].id
  ecs_sg_id = module.security-group.ecs_sg.id
  alb_sg_id = module.security-group.alb_sg.id
  tg_group_arn = module.app-loadbalancer.ecs_tg.arn
  ecs_task_execution_role = module.iam.ecs_task_execution_role
  cloudwatch_log_group_id = module.cloudwatch.cloudwatch_log_group.id
  ecr_repository_url = module.ecr.ecr_repository.repository_url
  alb_listener = module.app-loadbalancer.alb_listener
  aws_region = var.aws_region
  app_name = var.app_name
  app_environment = var.app_env
}

module "rds" {
  source = "./modules/rds"
  avail_zones = data.aws_availability_zones.available.names
  rds_sg_id = module.security-group.rds_sg.id
  aws_s3_bucket_id = module.s3.s3_bucket_aurora.id
  rds_db_subnet_group_name = module.subnet.rds_db_subnet_group.name
  vpc_zone_identifier = module.subnet.rds_db_subnet_group.subnet_ids
  app_name = var.app_name
  app_env = var.app_env
}