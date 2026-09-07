# Minimarket Backend v0.2

Backend REST para POS de minimarket con Java 21 + Spring Boot 3 + PostgreSQL + Flyway.

## Qué incorpora v0.2

- Autenticación JWT real.
- Roles y permisos cargados desde BD.
- Protección de endpoints con Spring Security.
- CRUD de productos, categorías, marcas, unidades, clientes y proveedores.
- Búsqueda de producto por código de barras.
- Movimientos de inventario transaccionales.
- Apertura y cierre de turnos de caja.
- Ventas con múltiples productos y pagos combinados.
- Descuento de stock y registro de efectivo en caja al completar una venta.
- Anulación de venta con devolución de stock y reversa del efectivo.
- Validación de DTOs y manejo de errores sin filtrar excepciones internas.
- CORS para frontend local (Vite/React).
- Migraciones Flyway separadas de los datos ficticios de desarrollo.
- V15 de hardening de integridad e índices.

## Arranque local

1. Crear una base PostgreSQL llamada `minimarket`.
2. Ejecutar la aplicación con el perfil `dev`.
3. Flyway aplicará V1..V13, V14 desde `db/migration/dev` y V15.
4. El usuario de desarrollo sembrado por V14 es `admin` / `Admin123!`. Cambiarlo antes de cualquier uso real.

Variables opcionales de desarrollo:

```text
DB_URL=jdbc:postgresql://localhost:5432/minimarket
DB_USERNAME=postgres
DB_PASSWORD=postgres
JWT_SECRET=una-clave-larga-solo-para-desarrollo
```

Para producción, `JWT_SECRET`, `DB_URL`, `DB_USERNAME` y `DB_PASSWORD` son obligatorios y los datos de prueba V14 no se cargan.

## API principal

```text
POST /api/auth/login

GET/POST/PUT/DELETE /api/productos
GET /api/productos/barcode/{codigoBarras}

GET/POST/PUT/DELETE /api/categorias
GET/POST/PUT/DELETE /api/marcas
GET/POST/PUT /api/unidades-medida

GET/POST/PUT/DELETE /api/clientes
GET /api/clientes/documento/{numero}

GET/POST/PUT/DELETE /api/proveedores

POST /api/inventario/movimientos
GET  /api/inventario/kardex/{productoId}

POST /api/caja-turnos/abrir
GET  /api/caja-turnos/actual/{cajaId}
POST /api/caja-turnos/{id}/cerrar

POST /api/ventas
GET  /api/ventas
GET  /api/ventas/{id}
POST /api/ventas/{id}/anular
```

## Importante

La emisión electrónica SUNAT queda desacoplada del núcleo comercial. Antes de implementarla se debe validar la normativa y el formato electrónico vigente.

La venta, inventario y caja se procesan de forma transaccional; una venta no debe quedar parcialmente registrada si falla el descuento de stock o la validación de pagos.
