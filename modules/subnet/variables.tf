variable vpc_id {}

variable "azs" {
 type        = list(string)
 default     = ["ap-northeast-1a", "ap-northeast-1b", "ap-northeast-1c"]
}

variable public_subnet_cidrs {
    type = list(string)
}
variable private_subnet_cidrs {
    type = list(string)
}
variable db_subnet_group_name {}
variable app_name {}
variable app_env {}