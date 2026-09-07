# Base de datos — Sistema POS Minimarket (PostgreSQL + Flyway)

Esquema completo (versión "final" según el plan) para poder probar ya
mismo, aunque el backend todavía se vaya construyendo por fases.
**Probado de extremo a extremo**: las 14 migraciones se ejecutaron contra
un PostgreSQL 16 real y se simuló un flujo completo de venta (turno de
caja → venta → pago combinado → descuento de stock → movimiento de
caja → comprobante con correlativo) sin errores. También se verificó que
la BD rechaza estados inválidos y turnos de caja duplicados.

## 1. Contenido

```
migrations/                          ← fuente de verdad (Flyway)
  V1__extensiones_y_funciones_comunes.sql
  V2__seguridad.sql                  usuarios, roles, permisos
  V3__proveedores.sql
  V4__catalogo_productos.sql         categorías, marcas, unidades, productos
  V5__clientes.sql
  V6__caja.sql                       cajas, turnos, movimientos
  V7__inventario.sql                 lotes, movimientos de stock
  V8__ventas.sql
  V9__pagos.sql                      pago combinado por venta
  V10__comprobantes.sql              boleta/factura/notas (independiente de la venta)
  V11__sunat.sql                     documento electrónico (desacoplado del núcleo)
  V12__auditoria.sql
  V13__seed_catalogos.sql            datos maestros (roles, métodos de pago, series...)
  V15__hardening_integridad_indices.sql  restricciones e índices de producción
  dev/V14__seed_datos_prueba.sql      datos ficticios SOLO para desarrollo/pruebas
schema_completo_referencia.sql       dump de solo-esquema, solo como referencia rápida
docker-compose.yml                   PostgreSQL local opcional para pruebas
```

Las tablas están organizadas exactamente según las áreas del documento
(sección 5): Seguridad, Catálogo, Inventario, Clientes, Ventas, Pagos,
Caja, Comprobantes, Electrónica/SUNAT, Auditoría. 28 tablas en total.

## 2. Decisiones de diseño clave (siguiendo la sección 6 del plan)

- **Venta ≠ Comprobante ≠ Documento electrónico**: son tres tablas
  distintas (`ventas`, `comprobantes`, `documentos_electronicos`). Una
  nota de crédito/débito referencia a otro comprobante
  (`comprobante_referencia_id`), no a una venta.
- **Pago combinado**: `venta_pagos` permite varias filas por venta
  (ej. parte efectivo + parte Yape). La suma debe cuadrar con
  `ventas.total`; esa validación es responsabilidad del backend.
- **Inventario con historial**: `productos.stock_actual` es una caché;
  la fuente de verdad es el historial inmutable en
  `inventario_movimientos`.
- **Caja**: `caja_turnos` registra apertura/cierre con diferencia
  calculada; un índice único parcial impide dos turnos `ABIERTO`
  simultáneos en la misma caja (regla de negocio forzada por la BD,
  no solo por el backend).
- **Estados en vez de borrados**: ventas y comprobantes usan
  `estado` (`CHECK`) en lugar de `DELETE` para no perder trazabilidad.
- **Auditoría**: `created_at`/`updated_at` en todas las tablas
  relevantes (actualizados automáticamente por trigger), más
  `auditoria_log` para acciones administrativas.
- **Series y correlativos**: `series_comprobante.correlativo_actual`
  se incrementa transaccionalmente al emitir cada comprobante.

## 3. Cómo levantarla para probar

**Opción A — ya tienes PostgreSQL instalado:**
```bash
createdb -U postgres minimarket
psql -U postgres -d minimarket -v ON_ERROR_STOP=1 -f migrations/V1__extensiones_y_funciones_comunes.sql
# ...repetir en orden hasta V15 (los datos V14 están dentro de migrations/dev y son solo de desarrollo)
```

**Opción B — Docker (no requiere instalar PostgreSQL):**
```bash
docker compose up -d
# espera unos segundos a que el healthcheck esté "healthy", luego aplica las migraciones igual que en la opción A
```

**Opción C — Flyway ya integrado en el backend:** el proyecto
`minimarket-backend` trae estas mismas migraciones en
`src/main/resources/db/migration`. Al levantar la app Spring Boot con
`spring.flyway.enabled=true` (por defecto), Flyway las aplica solo, en
orden, la primera vez que arranca.

## 4. Datos de prueba (`V14`)

- Usuario: `admin` / contraseña: `Admin123!` (rol ADMIN completo).
  **Cambiar antes de cualquier uso real.**
- Cliente genérico "Clientes Varios" (para boletas sin cliente
  identificado) y un cliente con RUC de prueba (para probar factura).
- Un proveedor, 4 categorías, 4 marcas y 5 productos típicos de
  minimarket con stock inicial.
- Una caja ("Caja principal").

**Para producción:** `V14` está separado en `migrations/dev/`, por lo que
el backend de producción solo carga `migrations/` y aplica hasta `V15`.
No se usa `flyway.target` para ocultar migraciones posteriores.

## 5. Qué falta (a propósito, para fases posteriores del plan)

- Validación normativa final de campos SUNAT (Fase 12) antes de cerrar
  la implementación del módulo electrónico — la estructura actual de
  `documentos_electronicos` es un contenedor genérico (XML/CDR/estado)
  pensado para ajustarse cuando se confirme el formato exacto.
- Multi-almacén: no incluido porque el plan no lo pide (minimarket de
  una sola ubicación); si en el futuro se necesita, se agrega una tabla
  `almacenes` y una FK en `inventario_movimientos` sin romper lo demás.
\n## 6. Hardening V15\n\nV15 refuerza que los stocks históricos no puedan resultar negativos y añade índices para búsquedas frecuentes de documentos, referencias de pago y lotes por vencer. No contiene datos de prueba.\n