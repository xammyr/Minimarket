-- =========================================================================
-- V10: Comprobantes (independientes de la venta y del documento electrónico)
-- =========================================================================
CREATE TABLE tipos_comprobante (
    id                    BIGSERIAL PRIMARY KEY,
    codigo                VARCHAR(15) NOT NULL UNIQUE,  -- TICKET, BOLETA, FACTURA, NOTA_CREDITO, NOTA_DEBITO
    nombre                VARCHAR(50) NOT NULL,
    requiere_cliente_ruc  BOOLEAN NOT NULL DEFAULT FALSE,
    es_electronico        BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE series_comprobante (
    id                   BIGSERIAL PRIMARY KEY,
    tipo_comprobante_id  BIGINT NOT NULL REFERENCES tipos_comprobante(id) ON DELETE RESTRICT,
    serie                VARCHAR(4) NOT NULL,
    correlativo_actual   BIGINT NOT NULL DEFAULT 0 CHECK (correlativo_actual >= 0),
    activo               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tipo_comprobante_id, serie)
);
CREATE TRIGGER trg_series_comprobante_updated_at BEFORE UPDATE ON series_comprobante
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TABLE comprobantes (
    id                        BIGSERIAL PRIMARY KEY,
    venta_id                  BIGINT REFERENCES ventas(id) ON DELETE RESTRICT,
    tipo_comprobante_id       BIGINT NOT NULL REFERENCES tipos_comprobante(id)  ON DELETE RESTRICT,
    serie_id                  BIGINT NOT NULL REFERENCES series_comprobante(id) ON DELETE RESTRICT,
    numero                    BIGINT NOT NULL,
    comprobante_referencia_id BIGINT REFERENCES comprobantes(id) ON DELETE RESTRICT, -- para notas de crédito/débito
    cliente_id                BIGINT REFERENCES clientes(id) ON DELETE RESTRICT,
    fecha_emision             TIMESTAMPTZ NOT NULL DEFAULT now(),
    subtotal                  NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    descuento                 NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    igv                       NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (igv >= 0),
    total                     NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    estado                    VARCHAR(15) NOT NULL DEFAULT 'EMITIDO' CHECK (estado IN ('EMITIDO','ANULADO')),
    motivo_anulacion          VARCHAR(200),
    created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (serie_id, numero)
);
CREATE TRIGGER trg_comprobantes_updated_at BEFORE UPDATE ON comprobantes
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_comprobantes_venta   ON comprobantes(venta_id);
CREATE INDEX idx_comprobantes_cliente ON comprobantes(cliente_id);
CREATE INDEX idx_comprobantes_fecha   ON comprobantes(fecha_emision);
CREATE INDEX idx_comprobantes_estado  ON comprobantes(estado);

CREATE TABLE comprobante_detalle (
    id               BIGSERIAL PRIMARY KEY,
    comprobante_id   BIGINT NOT NULL REFERENCES comprobantes(id) ON DELETE CASCADE,
    producto_id      BIGINT REFERENCES productos(id) ON DELETE SET NULL,
    descripcion      VARCHAR(200) NOT NULL,  -- snapshot del nombre al momento de emisión
    cantidad         NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    descuento        NUMERIC(12,2) NOT NULL DEFAULT 0,
    igv              NUMERIC(12,2) NOT NULL DEFAULT 0,
    subtotal         NUMERIC(12,2) NOT NULL,
    total            NUMERIC(12,2) NOT NULL
);
CREATE INDEX idx_comprobante_detalle_comprobante ON comprobante_detalle(comprobante_id);

COMMENT ON TABLE comprobantes IS
'Documento tributario (boleta/factura/nota). Independiente de venta y de documentos_electronicos (que maneja el ciclo con SUNAT).';
COMMENT ON COLUMN comprobantes.venta_id IS
'NULL permitido: una nota de crédito/débito referencia otro comprobante (comprobante_referencia_id), no directamente una venta.';
