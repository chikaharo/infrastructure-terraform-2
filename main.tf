provider "aws" {  
  region = var.aws_region  
}

resource "aws_vpc" "myapp-vpc" {  
  cidr_block = var.vpc_cidr_block

  enable_dns_support = true 
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}  

data "aws_availability_zones" "available" {}  

module "subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id 
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    azs = data.aws_availability_zones.available.names
    db_subnet_group_name = var.db_subnet_group_name
    app_name = var.app_name
    app_env = var.app_env
}

module "security-group" {
  source = "./modules/security-group"
  vpc_id = aws_vpc.myapp-vpc.id
  bastion_ingress_ip = var.bastion_ingress_ip
  ecs_ingress_cidr_blocks = var.ecs_ingress_cidr_blocks
  rds_cidr_blocks = var.rds_cidr_blocks
  app_name = var.app_name
  app_env = var.app_env
}

module "route53" {
  source = "./modules/route53"
  domain_name = var.domain_name
  dns_type = var.dns_type
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
  origin_id = var.origin_id
  app_name = var.app_name
  app_env = var.app_env
}

module "s3" {
    source = "./modules/s3"
    s3_frontend_bucket = var.s3_frontend_bucket 
    s3_aurora_bucket = var.s3_aurora_bucket
}

module "bastion" {
  source = "./modules/bastion"
  subnet_id = module.subnet.public-subnets[0].id
  bastion_sg_id = module.security-group.bastion-sg.id
  bastion_host_key_name = var.bastion_host_key_name
  bastion_host_instance_type = var.bastion_host_instance_type
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
  ecr_name = var.ecr_name
}

module "iam" {
  source = "./modules/iam"
  app_env = var.app_env
  app_name = var.app_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
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
  desired_count = var.ecs_desired_count
  ecs_max_capacity = var.ecs_max_capacity
  ecs_min_capacity = var.ecs_min_capacity
  instance_type = var.ecs_instance_type
  container_port = var.ecs_container_port
  host_port = var.ecs_host_port
  aws_region = var.aws_region
  app_name = var.app_name
  app_environment = var.app_env
}

module "rds" {
  source = "./modules/rds"
  cluster_identifier = var.rds_cluster_identifier
  db_name = var.db_name
  db_instance_class = var.db_instance_class
  engine = var.engine
  engine_version = var.engine_ver
  avail_zones = data.aws_availability_zones.available.names
  rds_sg_id = module.security-group.rds_sg.id
  desired_read_replicas = var.desired_read_replicas
  master_username = var.master_username
  master_password = var.master_password
  aws_s3_bucket_id = module.s3.s3_bucket_aurora.id
  rds_db_subnet_group_name = module.subnet.rds_db_subnet_group.name
  vpc_zone_identifier = module.subnet.rds_db_subnet_group.subnet_ids
  replica_scale_max = var.replica_scale_max
  replica_scale_min = var.replica_scale_min
  app_name = var.app_name
  app_env = var.app_env
}