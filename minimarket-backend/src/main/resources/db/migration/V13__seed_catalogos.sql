-- =========================================================================
-- V13: Datos maestros (catálogos base) - válidos para CUALQUIER ambiente,
-- no son datos ficticios: son configuración mínima que el sistema necesita
-- para funcionar (roles, métodos de pago, tipos de documento/comprobante...)
-- =========================================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('ADMIN',      'Acceso total al sistema'),
    ('CAJERO',     'Operación de punto de venta y caja'),
    ('INVENTARIO', 'Gestión de productos, stock e inventario');

INSERT INTO permisos (codigo, nombre) VALUES
    ('PRODUCTO_VER',      'Ver productos'),
    ('PRODUCTO_CREAR',    'Crear productos'),
    ('PRODUCTO_EDITAR',   'Editar productos'),
    ('INVENTARIO_AJUSTAR','Ajustar inventario'),
    ('VENTA_CREAR',       'Registrar ventas'),
    ('VENTA_ANULAR',      'Anular ventas'),
    ('CAJA_ABRIR',        'Abrir turno de caja'),
    ('CAJA_CERRAR',       'Cerrar turno de caja'),
    ('REPORTE_VER',       'Ver reportes'),
    ('USUARIO_ADMINISTRAR','Administrar usuarios y roles');

-- ADMIN obtiene todos los permisos
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT (SELECT id FROM roles WHERE nombre = 'ADMIN'), p.id FROM permisos p;

-- CAJERO: operación diaria
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT (SELECT id FROM roles WHERE nombre = 'CAJERO'), p.id
FROM permisos p WHERE p.codigo IN ('PRODUCTO_VER','VENTA_CREAR','CAJA_ABRIR','CAJA_CERRAR');

-- INVENTARIO
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT (SELECT id FROM roles WHERE nombre = 'INVENTARIO'), p.id
FROM permisos p WHERE p.codigo IN ('PRODUCTO_VER','PRODUCTO_CREAR','PRODUCTO_EDITAR','INVENTARIO_AJUSTAR');

INSERT INTO metodos_pago (codigo, nombre) VALUES
    ('EFECTIVO',     'Efectivo'),
    ('YAPE',         'Yape'),
    ('PLIN',         'Plin'),
    ('TARJETA',      'Tarjeta'),
    ('TRANSFERENCIA','Transferencia bancaria'),
    ('OTROS',        'Otros');

INSERT INTO unidades_medida (nombre, abreviatura) VALUES
    ('Unidad',    'UND'),
    ('Kilogramo', 'KG'),
    ('Litro',     'LT'),
    ('Paquete',   'PAQ'),
    ('Caja',      'CJA'),
    ('Docena',    'DOC');

INSERT INTO tipos_documento_identidad (codigo, nombre) VALUES
    ('DNI',       'Documento Nacional de Identidad'),
    ('RUC',       'Registro Único de Contribuyente'),
    ('CE',        'Carné de Extranjería'),
    ('PASAPORTE', 'Pasaporte'),
    ('SIN_DOC',   'Sin documento');

INSERT INTO tipos_comprobante (codigo, nombre, requiere_cliente_ruc, es_electronico) VALUES
    ('TICKET',       'Ticket interno',    FALSE, FALSE),
    ('BOLETA',       'Boleta de venta',   FALSE, TRUE),
    ('FACTURA',      'Factura',           TRUE,  TRUE),
    ('NOTA_CREDITO', 'Nota de crédito',   FALSE, TRUE),
    ('NOTA_DEBITO',  'Nota de débito',    FALSE, TRUE);

INSERT INTO series_comprobante (tipo_comprobante_id, serie, correlativo_actual) VALUES
    ((SELECT id FROM tipos_comprobante WHERE codigo = 'TICKET'),  'T001', 0),
    ((SELECT id FROM tipos_comprobante WHERE codigo = 'BOLETA'),  'B001', 0),
    ((SELECT id FROM tipos_comprobante WHERE codigo = 'FACTURA'), 'F001', 0);
