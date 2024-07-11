output "instance_id" {
    description = "instance_id of the provisioned aws_instance"
    value = aws_instance.my_vm.id
}

output "public_ip" {
    description = "the public_ip of the aws_instance"
    value = aws_instance.my_vm.public_ip
}