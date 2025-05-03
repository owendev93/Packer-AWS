provider "aws" {
    region = var.aws_region
}

resource "aws_instance" "node_app" {
    ami           = var.ami_id
    instance_type = "t2.micro"
    key_name      = var.key_name
    associate_public_ip_address = true

    vpc_security_group_ids = [var.security_group_id]

    tags = {
    Name = "NodeApp"
    }
}
