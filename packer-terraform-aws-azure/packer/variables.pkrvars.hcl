### Variables de Packer
ami_name          = "Node-AWS-ACT1-v0.1"
instance_type     = "t2.micro"
project_name      = "PackerAWS"
environment       = "des"

# AWS
aws_region        = "sa-east-1"

# Azure
azure_region          = "Brazil South"
azure_instance_type   = "Standard_B1ls"
azure_admin_username  = "adminuser"
azure_admin_password  = "P@ssword93"
azure_image_name      = "Node-AZU-ACT1-v0.1"
azure_resource_group_name  = "packer-azu-images"