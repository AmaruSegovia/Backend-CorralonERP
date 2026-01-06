-- ---------------------------------------------
-- DATOS INICIALES (PostgreSQL version)
-- ---------------------------------------------

-- Unidades de medida
INSERT INTO unidades_medida (codigo, nombre, tipo) VALUES
('UN', 'Unidad', 'unidad'),
('M', 'Metro', 'longitud'),
('M2', 'Metro Cuadrado', 'area'),
('M3', 'Metro Cúbico', 'volumen'),
('KG', 'Kilogramo', 'peso'),
('LT', 'Litro', 'volumen'),
('BL', 'Bolsa', 'unidad'),
('CJ', 'Caja', 'unidad')
ON CONFLICT DO NOTHING;

-- Categorias de productos
INSERT INTO categorias (nombre, descripcion) VALUES
('Cemento y Adhesivos', 'Cementos, pegamentos y adhesivos para construcción'),
('Hierros y Aceros', 'Hierros, varillas, mallas y estructuras metálicas'),
('Ladrillos y Bloques', 'Ladrillos, bloques y materiales de mampostería'),
('Cerámicos y Porcelanatos', 'Revestimientos cerámicos y porcelanatos'),
('Pinturas', 'Pinturas, esmaltes y revestimientos'),
('Sanitarios', 'Inodoros, lavatorios, grifería y accesorios'),
('Aberturas', 'Puertas, ventanas y marcos'),
('Electricidad', 'Cables, llaves, tomas y materiales eléctricos'),
('Plomería', 'Caños, conexiones y accesorios de plomería'),
('Herramientas', 'Herramientas manuales y eléctricas')
ON CONFLICT DO NOTHING;

-- Listas de precios
INSERT INTO listas_precios (nombre, descripcion, tipo) VALUES
('Minorista', 'Precio de venta al público', 'minorista'),
('Mayorista', 'Precio para compras al por mayor', 'mayorista'),
('Contado', 'Precio especial para pago en efectivo', 'contado'),
('Arquitectos', 'Precio especial para profesionales', 'especial')
ON CONFLICT DO NOTHING;

-- Deposito principal
INSERT INTO depositos (codigo, nombre, direccion) VALUES
('DEP-01', 'Depósito Central', 'Av. Principal 123, San Salvador de Jujuy')
ON CONFLICT DO NOTHING;

-- Caja principal
INSERT INTO cajas (nombre, tipo, saldo) VALUES
('Caja Principal', 'efectivo', 0),
('Banco Nación - Cta. Cte.', 'banco', 0)
ON CONFLICT DO NOTHING;
