# Plantilla de Packer para crear una imagen para AWS y Azure con Ubuntu 18.04, Nginx y Node.js

# Definición de los Plugings necesarios para la plantilla.
packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    azure-arm = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Definición de variables para la plantilla de Packer
# Variables para la plantilla de Packer
variable "aws_region" { description = "Región de AWS" }
variable "ami_name" { description = "Nombre de la AMI generada" }
variable "instance_type" { description = "Tipo de instancia de AWS" }
variable "project_name" { description = "Nombre del proyecto" }
variable "environment" { description = "Entorno del proyecto (dev, test, prod)" }
# Credenciales de AWS
variable "aws_access_key" { 
  description = "Clave de acceso de AWS" 
  default = "default"
}
variable "aws_secret_key" { 
  description = "Clave secreta de AWS" 
  default = "default"
}
variable "aws_session_token" { 
  description = "Token de sesión de AWS" 
  default = "default"
}

variable "azure_image_name" { description = "Nombre de la imagen para Azure" }
variable "azure_region" { description = "Región de Azure" }
variable "azure_instance_type" { description = "Tipo de instancia en Azure"  }
variable "azure_admin_username" { description = "Usuario administrador para Azure"  }
variable "azure_admin_password" { description = "Contraseña del administrador para Azure"  }
variable "azure_resource_group_name" { description = "Nombre del grupo de recursos de Azure" }

variable "azure_subscription_id" { 
  description = "ID de la suscripción de Azure" 
  default = "default"
}
variable "azure_client_id" { 
  description = "ID de la aplicación (cliente) en Azure" 
  default = "default"
}
variable "azure_client_secret" { 
  description = "Clave secreta de la aplicación (cliente) en Azure" 
  default = "default"
}
variable "azure_tenant_id" { 
  description = "ID del inquilino en Azure" 
  default = "default"
}


# Builder para AWS
# Se define cómo se construye la AMI en AWS
# Se utiliza el plugin de Amazon EBS para crear una imagen de Amazon EC2
# Se define el filtro para seleccionar la AMI base de Ubuntu 18.04
source "amazon-ebs" "aws_builder" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  token         = var.aws_session_token
  region        = var.aws_region
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  instance_type = var.instance_type # Instancia AMIs t2.micro
  ssh_username  = "ubuntu" # Usuario SSH para la imagen de AWS
  ami_name      = var.ami_name

  tags = {
    Name = "Packer-AWS" 
  }
}


# Builder para AZURE
# Se define cómo se construye la imagen en Azure
# Se utiliza el plugin de Azure ARM para crear una imagen de Azure
# Se define el filtro para seleccionar la imagen base de Ubuntu 18.04
source "azure-arm" "azure_builder" {
  subscription_id                = var.azure_subscription_id
  client_id                      = var.azure_client_id
  client_secret                  = var.azure_client_secret
  tenant_id                      = var.azure_tenant_id

  managed_image_name             = var.azure_image_name
  managed_image_resource_group_name = var.azure_resource_group_name
  location                       = var.azure_region
  ssh_username = "ubuntu" # Usuario SSH para la imagen de Azure

  vm_size                        = var.azure_instance_type # Instancia de Azure (ej. Standard_B1s) equivalente a t2.micro de AWS
  os_type                        = "Linux"
  image_publisher                = "Canonical"
  image_offer                    = "UbuntuServer"
  image_sku                      = "18.04-LTS" 
  image_version                  = "latest"
  azure_tags = {
    environment = var.environment
  }
}


# Provisioners para AWS y Azure
# Se definen los provisioners para instalar y configurar el software en la imagen
build {
  name    = "comandos-cloud-node-nginx"
  sources = ["source.amazon-ebs.aws_builder"]

  # Se utiliza para instalar Nginx y Node.js, y configurar el firewall
  # Se utiliza el plugin de shell para ejecutar comandos en la instancia
  # Se utiliza el plugin de file para transferir archivos desde el host a la instancia
  provisioner "shell" {                             
    inline = [
      "sudo apt update -y",                         
      "sudo apt install -y nginx",                 
      "curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -", 
      "sudo apt install -y nodejs build-essential", 
      "sudo npm install pm2@latest -g",            
      "sudo ufw allow 'Nginx Full'",               
      "sudo systemctl enable nginx"                
    ]
  }

  provisioner "file" {                              
    source      = "../packer/provisioners/app.js"           
    destination = "/home/ubuntu/app.js"            
  }

  provisioner "shell" {
    inline = [
      "sudo pm2 start /home/ubuntu/app.js",               
      "sudo env PATH=$PATH:/usr/bin pm2 startup systemd --hp /root", 
      "sudo pm2 save",                                    
      "sudo cp /root/.pm2/dump.pm2 /etc/pm2-dump.pm2 || true" 
    ]
  }

  # Cuarto provisioner: Copiar el archivo de configuración de Nginx al servidor
  provisioner "file" {
    source      = "../packer/provisioners/nginx_default.conf"
    destination = "/tmp/nginx_default"
  }

  # Quinto provisioner:Configuración de Nginx como proxy inverso y validación
  provisioner "shell" {
    inline = [
      "sudo cp /tmp/nginx_default /etc/nginx/sites-available/default",
      "sudo nginx -t",
      "sudo systemctl restart nginx",
      "curl -I localhost"
    ]
  }
}

#######################################################################3
# PROVISIONER para Azure usamos Ansible

build {
  name    = "ansible-cloud-node-nginx"
  sources = ["source.azure-arm.azure_builder"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y ansible"
    ]
  }
  provisioner "file" { # Pasamos los ficheros a la instancia para que ansible los puedo manipular (ansible esta en la instancia)
  source      = "../packer/provisioners/app.js"
  destination = "/tmp/app.js"
}

  provisioner "file" {
  source      = "../packer/provisioners/nginx_default.conf"
  destination = "/tmp/nginx_default.conf"
}
  provisioner "ansible-local" {
    playbook_file = "../packer/provisioners/provision.yml" #perspectiva desde el terraform apply 
  }
}
