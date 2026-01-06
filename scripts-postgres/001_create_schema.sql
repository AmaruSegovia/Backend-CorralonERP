-- ---------------------------------------------
-- ESQUEMA DE BASE DE DATOS (PostgreSQL version)
-- ---------------------------------------------

-- Habilitar extensión para UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------
-- TIPOS ENUM
-- ---------------------------------------------

CREATE TYPE user_role AS ENUM ('admin', 'vendedor', 'deposito', 'contador');
CREATE TYPE unidad_tipo AS ENUM ('unidad', 'peso', 'longitud', 'area', 'volumen');
CREATE TYPE tipo_persona AS ENUM ('fisica', 'juridica');
CREATE TYPE condicion_iva_cliente AS ENUM ('responsable_inscripto', 'monotributista', 'exento', 'consumidor_final');
CREATE TYPE condicion_iva_proveedor AS ENUM ('responsable_inscripto', 'monotributista', 'exento');
CREATE TYPE lista_precio_tipo AS ENUM ('mayorista', 'minorista', 'contado', 'especial');
CREATE TYPE presupuesto_estado AS ENUM ('borrador', 'enviado', 'aprobado', 'rechazado', 'convertido');
CREATE TYPE acopio_estado AS ENUM ('activo', 'parcial', 'completado', 'vencido');
CREATE TYPE factura_tipo AS ENUM ('A', 'B', 'C', 'NC', 'ND');
CREATE TYPE factura_estado AS ENUM ('borrador', 'emitida', 'pagada', 'anulada');
CREATE TYPE remito_tipo AS ENUM ('salida', 'entrada');
CREATE TYPE remito_estado AS ENUM ('pendiente', 'preparacion', 'en_reparto', 'entregado', 'anulado');
CREATE TYPE orden_compra_estado AS ENUM ('borrador', 'enviada', 'confirmada', 'recibida_parcial', 'recibida', 'anulada');
CREATE TYPE caja_tipo AS ENUM ('efectivo', 'banco');
CREATE TYPE movimiento_tipo AS ENUM ('ingreso', 'egreso');
CREATE TYPE medio_pago AS ENUM ('efectivo', 'transferencia', 'cheque', 'tarjeta_debito', 'tarjeta_credito');
CREATE TYPE cuenta_tipo AS ENUM ('debe', 'haber');
CREATE TYPE movimiento_stock_tipo AS ENUM ('entrada', 'salida', 'ajuste', 'transferencia');
CREATE TYPE serie_lote_tipo AS ENUM ('serie', 'lote');

-- ---------------------------------------------
-- TABLAS DE AUTENTICACION Y USUARIOS
-- ---------------------------------------------

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  nombre_completo VARCHAR(255) NOT NULL,
  rol user_role NOT NULL,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_profiles_users FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------
-- MODULO DE PRODUCTOS E INVENTARIO
-- ---------------------------------------------

CREATE TABLE IF NOT EXISTS categorias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS unidades_medida (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  tipo unidad_tipo,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS productos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  categoria_id UUID,
  unidad_medida_id UUID,
  precio_costo DECIMAL(12,2) DEFAULT 0,
  precio_venta DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  stock_minimo DECIMAL(10,2) DEFAULT 0,
  stock_maximo DECIMAL(10,2),
  usa_serie BOOLEAN DEFAULT false,
  usa_lote BOOLEAN DEFAULT false,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_productos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  CONSTRAINT fk_productos_unidad FOREIGN KEY (unidad_medida_id) REFERENCES unidades_medida(id)
);

