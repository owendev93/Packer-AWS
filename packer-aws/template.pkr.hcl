packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

/*variable "aws_access_key" {
  type    = string
  default = "TU_ACCESS_KEY"
}

variable "aws_secret_key" {
  type    = string
  default = "TU_SECRET_KEY"
}*/

source "amazon-ebs" "packer-aws" {
  /*access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key*/
  region        = "sa-east-1"
  ami_name      = "pkr-nodejs-ubuntu-v1.0{{timestamp}}"
  instance_type = "t2.micro"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.packer-aws"]
}