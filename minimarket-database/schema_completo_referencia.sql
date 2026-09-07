--
-- PostgreSQL database dump
--

\restrict JorkVUs72uGafVFgmDluaxBxlRB5uGzqWpm03U7W4vaQci1aaX8zGrVGN6jQ4qp

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION fn_set_updated_at(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.fn_set_updated_at() IS 'Actualiza automáticamente updated_at. Se asocia a tablas vía trigger BEFORE UPDATE.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auditoria_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auditoria_log (
    id bigint NOT NULL,
    usuario_id bigint,
    entidad character varying(60) NOT NULL,
    entidad_id bigint,
    accion character varying(20) NOT NULL,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    ip_origen character varying(45),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT auditoria_log_accion_check CHECK (((accion)::text = ANY ((ARRAY['CREATE'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying, 'LOGIN'::character varying, 'LOGOUT'::character varying, 'ANULACION'::character varying])::text[])))
);


--
-- Name: auditoria_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auditoria_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auditoria_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auditoria_log_id_seq OWNED BY public.auditoria_log.id;


--
-- Name: caja_movimientos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.caja_movimientos (
    id bigint NOT NULL,
    caja_turno_id bigint NOT NULL,
    tipo_movimiento character varying(20) NOT NULL,
    monto numeric(12,2) NOT NULL,
    concepto character varying(150),
    referencia_tipo character varying(30),
    referencia_id bigint,
    usuario_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT caja_movimientos_monto_check CHECK ((monto <> (0)::numeric)),
    CONSTRAINT caja_movimientos_tipo_movimiento_check CHECK (((tipo_movimiento)::text = ANY ((ARRAY['APERTURA'::character varying, 'INGRESO'::character varying, 'EGRESO'::character varying, 'VENTA'::character varying])::text[])))
);


--
-- Name: caja_movimientos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.caja_movimientos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caja_movimientos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.caja_movimientos_id_seq OWNED BY public.caja_movimientos.id;


--
-- Name: caja_turnos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.caja_turnos (
    id bigint NOT NULL,
    caja_id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    monto_apertura numeric(12,2) DEFAULT 0 NOT NULL,
    fecha_apertura timestamp with time zone DEFAULT now() NOT NULL,
    monto_cierre_esperado numeric(12,2),
    monto_cierre_real numeric(12,2),
    diferencia numeric(12,2),
    fecha_cierre timestamp with time zone,
    usuario_cierre_id bigint,
    estado character varying(10) DEFAULT 'ABIERTO'::character varying NOT NULL,
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT caja_turnos_estado_check CHECK (((estado)::text = ANY ((ARRAY['ABIERTO'::character varying, 'CERRADO'::character varying])::text[]))),
    CONSTRAINT caja_turnos_monto_apertura_check CHECK ((monto_apertura >= (0)::numeric))
);


--
-- Name: caja_turnos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.caja_turnos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caja_turnos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.caja_turnos_id_seq OWNED BY public.caja_turnos.id;


