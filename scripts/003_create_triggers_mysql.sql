-- -------------------------------------------
-- TRIGGERS (MySQL version)
-- -------------------------------------------

-- NOTA: Para las columnas 'updated_at', NO necesitas triggers en MySQL.
-- En el script de esquema ya configuramos:
-- `updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
-- Esto hace que MySQL lo maneje automáticamente de forma nativa.

-- ---------------------------------------------------------
-- Trigger para crear perfil automáticamente al registrarse
-- ---------------------------------------------------------

DELIMITER $$

CREATE TRIGGER after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    -- En un entorno fuera de Supabase, los metadatos de usuario
    -- suelen manejarse en la aplicación (NestJS).
    -- Este trigger es una traducción lógica del de Supabase.
    
    INSERT INTO profiles (id, email, nombre_completo, rol)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.email, -- En MySQL base no tenemos el JSON de metadatos de Supabase por defecto
        'vendedor'
    )
    ON DUPLICATE KEY UPDATE id=id;
END$$

DELIMITER ;
