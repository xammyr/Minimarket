-- =========================================================================
-- V8: Ventas
-- =========================================================================
CREATE TABLE ventas (
    id                BIGSERIAL PRIMARY KEY,
    numero_venta      VARCHAR(20) NOT NULL UNIQUE,
    cliente_id        BIGINT REFERENCES clientes(id)      ON DELETE RESTRICT,  -- NULL = cliente varios
    usuario_id        BIGINT NOT NULL REFERENCES usuarios(id)    ON DELETE RESTRICT,  -- cajero
    caja_turno_id     BIGINT NOT NULL REFERENCES caja_turnos(id) ON DELETE RESTRICT,
    fecha_venta       TIMESTAMPTZ NOT NULL DEFAULT now(),
    subtotal          NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    descuento         NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    igv               NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (igv >= 0),
    total             NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    estado            VARCHAR(15) NOT NULL DEFAULT 'COMPLETADA' CHECK (estado IN ('PENDIENTE','COMPLETADA','ANULADA')),
    motivo_anulacion  VARCHAR(200),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_ventas_updated_at BEFORE UPDATE ON ventas
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_ventas_fecha    ON ventas(fecha_venta);
CREATE INDEX idx_ventas_cliente  ON ventas(cliente_id);
CREATE INDEX idx_ventas_usuario  ON ventas(usuario_id);
CREATE INDEX idx_ventas_estado   ON ventas(estado);
CREATE INDEX idx_ventas_caja_turno ON ventas(caja_turno_id);

CREATE TABLE venta_detalle (
    id               BIGSERIAL PRIMARY KEY,
    venta_id         BIGINT NOT NULL REFERENCES ventas(id)    ON DELETE CASCADE,
    producto_id      BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    cantidad         NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    descuento        NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    igv              NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (igv >= 0),
    subtotal         NUMERIC(12,2) NOT NULL,
    total            NUMERIC(12,2) NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_venta_detalle_venta    ON venta_detalle(venta_id);
CREATE INDEX idx_venta_detalle_producto ON venta_detalle(producto_id);

COMMENT ON TABLE ventas IS
'Una venta NO es un comprobante: la venta es el hecho comercial/operativo. El comprobante (boleta/factura) se modela aparte en la tabla comprobantes.';
