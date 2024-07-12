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

# template file using user_data
resource "aws_instance" "demo_vm" {
    ami = var.ami
    instance_type = var.type
    user_data = templatefile("scirpt.tftpl", {request_id = "<YOUR_REQUEST_ID>", name = "<YOUR_DESIRED_NAME"})
    key_name = "tftemplate"

    tags = {
        name = "demo vm"
        type = "Templated"
    }
}

# template file using for loop
resource "aws_instance" "demo_vm2" {
    ami = var.ami
    instance_type = var.type
    key_name = "tftemplate"

    provisioner "file" {
      source = templatefile("resolv.conf.tftpl", {ip_addr = ["192.168.0.100", "8.8.8.8", "8.8.4.4"]})
      destination = "/etc/resolv.conf"
    }

    # creating JSON files using jsonencode in the templatefile
    provisioner "file" {
    source = templatefile("dependencies.tftpl", var.dep_vers)
    destination = "/desired/path/dependencies.tftpl"
}

    tags = {
        name = "demo vm"
        type = "Templated"
    }
}
