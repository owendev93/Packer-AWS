# CONFIGURACIÓN DE TERRAFORM PARA LOS PROVEEDORES AWS Y AZURE
# Este archivo define la infraestructura en la nube utilizando Terraform, incluyendo la creación de instancias EC2 en AWS y máquinas virtuales en Azure.
# Se utilizan variables para definir configuraciones específicas y se implementan recursos como grupos de seguridad, redes virtuales y máquinas virtuales.
# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Azure Provider
provider "azurerm" {
  features {}
}


#AWS PROVIDER
# Se especifica la región de AWS donde se desplegarán los recursos.

# RECURSO PARA EJECUTAR PACKER Y GENERAR LA AMI EN AWS
# Este recurso utiliza un comando local (en la máquina que ejecuta `terraform init`) para ejecutar Packer con las variables necesarias
resource "null_resource" "packer_ami" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0

  # local-exec ejecuta un comando en la máquina que ejecuta Terraform.
  provisioner "local-exec" {
    # Este comando invoca Packer para construir una AMI personalizada usando las variables y configuraciones proporcionadas.
    # Se especifica el nombre de la AMI y las credenciales de AWS necesarias para la creación.
    # Se utiliza el archivo de configuración de Packer (`main.pkr.hcl`) y un archivo de variables (`variables.pkrvars.hcl`).
    command = "packer build -only=comandos-cloud-node-nginx.amazon-ebs.aws_builder -var aws_access_key=${var.aws_access_key} -var aws_secret_key=${var.aws_secret_key} -var aws_session_token=${var.aws_session_token} -var-file=..\\packer\\variables.pkrvars.hcl ..\\packer\\main.pkr.hcl"
  }
}

# OBTENER LA ÚLTIMA AMI CREADA
# Este bloque recupera la AMI más reciente creada por Packer, utilizando un filtro para buscar por nombre.
# Se asegura de que la AMI sea creada antes de intentar recuperarla utilizando `depends_on`.
data "aws_ami" "latest_ami" {
  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  depends_on = [null_resource.packer_ami] 
  most_recent = true                     
  filter {
    name   = "name"                      
    values = ["${var.ami_name}*"]         
  }
  owners = ["self"]                       
}

# OBTENER LA VPC POR DEFECTO (configuración de red virtual)

data "aws_vpc" "default" {
  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  default = true 
}

# Este bloque recupera la VPC predeterminada de AWS, que se utilizará para asociar los recursos creados.
# Se asegura de que la VPC sea creada antes de intentar recuperarla utilizando `depends_on`.
resource "aws_security_group" "web_server_sg" {
  
  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name        = "${var.instance_name}-sg" 
  description = "Grupo de seguridad para la instancia EC2" 
  vpc_id      = length(data.aws_vpc.default) > 0 ? data.aws_vpc.default[0].id : null
  
  ingress {
    description      = "Permitir trafico HTTP"
    from_port        = 80               
    to_port          = 80
    protocol         = "tcp"            
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  ingress {
    description      = "Permitir trafico HTTPS"
    from_port        = 443              
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  ingress {
    description      = "Permitir acceso SSH"
    from_port        = 22               
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  egress {
    from_port   = 0                     
    to_port     = 0
    protocol    = "-1"                 
    cidr_blocks = ["0.0.0.0/0"]        
  }
}

# GENERA EL PAR DE CLAVES Y SE LO PASA A AWS
# Este bloque genera un par de claves SSH automáticamente y registra la clave pública en AWS.
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name 
  public_key = tls_private_key.ssh_key.public_key_openssh
}


# CONFIGURACIÓN DE LA INSTANCIA EC2.
# Este bloque lanza una instancia EC2 en AWS utilizando la AMI recuperada anteriormente.
# Se especifica el tipo de instancia, la clave SSH y el grupo de seguridad asociado.

resource "aws_instance" "web_server" {
  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0

  ami                   = data.aws_ami.latest_ami[0].id 
  instance_type         = var.instance_type          
  key_name              = aws_key_pair.generated_key.key_name              
  vpc_security_group_ids = [aws_security_group.web_server_sg[0].id]

  tags = {
    Name = var.instance_name 
  }
  # Configuración de la red para la instancia EC2.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
  }

  # Provisionador remoto para ejecutar comandos en la instancia EC2.
  provisioner "remote-exec" {
    inline = [
      "echo 'La instancia está configurada correctamente.'" 
    ]
  }
}


#AZURE PROVIDER
# Se especifica la región de Azure donde se desplegarán los recursos.

# Crea un grupo de recursos donde se alojarán los recursos de Azure, como redes y máquinas virtuales.
resource "azurerm_resource_group" "example_rg" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name = var.azure_resource_group_name
  location = var.azure_region          
}

