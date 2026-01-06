-- -------------------------------------------
-- ROW LEVEL SECURITY (RLS)
-- -------------------------------------------

-- Habilitar RLS en todas las tablas (solo si existen)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'categorias') THEN
    ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'unidades_medida') THEN
    ALTER TABLE public.unidades_medida ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'productos') THEN
    ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'depositos') THEN
    ALTER TABLE public.depositos ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'stock') THEN
    ALTER TABLE public.stock ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'movimientos_stock') THEN
    ALTER TABLE public.movimientos_stock ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'series_lotes') THEN
    ALTER TABLE public.series_lotes ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'clientes') THEN
    ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'proveedores') THEN
    ALTER TABLE public.proveedores ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'listas_precios') THEN
    ALTER TABLE public.listas_precios ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'precios') THEN
    ALTER TABLE public.precios ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'presupuestos') THEN
    ALTER TABLE public.presupuestos ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'presupuestos_detalle') THEN
    ALTER TABLE public.presupuestos_detalle ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'acopios') THEN
    ALTER TABLE public.acopios ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'acopios_detalle') THEN
    ALTER TABLE public.acopios_detalle ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'facturas') THEN
    ALTER TABLE public.facturas ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'facturas_detalle') THEN
    ALTER TABLE public.facturas_detalle ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'remitos') THEN
    ALTER TABLE public.remitos ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'remitos_detalle') THEN
    ALTER TABLE public.remitos_detalle ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ordenes_compra') THEN
    ALTER TABLE public.ordenes_compra ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ordenes_compra_detalle') THEN
    ALTER TABLE public.ordenes_compra_detalle ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cajas') THEN
    ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'movimientos_caja') THEN
    ALTER TABLE public.movimientos_caja ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cuenta_corriente_clientes') THEN
    ALTER TABLE public.cuenta_corriente_clientes ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cuenta_corriente_proveedores') THEN
    ALTER TABLE public.cuenta_corriente_proveedores ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- ---------------------------------------------
-- POLITICAS DE SEGURIDAD
-- ---------------------------------------------

-- Profiles: Los usuarios pueden ver y actualizar su propio perfil
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
    DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
    CREATE POLICY "profiles_select_own" ON public.profiles FOR SELECT USING (auth.uid() = id);
    
    DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
    CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;

