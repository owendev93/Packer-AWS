############################################
# AWS
######º#####################################


variable "aws_region" {
  default     = "sa-east-1"
  description = "AWS Region"
}

variable "ami_name" {
  default     = "ami-node-nginx"
  description = "Nombre base de la AMI a crear"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Tipo de instancia EC2"
}

variable "key_name" {
  description = "Nombre del par de claves para acceder a la instancia generado"
}

variable "instance_name" {
  default     = "packer-aws-ec2"
  description = "Nombre de la instancia"
}
### CREDENCIALES

variable "aws_access_key" {
  description = "Acceso de AWS (AWS_ACCESS_KEY_ID)"
}

variable "aws_secret_key" {
  description = "Secreta de AWS (AWS_SECRET_ACCESS_KEY)"
}

variable "aws_session_token" {
  description = "Sesión de AWS (AWS_SESSION_TOKEN)"
}

############################################
# AZURE
######º#####################################

###############CREDENCIALES
variable "azure_subscription_id" { description = "Azure ID subscription " }
variable "azure_client_id" { description = "Azure client ID" }
variable "azure_client_secret" { description = "Azure client secret" }
variable "azure_tenant_id" { description = "Azure tenant ID" }
###############################

variable "azure_region" { 
  default = "East US" 
  description = "Azure region" 
}
variable "azure_instance_type" { 
  default = "Standard_B1ms" 
  description = "Azure instance type" 
  }
variable "azure_admin_username" { 
  default = "adminuser" 
  description = "Admin username for Azure VM" 
}
variable "azure_admin_password" { description = "Admin password for Azure VM" }
variable "azure_image_name" { description = "Name of the Azure image created by Packer" }
variable "azure_resource_group_name" { description = "Name of the Azure resource group" }
variable "azure_instance_name" { description = "Name of the Azure instance" }

