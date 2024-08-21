variable vpc_id {}
# variable avail_zone {}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["ap-northeast-1a", "ap-northeast-1b", "ap-northeast-1c"]
}
