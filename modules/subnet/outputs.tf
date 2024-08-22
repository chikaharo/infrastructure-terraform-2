output "private-subnets" {
    value = aws_subnet.private-subnet[*]
}
output "private-subnet-ids" {
    value = aws_subnet.private-subnet[*].id
}

# output "public-subnet-1" {
#     value = aws_subnet.public-subnet-1
# }

# output "public-subnet-2" {
#     value = aws_subnet.public-subnet-2
# }

output "public-subnets" {
    value = aws_subnet.public-subnet[*]
}
output "public-subnet-ids" {
    value = aws_subnet.public-subnet[*].id
}

output "rds_db_subnet_group" {
    value = aws_db_subnet_group.rds-db-subnet-group
}