# CONFIGURACIÓN PARA EJECUTAR PACKER Y GENERAR LA IMAGEN EN AZURE
resource "null_resource" "packer_ami_azure" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  depends_on = [azurerm_resource_group.example_rg] 
  provisioner "local-exec" {
    command = "packer build -only=ansible-cloud-node-nginx.azure-arm.azure_builder -var azure_subscription_id=${var.azure_subscription_id} -var azure_client_id=${var.azure_client_id} -var azure_client_secret=${var.azure_client_secret} -var azure_tenant_id=${var.azure_tenant_id} -var-file=../packer/variables.pkrvars.hcl ../packer/main.pkr.hcl"
  }
}
# OBTENER LA ÚLTIMA IMAGEN CREADA EN AZURE
data "azurerm_image" "latest_azure_image" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0

  depends_on          = [null_resource.packer_ami_azure] 
  name                = var.azure_image_name   
  resource_group_name = var.azure_resource_group_name
}

# OBTENER LA RED VIRTUAL POR DEFECTO (configuración de red virtual)
resource "azurerm_virtual_network" "example_vnet" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name                = "${var.azure_instance_name}-vnet"  
  address_space       = ["10.0.0.0/16"]              
  location            = azurerm_resource_group.example_rg[0].location 
  resource_group_name = azurerm_resource_group.example_rg[0].name     
}

resource "azurerm_network_security_group" "example_nsg" {
  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name                = "${var.azure_instance_name}-nsg"
  location            = azurerm_resource_group.example_rg[0].location
  resource_group_name = azurerm_resource_group.example_rg[0].name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Configura una subred dentro de la red virtual creada anteriormente.
# Esta subred se utilizará para alojar la máquina virtual y otros recursos de red.
resource "azurerm_subnet" "example_subnet" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name                 = "${var.azure_instance_name}-subnet"  
  resource_group_name  = azurerm_resource_group.example_rg[0].name 
  virtual_network_name = azurerm_virtual_network.example_vnet[0].name 
  address_prefixes     = ["10.0.1.0/24"]                
  
}

# Configura una IP pública para la máquina virtual.
resource "azurerm_public_ip" "example_public_ip" {
  count               = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name                = "${var.azure_instance_name}-public-ip"
  location            = azurerm_resource_group.example_rg[0].location
  resource_group_name = azurerm_resource_group.example_rg[0].name
  allocation_method   = "Static" 
  sku                 = "Standard" 
}

# Configura una interfaz de red para la máquina virtual.
resource "azurerm_network_interface" "example_nic" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0
  name                = "${var.azure_instance_name}-nic"       
  location            = azurerm_resource_group.example_rg[0].location 
  resource_group_name = azurerm_resource_group.example_rg[0].name      
  
  ip_configuration {
    name                          = "internal"           
    subnet_id                     = azurerm_subnet.example_subnet[0].id 
    private_ip_address_allocation = "Dynamic"            
    public_ip_address_id          = azurerm_public_ip.example_public_ip[0].id 
  }
  
}
# Asocia la interfaz de red con el grupo de seguridad de red.
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example_nic[0].id
  network_security_group_id = azurerm_network_security_group.example_nsg[0].id
}


# Configura la máquina virtual en Azure.
# Esta sección define la configuración de la máquina virtual, incluyendo el tamaño, la imagen y las credenciales de acceso.
resource "azurerm_virtual_machine" "example_vm" {

  count = var.deployment_target == "aws" || var.deployment_target == "both" ? 1 : 0

  name                  = "${var.azure_instance_name}-vm" 
  location              = azurerm_resource_group.example_rg[0].location 
  resource_group_name   = azurerm_resource_group.example_rg[0].name      
  network_interface_ids = [azurerm_network_interface.example_nic[0].id] 
  vm_size               = var.azure_instance_type                    

  # Configuración del disco del sistema operativo.
  storage_os_disk {
    name              = "${var.azure_instance_name}-osdisk"  
    caching           = "ReadWrite"                   
    create_option     = "FromImage"                   
    managed_disk_type = "Standard_LRS"                
  }

  # Configuración para usar la imagen personalizada generada con Packer.
  storage_image_reference {
    id = data.azurerm_image.latest_azure_image[0].id     
  }
  
  os_profile {
    computer_name  = "${var.azure_instance_name}"          
    admin_username = var.azure_admin_username       
    admin_password = var.azure_admin_password       
  }

  os_profile_linux_config {
    disable_password_authentication = false         
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.example_public_ip[0].ip_address
      user        = var.azure_admin_username
      password    = var.azure_admin_password
    }

    inline = [
      "pm2 start /home/ubuntu/app.js"
    ]
  }
}