-- ---------------------------------------------
-- DATOS INICIALES (MySQL version)
-- ---------------------------------------------

-- Unidades de medida
INSERT IGNORE INTO unidades_medida (id, codigo, nombre, tipo) VALUES
(UUID(), 'UN', 'Unidad', 'unidad'),
(UUID(), 'M', 'Metro', 'longitud'),
(UUID(), 'M2', 'Metro Cuadrado', 'area'),
(UUID(), 'M3', 'Metro Cúbico', 'volumen'),
(UUID(), 'KG', 'Kilogramo', 'peso'),
(UUID(), 'LT', 'Litro', 'volumen'),
(UUID(), 'BL', 'Bolsa', 'unidad'),
(UUID(), 'CJ', 'Caja', 'unidad');

-- Categorias de productos
INSERT IGNORE INTO categorias (id, nombre, descripcion) VALUES
(UUID(), 'Cemento y Adhesivos', 'Cementos, pegamentos y adhesivos para construcción'),
(UUID(), 'Hierros y Aceros', 'Hierros, varillas, mallas y estructuras metálicas'),
(UUID(), 'Ladrillos y Bloques', 'Ladrillos, bloques y materiales de mampostería'),
(UUID(), 'Cerámicos y Porcelanatos', 'Revestimientos cerámicos y porcelanatos'),
(UUID(), 'Pinturas', 'Pinturas, esmaltes y revestimientos'),
(UUID(), 'Sanitarios', 'Inodoros, lavatorios, grifería y accesorios'),
(UUID(), 'Aberturas', 'Puertas, ventanas y marcos'),
(UUID(), 'Electricidad', 'Cables, llaves, tomas y materiales eléctricos'),
(UUID(), 'Plomería', 'Caños, conexiones y accesorios de plomería'),
(UUID(), 'Herramientas', 'Herramientas manuales y eléctricas');

-- Listas de precios
INSERT IGNORE INTO listas_precios (id, nombre, descripcion, tipo) VALUES
(UUID(), 'Minorista', 'Precio de venta al público', 'minorista'),
(UUID(), 'Mayorista', 'Precio para compras al por mayor', 'mayorista'),
(UUID(), 'Contado', 'Precio especial para pago en efectivo', 'contado'),
(UUID(), 'Arquitectos', 'Precio especial para profesionales', 'especial');

-- Deposito principal
INSERT IGNORE INTO depositos (id, codigo, nombre, direccion) VALUES
(UUID(), 'DEP-01', 'Depósito Central', 'Av. Principal 123, San Salvador de Jujuy');

-- Caja principal
INSERT IGNORE INTO cajas (id, nombre, tipo, saldo) VALUES
(UUID(), 'Caja Principal', 'efectivo', 0),
(UUID(), 'Banco Nación - Cta. Cte.', 'banco', 0);
