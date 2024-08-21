

resource "aws_subnet" "private-subnet" {
  vpc_id     =  var.vpc_id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "myapp-private-subnet"
  }
  map_public_ip_on_launch = false
}

## Public subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id     =  var.vpc_id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "myapp-public-subnet-1"
  }
  
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id     =  var.vpc_id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "myapp-public-subnet-2"
  }
  
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id
    tags = {
        Name: "myapp-igw"
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
    Name = "public subnet route table"
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
    Name = "private subnet route table"
  }
}

resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-subnet-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public-subnet-2.id
}