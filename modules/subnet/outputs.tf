output "private-subnet" {
    value = aws_subnet.private-subnet
}

output "public-subnet-1" {
    value = aws_subnet.public-subnet-1
}

output "public-subnet-2" {
    value = aws_subnet.public-subnet-2
}

# output "rds-db-subnet-group" {
#     value = aws_db_subnet_group.rds-db-subnet-group
# }