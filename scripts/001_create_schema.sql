-- ---------------------------------------------
-- ESQUEMA DE BASE DE DATOS
-- ---------------------------------------------

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------
-- TABLAS DE AUTENTICACION Y USUARIOS
-- ---------------------------------------------

-- Tabla de perfiles de usuario (extiende auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  nombre_completo TEXT NOT NULL,
  rol TEXT NOT NULL CHECK (rol IN ('admin', 'vendedor', 'deposito', 'contador')),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------
-- MODULO DE PRODUCTOS E INVENTARIO
-- ---------------------------------------------

-- Categorias de productos
CREATE TABLE IF NOT EXISTS public.categorias (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unidades de medida
CREATE TABLE IF NOT EXISTS public.unidades_medida (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  tipo TEXT CHECK (tipo IN ('unidad', 'peso', 'longitud', 'area', 'volumen')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Productos
CREATE TABLE IF NOT EXISTS public.productos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  categoria_id UUID REFERENCES public.categorias(id),
  unidad_medida_id UUID REFERENCES public.unidades_medida(id),
  precio_costo DECIMAL(12,2) DEFAULT 0,
  precio_venta DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  stock_minimo DECIMAL(10,2) DEFAULT 0,
  stock_maximo DECIMAL(10,2),
  usa_serie BOOLEAN DEFAULT false,
  usa_lote BOOLEAN DEFAULT false,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Depositos
CREATE TABLE IF NOT EXISTS public.depositos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  direccion TEXT,
  responsable_id UUID REFERENCES public.profiles(id),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stock por deposito
CREATE TABLE IF NOT EXISTS public.stock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producto_id UUID REFERENCES public.productos(id) ON DELETE CASCADE,
  deposito_id UUID REFERENCES public.depositos(id) ON DELETE CASCADE,
  cantidad_real DECIMAL(10,2) DEFAULT 0,
  cantidad_comprometida DECIMAL(10,2) DEFAULT 0,
  cantidad_disponible DECIMAL(10,2) GENERATED ALWAYS AS (cantidad_real - cantidad_comprometida) STORED,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(producto_id, deposito_id)
);

-- Movimientos de stock
CREATE TABLE IF NOT EXISTS public.movimientos_stock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT NOT NULL CHECK (tipo IN ('entrada', 'salida', 'ajuste', 'transferencia')),
  producto_id UUID REFERENCES public.productos(id),
  deposito_origen_id UUID REFERENCES public.depositos(id),
  deposito_destino_id UUID REFERENCES public.depositos(id),
  cantidad DECIMAL(10,2) NOT NULL,
  motivo TEXT NOT NULL,
  referencia TEXT,
  usuario_id UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Series y lotes
CREATE TABLE IF NOT EXISTS public.series_lotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producto_id UUID REFERENCES public.productos(id) ON DELETE CASCADE,
  deposito_id UUID REFERENCES public.depositos(id),
  tipo TEXT CHECK (tipo IN ('serie', 'lote')),
  numero TEXT NOT NULL,
  cantidad DECIMAL(10,2),
  fecha_vencimiento DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(producto_id, numero)
);

-- ---------------------------------------------
-- MODULO DE CLIENTES Y PROVEEDORES
-- ---------------------------------------------

-- Clientes
CREATE TABLE IF NOT EXISTS public.clientes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo_persona TEXT CHECK (tipo_persona IN ('fisica', 'juridica')),
  razon_social TEXT NOT NULL,
  nombre_fantasia TEXT,
  cuit_cuil TEXT UNIQUE,
  condicion_iva TEXT CHECK (condicion_iva IN ('responsable_inscripto', 'monotributista', 'exento', 'consumidor_final')),
  email TEXT,
  telefono TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT DEFAULT 'Jujuy',
  codigo_postal TEXT,
  limite_credito DECIMAL(12,2) DEFAULT 0,
  dias_credito INTEGER DEFAULT 0,
  lista_precio_id UUID,
  arquitecto_obra TEXT,
  observaciones TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Proveedores
CREATE TABLE IF NOT EXISTS public.proveedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  razon_social TEXT NOT NULL,
  nombre_fantasia TEXT,
  cuit TEXT UNIQUE,
  condicion_iva TEXT CHECK (condicion_iva IN ('responsable_inscripto', 'monotributista', 'exento')),
  email TEXT,
  telefono TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  dias_pago INTEGER DEFAULT 0,
  observaciones TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------
-- MODULO DE PRECIOS
-- ---------------------------------------------

-- Listas de precios
CREATE TABLE IF NOT EXISTS public.listas_precios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  tipo TEXT CHECK (tipo IN ('mayorista', 'minorista', 'contado', 'especial')),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Precios por lista
CREATE TABLE IF NOT EXISTS public.precios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producto_id UUID REFERENCES public.productos(id) ON DELETE CASCADE,
  lista_precio_id UUID REFERENCES public.listas_precios(id) ON DELETE CASCADE,
  precio DECIMAL(12,2) NOT NULL,
  fecha_desde DATE DEFAULT CURRENT_DATE,
  fecha_hasta DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(producto_id, lista_precio_id, fecha_desde)
);

-- ---------------------------------------------
-- MODULO DE VENTAS
-- ---------------------------------------------

-- Presupuestos/Cotizaciones
CREATE TABLE IF NOT EXISTS public.presupuestos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero TEXT NOT NULL UNIQUE,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_vencimiento DATE,
  cliente_id UUID REFERENCES public.clientes(id),
  vendedor_id UUID REFERENCES public.profiles(id),
  estado TEXT CHECK (estado IN ('borrador', 'enviado', 'aprobado', 'rechazado', 'convertido')) DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  descuento DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Detalle de presupuestos
CREATE TABLE IF NOT EXISTS public.presupuestos_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  presupuesto_id UUID REFERENCES public.presupuestos(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES public.productos(id),
  descripcion TEXT NOT NULL,
  cantidad DECIMAL(10,2) NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  descuento DECIMAL(5,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Acopios
CREATE TABLE IF NOT EXISTS public.acopios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero TEXT NOT NULL UNIQUE,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_limite DATE,
  cliente_id UUID REFERENCES public.clientes(id),
  vendedor_id UUID REFERENCES public.profiles(id),
  estado TEXT CHECK (estado IN ('activo', 'parcial', 'completado', 'vencido')) DEFAULT 'activo',
  monto_total DECIMAL(12,2) NOT NULL,
  monto_pagado DECIMAL(12,2) DEFAULT 0,
  saldo DECIMAL(12,2) GENERATED ALWAYS AS (monto_total - monto_pagado) STORED,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Detalle de acopios
CREATE TABLE IF NOT EXISTS public.acopios_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  acopio_id UUID REFERENCES public.acopios(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES public.productos(id),
  cantidad_total DECIMAL(10,2) NOT NULL,
  cantidad_entregada DECIMAL(10,2) DEFAULT 0,
  cantidad_pendiente DECIMAL(10,2) GENERATED ALWAYS AS (cantidad_total - cantidad_entregada) STORED,
  precio_unitario DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Facturas
CREATE TABLE IF NOT EXISTS public.facturas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT CHECK (tipo IN ('A', 'B', 'C', 'NC', 'ND')) NOT NULL,
  punto_venta TEXT NOT NULL,
  numero TEXT NOT NULL,
  numero_completo TEXT GENERATED ALWAYS AS (tipo || ' ' || punto_venta || '-' || numero) STORED,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_vencimiento DATE,
  cliente_id UUID REFERENCES public.clientes(id),
  vendedor_id UUID REFERENCES public.profiles(id),
  presupuesto_id UUID REFERENCES public.presupuestos(id),
  acopio_id UUID REFERENCES public.acopios(id),
  estado TEXT CHECK (estado IN ('borrador', 'emitida', 'pagada', 'anulada')) DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  descuento DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  saldo DECIMAL(12,2) DEFAULT 0,
  cae TEXT,
  vencimiento_cae DATE,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tipo, punto_venta, numero)
);

-- Detalle de facturas
CREATE TABLE IF NOT EXISTS public.facturas_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  factura_id UUID REFERENCES public.facturas(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES public.productos(id),
  descripcion TEXT NOT NULL,
  cantidad DECIMAL(10,2) NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  descuento DECIMAL(5,2) DEFAULT 0,
  iva DECIMAL(5,2) DEFAULT 21.00,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Remitos
CREATE TABLE IF NOT EXISTS public.remitos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero TEXT NOT NULL UNIQUE,
  tipo TEXT CHECK (tipo IN ('salida', 'entrada')) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  cliente_id UUID REFERENCES public.clientes(id),
  deposito_id UUID REFERENCES public.depositos(id),
  factura_id UUID REFERENCES public.facturas(id),
  estado TEXT CHECK (estado IN ('pendiente', 'preparacion', 'en_reparto', 'entregado', 'anulado')) DEFAULT 'pendiente',
  transporte TEXT,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Detalle de remitos
CREATE TABLE IF NOT EXISTS public.remitos_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  remito_id UUID REFERENCES public.remitos(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES public.productos(id),
  cantidad DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------
-- MODULO DE COMPRAS
-- ---------------------------------------------

-- Ordenes de compra
CREATE TABLE IF NOT EXISTS public.ordenes_compra (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero TEXT NOT NULL UNIQUE,
  fecha DATE DEFAULT CURRENT_DATE,
  fecha_entrega_estimada DATE,
  proveedor_id UUID REFERENCES public.proveedores(id),
  deposito_id UUID REFERENCES public.depositos(id),
  usuario_id UUID REFERENCES public.profiles(id),
  estado TEXT CHECK (estado IN ('borrador', 'enviada', 'confirmada', 'recibida_parcial', 'recibida', 'anulada')) DEFAULT 'borrador',
  subtotal DECIMAL(12,2) DEFAULT 0,
  iva DECIMAL(12,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Detalle de ordenes de compra
CREATE TABLE IF NOT EXISTS public.ordenes_compra_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  orden_compra_id UUID REFERENCES public.ordenes_compra(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES public.productos(id),
  cantidad_pedida DECIMAL(10,2) NOT NULL,
  cantidad_recibida DECIMAL(10,2) DEFAULT 0,
  precio_unitario DECIMAL(12,2) NOT NULL,
  iva DECIMAL(5,2) DEFAULT 21.00,
  subtotal DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------
-- MODULO DE TESORERIA Y FINANZAS
-- ---------------------------------------------

-- Cajas
CREATE TABLE IF NOT EXISTS public.cajas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  tipo TEXT CHECK (tipo IN ('efectivo', 'banco')) NOT NULL,
  numero_cuenta TEXT,
  banco TEXT,
  saldo DECIMAL(12,2) DEFAULT 0,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Movimientos de caja
CREATE TABLE IF NOT EXISTS public.movimientos_caja (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caja_id UUID REFERENCES public.cajas(id),
  tipo TEXT CHECK (tipo IN ('ingreso', 'egreso')) NOT NULL,
  concepto TEXT NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  medio_pago TEXT CHECK (medio_pago IN ('efectivo', 'transferencia', 'cheque', 'tarjeta_debito', 'tarjeta_credito')),
  referencia TEXT,
  usuario_id UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cuenta corriente de clientes
CREATE TABLE IF NOT EXISTS public.cuenta_corriente_clientes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id),
  tipo TEXT CHECK (tipo IN ('debe', 'haber')) NOT NULL,
  concepto TEXT NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  saldo DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  factura_id UUID REFERENCES public.facturas(id),
  movimiento_caja_id UUID REFERENCES public.movimientos_caja(id),
  usuario_id UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cuenta corriente de proveedores
CREATE TABLE IF NOT EXISTS public.cuenta_corriente_proveedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  proveedor_id UUID REFERENCES public.proveedores(id),
  tipo TEXT CHECK (tipo IN ('debe', 'haber')) NOT NULL,
  concepto TEXT NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  saldo DECIMAL(12,2) NOT NULL,
  fecha DATE DEFAULT CURRENT_DATE,
  orden_compra_id UUID REFERENCES public.ordenes_compra(id),
  movimiento_caja_id UUID REFERENCES public.movimientos_caja(id),
  usuario_id UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------
-- INDICES PARA OPTIMIZACION
-- ---------------------------------------------

CREATE INDEX idx_productos_codigo ON public.productos(codigo);
CREATE INDEX idx_productos_categoria ON public.productos(categoria_id);
CREATE INDEX idx_stock_producto ON public.stock(producto_id);
CREATE INDEX idx_stock_deposito ON public.stock(deposito_id);
CREATE INDEX idx_clientes_cuit ON public.clientes(cuit_cuil);
CREATE INDEX idx_facturas_cliente ON public.facturas(cliente_id);
CREATE INDEX idx_facturas_fecha ON public.facturas(fecha);
CREATE INDEX idx_facturas_estado ON public.facturas(estado);
CREATE INDEX idx_movimientos_stock_producto ON public.movimientos_stock(producto_id);
CREATE INDEX idx_cuenta_corriente_clientes_cliente ON public.cuenta_corriente_clientes(cliente_id);
CREATE INDEX idx_cuenta_corriente_proveedores_proveedor ON public.cuenta_corriente_proveedores(proveedor_id);
