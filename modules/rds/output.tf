output "rds-url" {
  value = aws_rds_cluster.aurora.endpoint
}

output "db_instance_id" {
  value = aws_rds_cluster_instance.aurora-instance.id
}