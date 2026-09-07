-- =========================================================================
-- V12: Auditoría
-- =========================================================================
CREATE TABLE auditoria_log (
    id               BIGSERIAL PRIMARY KEY,
    usuario_id       BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    entidad          VARCHAR(60) NOT NULL,
    entidad_id       BIGINT,
    accion           VARCHAR(20) NOT NULL CHECK (accion IN ('CREATE','UPDATE','DELETE','LOGIN','LOGOUT','ANULACION')),
    datos_anteriores JSONB,
    datos_nuevos     JSONB,
    ip_origen        VARCHAR(45),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_auditoria_entidad ON auditoria_log(entidad, entidad_id);
CREATE INDEX idx_auditoria_usuario ON auditoria_log(usuario_id);
CREATE INDEX idx_auditoria_fecha   ON auditoria_log(created_at);
