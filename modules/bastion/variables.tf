variable "ec2-bastion-public-key-path" {
  type = string
  default = "/Users/admin/Desktop/DEV/Devops/terraform/test-hblab/secrets/ec2-bastion-key-pair.pub"
}
variable bastion_host_key_name {}
variable bastion_host_instance_type {}
variable subnet_id {}
variable bastion_sg_id {}
variable app_name {}
variable app_env {}
