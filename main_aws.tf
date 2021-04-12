provider "aws" {
    region  = "us-east-1"
    access_key = "AKIA5FHHTG5UIEVUEWVT"
    secret_key = "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"
}

# # Creating resource instance
# resource "aws_instance""my-first-server" {
#     ami = "ami-013f17f36f8b1fefb"
#     instance_type = "t2.micro"
#     tags = {
#         Name ="Sample project"
#     }
# }

# resource  "aws_vpc" "first-vpc" {
#     cidr_block = "10.0.0.0/16"
#     tags = {
#         Name = "production"
#     }
# }

#Order of codes in terraform in unimportant

# resource  "aws_subnet" "subnet-1" {
#   vpc_id     = aws_vpc.first-vpc.id
#   cidr_block = "10.0.1.0/24"
#   tags = {
#     Name = "prod-subnet"
#   }
# }

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.prod-vpc.id
    tags = {
        Name = "gateway-prod"
    }
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  # ipv6
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# Create Subnet
# using variables
variable "subnet_prefix" {
  description = "cidr block for subnet"
  default = "10.0.1.0/24"
}

resource  "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.subnet_prefix[0]
  availability_zone = "us-east-1a"
  tags = {
    Name = "prod-subnet"
  }
}

resource  "aws_subnet" "subnet-1-dev" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.subnet_prefix[1]
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-subnet"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      =  aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

#create security group to allow port 22,80, 443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# Create a network interface with an ip in the subnet that was craeted in step 4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       =  aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

#printing out public IP te
output "server_public_ip" {
  value = aws_eip.one.associate_with_private_ip
}

#create Ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
    ami = "ami-013f17f36f8b1fefb"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "main-key"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo systemctl start apache2
        sudo bash -c 'echo your very first web server > /var/www/html/index.html'
        EOF
    
    tags = {
        Name ="web-server"
    }
}


