# DevOps InnovaTech - CI/CD & Infraestructura AWS

**Descripción**
Proyecto integral de DevOps que automatiza el aprovisionamiento de infraestructura en AWS y el despliegue de una arquitectura de microservicios. Utiliza Terraform para la infraestructura como código (IaC) y un pipeline de CI/CD en GitHub Actions para construir, almacenar y desplegar contenedores Docker en una instancia EC2.

* **Infraestructura como Código (IaC):** Aprovisionamiento de VPC, EC2, ECR y Security Groups usando Terraform.
* **Microservicios:** Frontend en React/Vite (servido con Nginx) y dos APIs Backend en Java Spring Boot (Ventas y Despachos).
* **Contenedorización:** Imágenes Docker optimizadas con Multi-Stage builds para frontend y backends.
* **Automatización CI/CD:** Pipeline de GitHub Actions que compila, sube imágenes a Amazon ECR y despliega automáticamente usando Docker Compose vía SSH.
* **Gestión de Base de Datos:** Contenedor MySQL versión 8 con volúmenes persistentes y *healthchecks*.

---

### 📦 Estructura del proyecto

```text
DEVOPS-INNOVATECH/
├── .github/
│   └── workflows/
│       └── cicd.yml                # Pipeline automatizado de CI/CD
├── back-Despachos_SpringBoot/      # Microservicio de Despachos
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile                  # Multi-stage build (Java 17)
├── back-Ventas_SpringBoot/         # Microservicio de Ventas
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile                  # Multi-stage build (Java 17)
├── front_despacho/                 # Aplicación Frontend (Node/Vite)
│   ├── src/
│   ├── package.json
│   ├── nginx.conf
│   └── Dockerfile                  # Multi-stage build (Node 18 -> Nginx)
├── infra/etapa_2/                  # Código de Infraestructura (Terraform)
│   ├── compute.tf                  # Definición de instancia EC2
│   ├── network.tf                  # VPC, Subnets y ruteo
│   ├── ecr.tf                      # Repositorios de contenedores
│   ├── security.tf                 # Grupos de seguridad
│   ├── main.tf
│   └── variables.tf
└── docker-compose.yml              # Orquestación de contenedores en el servidor
🚀 Requisitos
Terraform CLI instalado localmente.

Cuenta de AWS con credenciales de acceso (Access Key ID y Secret Access Key).

GitHub Repository con los siguientes Secrets configurados para el entorno:

AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY

AWS_SESSION_TOKEN (Si aplica)

EC2_SSH_KEY (Llave privada PEM para acceder a la instancia)

Docker y Docker Compose (para pruebas en entornos locales).

⚙️ Flujo de uso y despliegue
1. Aprovisionar la Infraestructura (Terraform)
Primero, debes crear los recursos en AWS. Navega a la carpeta de infraestructura e inicializa Terraform:

Bash
cd infra/etapa_2
terraform init
Verifica el plan de ejecución y aplícalo:

Bash
terraform plan
terraform apply -auto-approve
(Nota: Guarda la IP pública de la instancia EC2 generada y actualízala en tu archivo cicd.yml en la variable EC2_HOST).

2. Despliegue automatizado (CI/CD)
El proyecto cuenta con integración y entrega continua. Para desplegar la aplicación, simplemente realiza un push a la rama deploy:

Bash
git add .
git commit -m "feat: actualización de servicios"
git push origin deploy
El pipeline de GitHub Actions se encargará de compilar, empaquetar, subir las imágenes a Amazon ECR y reiniciar los contenedores en la máquina EC2 de forma automática.

🏗️ ¿Qué despliega este proyecto? (Paso a paso)
El proyecto funciona en dos grandes etapas operativas:

1. Infraestructura Base (Terraform):
Se encarga de crear el ecosistema de red (VPC, Subnets), las reglas de seguridad (Security Groups para habilitar los puertos 80, 8081, 8082, 3306 y 22), los repositorios privados en Amazon ECR para almacenar las imágenes Docker, y finalmente una máquina virtual Amazon EC2 (Ubuntu/Amazon Linux) que actuará como servidor host.

2. Despliegue de Aplicación (GitHub Actions + Docker Compose):
Cuando se detectan cambios, el workflow cicd.yml ejecuta lo siguiente:

Build & Push: Lee los Dockerfile de cada carpeta. Usa Maven para compilar los .jar de Spring Boot y Node para compilar los estáticos del Frontend. Luego, crea imágenes mínimas basadas en Alpine/Nginx y las sube a los repositorios de Amazon ECR.

Transferencia: Copia el archivo docker-compose.yml desde el repositorio hacia la instancia EC2 usando SCP.

Despliegue unificado: Se conecta por SSH a la EC2, inyecta las variables de entorno de base de datos dinámicamente (.env), se autentica con Amazon ECR, descarga (pull) las imágenes más recientes y levanta los servicios (docker compose up -d).

Servicios levantados en el EC2:

Frontend: Expuesto en el puerto 80.

Backend Ventas: Expuesto en el puerto 8081.

Backend Despachos: Expuesto en el puerto 8082.

Base de datos: MySQL 8 expuesto en el puerto 3306, aislado en su propia red interna y con almacenamiento persistente.

📌 Mejores prácticas incluidas
Modularización de IaC: Separación lógica de recursos por archivo (network, compute, security, ecs) para facilitar el mantenimiento.

Automatización de inicialización: Uso de user_data para evitar configuraciones manuales por SSH en el servidor de base de datos.

Gestión de secretos y estados: Archivo .gitignore configurado rigurosamente para prevenir la subida de archivos .env y el estado sensible de Terraform (.tfstate).

Dependencias de servicios: Configuración de depends_on y healthcheck en Docker Compose y Terraform para asegurar el orden correcto de inicialización de los servicios.

🔧 Cómo extender este proyecto
Implementar un Application Load Balancer (ALB) frente al clúster ECS para balancear tráfico y habilitar HTTPS.

Migrar la Base de Datos desde una instancia EC2 autogestionada hacia un servicio administrado como Amazon RDS.

Automatizar la construcción y el push de imágenes de Docker hacia ECR utilizando pipelines CI/CD mediante GitHub Actions.

Configurar un backend remoto para Terraform (como un bucket S3 y DynamoDB) para el bloqueo y gestión compartida del estado.