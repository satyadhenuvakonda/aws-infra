# Internet VPC
resource "aws_vpc" "k8s" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "k8s"
  }
}

# Subnets PUBLIC-1
resource "aws_subnet" "k8s-public-1" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "k8s-public-1"
  }
}


# Subnets PUBLIC-2
resource "aws_subnet" "k8s-public-2" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "k8s-public-2"
  }
}

# Subnets PUBLIC-3
resource "aws_subnet" "k8s-public-3" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1c"

  tags = {
    Name = "k8s-public-3"
  }
}

# Subnets PRIVATE-1
resource "aws_subnet" "k8s-private-1" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "k8s-private-1"
  }
}

# Subnets PRIVATE-2
resource "aws_subnet" "k8s-private-2" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "k8s-private-2"
  }
}

# Subnets PRIVATE-3
resource "aws_subnet" "k8s-private-3" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1c"

  tags = {
    Name = "k8s-private-3"
  }
}



# Internet GW
resource "aws_internet_gateway" "k8s-gw" {
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s"
  }
}



# route tables
resource "aws_route_table" "k8s-public" {
  vpc_id = aws_vpc.k8s.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-gw.id
  }

  tags = {
    Name = "k8s-public-1"
  }
}



# route associations public
resource "aws_route_table_association" "k8s-public-1-a" {
  subnet_id      = aws_subnet.k8s-public-1.id
  route_table_id = aws_route_table.k8s-public.id
}

resource "aws_route_table_association" "k8s-public-2-a" {
  subnet_id      = aws_subnet.k8s-public-2.id
  route_table_id = aws_route_table.k8s-public.id
}

resource "aws_route_table_association" "k8s-public-3-a" {
  subnet_id      = aws_subnet.k8s-public-3.id
  route_table_id = aws_route_table.k8s-public.id
}



# SECURITY GROUP 

resource "aws_security_group" "allow-ssh" {
  vpc_id      = aws_vpc.k8s.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "k8s"
  }
}


# KEY PAIR FOR EC2
resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# AWS EC2 INSTANCE CREATION
resource "aws_instance" "example" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  subnet_id = aws_subnet.k8s-public-1.id
  key_name      = aws_key_pair.k8s-key.key_name
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

# COPYING THE USERDATA FILE TO THE EC2 INSTANCE 
  provisioner "file" {
    source      = "k8s-node-install.sh"
    destination = "/tmp/k8s-node-install.sh"
  }

# RUNNINS A SHELL SCRIPT IN THE EC2 INSTANCE 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-node-install.sh",
      "sudo /tmp/k8s-node-install.sh",
    ]
  }
# CONNECTING TO THE EC2 INSTANCE VIA SSH, MAKE SURE THE USERNAME AND THE KEYS ARE CORRECT
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
    tags = {
    Name = "k8s"
  }
}


