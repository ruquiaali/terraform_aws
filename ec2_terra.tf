provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

resource "aws_vpc" "vpc_terra" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "vpc_terra"
  }
}
resource "aws_subnet" "vpc_public_terra" {
  vpc_id            = aws_vpc.vpc_terra.id
  cidr_block        = "10.10.1.0/24"
  tags = {
    Name = "vpc_public_terra"
  }
}


resource "aws_internet_gateway" "igw_terra" {
  vpc_id = aws_vpc.vpc_terra.id

  tags = {
    Name = "igw_terra"
  }
}

resource "aws_route_table" "rt_public_terra" {
  vpc_id = aws_vpc.vpc_terra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_terra.id
  }
 tags = {
    Name = "rt_public_terra"
  }
}


  resource "aws_route_table_association" "rt_public_terra" {
  subnet_id      = aws_subnet.vpc_public_terra.id
  route_table_id = aws_route_table.rt_public_terra.id
}

resource "aws_security_group" "sg_terra" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.vpc_terra.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
    Name = "sg_terra"
  }
}



resource "aws_instance" "ec2_terra" {
  ami           = "ami-02660b83a0d8dbaef"
  instance_type = "t2.micro"
  key_name      = "Mykeypair-Ruq"

  subnet_id                   = aws_subnet.vpc_public_terra.id
  vpc_security_group_ids      = [aws_security_group.sg_terra.id]
  associate_public_ip_address = true
   tags = {
    "Name" : "ec2_terra"
  }
}