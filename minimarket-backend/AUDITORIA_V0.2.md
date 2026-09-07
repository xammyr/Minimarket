# Auditoría y mejoras v0.2

## Alcance
Se revisó el backend y las migraciones existentes y se construyó una versión incremental sin rehacer la arquitectura.

## Correcciones clave
1. Seguridad JWT conectada a Spring Security.
2. Roles/permisos de BD convertidos en authorities.
3. Login real.
4. Endpoints de producto protegidos por permisos.
5. Validación de códigos internos y de barras.
6. Actualización correcta de marca/proveedor en productos.
7. CRUD operativo para categorías, marcas, unidades, clientes y proveedores.
8. Inventario transaccional con prohibición de stock negativo.
9. Caja: apertura/cierre y cálculo esperado.
10. Ventas transaccionales con pagos combinados.
11. Venta: descuento de stock y registro de efectivo.
12. Anulación: devolución de stock y reversa del efectivo.
13. CORS para frontend local.
14. Errores internos no se exponen al cliente.
15. V14 de datos ficticios separada de migraciones de producción.
16. V15 agrega índices, restricciones y permisos maestros.

## Verificación realizada
- 125 archivos Java presentes.
- Balance de llaves `{}` verificado en todos los Java.
- Sin literales `\n` accidentales.
- Migraciones V1-V13 y V15 son idénticas entre backend y repositorio de BD.
- V14 de desarrollo es idéntica en ambos repositorios.
- No fue posible ejecutar `mvn test` en el entorno de auditoría porque Maven (`mvn`) no está instalado. Por eso esta entrega fue validada estáticamente, no como build Maven ejecutado.

## Pendientes
- Usuarios/roles/permisos CRUD.
- Lotes avanzados y FIFO/FEFO.
- Compras.
- Comprobantes.
- Auditoría automática.
- Reportes.
- SUNAT.
- Tests de integración con PostgreSQL.
