-- =========================================================================
-- V4: Catálogo de productos (categorías, marcas, unidades, productos)
-- =========================================================================
CREATE TABLE categorias (
    id                  BIGSERIAL PRIMARY KEY,
    nombre              VARCHAR(80) NOT NULL UNIQUE,
    descripcion         VARCHAR(200),
    categoria_padre_id  BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_categorias_updated_at BEFORE UPDATE ON categorias
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TABLE marcas (
    id          BIGSERIAL PRIMARY KEY,
    nombre      VARCHAR(80) NOT NULL UNIQUE,
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_marcas_updated_at BEFORE UPDATE ON marcas
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TABLE unidades_medida (
    id           BIGSERIAL PRIMARY KEY,
    nombre       VARCHAR(30) NOT NULL UNIQUE,
    abreviatura  VARCHAR(10) NOT NULL UNIQUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE productos (
    id                BIGSERIAL PRIMARY KEY,
    codigo_interno    VARCHAR(30) NOT NULL UNIQUE,
    codigo_barras     VARCHAR(30) UNIQUE,
    nombre            VARCHAR(150) NOT NULL,
    descripcion       TEXT,
    categoria_id      BIGINT NOT NULL REFERENCES categorias(id)      ON DELETE RESTRICT,
    marca_id          BIGINT REFERENCES marcas(id)                   ON DELETE SET NULL,
    unidad_medida_id  BIGINT NOT NULL REFERENCES unidades_medida(id) ON DELETE RESTRICT,
    proveedor_id      BIGINT REFERENCES proveedores(id)              ON DELETE SET NULL,
    precio_compra     NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (precio_compra >= 0),
    precio_venta      NUMERIC(12,2) NOT NULL CHECK (precio_venta >= 0),
    afecto_igv        BOOLEAN NOT NULL DEFAULT TRUE,
    stock_actual      NUMERIC(12,3) NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo      NUMERIC(12,3) NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    controla_stock    BOOLEAN NOT NULL DEFAULT TRUE,
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_productos_updated_at BEFORE UPDATE ON productos
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX idx_productos_categoria   ON productos(categoria_id);
CREATE INDEX idx_productos_proveedor   ON productos(proveedor_id);
CREATE INDEX idx_productos_activo      ON productos(activo);
CREATE INDEX idx_productos_nombre_trgm ON productos USING gin (nombre gin_trgm_ops);

COMMENT ON COLUMN productos.stock_actual IS
'Cache del stock vigente. La fuente de verdad histórica es inventario_movimientos; este campo se recalcula transaccionalmente en cada movimiento.';
