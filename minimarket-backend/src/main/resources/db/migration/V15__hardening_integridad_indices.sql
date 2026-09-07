-- V15: Hardening de integridad, índices y permisos POS
-- No contiene datos de prueba.

ALTER TABLE inventario_movimientos
    ADD CONSTRAINT ck_inv_stock_anterior_nonnegative CHECK (stock_anterior >= 0),
    ADD CONSTRAINT ck_inv_stock_resultante_nonnegative CHECK (stock_resultante >= 0);

ALTER TABLE comprobante_detalle
    ADD CONSTRAINT ck_comp_detalle_descuento_nonnegative CHECK (descuento >= 0),
    ADD CONSTRAINT ck_comp_detalle_igv_nonnegative CHECK (igv >= 0);

CREATE INDEX IF NOT EXISTS idx_clientes_documento
    ON clientes(numero_documento);
CREATE INDEX IF NOT EXISTS idx_proveedores_documento
    ON proveedores(tipo_documento, numero_documento);
CREATE INDEX IF NOT EXISTS idx_venta_pagos_referencia
    ON venta_pagos(referencia) WHERE referencia IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lotes_activos_vencimiento
    ON lotes(fecha_vencimiento) WHERE activo = TRUE AND fecha_vencimiento IS NOT NULL;

INSERT INTO permisos (codigo, nombre, descripcion) VALUES
 ('CLIENTE_VER','Ver clientes','Consultar clientes desde el POS'),
 ('CLIENTE_ADMINISTRAR','Administrar clientes','Crear, editar y desactivar clientes'),
 ('PROVEEDOR_ADMINISTRAR','Administrar proveedores','Crear, editar y desactivar proveedores'),
 ('CATALOGO_ADMINISTRAR','Administrar catálogo','Administrar categorías, marcas y unidades'),
 ('INVENTARIO_VER','Ver inventario','Consultar stock y kardex'),
 ('CAJA_ADMINISTRAR','Administrar cajas','Crear y administrar cajas físicas'),
 ('PAGO_VER','Ver métodos de pago','Consultar métodos de pago')
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.nombre='ADMIN'
  AND p.codigo IN ('CLIENTE_VER','CLIENTE_ADMINISTRAR','PROVEEDOR_ADMINISTRAR','CATALOGO_ADMINISTRAR','INVENTARIO_VER','CAJA_ADMINISTRAR','PAGO_VER')
ON CONFLICT DO NOTHING;

INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.nombre='CAJERO'
  AND p.codigo IN ('CLIENTE_VER','CLIENTE_ADMINISTRAR','INVENTARIO_VER','PAGO_VER')
ON CONFLICT DO NOTHING;

INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.nombre='INVENTARIO'
  AND p.codigo IN ('INVENTARIO_VER','PROVEEDOR_ADMINISTRAR','CATALOGO_ADMINISTRAR')
ON CONFLICT DO NOTHING;

COMMENT ON CONSTRAINT ck_inv_stock_resultante_nonnegative ON inventario_movimientos
    IS 'El stock resultante nunca puede ser negativo.';