CREATE TABLE IF NOT EXISTS depositos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(100) NOT NULL UNIQUE,
  nombre VARCHAR(255) NOT NULL,
  direccion TEXT,
  responsable_id UUID,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_depositos_responsable FOREIGN KEY (responsable_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID,
  deposito_id UUID,
  cantidad_real DECIMAL(10,2) DEFAULT 0,
  cantidad_comprometida DECIMAL(10,2) DEFAULT 0,
  cantidad_disponible DECIMAL(10,2) DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(producto_id, deposito_id),
  CONSTRAINT fk_stock_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS movimientos_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo movimiento_stock_tipo NOT NULL,
  producto_id UUID,
  deposito_origen_id UUID,
  deposito_destino_id UUID,
  cantidad DECIMAL(10,2) NOT NULL,
  motivo TEXT NOT NULL,
  referencia TEXT,
  usuario_id UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
  CONSTRAINT fk_mov_deposito_orig FOREIGN KEY (deposito_origen_id) REFERENCES depositos(id),
  CONSTRAINT fk_mov_deposito_dest FOREIGN KEY (deposito_destino_id) REFERENCES depositos(id),
  CONSTRAINT fk_mov_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS series_lotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID,
  deposito_id UUID,
  tipo serie_lote_tipo,
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

CREATE TABLE IF NOT EXISTS clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_persona tipo_persona,
  razon_social VARCHAR(255) NOT NULL,
  nombre_fantasia VARCHAR(255),
  cuit_cuil VARCHAR(20) UNIQUE,
  condicion_iva condicion_iva_cliente,
  email VARCHAR(255),
  telefono VARCHAR(100),
  direccion TEXT,
  ciudad VARCHAR(100),
  provincia VARCHAR(100) DEFAULT 'Jujuy',
  codigo_postal VARCHAR(20),
  limite_credito DECIMAL(12,2) DEFAULT 0,
  dias_credito INTEGER DEFAULT 0,
  lista_precio_id UUID,
  arquitecto_obra VARCHAR(255),
  observaciones TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS proveedores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  razon_social VARCHAR(255) NOT NULL,
  nombre_fantasia VARCHAR(255),
  cuit VARCHAR(20) UNIQUE,
  condicion_iva condicion_iva_proveedor,
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
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------
-- MODULO DE PRECIOS
-- ---------------------------------------------

CREATE TABLE IF NOT EXISTS listas_precios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  tipo lista_precio_tipo,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS precios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID,
  lista_precio_id UUID,
  precio DECIMAL(12,2) NOT NULL,
  fecha_desde DATE DEFAULT CURRENT_DATE,
  fecha_hasta DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(producto_id, lista_precio_id, fecha_desde),
  CONSTRAINT fk_precios_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  CONSTRAINT fk_precios_lista FOREIGN KEY (lista_precio_id) REFERENCES listas_precios(id) ON DELETE CASCADE
);

-- ---------------------------------------------
-- MODULO DE VENTAS
-- ---------------------------------------------

CREATE TABLE IF NOT EXISTS presupuestos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero VARCHAR(100) NOT NULL UNIQUE,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_vencimiento DATE,
  cliente_id UUID,
  vendedor_id UUID,
  estado presupuesto_estado DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  descuento DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_presupuesto_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_presupuesto_vendedor FOREIGN KEY (vendedor_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS presupuestos_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  presupuesto_id UUID,
  producto_id UUID,
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

CREATE TABLE IF NOT EXISTS acopios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero VARCHAR(100) NOT NULL UNIQUE,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_limite DATE,
  cliente_id UUID,
  vendedor_id UUID,
  estado acopio_estado DEFAULT 'activo',
  monto_total DECIMAL(12,2) NOT NULL,
  monto_pagado DECIMAL(12,2) DEFAULT 0,
  saldo DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_acopio_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_acopio_vendedor FOREIGN KEY (vendedor_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS acopios_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acopio_id UUID,
  producto_id UUID,
  cantidad_total DECIMAL(10,2) NOT NULL,
  cantidad_entregada DECIMAL(10,2) DEFAULT 0,
  cantidad_pendiente DECIMAL(10,2) DEFAULT 0,
  precio_unitario DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_aco_det_acopio FOREIGN KEY (acopio_id) REFERENCES acopios(id) ON DELETE CASCADE,
  CONSTRAINT fk_aco_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE IF NOT EXISTS facturas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo factura_tipo NOT NULL,
  punto_venta VARCHAR(20) NOT NULL,
  numero VARCHAR(100) NOT NULL,
  numero_completo VARCHAR(150),
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_vencimiento DATE,
  cliente_id UUID,
  vendedor_id UUID,
  presupuesto_id UUID,
  acopio_id UUID,
  estado factura_estado DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  descuento DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  saldo DECIMAL(12,2) DEFAULT 0,
  cae VARCHAR(100),
  vencimiento_cae DATE,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(tipo, punto_venta, numero),
  CONSTRAINT fk_fact_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_fact_vendedor FOREIGN KEY (vendedor_id) REFERENCES profiles(id),
  CONSTRAINT fk_fact_presupuesto FOREIGN KEY (presupuesto_id) REFERENCES presupuestos(id),
  CONSTRAINT fk_fact_acopio FOREIGN KEY (acopio_id) REFERENCES acopios(id)
);

CREATE TABLE IF NOT EXISTS facturas_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  factura_id UUID,
  producto_id UUID,
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

CREATE TABLE IF NOT EXISTS remitos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero VARCHAR(100) NOT NULL UNIQUE,
  tipo remito_tipo NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  cliente_id UUID,
  deposito_id UUID,
  factura_id UUID,
  estado remito_estado DEFAULT 'pendiente',
  transporte VARCHAR(255),
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_remito_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_remito_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id),
  CONSTRAINT fk_remito_factura FOREIGN KEY (factura_id) REFERENCES facturas(id)
);

