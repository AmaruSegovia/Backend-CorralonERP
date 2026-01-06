# 🏗️ Corralón ERP - Backend API

Backend RESTful para el Sistema de Gestión Integral de Corralones de Materiales de Construcción.

## 📦 Tecnologías Utilizadas

| Tecnología          | Versión | Descripción                               |
| ------------------- | ------- | ----------------------------------------- |
| **NestJS**          | 11.x    | Framework backend progresivo para Node.js |
| **TypeORM**         | 0.3.x   | ORM para TypeScript/JavaScript            |
| **MySQL**           | 8.x     | Base de datos relacional                  |
| **Passport JWT**    | 4.x     | Autenticación basada en tokens            |
| **Swagger**         | 11.x    | Documentación automática de API           |
| **class-validator** | 0.14.x  | Validación de DTOs                        |
| **bcrypt**          | 6.x     | Hash de contraseñas                       |

## 🧠 Conceptos y Patrones Utilizados

### Arquitectura

- **Modular Architecture**: Cada feature es un módulo independiente (auth, productos, clientes, etc.)
- **Repository Pattern**: Abstracción de acceso a datos via TypeORM
- **DTO Pattern**: Data Transfer Objects para validación de entrada/salida
- **Dependency Injection**: Inyección de dependencias nativa de NestJS

### Seguridad

- **JWT Authentication**: Tokens de acceso con expiración configurable
- **Password Hashing**: Bcrypt con salt rounds automático
- **Guards**: Protección de endpoints con `@UseGuards(AuthGuard('jwt'))`
- **Validation Pipe**: Validación automática de payloads con class-validator

### Base de Datos

- **Entities**: Modelos de TypeORM que mapean tablas MySQL
- **Relations**: Relaciones definidas con decoradores (`@ManyToOne`, `@OneToMany`)
- **UUID Primary Keys**: Identificadores únicos para todas las entidades

## 📁 Estructura del Proyecto

```
server/
├── src/
│   ├── main.ts                 # Bootstrap, Swagger, CORS, ValidationPipe
│   ├── app.module.ts           # Módulo raíz con configuración TypeORM
│   ├── auth/                   # Módulo de autenticación
│   │   ├── entities/           # User, Profile entities
│   │   ├── dto/                # LoginDto, RegisterDto
│   │   ├── auth.service.ts     # Lógica de registro/login
│   │   ├── auth.controller.ts  # Endpoints /auth/*
│   │   ├── auth.module.ts
│   │   └── jwt.strategy.ts     # Estrategia Passport JWT
│   ├── productos/              # Módulo CRUD de productos
│   │   ├── entities/
│   │   ├── dto/
│   │   ├── productos.service.ts
│   │   ├── productos.controller.ts
│   │   └── productos.module.ts
│   ├── clientes/               # Módulo CRUD de clientes
│   │   └── ... (misma estructura)
│   └── categorias/             # Módulo CRUD de categorías
│       └── ... (misma estructura)
├── .env                        # Variables de entorno
└── package.json
```

## 🚀 Quick Start (Para Colaboradores)

Sigue estos pasos para levantar el proyecto localmente:

### Prerequisitos