-- Categorias
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'categorias') THEN
    DROP POLICY IF EXISTS "categorias_select_all" ON public.categorias;
    CREATE POLICY "categorias_select_all" ON public.categorias FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "categorias_insert_admin" ON public.categorias;
    CREATE POLICY "categorias_insert_admin" ON public.categorias FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "categorias_update_admin" ON public.categorias;
    CREATE POLICY "categorias_update_admin" ON public.categorias FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Unidades de medida
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'unidades_medida') THEN
    DROP POLICY IF EXISTS "unidades_select_all" ON public.unidades_medida;
    CREATE POLICY "unidades_select_all" ON public.unidades_medida FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "unidades_insert_admin" ON public.unidades_medida;
    CREATE POLICY "unidades_insert_admin" ON public.unidades_medida FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Productos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'productos') THEN
    DROP POLICY IF EXISTS "productos_select_all" ON public.productos;
    CREATE POLICY "productos_select_all" ON public.productos FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "productos_insert_all" ON public.productos;
    CREATE POLICY "productos_insert_all" ON public.productos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "productos_update_all" ON public.productos;
    CREATE POLICY "productos_update_all" ON public.productos FOR UPDATE USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "productos_delete_all" ON public.productos;
    CREATE POLICY "productos_delete_all" ON public.productos FOR DELETE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Depositos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'depositos') THEN
    DROP POLICY IF EXISTS "depositos_select_all" ON public.depositos;
    CREATE POLICY "depositos_select_all" ON public.depositos FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "depositos_insert_all" ON public.depositos;
    CREATE POLICY "depositos_insert_all" ON public.depositos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "depositos_update_all" ON public.depositos;
    CREATE POLICY "depositos_update_all" ON public.depositos FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Stock
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'stock') THEN
    DROP POLICY IF EXISTS "stock_select_all" ON public.stock;
    CREATE POLICY "stock_select_all" ON public.stock FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "stock_insert_all" ON public.stock;
    CREATE POLICY "stock_insert_all" ON public.stock FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "stock_update_all" ON public.stock;
    CREATE POLICY "stock_update_all" ON public.stock FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Movimientos de stock
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'movimientos_stock') THEN
    DROP POLICY IF EXISTS "movimientos_stock_select_all" ON public.movimientos_stock;
    CREATE POLICY "movimientos_stock_select_all" ON public.movimientos_stock FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "movimientos_stock_insert_all" ON public.movimientos_stock;
    CREATE POLICY "movimientos_stock_insert_all" ON public.movimientos_stock FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Series y lotes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'series_lotes') THEN
    DROP POLICY IF EXISTS "series_lotes_select_all" ON public.series_lotes;
    CREATE POLICY "series_lotes_select_all" ON public.series_lotes FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "series_lotes_insert_all" ON public.series_lotes;
    CREATE POLICY "series_lotes_insert_all" ON public.series_lotes FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Clientes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'clientes') THEN
    DROP POLICY IF EXISTS "clientes_select_all" ON public.clientes;
    CREATE POLICY "clientes_select_all" ON public.clientes FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "clientes_insert_all" ON public.clientes;
    CREATE POLICY "clientes_insert_all" ON public.clientes FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "clientes_update_all" ON public.clientes;
    CREATE POLICY "clientes_update_all" ON public.clientes FOR UPDATE USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "clientes_delete_all" ON public.clientes;
    CREATE POLICY "clientes_delete_all" ON public.clientes FOR DELETE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Proveedores
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'proveedores') THEN
    DROP POLICY IF EXISTS "proveedores_select_all" ON public.proveedores;
    CREATE POLICY "proveedores_select_all" ON public.proveedores FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "proveedores_insert_all" ON public.proveedores;
    CREATE POLICY "proveedores_insert_all" ON public.proveedores FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "proveedores_update_all" ON public.proveedores;
    CREATE POLICY "proveedores_update_all" ON public.proveedores FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Listas de precios
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'listas_precios') THEN
    DROP POLICY IF EXISTS "listas_precios_select_all" ON public.listas_precios;
    CREATE POLICY "listas_precios_select_all" ON public.listas_precios FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "listas_precios_insert_all" ON public.listas_precios;
    CREATE POLICY "listas_precios_insert_all" ON public.listas_precios FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "listas_precios_update_all" ON public.listas_precios;
    CREATE POLICY "listas_precios_update_all" ON public.listas_precios FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Precios
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'precios') THEN
    DROP POLICY IF EXISTS "precios_select_all" ON public.precios;
    CREATE POLICY "precios_select_all" ON public.precios FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "precios_insert_all" ON public.precios;
    CREATE POLICY "precios_insert_all" ON public.precios FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "precios_update_all" ON public.precios;
    CREATE POLICY "precios_update_all" ON public.precios FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Presupuestos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'presupuestos') THEN
    DROP POLICY IF EXISTS "presupuestos_select_all" ON public.presupuestos;
    CREATE POLICY "presupuestos_select_all" ON public.presupuestos FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "presupuestos_insert_all" ON public.presupuestos;
    CREATE POLICY "presupuestos_insert_all" ON public.presupuestos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "presupuestos_update_all" ON public.presupuestos;
    CREATE POLICY "presupuestos_update_all" ON public.presupuestos FOR UPDATE USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "presupuestos_delete_all" ON public.presupuestos;
    CREATE POLICY "presupuestos_delete_all" ON public.presupuestos FOR DELETE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Presupuestos detalle
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'presupuestos_detalle') THEN
    DROP POLICY IF EXISTS "presupuestos_detalle_select_all" ON public.presupuestos_detalle;
    CREATE POLICY "presupuestos_detalle_select_all" ON public.presupuestos_detalle FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "presupuestos_detalle_insert_all" ON public.presupuestos_detalle;
    CREATE POLICY "presupuestos_detalle_insert_all" ON public.presupuestos_detalle FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "presupuestos_detalle_update_all" ON public.presupuestos_detalle;
    CREATE POLICY "presupuestos_detalle_update_all" ON public.presupuestos_detalle FOR UPDATE USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "presupuestos_detalle_delete_all" ON public.presupuestos_detalle;
    CREATE POLICY "presupuestos_detalle_delete_all" ON public.presupuestos_detalle FOR DELETE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Acopios
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'acopios') THEN
    DROP POLICY IF EXISTS "acopios_select_all" ON public.acopios;
    CREATE POLICY "acopios_select_all" ON public.acopios FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "acopios_insert_all" ON public.acopios;
    CREATE POLICY "acopios_insert_all" ON public.acopios FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "acopios_update_all" ON public.acopios;
    CREATE POLICY "acopios_update_all" ON public.acopios FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Acopios detalle
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'acopios_detalle') THEN
    DROP POLICY IF EXISTS "acopios_detalle_select_all" ON public.acopios_detalle;
    CREATE POLICY "acopios_detalle_select_all" ON public.acopios_detalle FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "acopios_detalle_insert_all" ON public.acopios_detalle;
    CREATE POLICY "acopios_detalle_insert_all" ON public.acopios_detalle FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "acopios_detalle_update_all" ON public.acopios_detalle;
    CREATE POLICY "acopios_detalle_update_all" ON public.acopios_detalle FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Facturas
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'facturas') THEN
    DROP POLICY IF EXISTS "facturas_select_all" ON public.facturas;
    CREATE POLICY "facturas_select_all" ON public.facturas FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "facturas_insert_all" ON public.facturas;
    CREATE POLICY "facturas_insert_all" ON public.facturas FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "facturas_update_all" ON public.facturas;
    CREATE POLICY "facturas_update_all" ON public.facturas FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Facturas detalle
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'facturas_detalle') THEN
    DROP POLICY IF EXISTS "facturas_detalle_select_all" ON public.facturas_detalle;
    CREATE POLICY "facturas_detalle_select_all" ON public.facturas_detalle FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "facturas_detalle_insert_all" ON public.facturas_detalle;
    CREATE POLICY "facturas_detalle_insert_all" ON public.facturas_detalle FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "facturas_detalle_update_all" ON public.facturas_detalle;
    CREATE POLICY "facturas_detalle_update_all" ON public.facturas_detalle FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Remitos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'remitos') THEN
    DROP POLICY IF EXISTS "remitos_select_all" ON public.remitos;
    CREATE POLICY "remitos_select_all" ON public.remitos FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "remitos_insert_all" ON public.remitos;
    CREATE POLICY "remitos_insert_all" ON public.remitos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "remitos_update_all" ON public.remitos;
    CREATE POLICY "remitos_update_all" ON public.remitos FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Remitos detalle
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'remitos_detalle') THEN
    DROP POLICY IF EXISTS "remitos_detalle_select_all" ON public.remitos_detalle;
    CREATE POLICY "remitos_detalle_select_all" ON public.remitos_detalle FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "remitos_detalle_insert_all" ON public.remitos_detalle;
    CREATE POLICY "remitos_detalle_insert_all" ON public.remitos_detalle FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Ordenes de compra
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ordenes_compra') THEN
    DROP POLICY IF EXISTS "ordenes_compra_select_all" ON public.ordenes_compra;
    CREATE POLICY "ordenes_compra_select_all" ON public.ordenes_compra FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "ordenes_compra_insert_all" ON public.ordenes_compra;
    CREATE POLICY "ordenes_compra_insert_all" ON public.ordenes_compra FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "ordenes_compra_update_all" ON public.ordenes_compra;
    CREATE POLICY "ordenes_compra_update_all" ON public.ordenes_compra FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Ordenes de compra detalle
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ordenes_compra_detalle') THEN
    DROP POLICY IF EXISTS "ordenes_compra_detalle_select_all" ON public.ordenes_compra_detalle;
    CREATE POLICY "ordenes_compra_detalle_select_all" ON public.ordenes_compra_detalle FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "ordenes_compra_detalle_insert_all" ON public.ordenes_compra_detalle;
    CREATE POLICY "ordenes_compra_detalle_insert_all" ON public.ordenes_compra_detalle FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "ordenes_compra_detalle_update_all" ON public.ordenes_compra_detalle;
    CREATE POLICY "ordenes_compra_detalle_update_all" ON public.ordenes_compra_detalle FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Cajas
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cajas') THEN
    DROP POLICY IF EXISTS "cajas_select_all" ON public.cajas;
    CREATE POLICY "cajas_select_all" ON public.cajas FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "cajas_insert_all" ON public.cajas;
    CREATE POLICY "cajas_insert_all" ON public.cajas FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "cajas_update_all" ON public.cajas;
    CREATE POLICY "cajas_update_all" ON public.cajas FOR UPDATE USING (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Movimientos de caja
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'movimientos_caja') THEN
    DROP POLICY IF EXISTS "movimientos_caja_select_all" ON public.movimientos_caja;
    CREATE POLICY "movimientos_caja_select_all" ON public.movimientos_caja FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "movimientos_caja_insert_all" ON public.movimientos_caja;
    CREATE POLICY "movimientos_caja_insert_all" ON public.movimientos_caja FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Cuenta corriente clientes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cuenta_corriente_clientes') THEN
    DROP POLICY IF EXISTS "cuenta_corriente_clientes_select_all" ON public.cuenta_corriente_clientes;
    CREATE POLICY "cuenta_corriente_clientes_select_all" ON public.cuenta_corriente_clientes FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "cuenta_corriente_clientes_insert_all" ON public.cuenta_corriente_clientes;
    CREATE POLICY "cuenta_corriente_clientes_insert_all" ON public.cuenta_corriente_clientes FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;

-- Cuenta corriente proveedores
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cuenta_corriente_proveedores') THEN
    DROP POLICY IF EXISTS "cuenta_corriente_proveedores_select_all" ON public.cuenta_corriente_proveedores;
    CREATE POLICY "cuenta_corriente_proveedores_select_all" ON public.cuenta_corriente_proveedores FOR SELECT USING (auth.uid() IS NOT NULL);
    
    DROP POLICY IF EXISTS "cuenta_corriente_proveedores_insert_all" ON public.cuenta_corriente_proveedores;
    CREATE POLICY "cuenta_corriente_proveedores_insert_all" ON public.cuenta_corriente_proveedores FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
END $$;
