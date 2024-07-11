terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "alaalaeifar"

    workspaces {
      name = "alaalaeifar"
    }
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
  }
}


provider "aws" {
    region = "us-east-2"
}

data "aws_ami" "ubuntu" {
    filter {
        name = "key"
        values = ["ubuntu-*"]
    }

    most_recent = true
}

resource "aws_key_pair" "example" {
    key_name = "key"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
    ami = data.aws_ami.ubuntu.id
    instance_type = local.instance_type
    key_name = aws_key_pair.example.key_name

    # local-exec provisioner to save the private_ip address of the instance in a text-file in the host.
    provisioner "local-exec" {
        command = "echo ${self.private_ip} >> private_ip.txt"
    }
}

resource "null_resource" "copy_file_on_vm" {
    depends_on = [ 
        aws_instance.web
     ]

     connection {
       type = "ssh"
       user = "ubuntu"
       private_key = file("~/.ssh/id_rsa")
       host = aws_instance.web_public_dns
     }

     provisioner "file" {
       source = "./file.yaml"
       destination = "./file.yaml"
     }
}

resource "aws_instance" "my_vm" {
    ami = aws_ami.ami
    instance_type = local.instance_type

    key_name = "tfsn"
    security_groups = [aws_security_group.http_access.name] # adding http and ssh access to this instance

    provisioner "file" {
        source = "./somefile.txt"
        destination = "/home/ec2-user/somefile.txt"
    }

    # after the creation, it will execute the command on the remote EC2 instance
    provisioner "remote-exec" {
      inline = [ 
        "touch hello.txt",
        "echo 'Have a greate day exploring tf' >> hello.txt"
       ]
    }
    
    # the connection block used by the file provisioner to SSH into the EC2 instance to copy the file.
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file("./tfsn.cer") # it is created via AWS to connect to the ec2 instance.
      timeout = "4m"
    }

    tags = {
        Name = "my-vm-with-file-provisioner"
    }
}

locals {
    instance_type = "t2.micro"
}

# ------ more on connection block -------

# security group to acces inbound http and ssh into the ec2 instance
resource "aws_security_group" "http_access" {
    name = "http_access"
    description = "Allow HTTP inbound traffic"

    ingress {
        description = "HTTP access"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH Access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "http_access"
    }
}

# The local-exec provisioner works on the Terraform host – where Terraform configuration is applied/executed

/*
The file provisioner is a way to copy certain files or artifacts 
from the host machine to target resources that will be created in the future. 
This is a very handy way to transport certain script files, configuration files, 
artifacts like .jar files, binaries, etc. 
when the target resource is created and boots for the first time.
*/




