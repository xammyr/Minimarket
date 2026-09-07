-- =========================================================================
-- V14: Datos de PRUEBA/DESARROLLO (Fase 3 del plan: "datos semilla solo
-- para desarrollo"). NO ejecutar en producción — ver README para cómo
-- excluir esta migración en el perfil "prod".
-- =========================================================================

-- Usuario administrador de prueba. Password: Admin123!  (cámbialo antes de usar en serio)
INSERT INTO usuarios (username, password_hash, nombres, apellidos, email)
VALUES ('admin', crypt('Admin123!', gen_salt('bf')), 'Administrador', 'Sistema', '[email protected]');

INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT (SELECT id FROM usuarios WHERE username = 'admin'), (SELECT id FROM roles WHERE nombre = 'ADMIN');

-- Cliente genérico para ventas sin cliente identificado ("público general")
INSERT INTO clientes (tipo_documento_id, numero_documento, nombre_razon_social)
VALUES ((SELECT id FROM tipos_documento_identidad WHERE codigo = 'SIN_DOC'), '00000000', 'Clientes Varios');

-- Cliente de prueba con RUC (para probar emisión de factura)
INSERT INTO clientes (tipo_documento_id, numero_documento, nombre_razon_social)
VALUES ((SELECT id FROM tipos_documento_identidad WHERE codigo = 'RUC'), '20123456789', 'Comercial Los Andes S.A.C.');

-- Proveedor de prueba
INSERT INTO proveedores (tipo_documento, numero_documento, razon_social)
VALUES ('RUC', '20456789123', 'Distribuidora San Pedro S.A.C.');

-- Caja principal
INSERT INTO cajas (nombre, ubicacion) VALUES ('Caja principal', 'Mostrador');

-- Categorías y marcas de ejemplo
INSERT INTO categorias (nombre) VALUES ('Abarrotes'), ('Bebidas'), ('Limpieza'), ('Snacks');
INSERT INTO marcas (nombre) VALUES ('Gloria'), ('Alicorp'), ('Coca-Cola'), ('Genérico');

-- Productos de ejemplo (típicos de minimarket)
INSERT INTO productos (codigo_interno, codigo_barras, nombre, categoria_id, marca_id, unidad_medida_id, proveedor_id, precio_compra, precio_venta, stock_actual, stock_minimo)
VALUES
    ('PRD-0001', '7750182001019', 'Leche Gloria evaporada 400g',
        (SELECT id FROM categorias WHERE nombre='Abarrotes'), (SELECT id FROM marcas WHERE nombre='Gloria'),
        (SELECT id FROM unidades_medida WHERE abreviatura='UND'), (SELECT id FROM proveedores LIMIT 1), 3.20, 4.20, 50, 10),
    ('PRD-0002', '7750182002016', 'Fideos Don Vittorio spaghetti 500g',
        (SELECT id FROM categorias WHERE nombre='Abarrotes'), (SELECT id FROM marcas WHERE nombre='Alicorp'),
        (SELECT id FROM unidades_medida WHERE abreviatura='UND'), (SELECT id FROM proveedores LIMIT 1), 2.50, 3.50, 40, 10),
    ('PRD-0003', '7750182003013', 'Coca-Cola 500ml',
        (SELECT id FROM categorias WHERE nombre='Bebidas'), (SELECT id FROM marcas WHERE nombre='Coca-Cola'),
        (SELECT id FROM unidades_medida WHERE abreviatura='UND'), (SELECT id FROM proveedores LIMIT 1), 2.00, 3.00, 60, 15),
    ('PRD-0004', '7750182004010', 'Detergente genérico 1kg',
        (SELECT id FROM categorias WHERE nombre='Limpieza'), (SELECT id FROM marcas WHERE nombre='Genérico'),
        (SELECT id FROM unidades_medida WHERE abreviatura='UND'), (SELECT id FROM proveedores LIMIT 1), 5.00, 7.00, 25, 5),
    ('PRD-0005', '7750182005017', 'Papitas fritas 45g',
        (SELECT id FROM categorias WHERE nombre='Snacks'), (SELECT id FROM marcas WHERE nombre='Genérico'),
        (SELECT id FROM unidades_medida WHERE abreviatura='UND'), (SELECT id FROM proveedores LIMIT 1), 1.00, 1.50, 100, 20);

-- Movimiento de inventario inicial (carga de stock) para dejar historial coherente con stock_actual
INSERT INTO inventario_movimientos (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, motivo, usuario_id)
SELECT id, 'ENTRADA', stock_actual, 0, stock_actual, 'Carga inicial de stock (datos de prueba)',
       (SELECT id FROM usuarios WHERE username = 'admin')
FROM productos;
