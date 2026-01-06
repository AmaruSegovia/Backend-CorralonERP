-- Migración para corregir columnas de productos
-- Agrega todas las columnas faltantes si no existen

-- Función auxiliar para agregar columnas solo si no existen
DO $$
BEGIN
  -- Agregar columna usa_serie si no existe
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'usa_serie'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN usa_serie BOOLEAN DEFAULT false;
    
    UPDATE public.productos 
    SET usa_serie = false 
    WHERE usa_serie IS NULL;
  END IF;

  -- Agregar columna usa_lote si no existe
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'usa_lote'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN usa_lote BOOLEAN DEFAULT false;
    
    UPDATE public.productos 
    SET usa_lote = false 
    WHERE usa_lote IS NULL;
  END IF;

  -- Verificar que la columna iva existe
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'iva'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN iva DECIMAL(5,2) DEFAULT 21.00;
    
    -- Si existe iva_porcentaje, copiar los valores
    IF EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'productos' 
      AND column_name = 'iva_porcentaje'
    ) THEN
      UPDATE public.productos 
      SET iva = COALESCE(iva_porcentaje, 21.00) 
      WHERE iva IS NULL;
    ELSE
      UPDATE public.productos 
      SET iva = 21.00 
      WHERE iva IS NULL;
    END IF;
  END IF;

  -- Verificar stock_minimo
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'stock_minimo'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN stock_minimo DECIMAL(10,2) DEFAULT 0;
  END IF;

  -- Verificar stock_maximo
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'stock_maximo'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN stock_maximo DECIMAL(10,2);
  END IF;

  -- Verificar activo
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'activo'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN activo BOOLEAN DEFAULT true;
    
    UPDATE public.productos 
    SET activo = true 
    WHERE activo IS NULL;
  END IF;

  -- Verificar created_at
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'created_at'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
  END IF;

  -- Verificar updated_at
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'productos' 
    AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.productos 
    ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;

-- Forzar actualización del schema cache de Supabase (esto puede requerir reiniciar el servicio)
-- Nota: Después de ejecutar esta migración, es posible que necesites esperar unos minutos
-- o refrescar el schema cache en Supabase Dashboard

-- Comentario: La columna en la base de datos es 'iva', no 'iva_porcentaje'
-- El código debería usar 'iva' para mantener consistencia con el schema

