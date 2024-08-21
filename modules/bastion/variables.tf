variable "ec2-bastion-public-key-path" {
  type = string
  default = "/Users/admin/Desktop/DEV/Devops/terraform/test-hblab/secrets/ec2-bastion-key-pair.pub"
}

variable subnet_id {}
variable bastion_sg_id {}