--
-- Name: cajas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cajas (
    id bigint NOT NULL,
    nombre character varying(60) NOT NULL,
    ubicacion character varying(120),
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cajas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cajas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cajas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cajas_id_seq OWNED BY public.cajas.id;


--
-- Name: categorias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorias (
    id bigint NOT NULL,
    nombre character varying(80) NOT NULL,
    descripcion character varying(200),
    categoria_padre_id bigint,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categorias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorias_id_seq OWNED BY public.categorias.id;


--
-- Name: clientes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clientes (
    id bigint NOT NULL,
    tipo_documento_id bigint NOT NULL,
    numero_documento character varying(20) NOT NULL,
    nombre_razon_social character varying(150) NOT NULL,
    nombre_comercial character varying(150),
    direccion character varying(200),
    telefono character varying(20),
    email character varying(120),
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clientes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- Name: comprobante_detalle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comprobante_detalle (
    id bigint NOT NULL,
    comprobante_id bigint NOT NULL,
    producto_id bigint,
    descripcion character varying(200) NOT NULL,
    cantidad numeric(12,3) NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    descuento numeric(12,2) DEFAULT 0 NOT NULL,
    igv numeric(12,2) DEFAULT 0 NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    total numeric(12,2) NOT NULL,
    CONSTRAINT comprobante_detalle_cantidad_check CHECK ((cantidad > (0)::numeric)),
    CONSTRAINT comprobante_detalle_precio_unitario_check CHECK ((precio_unitario >= (0)::numeric))
);


--
-- Name: comprobante_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comprobante_detalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comprobante_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comprobante_detalle_id_seq OWNED BY public.comprobante_detalle.id;


--
-- Name: comprobantes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comprobantes (
    id bigint NOT NULL,
    venta_id bigint,
    tipo_comprobante_id bigint NOT NULL,
    serie_id bigint NOT NULL,
    numero bigint NOT NULL,
    comprobante_referencia_id bigint,
    cliente_id bigint,
    fecha_emision timestamp with time zone DEFAULT now() NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    descuento numeric(12,2) DEFAULT 0 NOT NULL,
    igv numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) NOT NULL,
    estado character varying(15) DEFAULT 'EMITIDO'::character varying NOT NULL,
    motivo_anulacion character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT comprobantes_descuento_check CHECK ((descuento >= (0)::numeric)),
    CONSTRAINT comprobantes_estado_check CHECK (((estado)::text = ANY ((ARRAY['EMITIDO'::character varying, 'ANULADO'::character varying])::text[]))),
    CONSTRAINT comprobantes_igv_check CHECK ((igv >= (0)::numeric)),
    CONSTRAINT comprobantes_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT comprobantes_total_check CHECK ((total >= (0)::numeric))
);


--
-- Name: TABLE comprobantes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.comprobantes IS 'Documento tributario (boleta/factura/nota). Independiente de venta y de documentos_electronicos (que maneja el ciclo con SUNAT).';


--
-- Name: COLUMN comprobantes.venta_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.comprobantes.venta_id IS 'NULL permitido: una nota de crédito/débito referencia otro comprobante (comprobante_referencia_id), no directamente una venta.';


--
-- Name: comprobantes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comprobantes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comprobantes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comprobantes_id_seq OWNED BY public.comprobantes.id;


--
-- Name: documentos_electronicos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documentos_electronicos (
    id bigint NOT NULL,
    comprobante_id bigint NOT NULL,
    estado character varying(15) DEFAULT 'PENDIENTE'::character varying NOT NULL,
    xml_nombre_archivo character varying(150),
    xml_contenido text,
    xml_firmado_contenido text,
    hash_codigo character varying(100),
    ticket_sunat character varying(50),
    cdr_nombre_archivo character varying(150),
    cdr_contenido bytea,
    mensaje_respuesta text,
    intentos_envio integer DEFAULT 0 NOT NULL,
    fecha_generacion timestamp with time zone,
    fecha_envio timestamp with time zone,
    fecha_respuesta timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT documentos_electronicos_estado_check CHECK (((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'GENERADO'::character varying, 'FIRMADO'::character varying, 'ENVIADO'::character varying, 'ACEPTADO'::character varying, 'RECHAZADO'::character varying, 'ANULADO'::character varying])::text[])))
);


--
-- Name: TABLE documentos_electronicos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.documentos_electronicos IS 'Ciclo de vida del documento electrónico ante SUNAT. Un problema aquí nunca debe revertir una venta ya registrada.';


--
-- Name: documentos_electronicos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documentos_electronicos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documentos_electronicos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documentos_electronicos_id_seq OWNED BY public.documentos_electronicos.id;


