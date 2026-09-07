-- =========================================================================
-- V9: Pagos (soporta pago combinado por venta)
-- =========================================================================
CREATE TABLE metodos_pago (
    id      BIGSERIAL PRIMARY KEY,
    codigo  VARCHAR(20) NOT NULL UNIQUE,   -- EFECTIVO, YAPE, PLIN, TARJETA, TRANSFERENCIA, OTROS
    nombre  VARCHAR(50) NOT NULL,
    activo  BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE venta_pagos (
    id              BIGSERIAL PRIMARY KEY,
    venta_id        BIGINT NOT NULL REFERENCES ventas(id)       ON DELETE CASCADE,
    metodo_pago_id  BIGINT NOT NULL REFERENCES metodos_pago(id) ON DELETE RESTRICT,
    monto           NUMERIC(12,2) NOT NULL CHECK (monto > 0),
    referencia      VARCHAR(100),   -- n° de operación Yape/Plin/tarjeta, si aplica
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_venta_pagos_venta  ON venta_pagos(venta_id);
CREATE INDEX idx_venta_pagos_metodo ON venta_pagos(metodo_pago_id);

COMMENT ON TABLE venta_pagos IS
'Una venta puede tener varias filas aquí (pago combinado: parte efectivo + parte Yape, etc). La suma de montos debe igualar ventas.total; esa regla se valida en el backend, no en la BD.';
