-- =========================================================================
-- V3: Proveedores
-- =========================================================================
CREATE TABLE proveedores (
    id                BIGSERIAL PRIMARY KEY,
    tipo_documento    VARCHAR(4)  NOT NULL DEFAULT 'RUC' CHECK (tipo_documento IN ('RUC','DNI','CE')),
    numero_documento  VARCHAR(20) NOT NULL,
    razon_social      VARCHAR(150) NOT NULL,
    nombre_comercial  VARCHAR(150),
    direccion         VARCHAR(200),
    telefono          VARCHAR(20),
    email             VARCHAR(120),
    contacto_nombre   VARCHAR(100),
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tipo_documento, numero_documento)
);
CREATE TRIGGER trg_proveedores_updated_at BEFORE UPDATE ON proveedores
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_proveedores_activo ON proveedores(activo);
