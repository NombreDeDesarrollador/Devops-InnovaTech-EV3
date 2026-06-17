# 🚀 InnovaTech - Proyecto DevOps

Plataforma de microservicios para InnovaTech, con CI/CD automatizado, despliegue en Kubernetes (AWS EKS) y orquestación local con Docker Compose.

## 📋 Descripción

Sistema compuesto por dos microservicios backend (Spring Boot), un frontend, base de datos MySQL, integración continua y despliegue continuo mediante GitHub Actions hacia AWS EKS, con autoescalado horizontal (HPA) configurado para cada componente.

## 🏗️ Estructura del proyecto

```
DEVOPS-INNOVATECH-EV3/
├── .github/workflows/
│   ├── ci.yml              # Integración Continua
│   └── cd.yml              # Despliegue Continuo
├── back-Ventas_SpringBoot/
│   └── Springboot-API-REST/
├── back-Despachos_SpringBoot/
│   └── Springboot-API-REST-DESPACHO/
├── front_despacho/
├── infra/
│   ├── etapa_2/
│   └── k8s/
│       ├── autoscaling.yaml
│       ├── backend-despacho.yml
│       ├── backend-venta.yml
│       ├── frontend.yml
│       ├── hpa.yml
│       ├── mysql.yml
│       └── secrets.yml
├── docker-compose.yml
└── README.md
```

## ⚙️ Tecnologías utilizadas

- **Backend:** Java 17, Spring Boot, Maven
- **Frontend:** Node.js, Vite
- **Base de datos:** MySQL 8
- **Contenedores:** Docker, Docker Compose
- **Orquestación:** Kubernetes (AWS EKS)
- **CI/CD:** GitHub Actions
- **Registro de imágenes:** Amazon ECR
- **Autoescalado:** Horizontal Pod Autoscaler (HPA)

## 🔄 Integración Continua (CI)

El workflow `ci.yml` se ejecuta en cada `push` o `pull request` hacia las ramas `main` y `develop`, y realiza:

- **test-backend-ventas:** Compila y testea el microservicio de Ventas con Java 17 y Maven.
- **test-backend-despachos:** Compila y testea el microservicio de Despachos con Java 17 y Maven.
- **test-frontend:** Instala dependencias con Node 18 y verifica la compilación del frontend.

## 🚀 Despliegue Continuo (CD)

El workflow `cd.yml` se ejecuta en `push` a `main` y realiza:

1. Checkout del repositorio.
2. Configuración de credenciales AWS.
3. Login en Amazon ECR.
4. Build y push de las imágenes Docker (Ventas, Despachos y Frontend) a ECR, etiquetadas con el SHA del commit.
5. Configuración del contexto del clúster EKS.
6. Aplicación de manifiestos de Kubernetes (`kubectl apply -f infra/k8s/`).
7. Actualización de las imágenes de los deployments con la nueva versión.

## ☸️ Infraestructura en Kubernetes

| Archivo | Descripción |
|---|---|
| `mysql.yml` | Deployment y Service de MySQL, con ConfigMap de inicialización de base de datos |
| `secrets.yml` | Secret con credenciales de base de datos (root, usuario, password) |
| `backend-venta.yml` | Deployment y Service del microservicio de Ventas |
| `backend-despacho.yml` | Deployment y Service del microservicio de Despachos, con initContainer que espera a la API de Ventas |
| `frontend.yml` | Deployment y Service (LoadBalancer) del Frontend |
| `autoscaling.yaml` / `hpa.yml` | HorizontalPodAutoscalers para Ventas, Despachos y Frontend (CPU y memoria) |

### Health Checks

Cada backend implementa `livenessProbe` y `readinessProbe` sobre los endpoints `/actuator/health/liveness` y `/actuator/health/readiness` (Spring Boot Actuator).

## 🐳 Ejecución local con Docker Compose

```bash
docker compose up -d
```

> ⚠️ Configura el archivo `.env` con la variable `MYSQL_ROOT_PASSWORD` antes de levantar los contenedores.

## 🔐 Variables y Secretos necesarios (GitHub Actions)

| Secreto | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access Key de AWS |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de AWS |
| `AWS_SESSION_TOKEN` | Token de sesión AWS (credenciales temporales) |
| `AWS_REGION` | Región de AWS (ej: us-east-1) |

## 📦 Requisitos previos

- Cuenta de AWS con clúster EKS configurado
- AWS CLI configurado
- kubectl
- Docker y Docker Compose
- Acceso al repositorio Amazon ECR

## 👥 Autores

Proyecto desarrollado para la Evaluación 3 del módulo DevOps - InnovaTech.

aws eks update-kubeconfig --region us-east-1 --name innovatech-cluster

sipo_2