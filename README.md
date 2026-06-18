# 🚀 InnovaTech — Plataforma DevOps

Sistema de microservicios desplegado en **AWS EKS** con CI/CD automatizado mediante GitHub Actions, autoescalado horizontal y orquestación completa en Kubernetes.

---

## 📋 Descripción general

InnovaTech es una plataforma compuesta por tres microservicios (dos backends Spring Boot y un frontend), base de datos MySQL, y un pipeline CI/CD completo que va desde el `git push` hasta el despliegue automático en producción en AWS.

---

## 🏗️ Estructura del proyecto

```
DEVOPS-INNOVATECH-EV3/
├── .github/workflows/
│   ├── ci.yml                        # Pipeline de Integración Continua
│   └── cd.yml                        # Pipeline de Despliegue Continuo
├── back-Ventas_SpringBoot/
│   └── Springboot-API-REST/
├── back-Despachos_SpringBoot/
│   └── Springboot-API-REST-DESPACHO/
├── front_despacho/
├── infra/
│   ├── etapa_2/                      # Infraestructura como código (Terraform)
│   │   ├── main.tf
│   │   ├── network.tf
│   │   ├── security-groups.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── k8s/                          # Manifiestos de Kubernetes
│       ├── autoscaling.yaml
│       ├── backend-despacho.yml
│       ├── backend-venta.yml
│       ├── frontend.yml
│       ├── hpa.yml
│       ├── mysql.yml
│       └── secrets.yml
└── README.md
```

---

## ⚙️ Stack tecnológico

| Capa | Tecnología |
|---|---|
| Backend | Java 17, Spring Boot, Maven |
| Frontend | Node.js, Vite |
| Base de datos | MySQL 8 |
| Orquestación | Kubernetes — AWS EKS |
| Infraestructura | Terraform |
| CI/CD | GitHub Actions |
| Registro de imágenes | Amazon ECR |
| Autoescalado | Horizontal Pod Autoscaler (HPA) |

---

## 🔄 Pipeline CI/CD

### Integración Continua — `ci.yml`

Se ejecuta en cada `push` o `pull request` a las ramas `main` y `develop`.

```
git push
    │
    ├── test-backend-ventas     → Compila y testea con Java 17 + Maven
    ├── test-backend-despachos  → Compila y testea con Java 17 + Maven
    └── test-frontend           → Instala dependencias y verifica build (Node 18)
```

### Despliegue Continuo — `cd.yml`

Se ejecuta automáticamente al hacer `push` a `main`, **solo si el CI pasa**.

```
CI exitoso
    │
    ├── 1. Checkout del repositorio
    ├── 2. Configuración de credenciales AWS
    ├── 3. Login en Amazon ECR
    ├── 4. Build y push de imágenes Docker (etiquetadas con SHA del commit)
    │       ├── innovatech-back-ventas
    │       ├── innovatech-back-despachos
    │       └── innovatech-frontend
    ├── 5. Configuración del contexto EKS
    ├── 6. Aplicación de manifiestos: kubectl apply -f infra/k8s/
    └── 7. Actualización de imágenes en los Deployments
```

---

## ☸️ Infraestructura en Kubernetes

### Manifiestos

| Archivo | Descripción |
|---|---|
| `mysql.yml` | Deployment y Service de MySQL con ConfigMap de inicialización |
| `secrets.yml` | Secret con credenciales de base de datos |
| `backend-venta.yml` | Deployment y Service del microservicio Ventas (puerto 8081) |
| `backend-despacho.yml` | Deployment y Service del microservicio Despachos (puerto 8082), con initContainer que espera disponibilidad de la API de Ventas |
| `frontend.yml` | Deployment y Service tipo LoadBalancer del Frontend (puerto 80) |
| `hpa.yml` / `autoscaling.yaml` | HorizontalPodAutoscalers para Ventas, Despachos y Frontend |

### Dependencia entre servicios

```
MySQL
  └── Ventas (espera MySQL)
        └── Despachos (initContainer espera que Ventas esté disponible)
              └── Frontend
```

> ⚠️ El initContainer de Despachos hace `nc -z innovatech-ventas-svc 8081` hasta que el servicio de Ventas responda. Si Ventas no está healthy, Despachos permanecerá en estado `Init:0/1`.

### Health Checks

Todos los backends exponen endpoints de Spring Boot Actuator:

| Probe | Endpoint |
|---|---|
| `livenessProbe` | `/actuator/health/liveness` |
| `readinessProbe` | `/actuator/health/readiness` |

### Autoescalado (HPA)

| Componente | Min Pods | Max Pods | Métrica |
|---|---|---|---|
| Backend Ventas | 2 | 5 | CPU 50%, Memoria 70% |
| Backend Despachos | 2 | 5 | CPU 50%, Memoria 70% |
| Frontend | 1 | 3 | CPU 60% |
| innovatech-frontend | 1 | 2 | CPU 50% |
| innovatech-ventas | 1 | 3 | CPU 50% |
| innovatech-despachos | 1 | 3 | CPU 50% |

---

## 🔐 Secretos requeridos en GitHub Actions

Configurar en **Settings → Secrets and variables → Actions**:

| Secreto | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access Key de AWS |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de AWS |
| `AWS_SESSION_TOKEN` | Token de sesión (credenciales temporales) |
| `AWS_REGION` | Región de AWS (ej: `us-east-1`) |

---

## 🛠️ Comandos útiles

### Conectarse al cluster EKS
```bash
aws eks update-kubeconfig --region us-east-1 --name innovatech-cluster
```

### Ver estado de los pods
```bash
kubectl get pods
kubectl get pods -A          # Todos los namespaces
kubectl get pods -o wide     # Con info de nodos
```

### Ver logs de un pod
```bash
kubectl logs <nombre-del-pod>
kubectl logs <nombre-del-pod> -c <nombre-del-contenedor>   # Para initContainers
```

### Ver detalle de un pod (útil para diagnosticar errores)
```bash
kubectl describe pod <nombre-del-pod>
```

### Ver estado del autoescalado
```bash
kubectl get hpa
```

### Aplicar cambios manualmente
```bash
kubectl apply -f infra/k8s/
```

---

## 📦 Requisitos previos

- Cuenta de AWS con cluster EKS activo
- AWS CLI configurado localmente
- `kubectl` instalado
- Acceso a Amazon ECR con permisos de push/pull

---

## 👥 Autores

Proyecto desarrollado para la **Evaluación 3 — Módulo DevOps** · InnovaTech

aws eks update-kubeconfig --region us-east-1 --name innovatech-cluster
