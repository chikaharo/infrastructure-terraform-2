
resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = var.cluster_identifier
  engine                 = var.engine  
  engine_version         = var.engine_version
  database_name          = var.db_name
  availability_zones     = [var.avail_zones[2]]
  master_username        = var.master_username  
  master_password        = var.master_password  
  
  skip_final_snapshot    = true  
  vpc_security_group_ids = [var.rds_sg_id]

  s3_import {
    source_engine         = var.s3_engine
    source_engine_version = var.s3_engine_ver
    bucket_name           = var.aws_s3_bucket_id
    bucket_prefix         = "backups"
    ingestion_role        = "arn:aws:iam::1234567890:role/role-xtrabackup-rds-restore"
  }

}


resource "aws_rds_cluster_instance" "aurora-instance" {
  count                        = var.desired_read_replicas
  identifier                   = "${aws_rds_cluster.aurora.id}-instance-${count.index}"
  engine                       = var.engine
  engine_version               = var.engine_version
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = var.db_instance_class
  publicly_accessible          = false
  # db_parameter_group_name      = aws_db_parameter_group.aurora-db-parameters.id
  preferred_maintenance_window    = "sat:13:00-sat:13:30" //UTC Time
  apply_immediately            = false
  auto_minor_version_upgrade   = false
  tags = {
    Name = "${var.app_name}-rds-aurora-cluster-instace-${count.index}"
    Environment = "${var.app_env}-rds-aurora-cluster-instace-${count.index}"
  }
  lifecycle {
    prevent_destroy = true   //it will prevent from accidental deletion
  }
}


resource "aws_appautoscaling_target" "read_replica" {

  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = aws_rds_cluster.aurora.id
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "read_replica" {

  name               = "${aws_rds_cluster.aurora.id}-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_rds_cluster.aurora.id
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 40
  }

  depends_on = [aws_appautoscaling_target.read_replica]
}
