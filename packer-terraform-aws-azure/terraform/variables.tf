
# AWS

# Podemos que infraestructura desplegar: aws, azure o ambos
# En este caso, se define una variable de entorno para el despliegue
# de la infraestructura en AWS o Azure.
variable "deployment_target" {
  description = "Define qué infraestructura desplegar: aws, azure o both"
  default     = "both"
}

# Variables de configuración para Packer y Terraform
# AWS

variable "aws_region" {
  default     = "sa-east-1"
  description = "AWS Region"
}

variable "ami_name" {
  default     = "ami-node-nginx"
  description = "Nombre base de la AMI"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instancia EC2"
}

variable "key_name" {
  description = "Nombre del par de claves de AWS"
}

variable "instance_name" {
  default     = "packer-aws-ec2"
  description = "Nombre de la instancia"
}
### CREDENCIALES

variable "aws_access_key" {
  description = "Acceso AWS (AWS_ACCESS_KEY_ID)"
}

variable "aws_secret_key" {
  description = "Secreta AWS (AWS_SECRET_ACCESS_KEY)"
}

variable "aws_session_token" {
  description = "Token AWS (AWS_SESSION_TOKEN)"
}

# AZURE
variable "azure_subscription_id" { description = "ID subscription " }
variable "azure_client_id" { description = "Client ID" }
variable "azure_client_secret" { description = "Client secret" }
variable "azure_tenant_id" { description = "Tenant ID" }


variable "azure_region" { 
  default = "Brazil South" 
  description = "Region de Azure Disponible" 
}
variable "azure_instance_type" { 
  default = "Standard_B1ms" 
  description = "Azure instance type" 
  }
variable "azure_admin_username" { 
  default = "adminuser" 
  description = "Usuario Administrador para gestionar la VM de Azure" 
}
variable "azure_admin_password" { description = "Password for Azure VM" }
variable "azure_image_name" { description = "Name of the Azure image created by Packer" }
variable "azure_resource_group_name" { description = "Name of the Azure resource group" }
variable "azure_instance_name" { description = "Name of the Azure instance" }

