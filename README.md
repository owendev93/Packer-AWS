<!--# Automatización de Imágenes Multinube con Packer-->
<h1 align="center"> 🧩 Automatización de Imágenes Multinube (Multi-cloud Image Automation) con Packer </h1>

<!--![Automatización WordPress con Vagrant y Puppet](./img.png)-->

>Este repositorio contiene diversas versiones de un proyecto de automatización de imágenes para AWS y Azure utilizando Packer. El objetivo de este proyecto es crear imágenes de máquina listas para el despliegue de aplicaciones web (como Node.js con Nginx) en varias nubes, promoviendo la eficiencia y la consistencia en el proceso de aprovisionamiento.

## Descripción.
>La automatización multinube permite crear imágenes de máquinas virtuales personalizadas que pueden ser desplegadas de manera coherente a través de diferentes proveedores de nube. En este repositorio, cada versión de la plantilla de Packer está configurada para aprovisionar y configurar una aplicación Node.js sobre un servidor Nginx, listo para ser lanzado en AWS y Azure con instancias de tipo t2.micro (en AWS). A lo largo del repositorio, podrás encontrar diferentes versiones de plantillas que exploran diversas configuraciones y mejoras para optimizar la construcción y despliegue en estos entornos multinube.

## Características del Proyecto.
- **Automatización:** Uso de Packer para generar imágenes personalizadas.

- **Multinube:** Plantillas preparadas para AWS y Azure.

- **Escalabilidad:** Despliegue de una aplicación web de Node.js sobre Nginx.

- **Versionado:** Este repositorio contiene distintas versiones del proyecto que muestran mejoras y nuevas funcionalidades.

## Versiones.
- **packer-aws:** Este template de Packer crea una imagen AMI personalizada en AWS basada en la última versión de Ubuntu 22.04, utilizando una instancia temporal t2.micro en la región que se defina. El proceso se autentica por defecto (usando credenciales locales) y permite conectarse vía SSH como usuario ubuntu. La imagen resultante incluye un nombre único con timestamp.
- **packer-aws-ami:**
- **packer-aws-ami-terraform:**