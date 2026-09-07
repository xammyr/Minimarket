-- =========================================================================
-- V2: Seguridad (usuarios, roles, permisos)
-- =========================================================================
CREATE TABLE usuarios (
    id              BIGSERIAL PRIMARY KEY,
    username        VARCHAR(40)  NOT NULL UNIQUE,
    password_hash   VARCHAR(100) NOT NULL,
    nombres         VARCHAR(80)  NOT NULL,
    apellidos       VARCHAR(80)  NOT NULL,
    email           VARCHAR(120) UNIQUE,
    telefono        VARCHAR(20),
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    ultimo_acceso   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
CREATE INDEX idx_usuarios_activo ON usuarios(activo);

CREATE TABLE roles (
    id          BIGSERIAL PRIMARY KEY,
    nombre      VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_roles_updated_at BEFORE UPDATE ON roles
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TABLE permisos (
    id          BIGSERIAL PRIMARY KEY,
    codigo      VARCHAR(60) NOT NULL UNIQUE,   -- ej: PRODUCTO_CREAR, VENTA_ANULAR
    nombre      VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE usuario_rol (
    usuario_id   BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol_id       BIGINT NOT NULL REFERENCES roles(id)    ON DELETE RESTRICT,
    asignado_en  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (usuario_id, rol_id)
);

CREATE TABLE rol_permiso (
    rol_id      BIGINT NOT NULL REFERENCES roles(id)    ON DELETE CASCADE,
    permiso_id  BIGINT NOT NULL REFERENCES permisos(id) ON DELETE CASCADE,
    PRIMARY KEY (rol_id, permiso_id)
);

COMMENT ON TABLE usuarios IS 'Usuarios del sistema (cajeros, administradores, etc).';
COMMENT ON COLUMN usuarios.password_hash IS 'Hash BCrypt generado por Spring Security, nunca texto plano.';
