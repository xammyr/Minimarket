CREATE TABLE compras (
    id BIGSERIAL PRIMARY KEY,
    numero_comprobante VARCHAR(50) NOT NULL,
    proveedor_id BIGINT NOT NULL REFERENCES proveedores(id),
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id),
    fecha_compra TIMESTAMP WITH TIME ZONE NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    igv NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(15) NOT NULL DEFAULT 'COMPLETADA',
    motivo_anulacion VARCHAR(200),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TRIGGER tr_compras_updated_at
BEFORE UPDATE ON compras
FOR EACH ROW
EXECUTE FUNCTION fn_set_updated_at();

CREATE TABLE compra_detalle (
    id BIGSERIAL PRIMARY KEY,
    compra_id BIGINT NOT NULL REFERENCES compras(id),
    producto_id BIGINT NOT NULL REFERENCES productos(id),
    cantidad NUMERIC(12, 3) NOT NULL,
    precio_unitario NUMERIC(12, 2) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE TRIGGER tr_compra_detalle_updated_at
BEFORE UPDATE ON compra_detalle
FOR EACH ROW
EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX idx_compras_fecha ON compras(fecha_compra);
CREATE INDEX idx_compras_proveedor ON compras(proveedor_id);
