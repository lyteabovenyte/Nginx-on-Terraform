variable "ami" {
    description = "the ami image id for EC2 instance"
    type = string
    default = "ami-xxxxxxx"
}

variable "type" {
    description = "instance_type"
    type = string
    default = "t2.micro"
}

# variables json templatefile using jsonencode
variable dep_vers {
   default = {
       "cradle_v": "0.5.5",
       "jade_v": "0.10.4",
       "redis_v": "0.5.11",
       "socket_v": "0.6.16",
       "twitter_v": "0.0.2",
       "express_v": "2.2.0"
   }
}
