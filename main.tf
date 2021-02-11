terraform {
  required_providers {
     aws = {
         source = "hashicorp/aws"
         version = "~>3.0"
     }
  }
}

#config aws provider

provider "aws" {
  region = "us-east-2"
  access_key = "masuan access key"
  secret_key = "masukan secretkey"

}

#create vpc
resource "aws_vpc" "mylab-vpc" {
    cidr_block = var.cidr_block[0]   
    
    tags = {
      Name = "mylab-vpc"
    }
}

#konfigurasi subnetwork (public)

resource "aws_subnet" "mylab-subnet1" {
   vpc_id = aws_vpc.mylab-vpc.id
   cidr_block = var.cidr_block[1]
   
   tags = {
     "Name" = "mylab-subnet1"
   }
}

#konfigurasi internet Gateway

resource "aws_internet_gateway" "my-inetGW" {
   vpc_id = aws_vpc.mylab-vpc.id
   
   tags = {
     "Name" = "Mylab-inetGW"
   }
}

# konfigurasi security group

resource "aws_security_group" "mylab-secgroup" {
  name = "mylab-security-group"
  description = "allow inbound and outbound traffic to mylab"
  vpc_id = aws_vpc.mylab-vpc.id

  dynamic ingress  {
    iterator = port
    for_each = var.ports
       content {
            cidr_blocks = ["0.0.0.0/0"]
            description = "ingresstraffic"
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
       }
  }
  egress {

    cidr_blocks = ["0.0.0.0/0"]
    description = "egress traffic"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags = {
     Name = "allow traffic"
 }
}

# konfigurasi AWS route table

resource "aws_route_table" "Mynode-routetable" {
  vpc_id = aws_vpc.mylab-vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-inetGW.id
    
  }
   tags = {
      Name = "Myroute-table"
  }
}

resource "aws_route_table_association" "Mynode-routeAssn" {
  subnet_id = aws_subnet.mylab-subnet1.id
  route_table_id = aws_route_table.Mynode-routetable.id
}

# konfigurasi AWS EC2 instances

 resource "aws_instance" "Mylabinstance" {
     ami = var.instance[0]
     instance_type = var.instance[1]
     key_name = var.instance[2]
     vpc_security_group_ids = [aws_security_group.mylab-secgroup.id]
     subnet_id = aws_subnet.mylab-subnet1.id
     associate_public_ip_address = true
     user_data = file("./installjenkins.sh")
     tags = {
        Name = "Jenkins-Server"
     } 
 }

# konfigurasi AWS EC2 Instance untuk ansible server

resource "aws_instance" "ansiblecontrolnode" {
     ami = var.instance[0]
     instance_type = var.instance[1]
     key_name = var.instance[2]
     vpc_security_group_ids = [aws_security_group.mylab-secgroup.id]
     subnet_id = aws_subnet.mylab-subnet1.id
     associate_public_ip_address = true
     user_data = file("./InstallAnsibleCN.sh")
     tags = {
        Name = "Ansible-ControlNode"
     } 
}

# konfigurasi Ansible Managed Node

 resource "aws_instance" "ansibleManagedNode" {
     ami = var.instance[0]
     instance_type = var.instance[1]
     key_name = var.instance[2]
     vpc_security_group_ids = [aws_security_group.mylab-secgroup.id]
     subnet_id = aws_subnet.mylab-subnet1.id
     associate_public_ip_address = true
     user_data = file("./AnsibleManagedNode.sh")
     tags = {
        Name = "Ansible-ManagedNode"
     }  
 }
#konfigurasi EC2 untuk Docker Host

resource "aws_instance" "Dockerhost" {
  ami = var.instance[0]
  instance_type = var.instance[1]
  key_name = var.instance[2]
  vpc_security_group_ids = [aws_security_group.mylab-secgroup.id]
  subnet_id = aws_subnet.mylab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./Docker.sh")
  tags = {
    Name = "Docker-ManagedNode"
  }
}

#konfigurasi EC2 Aws instance untuk Sonatype host nexus

resource "aws_instance" "Sonatype_nexus" {
    ami = var.instance[0]
    instance_type = var.instance[1]
    key_name = var.instance[2]
    vpc_security_group_ids = [aws_security_group.mylab-secgroup.id]
    subnet_id = aws_subnet.mylab-subnet1.id
    associate_public_ip_address = true
    user_data = file("./InstallNexus.sh")
    tags = {
    Name = "Sonatype-Node"
  }
}
