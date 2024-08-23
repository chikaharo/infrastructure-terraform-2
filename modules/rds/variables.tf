variable cluster_identifier {}
variable engine {}
variable engine_version {}
variable db_instance_class {}
variable rds_sg_id {}
variable desired_read_replicas {}
variable master_username {}
variable master_password {}
variable aws_s3_bucket_id {}
variable rds_db_subnet_group_name {}
variable vpc_zone_identifier {}
variable avail_zones {}
variable replica_scale_max {}
variable replica_scale_min {}
variable db_name {}
variable s3_engine {
    default = "mysql"
}
variable s3_engine_ver {
    default = "5.7"
}
variable service_namespace {
    
}

variable app_name {}
variable app_env {}