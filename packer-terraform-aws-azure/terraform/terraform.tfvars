
# AWS
# Credenciales de AWS, las obtiene de las variables de entorno

aws_region     = "sa-east-1"
ami_name       = "Node-AWS-ACT1-v0.1"
instance_type  = "t2.micro"
key_name       = "packNode" 

# COMPARTIDOS ENTRE LOS DOS
instance_name  = "Node_Nginx_AWS_AZU"
azure_instance_name = "Node-Nginx-AWS-AZU"


# AZURE
# azure_subscription_id = "subscription_id"
# azure_client_id       = "client_id"
# azure_client_secret   = "client_secret"
# azure_tenant_id       = "tenant_id"
azure_region          = "Brazil South"
azure_instance_type   = "Standard_B1ls"
azure_admin_username  = "ubuntu"
azure_admin_password  = "Azure..93**"
azure_image_name      = "Node-AZU-ACT1-v0.1"
azure_resource_group_name  = "packer-azu-images"