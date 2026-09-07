# Backend / Database v0.2

## Implementado
- JWT real conectado a Spring Security.
- Roles y permisos derivados de la BD.
- Login `/api/auth/login`.
- Protección de endpoints con permisos.
- CRUD de categorías, marcas, unidades, clientes y proveedores.
- Búsqueda de productos por código de barras.
- Validaciones de unicidad de código interno y código de barras.
- Inventario transaccional con kardex y stock no negativo.
- Apertura/cierre de caja.
- Venta transaccional con pago combinado.
- Descuento de stock por venta.
- Registro de efectivo en caja.
- Anulación con devolución de stock y reversa del efectivo.
- CORS para frontend local.
- Manejo de errores sin exposición de mensajes internos.
- Separación de datos de prueba V14 respecto de migraciones de producción.
- V15 con restricciones, índices y permisos adicionales.

## Pendiente para v0.3
- CRUD de usuarios/roles/permisos desde API.
- Gestión avanzada de lotes y vencimientos.
- Compras.
- Comprobantes y series/correlativos.
- Auditoría automática/AOP.
- Reportes.
- SUNAT/UBL/XML/firma/envío/consulta de CDR.
- Tests de integración con PostgreSQL/Testcontainers.
- Idempotencia de operaciones de venta y endpoints de caja.
