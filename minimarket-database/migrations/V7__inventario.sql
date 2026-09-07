-- =========================================================================
-- V7: Inventario (lotes y movimientos históricos)
-- =========================================================================
CREATE TABLE lotes (
    id                BIGSERIAL PRIMARY KEY,
    producto_id       BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    numero_lote       VARCHAR(50) NOT NULL,
    fecha_vencimiento DATE,
    fecha_ingreso     DATE NOT NULL DEFAULT CURRENT_DATE,
    cantidad_inicial  NUMERIC(12,3) NOT NULL CHECK (cantidad_inicial >= 0),
    cantidad_actual   NUMERIC(12,3) NOT NULL CHECK (cantidad_actual >= 0),
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (producto_id, numero_lote)
);
CREATE TRIGGER trg_lotes_updated_at BEFORE UPDATE ON lotes
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_lotes_producto ON lotes(producto_id);
CREATE INDEX idx_lotes_vencimiento ON lotes(fecha_vencimiento);

CREATE TABLE inventario_movimientos (
    id                BIGSERIAL PRIMARY KEY,
    producto_id       BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    lote_id           BIGINT REFERENCES lotes(id) ON DELETE SET NULL,
    tipo_movimiento   VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN
                        ('ENTRADA','SALIDA','AJUSTE_POSITIVO','AJUSTE_NEGATIVO','VENTA','DEVOLUCION_VENTA','DEVOLUCION_COMPRA')),
    cantidad          NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    stock_anterior    NUMERIC(12,3) NOT NULL,
    stock_resultante  NUMERIC(12,3) NOT NULL,
    motivo            VARCHAR(200),
    referencia_tipo   VARCHAR(30),
    referencia_id     BIGINT,
    usuario_id        BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_inv_mov_producto ON inventario_movimientos(producto_id);
CREATE INDEX idx_inv_mov_referencia ON inventario_movimientos(referencia_tipo, referencia_id);
CREATE INDEX idx_inv_mov_fecha ON inventario_movimientos(created_at);

COMMENT ON TABLE inventario_movimientos IS
'Historial inmutable de todo movimiento de stock. productos.stock_actual es una caché derivada de esta tabla.';
