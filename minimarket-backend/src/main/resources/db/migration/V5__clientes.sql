-- =========================================================================
-- V5: Clientes
-- =========================================================================
CREATE TABLE tipos_documento_identidad (
    id      BIGSERIAL PRIMARY KEY,
    codigo  VARCHAR(15) NOT NULL UNIQUE,   -- DNI, RUC, CE, PASAPORTE, SIN_DOC
    nombre  VARCHAR(60) NOT NULL
);

CREATE TABLE clientes (
    id                    BIGSERIAL PRIMARY KEY,
    tipo_documento_id     BIGINT NOT NULL REFERENCES tipos_documento_identidad(id) ON DELETE RESTRICT,
    numero_documento      VARCHAR(20) NOT NULL,
    nombre_razon_social   VARCHAR(150) NOT NULL,
    nombre_comercial      VARCHAR(150),
    direccion             VARCHAR(200),
    telefono              VARCHAR(20),
    email                 VARCHAR(120),
    activo                BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tipo_documento_id, numero_documento)
);
CREATE TRIGGER trg_clientes_updated_at BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_clientes_activo ON clientes(activo);
