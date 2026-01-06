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

## 🚀 Cómo Ejecutar

### Prerequisitos

- Node.js 18+
- MySQL 8+
- pnpm

### 1. Configurar Base de Datos

```sql
CREATE DATABASE corralon;
```

Ejecutar los scripts de migración:

```bash
# Desde la raíz del proyecto
mysql -u root -p corralon < scripts/001_create_schema_mysql.sql
mysql -u root -p corralon < scripts/006_add_password_column.sql
mysql -u root -p corralon < scripts/004_seed_data_mysql.sql  # Opcional: datos de prueba
```

### 2. Configurar Variables de Entorno

Crear archivo `.env` en la carpeta `server/`:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=root
DB_DATABASE=corralon

JWT_SECRET=tu_clave_secreta_aqui
JWT_EXPIRES_IN=7d
```

### 3. Instalar Dependencias

```bash
cd server
pnpm install
```

### 4. Ejecutar el Servidor

```bash
# Desarrollo (con hot-reload)
pnpm run start:dev

# Producción
pnpm run build
pnpm run start:prod
```

El servidor estará disponible en:

- **API**: http://localhost:3001
- **Swagger**: http://localhost:3001/api

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