--
-- Name: documentos_electronicos_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documentos_electronicos_log (
    id bigint NOT NULL,
    documento_electronico_id bigint NOT NULL,
    evento character varying(50) NOT NULL,
    detalle text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: documentos_electronicos_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documentos_electronicos_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documentos_electronicos_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documentos_electronicos_log_id_seq OWNED BY public.documentos_electronicos_log.id;


--
-- Name: inventario_movimientos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventario_movimientos (
    id bigint NOT NULL,
    producto_id bigint NOT NULL,
    lote_id bigint,
    tipo_movimiento character varying(20) NOT NULL,
    cantidad numeric(12,3) NOT NULL,
    stock_anterior numeric(12,3) NOT NULL,
    stock_resultante numeric(12,3) NOT NULL,
    motivo character varying(200),
    referencia_tipo character varying(30),
    referencia_id bigint,
    usuario_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT inventario_movimientos_cantidad_check CHECK ((cantidad > (0)::numeric)),
    CONSTRAINT inventario_movimientos_tipo_movimiento_check CHECK (((tipo_movimiento)::text = ANY ((ARRAY['ENTRADA'::character varying, 'SALIDA'::character varying, 'AJUSTE_POSITIVO'::character varying, 'AJUSTE_NEGATIVO'::character varying, 'VENTA'::character varying, 'DEVOLUCION_VENTA'::character varying, 'DEVOLUCION_COMPRA'::character varying])::text[])))
);


--
-- Name: TABLE inventario_movimientos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.inventario_movimientos IS 'Historial inmutable de todo movimiento de stock. productos.stock_actual es una caché derivada de esta tabla.';


--
-- Name: inventario_movimientos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventario_movimientos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventario_movimientos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventario_movimientos_id_seq OWNED BY public.inventario_movimientos.id;


--
-- Name: lotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lotes (
    id bigint NOT NULL,
    producto_id bigint NOT NULL,
    numero_lote character varying(50) NOT NULL,
    fecha_vencimiento date,
    fecha_ingreso date DEFAULT CURRENT_DATE NOT NULL,
    cantidad_inicial numeric(12,3) NOT NULL,
    cantidad_actual numeric(12,3) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT lotes_cantidad_actual_check CHECK ((cantidad_actual >= (0)::numeric)),
    CONSTRAINT lotes_cantidad_inicial_check CHECK ((cantidad_inicial >= (0)::numeric))
);


--
-- Name: lotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lotes_id_seq OWNED BY public.lotes.id;


--
-- Name: marcas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marcas (
    id bigint NOT NULL,
    nombre character varying(80) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: marcas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marcas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marcas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marcas_id_seq OWNED BY public.marcas.id;


--
-- Name: metodos_pago; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metodos_pago (
    id bigint NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre character varying(50) NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: metodos_pago_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.metodos_pago_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metodos_pago_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.metodos_pago_id_seq OWNED BY public.metodos_pago.id;


--
-- Name: permisos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permisos (
    id bigint NOT NULL,
    codigo character varying(60) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: permisos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permisos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permisos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permisos_id_seq OWNED BY public.permisos.id;


--
-- Name: productos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productos (
    id bigint NOT NULL,
    codigo_interno character varying(30) NOT NULL,
    codigo_barras character varying(30),
    nombre character varying(150) NOT NULL,
    descripcion text,
    categoria_id bigint NOT NULL,
    marca_id bigint,
    unidad_medida_id bigint NOT NULL,
    proveedor_id bigint,
    precio_compra numeric(12,2) DEFAULT 0 NOT NULL,
    precio_venta numeric(12,2) NOT NULL,
    afecto_igv boolean DEFAULT true NOT NULL,
    stock_actual numeric(12,3) DEFAULT 0 NOT NULL,
    stock_minimo numeric(12,3) DEFAULT 0 NOT NULL,
    controla_stock boolean DEFAULT true NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT productos_precio_compra_check CHECK ((precio_compra >= (0)::numeric)),
    CONSTRAINT productos_precio_venta_check CHECK ((precio_venta >= (0)::numeric)),
    CONSTRAINT productos_stock_actual_check CHECK ((stock_actual >= (0)::numeric)),
    CONSTRAINT productos_stock_minimo_check CHECK ((stock_minimo >= (0)::numeric))
);


--
-- Name: COLUMN productos.stock_actual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.productos.stock_actual IS 'Cache del stock vigente. La fuente de verdad histórica es inventario_movimientos; este campo se recalcula transaccionalmente en cada movimiento.';


--
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- Name: proveedores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proveedores (
    id bigint NOT NULL,
    tipo_documento character varying(4) DEFAULT 'RUC'::character varying NOT NULL,
    numero_documento character varying(20) NOT NULL,
    razon_social character varying(150) NOT NULL,
    nombre_comercial character varying(150),
    direccion character varying(200),
    telefono character varying(20),
    email character varying(120),
    contacto_nombre character varying(100),
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT proveedores_tipo_documento_check CHECK (((tipo_documento)::text = ANY ((ARRAY['RUC'::character varying, 'DNI'::character varying, 'CE'::character varying])::text[])))
);


--
-- Name: proveedores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proveedores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proveedores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proveedores_id_seq OWNED BY public.proveedores.id;


--
-- Name: rol_permiso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rol_permiso (
    rol_id bigint NOT NULL,
    permiso_id bigint NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    nombre character varying(40) NOT NULL,
    descripcion character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: series_comprobante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.series_comprobante (
    id bigint NOT NULL,
    tipo_comprobante_id bigint NOT NULL,
    serie character varying(4) NOT NULL,
    correlativo_actual bigint DEFAULT 0 NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT series_comprobante_correlativo_actual_check CHECK ((correlativo_actual >= 0))
);


--
-- Name: series_comprobante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.series_comprobante_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_comprobante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.series_comprobante_id_seq OWNED BY public.series_comprobante.id;


--
-- Name: tipos_comprobante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipos_comprobante (
    id bigint NOT NULL,
    codigo character varying(15) NOT NULL,
    nombre character varying(50) NOT NULL,
    requiere_cliente_ruc boolean DEFAULT false NOT NULL,
    es_electronico boolean DEFAULT false NOT NULL
);


--
-- Name: tipos_comprobante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipos_comprobante_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipos_comprobante_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipos_comprobante_id_seq OWNED BY public.tipos_comprobante.id;


--
-- Name: tipos_documento_identidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipos_documento_identidad (
    id bigint NOT NULL,
    codigo character varying(15) NOT NULL,
    nombre character varying(60) NOT NULL
);


--
-- Name: tipos_documento_identidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipos_documento_identidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipos_documento_identidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipos_documento_identidad_id_seq OWNED BY public.tipos_documento_identidad.id;


--
-- Name: unidades_medida; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unidades_medida (
    id bigint NOT NULL,
    nombre character varying(30) NOT NULL,
    abreviatura character varying(10) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: unidades_medida_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unidades_medida_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unidades_medida_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unidades_medida_id_seq OWNED BY public.unidades_medida.id;


--
-- Name: usuario_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_rol (
    usuario_id bigint NOT NULL,
    rol_id bigint NOT NULL,
    asignado_en timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id bigint NOT NULL,
    username character varying(40) NOT NULL,
    password_hash character varying(100) NOT NULL,
    nombres character varying(80) NOT NULL,
    apellidos character varying(80) NOT NULL,
    email character varying(120),
    telefono character varying(20),
    activo boolean DEFAULT true NOT NULL,
    ultimo_acceso timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE usuarios; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.usuarios IS 'Usuarios del sistema (cajeros, administradores, etc).';


--
-- Name: COLUMN usuarios.password_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuarios.password_hash IS 'Hash BCrypt generado por Spring Security, nunca texto plano.';


--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: venta_detalle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venta_detalle (
    id bigint NOT NULL,
    venta_id bigint NOT NULL,
    producto_id bigint NOT NULL,
    cantidad numeric(12,3) NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    descuento numeric(12,2) DEFAULT 0 NOT NULL,
    igv numeric(12,2) DEFAULT 0 NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    total numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT venta_detalle_cantidad_check CHECK ((cantidad > (0)::numeric)),
    CONSTRAINT venta_detalle_descuento_check CHECK ((descuento >= (0)::numeric)),
    CONSTRAINT venta_detalle_igv_check CHECK ((igv >= (0)::numeric)),
    CONSTRAINT venta_detalle_precio_unitario_check CHECK ((precio_unitario >= (0)::numeric))
);


--
-- Name: venta_detalle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.venta_detalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venta_detalle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.venta_detalle_id_seq OWNED BY public.venta_detalle.id;


--
-- Name: venta_pagos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venta_pagos (
    id bigint NOT NULL,
    venta_id bigint NOT NULL,
    metodo_pago_id bigint NOT NULL,
    monto numeric(12,2) NOT NULL,
    referencia character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT venta_pagos_monto_check CHECK ((monto > (0)::numeric))
);


--
-- Name: TABLE venta_pagos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.venta_pagos IS 'Una venta puede tener varias filas aquí (pago combinado: parte efectivo + parte Yape, etc). La suma de montos debe igualar ventas.total; esa regla se valida en el backend, no en la BD.';


--
-- Name: venta_pagos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.venta_pagos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venta_pagos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.venta_pagos_id_seq OWNED BY public.venta_pagos.id;


--
-- Name: ventas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ventas (
    id bigint NOT NULL,
    numero_venta character varying(20) NOT NULL,
    cliente_id bigint,
    usuario_id bigint NOT NULL,
    caja_turno_id bigint NOT NULL,
    fecha_venta timestamp with time zone DEFAULT now() NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    descuento numeric(12,2) DEFAULT 0 NOT NULL,
    igv numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) NOT NULL,
    estado character varying(15) DEFAULT 'COMPLETADA'::character varying NOT NULL,
    motivo_anulacion character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ventas_descuento_check CHECK ((descuento >= (0)::numeric)),
    CONSTRAINT ventas_estado_check CHECK (((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'COMPLETADA'::character varying, 'ANULADA'::character varying])::text[]))),
    CONSTRAINT ventas_igv_check CHECK ((igv >= (0)::numeric)),
    CONSTRAINT ventas_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT ventas_total_check CHECK ((total >= (0)::numeric))
);


--
-- Name: TABLE ventas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ventas IS 'Una venta NO es un comprobante: la venta es el hecho comercial/operativo. El comprobante (boleta/factura) se modela aparte en la tabla comprobantes.';


--
-- Name: ventas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ventas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- Name: auditoria_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_log ALTER COLUMN id SET DEFAULT nextval('public.auditoria_log_id_seq'::regclass);


--
-- Name: caja_movimientos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_movimientos ALTER COLUMN id SET DEFAULT nextval('public.caja_movimientos_id_seq'::regclass);


--
-- Name: caja_turnos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_turnos ALTER COLUMN id SET DEFAULT nextval('public.caja_turnos_id_seq'::regclass);


--
-- Name: cajas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cajas ALTER COLUMN id SET DEFAULT nextval('public.cajas_id_seq'::regclass);


--
-- Name: categorias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id SET DEFAULT nextval('public.categorias_id_seq'::regclass);


--
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- Name: comprobante_detalle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobante_detalle ALTER COLUMN id SET DEFAULT nextval('public.comprobante_detalle_id_seq'::regclass);


--
-- Name: comprobantes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes ALTER COLUMN id SET DEFAULT nextval('public.comprobantes_id_seq'::regclass);


--
-- Name: documentos_electronicos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos ALTER COLUMN id SET DEFAULT nextval('public.documentos_electronicos_id_seq'::regclass);


--
-- Name: documentos_electronicos_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos_log ALTER COLUMN id SET DEFAULT nextval('public.documentos_electronicos_log_id_seq'::regclass);


--
-- Name: inventario_movimientos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventario_movimientos ALTER COLUMN id SET DEFAULT nextval('public.inventario_movimientos_id_seq'::regclass);


--
-- Name: lotes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes ALTER COLUMN id SET DEFAULT nextval('public.lotes_id_seq'::regclass);


--
-- Name: marcas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas ALTER COLUMN id SET DEFAULT nextval('public.marcas_id_seq'::regclass);


--
-- Name: metodos_pago id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metodos_pago ALTER COLUMN id SET DEFAULT nextval('public.metodos_pago_id_seq'::regclass);


--
-- Name: permisos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permisos ALTER COLUMN id SET DEFAULT nextval('public.permisos_id_seq'::regclass);


--
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- Name: proveedores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proveedores ALTER COLUMN id SET DEFAULT nextval('public.proveedores_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: series_comprobante id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series_comprobante ALTER COLUMN id SET DEFAULT nextval('public.series_comprobante_id_seq'::regclass);


--
-- Name: tipos_comprobante id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipos_comprobante ALTER COLUMN id SET DEFAULT nextval('public.tipos_comprobante_id_seq'::regclass);


--
-- Name: tipos_documento_identidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipos_documento_identidad ALTER COLUMN id SET DEFAULT nextval('public.tipos_documento_identidad_id_seq'::regclass);


--
-- Name: unidades_medida id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidades_medida ALTER COLUMN id SET DEFAULT nextval('public.unidades_medida_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Name: venta_detalle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_detalle ALTER COLUMN id SET DEFAULT nextval('public.venta_detalle_id_seq'::regclass);


--
-- Name: venta_pagos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_pagos ALTER COLUMN id SET DEFAULT nextval('public.venta_pagos_id_seq'::regclass);


--
-- Name: ventas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);


--
-- Name: auditoria_log auditoria_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_log
    ADD CONSTRAINT auditoria_log_pkey PRIMARY KEY (id);


--
-- Name: caja_movimientos caja_movimientos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_movimientos
    ADD CONSTRAINT caja_movimientos_pkey PRIMARY KEY (id);


--
-- Name: caja_turnos caja_turnos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_turnos
    ADD CONSTRAINT caja_turnos_pkey PRIMARY KEY (id);


--
-- Name: cajas cajas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_pkey PRIMARY KEY (id);


--
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: clientes clientes_tipo_documento_id_numero_documento_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_tipo_documento_id_numero_documento_key UNIQUE (tipo_documento_id, numero_documento);


--
-- Name: comprobante_detalle comprobante_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobante_detalle
    ADD CONSTRAINT comprobante_detalle_pkey PRIMARY KEY (id);


--
-- Name: comprobantes comprobantes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_pkey PRIMARY KEY (id);


--
-- Name: comprobantes comprobantes_serie_id_numero_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_serie_id_numero_key UNIQUE (serie_id, numero);


--
-- Name: documentos_electronicos documentos_electronicos_comprobante_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos
    ADD CONSTRAINT documentos_electronicos_comprobante_id_key UNIQUE (comprobante_id);


--
-- Name: documentos_electronicos_log documentos_electronicos_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos_log
    ADD CONSTRAINT documentos_electronicos_log_pkey PRIMARY KEY (id);


--
-- Name: documentos_electronicos documentos_electronicos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos
    ADD CONSTRAINT documentos_electronicos_pkey PRIMARY KEY (id);


--
-- Name: inventario_movimientos inventario_movimientos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventario_movimientos
    ADD CONSTRAINT inventario_movimientos_pkey PRIMARY KEY (id);


--
-- Name: lotes lotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_pkey PRIMARY KEY (id);


--
-- Name: lotes lotes_producto_id_numero_lote_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_producto_id_numero_lote_key UNIQUE (producto_id, numero_lote);


--
-- Name: marcas marcas_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_nombre_key UNIQUE (nombre);


--
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- Name: metodos_pago metodos_pago_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metodos_pago
    ADD CONSTRAINT metodos_pago_codigo_key UNIQUE (codigo);


--
-- Name: metodos_pago metodos_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metodos_pago
    ADD CONSTRAINT metodos_pago_pkey PRIMARY KEY (id);


--
-- Name: permisos permisos_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_codigo_key UNIQUE (codigo);


--
-- Name: permisos permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id);


--
-- Name: productos productos_codigo_barras_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_codigo_barras_key UNIQUE (codigo_barras);


--
-- Name: productos productos_codigo_interno_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_codigo_interno_key UNIQUE (codigo_interno);


--
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (id);


--
-- Name: proveedores proveedores_tipo_documento_numero_documento_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_tipo_documento_numero_documento_key UNIQUE (tipo_documento, numero_documento);


--
-- Name: rol_permiso rol_permiso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_permiso
    ADD CONSTRAINT rol_permiso_pkey PRIMARY KEY (rol_id, permiso_id);


--
-- Name: roles roles_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_nombre_key UNIQUE (nombre);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: series_comprobante series_comprobante_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series_comprobante
    ADD CONSTRAINT series_comprobante_pkey PRIMARY KEY (id);


--
-- Name: series_comprobante series_comprobante_tipo_comprobante_id_serie_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series_comprobante
    ADD CONSTRAINT series_comprobante_tipo_comprobante_id_serie_key UNIQUE (tipo_comprobante_id, serie);


--
-- Name: tipos_comprobante tipos_comprobante_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipos_comprobante
    ADD CONSTRAINT tipos_comprobante_codigo_key UNIQUE (codigo);


--
-- Name: tipos_comprobante tipos_comprobante_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipos_comprobante
    ADD CONSTRAINT tipos_comprobante_pkey PRIMARY KEY (id);


--
-- Name: tipos_documento_identidad tipos_documento_identidad_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipos_documento_identidad
    ADD CONSTRAINT tipos_documento_identidad_codigo_key UNIQUE (codigo);


--
-- Name: tipos_documento_identidad tipos_documento_identidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipos_documento_identidad
    ADD CONSTRAINT tipos_documento_identidad_pkey PRIMARY KEY (id);


--
-- Name: unidades_medida unidades_medida_abreviatura_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidades_medida
    ADD CONSTRAINT unidades_medida_abreviatura_key UNIQUE (abreviatura);


--
-- Name: unidades_medida unidades_medida_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidades_medida
    ADD CONSTRAINT unidades_medida_nombre_key UNIQUE (nombre);


--
-- Name: unidades_medida unidades_medida_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidades_medida
    ADD CONSTRAINT unidades_medida_pkey PRIMARY KEY (id);


--
-- Name: usuario_rol usuario_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_pkey PRIMARY KEY (usuario_id, rol_id);


--
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- Name: venta_detalle venta_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT venta_detalle_pkey PRIMARY KEY (id);


--
-- Name: venta_pagos venta_pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_pagos
    ADD CONSTRAINT venta_pagos_pkey PRIMARY KEY (id);


--
-- Name: ventas ventas_numero_venta_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_numero_venta_key UNIQUE (numero_venta);


--
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- Name: idx_auditoria_entidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_entidad ON public.auditoria_log USING btree (entidad, entidad_id);


--
-- Name: idx_auditoria_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_fecha ON public.auditoria_log USING btree (created_at);


--
-- Name: idx_auditoria_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_usuario ON public.auditoria_log USING btree (usuario_id);


--
-- Name: idx_caja_movimientos_referencia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_caja_movimientos_referencia ON public.caja_movimientos USING btree (referencia_tipo, referencia_id);


--
-- Name: idx_caja_movimientos_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_caja_movimientos_turno ON public.caja_movimientos USING btree (caja_turno_id);


--
-- Name: idx_caja_turno_unico_abierto; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_caja_turno_unico_abierto ON public.caja_turnos USING btree (caja_id) WHERE ((estado)::text = 'ABIERTO'::text);


--
-- Name: idx_caja_turnos_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_caja_turnos_usuario ON public.caja_turnos USING btree (usuario_id);


--
-- Name: idx_clientes_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_activo ON public.clientes USING btree (activo);


--
-- Name: idx_comprobante_detalle_comprobante; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comprobante_detalle_comprobante ON public.comprobante_detalle USING btree (comprobante_id);


--
-- Name: idx_comprobantes_cliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comprobantes_cliente ON public.comprobantes USING btree (cliente_id);


--
-- Name: idx_comprobantes_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comprobantes_estado ON public.comprobantes USING btree (estado);


--
-- Name: idx_comprobantes_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comprobantes_fecha ON public.comprobantes USING btree (fecha_emision);


--
-- Name: idx_comprobantes_venta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comprobantes_venta ON public.comprobantes USING btree (venta_id);


--
-- Name: idx_doc_electronicos_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_doc_electronicos_estado ON public.documentos_electronicos USING btree (estado);


--
-- Name: idx_doc_electronicos_log_doc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_doc_electronicos_log_doc ON public.documentos_electronicos_log USING btree (documento_electronico_id);


--
-- Name: idx_inv_mov_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inv_mov_fecha ON public.inventario_movimientos USING btree (created_at);


--
-- Name: idx_inv_mov_producto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inv_mov_producto ON public.inventario_movimientos USING btree (producto_id);


--
-- Name: idx_inv_mov_referencia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inv_mov_referencia ON public.inventario_movimientos USING btree (referencia_tipo, referencia_id);


--
-- Name: idx_lotes_producto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lotes_producto ON public.lotes USING btree (producto_id);


--
-- Name: idx_lotes_vencimiento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lotes_vencimiento ON public.lotes USING btree (fecha_vencimiento);


--
-- Name: idx_productos_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_activo ON public.productos USING btree (activo);


--
-- Name: idx_productos_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_categoria ON public.productos USING btree (categoria_id);


--
-- Name: idx_productos_nombre_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_nombre_trgm ON public.productos USING gin (nombre public.gin_trgm_ops);


--
-- Name: idx_productos_proveedor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_proveedor ON public.productos USING btree (proveedor_id);


--
-- Name: idx_proveedores_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_proveedores_activo ON public.proveedores USING btree (activo);


--
-- Name: idx_usuarios_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_activo ON public.usuarios USING btree (activo);


--
-- Name: idx_venta_detalle_producto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_venta_detalle_producto ON public.venta_detalle USING btree (producto_id);


--
-- Name: idx_venta_detalle_venta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_venta_detalle_venta ON public.venta_detalle USING btree (venta_id);


--
-- Name: idx_venta_pagos_metodo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_venta_pagos_metodo ON public.venta_pagos USING btree (metodo_pago_id);


--
-- Name: idx_venta_pagos_venta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_venta_pagos_venta ON public.venta_pagos USING btree (venta_id);


--
-- Name: idx_ventas_caja_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_caja_turno ON public.ventas USING btree (caja_turno_id);


--
-- Name: idx_ventas_cliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_cliente ON public.ventas USING btree (cliente_id);


--
-- Name: idx_ventas_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_estado ON public.ventas USING btree (estado);


--
-- Name: idx_ventas_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_fecha ON public.ventas USING btree (fecha_venta);


--
-- Name: idx_ventas_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_usuario ON public.ventas USING btree (usuario_id);


--
-- Name: caja_turnos trg_caja_turnos_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_caja_turnos_updated_at BEFORE UPDATE ON public.caja_turnos FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: cajas trg_cajas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_cajas_updated_at BEFORE UPDATE ON public.cajas FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: categorias trg_categorias_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_categorias_updated_at BEFORE UPDATE ON public.categorias FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: clientes trg_clientes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_clientes_updated_at BEFORE UPDATE ON public.clientes FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: comprobantes trg_comprobantes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_comprobantes_updated_at BEFORE UPDATE ON public.comprobantes FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: documentos_electronicos trg_documentos_electronicos_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_documentos_electronicos_updated_at BEFORE UPDATE ON public.documentos_electronicos FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: lotes trg_lotes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_lotes_updated_at BEFORE UPDATE ON public.lotes FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: marcas trg_marcas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_marcas_updated_at BEFORE UPDATE ON public.marcas FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: productos trg_productos_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_productos_updated_at BEFORE UPDATE ON public.productos FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: proveedores trg_proveedores_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_proveedores_updated_at BEFORE UPDATE ON public.proveedores FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: roles trg_roles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: series_comprobante trg_series_comprobante_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_series_comprobante_updated_at BEFORE UPDATE ON public.series_comprobante FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: usuarios trg_usuarios_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_usuarios_updated_at BEFORE UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: ventas trg_ventas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ventas_updated_at BEFORE UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: auditoria_log auditoria_log_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_log
    ADD CONSTRAINT auditoria_log_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: caja_movimientos caja_movimientos_caja_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_movimientos
    ADD CONSTRAINT caja_movimientos_caja_turno_id_fkey FOREIGN KEY (caja_turno_id) REFERENCES public.caja_turnos(id) ON DELETE RESTRICT;


--
-- Name: caja_movimientos caja_movimientos_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_movimientos
    ADD CONSTRAINT caja_movimientos_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- Name: caja_turnos caja_turnos_caja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_turnos
    ADD CONSTRAINT caja_turnos_caja_id_fkey FOREIGN KEY (caja_id) REFERENCES public.cajas(id) ON DELETE RESTRICT;


--
-- Name: caja_turnos caja_turnos_usuario_cierre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_turnos
    ADD CONSTRAINT caja_turnos_usuario_cierre_id_fkey FOREIGN KEY (usuario_cierre_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: caja_turnos caja_turnos_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.caja_turnos
    ADD CONSTRAINT caja_turnos_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- Name: categorias categorias_categoria_padre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_categoria_padre_id_fkey FOREIGN KEY (categoria_padre_id) REFERENCES public.categorias(id) ON DELETE SET NULL;


--
-- Name: clientes clientes_tipo_documento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_tipo_documento_id_fkey FOREIGN KEY (tipo_documento_id) REFERENCES public.tipos_documento_identidad(id) ON DELETE RESTRICT;


--
-- Name: comprobante_detalle comprobante_detalle_comprobante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobante_detalle
    ADD CONSTRAINT comprobante_detalle_comprobante_id_fkey FOREIGN KEY (comprobante_id) REFERENCES public.comprobantes(id) ON DELETE CASCADE;


--
-- Name: comprobante_detalle comprobante_detalle_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobante_detalle
    ADD CONSTRAINT comprobante_detalle_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id) ON DELETE SET NULL;


--
-- Name: comprobantes comprobantes_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE RESTRICT;


--
-- Name: comprobantes comprobantes_comprobante_referencia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_comprobante_referencia_id_fkey FOREIGN KEY (comprobante_referencia_id) REFERENCES public.comprobantes(id) ON DELETE RESTRICT;


--
-- Name: comprobantes comprobantes_serie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_serie_id_fkey FOREIGN KEY (serie_id) REFERENCES public.series_comprobante(id) ON DELETE RESTRICT;


--
-- Name: comprobantes comprobantes_tipo_comprobante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_tipo_comprobante_id_fkey FOREIGN KEY (tipo_comprobante_id) REFERENCES public.tipos_comprobante(id) ON DELETE RESTRICT;


--
-- Name: comprobantes comprobantes_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comprobantes
    ADD CONSTRAINT comprobantes_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE RESTRICT;


--
-- Name: documentos_electronicos documentos_electronicos_comprobante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos
    ADD CONSTRAINT documentos_electronicos_comprobante_id_fkey FOREIGN KEY (comprobante_id) REFERENCES public.comprobantes(id) ON DELETE RESTRICT;


--
-- Name: documentos_electronicos_log documentos_electronicos_log_documento_electronico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_electronicos_log
    ADD CONSTRAINT documentos_electronicos_log_documento_electronico_id_fkey FOREIGN KEY (documento_electronico_id) REFERENCES public.documentos_electronicos(id) ON DELETE CASCADE;


--
-- Name: inventario_movimientos inventario_movimientos_lote_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventario_movimientos
    ADD CONSTRAINT inventario_movimientos_lote_id_fkey FOREIGN KEY (lote_id) REFERENCES public.lotes(id) ON DELETE SET NULL;


--
-- Name: inventario_movimientos inventario_movimientos_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventario_movimientos
    ADD CONSTRAINT inventario_movimientos_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id) ON DELETE RESTRICT;


--
-- Name: inventario_movimientos inventario_movimientos_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventario_movimientos
    ADD CONSTRAINT inventario_movimientos_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- Name: lotes lotes_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id) ON DELETE RESTRICT;


--
-- Name: productos productos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categorias(id) ON DELETE RESTRICT;


--
-- Name: productos productos_marca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_marca_id_fkey FOREIGN KEY (marca_id) REFERENCES public.marcas(id) ON DELETE SET NULL;


--
-- Name: productos productos_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(id) ON DELETE SET NULL;


--
-- Name: productos productos_unidad_medida_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_unidad_medida_id_fkey FOREIGN KEY (unidad_medida_id) REFERENCES public.unidades_medida(id) ON DELETE RESTRICT;


--
-- Name: rol_permiso rol_permiso_permiso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_permiso
    ADD CONSTRAINT rol_permiso_permiso_id_fkey FOREIGN KEY (permiso_id) REFERENCES public.permisos(id) ON DELETE CASCADE;


--
-- Name: rol_permiso rol_permiso_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_permiso
    ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: series_comprobante series_comprobante_tipo_comprobante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series_comprobante
    ADD CONSTRAINT series_comprobante_tipo_comprobante_id_fkey FOREIGN KEY (tipo_comprobante_id) REFERENCES public.tipos_comprobante(id) ON DELETE RESTRICT;


--
-- Name: usuario_rol usuario_rol_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: usuario_rol usuario_rol_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: venta_detalle venta_detalle_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT venta_detalle_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id) ON DELETE RESTRICT;


--
-- Name: venta_detalle venta_detalle_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_detalle
    ADD CONSTRAINT venta_detalle_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: venta_pagos venta_pagos_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_pagos
    ADD CONSTRAINT venta_pagos_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES public.metodos_pago(id) ON DELETE RESTRICT;


--
-- Name: venta_pagos venta_pagos_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venta_pagos
    ADD CONSTRAINT venta_pagos_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: ventas ventas_caja_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_caja_turno_id_fkey FOREIGN KEY (caja_turno_id) REFERENCES public.caja_turnos(id) ON DELETE RESTRICT;


--
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE RESTRICT;


--
-- Name: ventas ventas_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict JorkVUs72uGafVFgmDluaxBxlRB5uGzqWpm03U7W4vaQci1aaX8zGrVGN6jQ4qp

-- V15 hardening (mantener referencia alineada con migrations/V15)
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
