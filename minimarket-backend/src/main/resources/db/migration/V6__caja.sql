-- =========================================================================
-- V6: Caja (turnos, aperturas, cierres, movimientos)
-- =========================================================================
CREATE TABLE cajas (
    id          BIGSERIAL PRIMARY KEY,
    nombre      VARCHAR(60) NOT NULL,
    ubicacion   VARCHAR(120),
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_cajas_updated_at BEFORE UPDATE ON cajas
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TABLE caja_turnos (
    id                      BIGSERIAL PRIMARY KEY,
    caja_id                 BIGINT NOT NULL REFERENCES cajas(id)    ON DELETE RESTRICT,
    usuario_id              BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    monto_apertura          NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (monto_apertura >= 0),
    fecha_apertura          TIMESTAMPTZ NOT NULL DEFAULT now(),
    monto_cierre_esperado   NUMERIC(12,2),
    monto_cierre_real       NUMERIC(12,2),
    diferencia              NUMERIC(12,2),
    fecha_cierre            TIMESTAMPTZ,
    usuario_cierre_id       BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    estado                  VARCHAR(10) NOT NULL DEFAULT 'ABIERTO' CHECK (estado IN ('ABIERTO','CERRADO')),
    observaciones           TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_caja_turnos_updated_at BEFORE UPDATE ON caja_turnos
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Regla de negocio: una caja no puede tener dos turnos ABIERTO simultáneamente
CREATE UNIQUE INDEX idx_caja_turno_unico_abierto ON caja_turnos(caja_id) WHERE estado = 'ABIERTO';
CREATE INDEX idx_caja_turnos_usuario ON caja_turnos(usuario_id);

CREATE TABLE caja_movimientos (
    id               BIGSERIAL PRIMARY KEY,
    caja_turno_id    BIGINT NOT NULL REFERENCES caja_turnos(id) ON DELETE RESTRICT,
    tipo_movimiento  VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('APERTURA','INGRESO','EGRESO','VENTA')),
    monto            NUMERIC(12,2) NOT NULL CHECK (monto <> 0),
    concepto         VARCHAR(150),
    referencia_tipo  VARCHAR(30),
    referencia_id    BIGINT,
    usuario_id       BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_caja_movimientos_turno ON caja_movimientos(caja_turno_id);
CREATE INDEX idx_caja_movimientos_referencia ON caja_movimientos(referencia_tipo, referencia_id);