CREATE TABLE IF NOT EXISTS remitos_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  remito_id UUID,
  producto_id UUID,
  cantidad DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rem_det_remito FOREIGN KEY (remito_id) REFERENCES remitos(id) ON DELETE CASCADE,
  CONSTRAINT fk_rem_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- ---------------------------------------------
-- MODULO DE COMPRAS
-- ---------------------------------------------

CREATE TABLE IF NOT EXISTS ordenes_compra (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero VARCHAR(100) NOT NULL UNIQUE,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_entrega_estimada DATE,
  proveedor_id UUID,
  deposito_id UUID,
  usuario_id UUID,
  estado orden_compra_estado DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_oc_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
  CONSTRAINT fk_oc_deposito FOREIGN KEY (deposito_id) REFERENCES depositos(id),
  CONSTRAINT fk_oc_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS ordenes_compra_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  orden_compra_id UUID,
  producto_id UUID,
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

CREATE TABLE IF NOT EXISTS cajas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  tipo caja_tipo NOT NULL,
  numero_cuenta VARCHAR(100),
  banco VARCHAR(255),
  saldo DECIMAL(12,2) DEFAULT 0,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS movimientos_caja (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id UUID,
  tipo movimiento_tipo NOT NULL,
  concepto VARCHAR(255) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  medio_pago medio_pago,
  referencia TEXT,
  usuario_id UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_caja_caja FOREIGN KEY (caja_id) REFERENCES cajas(id),
  CONSTRAINT fk_mov_caja_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS cuenta_corriente_clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id UUID,
  tipo cuenta_tipo NOT NULL,
  concepto VARCHAR(255) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  saldo DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  factura_id UUID,
  movimiento_caja_id UUID,
  usuario_id UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ccc_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_ccc_factura FOREIGN KEY (factura_id) REFERENCES facturas(id),
  CONSTRAINT fk_ccc_mov_caja FOREIGN KEY (movimiento_caja_id) REFERENCES movimientos_caja(id),
  CONSTRAINT fk_ccc_usuario FOREIGN KEY (usuario_id) REFERENCES profiles(id)
);

CREATE TABLE IF NOT EXISTS cuenta_corriente_proveedores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proveedor_id UUID,
  tipo cuenta_tipo NOT NULL,
  concepto VARCHAR(255) NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  saldo DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  orden_compra_id UUID,
  movimiento_caja_id UUID,
  usuario_id UUID,
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

-- ----------------------------------------------
-- FUNCION PARA ACTUALIZAR updated_at
-- ---------------------------------------------

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_productos_updated_at BEFORE UPDATE ON productos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stock_updated_at BEFORE UPDATE ON stock FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_proveedores_updated_at BEFORE UPDATE ON proveedores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_presupuestos_updated_at BEFORE UPDATE ON presupuestos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_acopios_updated_at BEFORE UPDATE ON acopios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_facturas_updated_at BEFORE UPDATE ON facturas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_remitos_updated_at BEFORE UPDATE ON remitos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ordenes_compra_updated_at BEFORE UPDATE ON ordenes_compra FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