- [Node.js](https://nodejs.org/) 18+
- [pnpm](https://pnpm.io/es/installation) (`npm install -g pnpm`)
- [MySQL](https://dev.mysql.com/downloads/mysql/) 8+

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/Backend-CorralonERP.git
cd Backend-CorralonERP
```

### 2. Instalar Dependencias

```bash
pnpm install
```

### 3. Configurar Variables de Entorno

Copia el archivo de ejemplo y edítalo con tus credenciales:

```bash
cp .env.example .env
```

Luego abre `.env` y configura las variables de tu base de datos MySQL.

### 4. Configurar Base de Datos

```sql
CREATE DATABASE corralon;
```

> **Nota:** Si tienes scripts de migración en la carpeta `scripts/`, ejecútalos para crear las tablas.

### 5. Ejecutar el Servidor

```bash
# Desarrollo (con hot-reload)
pnpm run start:dev

# Producción
pnpm run build
pnpm run start:prod
```

El servidor estará disponible en:

- **API**: http://localhost:3001
- **Swagger (Documentación)**: http://localhost:3001/api

---

## ☁️ Deploy en Render.com

Este proyecto incluye un archivo `render.yaml` para despliegue automático.

### Pasos:

1. Sube tu repositorio a GitHub.
2. Ve a [Render Dashboard](https://dashboard.render.com/) y crea un nuevo **Blueprint**.
3. Conecta tu repositorio de GitHub.
4. Render detectará automáticamente el archivo `render.yaml`.
5. Configura las **Environment Variables** (DB_HOST, DB_PASSWORD, etc.) en el panel de Render.
6. ¡Listo! Tu API estará desplegada.

> **Importante:** Necesitarás una base de datos MySQL accesible desde internet (ej: [PlanetScale](https://planetscale.com/), [Railway MySQL](https://railway.app/), o un servidor propio).

---

## 📡 API Endpoints

### Auth

| Método | Endpoint         | Descripción       | Auth |
| ------ | ---------------- | ----------------- | ---- |
| POST   | `/auth/register` | Registrar usuario | ❌   |
| POST   | `/auth/login`    | Iniciar sesión    | ❌   |

### Productos

| Método | Endpoint         | Descripción  | Auth |
| ------ | ---------------- | ------------ | ---- |
| GET    | `/productos`     | Listar todos | ❌   |
| GET    | `/productos/:id` | Obtener uno  | ❌   |
| POST   | `/productos`     | Crear        | ✅   |
| PUT    | `/productos/:id` | Actualizar   | ✅   |
| DELETE | `/productos/:id` | Eliminar     | ✅   |

### Clientes

| Método | Endpoint        | Descripción  | Auth |
| ------ | --------------- | ------------ | ---- |
| GET    | `/clientes`     | Listar todos | ❌   |
| GET    | `/clientes/:id` | Obtener uno  | ❌   |
| POST   | `/clientes`     | Crear        | ✅   |
| PUT    | `/clientes/:id` | Actualizar   | ✅   |
| DELETE | `/clientes/:id` | Eliminar     | ✅   |

### Categorías

| Método | Endpoint          | Descripción  | Auth |
| ------ | ----------------- | ------------ | ---- |
| GET    | `/categorias`     | Listar todas | ❌   |
| GET    | `/categorias/:id` | Obtener una  | ❌   |
| POST   | `/categorias`     | Crear        | ✅   |
| PUT    | `/categorias/:id` | Actualizar   | ✅   |
| DELETE | `/categorias/:id` | Eliminar     | ✅   |

## 🖥️ Cliente (Frontend)

El frontend Next.js se encuentra en la carpeta raíz del proyecto.

```bash
# Desde la raíz del proyecto (no server/)
pnpm install
pnpm run dev
```

El cliente estará disponible en: http://localhost:3000

## 📋 Módulos Pendientes

Los siguientes módulos tienen el schema de base de datos listo pero faltan implementar en NestJS:

- [ ] **Proveedores** - CRUD de proveedores
- [ ] **Stock** - Gestión de inventario por depósito
- [ ] **Movimientos** - Registro de entradas/salidas de stock
- [ ] **Presupuestos** - Cotizaciones para clientes
- [ ] **Facturas** - Emisión de facturas A/B/C
- [ ] **Acopios** - Gestión de materiales acopiados
- [ ] **Remitos** - Control de entregas
- [ ] **Órdenes de Compra** - Pedidos a proveedores
- [ ] **Caja** - Movimientos de caja
- [ ] **Bancos** - Cuentas bancarias
- [ ] **Cobros/Pagos** - Gestión de cobranzas y pagos

## 🧪 Testing

```bash
# Tests unitarios
pnpm run test

# Tests e2e
pnpm run test:e2e

# Coverage
pnpm run test:cov
```

## 📖 Documentación Adicional

- Swagger UI: http://localhost:3001/api (cuando el servidor está corriendo)
- Scripts SQL: `../scripts/*.sql`

---

**Desarrollado para Sistema Corralón ERP** 🏗️
