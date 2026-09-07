-- =========================================================================
-- V1: Extensiones y funciones comunes
-- =========================================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- hashing (seed de usuarios de prueba)
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- búsqueda difusa de productos (POS)

-- Función genérica para mantener updated_at en cada UPDATE
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_set_updated_at() IS
'Actualiza automáticamente updated_at. Se asocia a tablas vía trigger BEFORE UPDATE.';
