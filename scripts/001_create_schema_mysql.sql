-- ---------------------------------------------
-- ESQUEMA DE BASE DE DATOS (MySQL version)
-- ---------------------------------------------

-- ---------------------------------------------
-- TABLAS DE AUTENTICACION Y USUARIOS
-- ---------------------------------------------

-- Tabla base de usuarios (Reemplaza auth.users de Supabase)
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de perfiles de usuario
CREATE TABLE IF NOT EXISTS profiles (
  id VARCHAR(36) PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  nombre_completo VARCHAR(255) NOT NULL,
  rol ENUM('admin', 'vendedor', 'deposito', 'contador') NOT NULL,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_profiles_users FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------
-- MODULO DE PRODUCTOS E INVENTARIO
-- ---------------------------------------------

-- Categorias de productos
CREATE TABLE IF NOT EXISTS categorias (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Unidades de medida
CREATE TABLE IF NOT EXISTS unidades_medida (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  codigo VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('unidad', 'peso', 'longitud', 'area', 'volumen'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Productos
CREATE TABLE IF NOT EXISTS productos (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  codigo VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  categoria_id VARCHAR(36),
  unidad_medida_id VARCHAR(36),
  precio_costo DECIMAL(12,2) DEFAULT 0,
  precio_venta DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  stock_minimo DECIMAL(10,2) DEFAULT 0,
  stock_maximo DECIMAL(10,2),
  usa_serie BOOLEAN DEFAULT false,
  usa_lote BOOLEAN DEFAULT false,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_productos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  CONSTRAINT fk_productos_unidad FOREIGN KEY (unidad_medida_id) REFERENCES unidades_medida(id)
);

-- Depositos
CREATE TABLE IF NOT EXISTS depositos (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  codigo VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(255) NOT NULL,
  direccion TEXT,
  responsable_id VARCHAR(36),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_depositos_responsable FOREIGN KEY (responsable_id) REFERENCES profiles(id)
);

-- Stock por deposito
CREATE TABLE IF NOT EXISTS stock (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  producto_id VARCHAR(36),
  deposito_id VARCHAR(36),
  cantidad_real DECIMAL(10,2) DEFAULT 0,
  cantidad_comprometida DECIMAL(10,2) DEFAULT 0,
  cantidad_disponible DECIMAL(10,2) AS (cantidad_real - cantidad_comprometida) STORED,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE(producto_id, deposito_id),
  CONSTRAINT fk_stock_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id) ON DELETE CASCADE
);

-- Movimientos de stock
CREATE TABLE IF NOT EXISTS movimientos_stock (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  tipo ENUM('entrada', 'salida', 'ajuste', 'transferencia') NOT NULL,
  producto_id VARCHAR(36),
  deposito_origen_id VARCHAR(36),
  deposito_destino_id VARCHAR(36),
  cantidad DECIMAL(10,2) NOT NULL,
  motivo TEXT NOT NULL,
  referencia TEXT,
  usuario_id VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
  CONSTRAINT fk_mov_deposito_orig FOREIGN KEY (deposito_origen_id) REFERENCES depositos(id),
  CONSTRAINT fk_mov_deposito_dest FOREIGN KEY (deposito_destino_id) REFERENCES depositos(id),
  CONSTRAINT fk_mov_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

-- Series y lotes
CREATE TABLE IF NOT EXISTS series_lotes (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  producto_id VARCHAR(36),
  deposito_id VARCHAR(36),
  tipo ENUM('serie', 'lote'),
  numero VARCHAR(255) NOT NULL,
  cantidad DECIMAL(10,2),
  fecha_vencimiento DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(producto_id, numero),
  CONSTRAINT fk_series_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  CONSTRAINT fk_series_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id)
);

-- ---------------------------------------------
-- MODULO DE CLIENTES Y PROVEEDORES
-- ---------------------------------------------

-- Clientes
CREATE TABLE IF NOT EXISTS clientes (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  tipo_persona ENUM('fisica', 'juridica'),
  razon_social VARCHAR(255) NOT NULL,
  nombre_fantasia VARCHAR(255),
  cuit_cuil VARCHAR(20) UNIQUE,
  condicion_iva ENUM('responsable_inscripto', 'monotributista', 'exento', 'consumidor_final'),
  email VARCHAR(255),
  telefono VARCHAR(100),
  direccion TEXT,
  ciudad VARCHAR(100),
  provincia VARCHAR(100) DEFAULT 'Jujuy',
  codigo_postal VARCHAR(20),
  limite_credito DECIMAL(12,2) DEFAULT 0,
  dias_credito INTEGER DEFAULT 0,
  lista_precio_id VARCHAR(36),
  arquitecto_obra VARCHAR(255),
  observaciones TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Proveedores
CREATE TABLE IF NOT EXISTS proveedores (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  razon_social VARCHAR(255) NOT NULL,
  nombre_fantasia VARCHAR(255),
  cuit VARCHAR(20) UNIQUE,
  condicion_iva ENUM('responsable_inscripto', 'monotributista', 'exento'),
  email VARCHAR(255),
  telefono VARCHAR(100),
  direccion TEXT,
  ciudad VARCHAR(100),
  provincia VARCHAR(100),
  codigo_postal VARCHAR(20),
  dias_pago INTEGER DEFAULT 0,
  observaciones TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ---------------------------------------------
-- MODULO DE PRECIOS
-- ---------------------------------------------

-- Listas de precios
CREATE TABLE IF NOT EXISTS listas_precios (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  tipo ENUM('mayorista', 'minorista', 'contado', 'especial'),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Precios por lista
CREATE TABLE IF NOT EXISTS precios (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  producto_id VARCHAR(36),
  lista_precio_id VARCHAR(36),
  precio DECIMAL(12,2) NOT NULL,
  fecha_desde DATE DEFAULT (CURRENT_DATE),
  fecha_hasta DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(producto_id, lista_precio_id, fecha_desde),
  CONSTRAINT fk_precios_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  CONSTRAINT fk_precios_lista FOREIGN KEY (lista_precio_id) REFERENCES listas_precios(id) ON DELETE CASCADE
);

-- ---------------------------------------------
-- MODULO DE VENTAS
-- ---------------------------------------------

-- Presupuestos/Cotizaciones
CREATE TABLE IF NOT EXISTS presupuestos (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  numero VARCHAR(100) NOT NULL UNIQUE,
  fecha DATE DEFAULT (CURRENT_DATE),
  fecha_vencimiento DATE,
  cliente_id VARCHAR(36),
  vendedor_id VARCHAR(36),
  estado ENUM('borrador', 'enviado', 'aprobado', 'rechazado', 'convertido') DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  descuento DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_presupuesto_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_presupuesto_vendedor FOREIGN KEY (vendedor_id) REFERENCES profiles(id)
);

-- Detalle de presupuestos
CREATE TABLE IF NOT EXISTS presupuestos_detalle (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  presupuesto_id VARCHAR(36),
  producto_id VARCHAR(36),
  descripcion VARCHAR(255) NOT NULL,
  cantidad DECIMAL(10,2) NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  descuento DECIMAL(5,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pres_det_presupuesto FOREIGN KEY (presupuesto_id) REFERENCES presupuestos(id) ON DELETE CASCADE,
  CONSTRAINT fk_pres_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Acopios
CREATE TABLE IF NOT EXISTS acopios (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  numero VARCHAR(100) NOT NULL UNIQUE,
  fecha DATE DEFAULT (CURRENT_DATE),
  fecha_limite DATE,
  cliente_id VARCHAR(36),
  vendedor_id VARCHAR(36),
  estado ENUM('activo', 'parcial', 'completado', 'vencido') DEFAULT 'activo',
  monto_total DECIMAL(12,2) NOT NULL,
  monto_pagado DECIMAL(12,2) DEFAULT 0,
  saldo DECIMAL(12,2) AS (monto_total - monto_pagado) STORED,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_acopio_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_acopio_vendedor FOREIGN KEY (vendedor_id) REFERENCES profiles(id)
);

-- Detalle de acopios
CREATE TABLE IF NOT EXISTS acopios_detalle (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  acopio_id VARCHAR(36),
  producto_id VARCHAR(36),
  cantidad_total DECIMAL(10,2) NOT NULL,
  cantidad_entregada DECIMAL(10,2) DEFAULT 0,
  cantidad_pendiente DECIMAL(10,2) AS (cantidad_total - cantidad_entregada) STORED,
  precio_unitario DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_aco_det_acopio FOREIGN KEY (acopio_id) REFERENCES acopios(id) ON DELETE CASCADE,
  CONSTRAINT fk_aco_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Facturas
CREATE TABLE IF NOT EXISTS facturas (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  tipo ENUM('A', 'B', 'C', 'NC', 'ND') NOT NULL,
  punto_venta VARCHAR(20) NOT NULL,
  numero VARCHAR(100) NOT NULL,
  numero_completo VARCHAR(150) AS (CONCAT(tipo, ' ', punto_venta, '-', numero)) STORED,
  fecha DATE DEFAULT (CURRENT_DATE),
  fecha_vencimiento DATE,
  cliente_id VARCHAR(36),
  vendedor_id VARCHAR(36),
  presupuesto_id VARCHAR(36),
  acopio_id VARCHAR(36),
  estado ENUM('borrador', 'emitida', 'pagada', 'anulada') DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  descuento DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  saldo DECIMAL(12,2) DEFAULT 0,
  cae VARCHAR(100),
  vencimiento_cae DATE,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE(tipo, punto_venta, numero),
  CONSTRAINT fk_fact_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_fact_vendedor FOREIGN KEY (vendedor_id) REFERENCES profiles(id),
  CONSTRAINT fk_fact_presupuesto FOREIGN KEY (presupuesto_id) REFERENCES presupuestos(id),
  CONSTRAINT fk_fact_acopio FOREIGN KEY (acopio_id) REFERENCES acopios(id)
);

-- Detalle de facturas
CREATE TABLE IF NOT EXISTS facturas_detalle (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  factura_id VARCHAR(36),
  producto_id VARCHAR(36),
  descripcion VARCHAR(255) NOT NULL,
  cantidad DECIMAL(10,2) NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  descuento DECIMAL(5,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_fact_det_factura FOREIGN KEY (factura_id) REFERENCES facturas(id) ON DELETE CASCADE,
  CONSTRAINT fk_fact_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Remitos
CREATE TABLE IF NOT EXISTS remitos (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  numero VARCHAR(100) NOT NULL UNIQUE,
  tipo ENUM('salida', 'entrada') NOT NULL,
  fecha DATE DEFAULT (CURRENT_DATE),
  cliente_id VARCHAR(36),
  deposito_id VARCHAR(36),
  factura_id VARCHAR(36),
  estado ENUM('pendiente', 'preparacion', 'en_reparto', 'entregado', 'anulado') DEFAULT 'pendiente',
  transporte VARCHAR(255),
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_remito_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_remito_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id),
  CONSTRAINT fk_remito_factura FOREIGN KEY (factura_id) REFERENCES facturas(id)
);

-- Detalle de remitos
CREATE TABLE IF NOT EXISTS remitos_detalle (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  remito_id VARCHAR(36),
  producto_id VARCHAR(36),
  cantidad DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rem_det_remito FOREIGN KEY (remito_id) REFERENCES remitos(id) ON DELETE CASCADE,
  CONSTRAINT fk_rem_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- ---------------------------------------------
-- MODULO DE COMPRAS
-- ---------------------------------------------

-- Ordenes de compra
CREATE TABLE IF NOT EXISTS ordenes_compra (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  numero VARCHAR(100) NOT NULL UNIQUE,
  fecha DATE DEFAULT (CURRENT_DATE),
  fecha_entrega_estimada DATE,
  proveedor_id VARCHAR(36),
  deposito_id VARCHAR(36),
  usuario_id VARCHAR(36),
  estado ENUM('borrador', 'enviada', 'confirmada', 'recibida_parcial', 'recibida', 'anulada') DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_oc_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
  CONSTRAINT fk_oc_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id),
  CONSTRAINT fk_oc_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

-- Detalle de ordenes de compra
CREATE TABLE IF NOT EXISTS ordenes_compra_detalle (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  orden_compra_id VARCHAR(36),
  producto_id VARCHAR(36),
  cantidad_pedida DECIMAL(10,2) NOT NULL,
  cantidad_recibida DECIMAL(10,2) DEFAULT 0,
  precio_unitario DECIMAL(12,2) NOT NULL,
  iva DECIMAL(5,2) DEFAULT 21.00,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_oc_det_pedido FOREIGN KEY (orden_compra_id) REFERENCES ordenes_compra(id) ON DELETE CASCADE,
  CONSTRAINT fk_oc_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- ----------------------------------------------
-- MODULO DE TESORERIA Y FINANZAS
-- ---------------------------------------------

-- Cajas
CREATE TABLE IF NOT EXISTS cajas (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  nombre VARCHAR(255) NOT NULL,
  tipo ENUM('efectivo', 'banco') NOT NULL,
  numero_cuenta VARCHAR(100),
  banco VARCHAR(255),
  saldo DECIMAL(12,2) DEFAULT 0,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Movimientos de caja
CREATE TABLE IF NOT EXISTS movimientos_caja (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  caja_id VARCHAR(36),
  tipo ENUM('ingreso', 'egreso') NOT NULL,
  concepto VARCHAR(255) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT (CURRENT_DATE),
  medio_pago ENUM('efectivo', 'transferencia', 'cheque', 'tarjeta_debito', 'tarjeta_credito'),
  referencia TEXT,
  usuario_id VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_caja_caja FOREIGN KEY (caja_id) REFERENCES cajas(id),
  CONSTRAINT fk_mov_caja_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

-- Cuenta corriente de clientes
CREATE TABLE IF NOT EXISTS cuenta_corriente_clientes (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  cliente_id VARCHAR(36),
  tipo ENUM('debe', 'haber') NOT NULL,
  concepto VARCHAR(255) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  saldo DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT (CURRENT_DATE),
  factura_id VARCHAR(36),
  movimiento_caja_id VARCHAR(36),
  usuario_id VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ccc_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_ccc_factura FOREIGN KEY (factura_id) REFERENCES facturas(id),
  CONSTRAINT fk_ccc_mov_caja FOREIGN KEY (movimiento_caja_id) REFERENCES movimientos_caja(id),
  CONSTRAINT fk_ccc_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

-- Cuenta corriente de proveedores
CREATE TABLE IF NOT EXISTS cuenta_corriente_proveedores (
  id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  proveedor_id VARCHAR(36),
  tipo ENUM('debe', 'haber') NOT NULL,
  concepto VARCHAR(255) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  saldo DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT (CURRENT_DATE),
  orden_compra_id VARCHAR(36),
  movimiento_caja_id VARCHAR(36),
  usuario_id VARCHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ccp_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
  CONSTRAINT fk_ccp_oc FOREIGN KEY (orden_compra_id) REFERENCES ordenes_compra(id),
  CONSTRAINT fk_ccp_mov_caja FOREIGN KEY (movimiento_caja_id) REFERENCES movimientos_caja(id),
  CONSTRAINT fk_ccp_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

-- ----------------------------------------------
-- INDICES PARA OPTIMIZACION
-- ---------------------------------------------

CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_stock_producto ON stock(producto_id);
CREATE INDEX idx_stock_deposito ON stock(deposito_id);
CREATE INDEX idx_clientes_cuit ON clientes(cuit_cuil);
CREATE INDEX idx_facturas_cliente ON facturas(cliente_id);
CREATE INDEX idx_facturas_fecha ON facturas(fecha);
CREATE INDEX idx_facturas_estado ON facturas(estado);
CREATE INDEX idx_movimientos_stock_producto ON movimientos_stock(producto_id);
CREATE INDEX idx_cuenta_corriente_clientes_cliente ON cuenta_corriente_clientes(cliente_id);
CREATE INDEX idx_cuenta_corriente_proveedores_proveedor ON cuenta_corriente_proveedores(proveedor_id);
