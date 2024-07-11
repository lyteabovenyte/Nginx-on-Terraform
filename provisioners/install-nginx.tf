/*
instead of supplying these command in an inline array attribute,
we wrap them in a shell file and execute that shell file.
this require us to use the file provisioner to first transport the shell file in the target EC2 instance
and then use the remote-exec provisioner to call the same.
*/
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

data "aws_ami" "ubuntu" {
    filter {
        name = "key"
        values = ["ubuntu-*"]
    }

    most_recent = true
}


resource "aws_instance" "my_vm" {
    ami = aws_ami.ubuntu.ami
    instance_type = local.instance_type

    security_groups = [aws_security_group.http_access.name]
    key_name = "tsfn"

    provisioner "file" {
      source = "./installnginx.sh"
      destination = "/home/ec2-user/installnginx.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod 777 ./installnginx.sh",
        "./installnginx.sh"
      ]
    }

    # connection credentials for ssh into the instance
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file("./tfsn.cer")
      timeout = "4m"
    }

    tags = {
        Name = "vm_for_installnginx"
    }
}

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

