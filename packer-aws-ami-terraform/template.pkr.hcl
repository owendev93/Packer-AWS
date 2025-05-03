packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" { type = string }
variable "ami_name" { type = string }

source "amazon-ebs" "packer-aws" {
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

  tags = {
    Name        = "app-nodejs"
    Version     = "1.0"
    Environment = "dev"
  }
}

build {
  sources = ["source.amazon-ebs.packer-aws"]

  provisioner "shell" {
  inline = ["mkdir -p /tmp/app"]
}

  # Subir cada archivo manualmente
  provisioner "file" {
    source      = "app/app.js"
    destination = "/tmp/app/app.js"
  }

  provisioner "file" {
    source      = "app/package.json"
    destination = "/tmp/app/package.json"
  }

  provisioner "file" {
    source      = "app/nginx-config.conf"
    destination = "/tmp/app/nginx-config.conf"
  }

  # Subir script de instalación
  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/tmp/install.sh"
  }

  # Ejecutar el script
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install.sh",
      "sudo bash -x /tmp/install.sh"
    ]
  }
}



