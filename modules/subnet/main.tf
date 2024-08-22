

resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id     =  var.vpc_id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[2]
  tags = {
    Name = "${var.app_name}-private-subnet-${count.index}"
    Environment = "${var.app_env}-private-subnet-${count.index}"
  }
  map_public_ip_on_launch = false
}

## Public subnet
resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id     =  var.vpc_id
  cidr_block =  var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.app_name}-private-subnet-${count.index}"
    Environment = "${var.app_env}-private-subnet-${count.index}"
  }
  
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id
   tags = {
    Name = "${var.app_name}-igw"
    Environment = "${var.app_env}-igw"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.app_name}-public-subnet-route-table"
    Environment = "${var.app_env}-public-subnet-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.app_name}-private-subnet-route-table"
    Environment = "${var.app_env}-private-subnet-route-table"
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public-subnet[count.index].id 
  route_table_id = aws_route_table.public-route-table.id

}

resource "aws_route_table_association" "private-subnet-association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public-subnet[1].id
}

resource "aws_db_subnet_group" "rds-db-subnet-group" {
  name       = var.db_subnet_group_name
  subnet_ids = aws_subnet.private-subnet[*].id

  tags = {
    Name = "${var.app_name}-rds-db-subnet-group"
    Environment = "${var.app_env}-rds-db-subnet-group"
  }
}