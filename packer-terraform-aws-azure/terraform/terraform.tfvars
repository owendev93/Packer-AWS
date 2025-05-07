
######### AWS
# Credenciales de AWS, las obtiene de las variables de entorno
# aws_access_key = "TU_ACCESS_KEY"
# aws_secret_key = "TU_SECRET_KEY"
# aws_session_token = "TU_SESSION_TOKEN"
aws_region     = "sa-east-1"
ami_name       = "Node-AWS-ACT1-v0.1"
instance_type  = "t2.micro"
key_name       = "packNode" # Nombre del par de claves para acceder a la instancia

######### COMPARTIDOS ENTRE LOS DOS
instance_name  = "Node_Nginx_AWS_AZU"
azure_instance_name = "Node-Nginx-AWS-AZU"


######### AZURE
# azure_subscription_id = "12345678-1234-1234-1234-123456789abc"
# azure_client_id       = "abcdef12-3456-7890-abcd-ef1234567890"
# azure_client_secret   = "your-secret-value"
# azure_tenant_id       = "12345678-1234-1234-1234-123456789abc"
azure_region          = "Brazil South"
azure_instance_type   = "Standard_B1ls"
azure_admin_username  = "ubuntu"
azure_admin_password  = "Azure..93**"
azure_image_name      = "Node-AZU-ACT1-v0.1"
azure_resource_group_name  = "packer-azu-images"