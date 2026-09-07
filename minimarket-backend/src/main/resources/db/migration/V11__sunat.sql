-- =========================================================================
-- V11: Electrónica / SUNAT (desacoplado del núcleo comercial)
-- =========================================================================
CREATE TABLE documentos_electronicos (
    id                      BIGSERIAL PRIMARY KEY,
    comprobante_id          BIGINT NOT NULL UNIQUE REFERENCES comprobantes(id) ON DELETE RESTRICT,
    estado                  VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado IN
                              ('PENDIENTE','GENERADO','FIRMADO','ENVIADO','ACEPTADO','RECHAZADO','ANULADO')),
    xml_nombre_archivo      VARCHAR(150),
    xml_contenido           TEXT,
    xml_firmado_contenido   TEXT,
    hash_codigo             VARCHAR(100),
    ticket_sunat            VARCHAR(50),
    cdr_nombre_archivo      VARCHAR(150),
    cdr_contenido           BYTEA,
    mensaje_respuesta       TEXT,
    intentos_envio          INTEGER NOT NULL DEFAULT 0,
    fecha_generacion        TIMESTAMPTZ,
    fecha_envio             TIMESTAMPTZ,
    fecha_respuesta         TIMESTAMPTZ,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_documentos_electronicos_updated_at BEFORE UPDATE ON documentos_electronicos
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_doc_electronicos_estado ON documentos_electronicos(estado);

CREATE TABLE documentos_electronicos_log (
    id                        BIGSERIAL PRIMARY KEY,
    documento_electronico_id  BIGINT NOT NULL REFERENCES documentos_electronicos(id) ON DELETE CASCADE,
    evento                    VARCHAR(50) NOT NULL,
    detalle                   TEXT,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_doc_electronicos_log_doc ON documentos_electronicos_log(documento_electronico_id);

COMMENT ON TABLE documentos_electronicos IS
'Ciclo de vida del documento electrónico ante SUNAT. Un problema aquí nunca debe revertir una venta ya registrada.';
