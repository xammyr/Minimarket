package com.minimarket.sunat.entity;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import com.minimarket.comprobante.entity.Comprobante;
import com.minimarket.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import java.time.OffsetDateTime;


/**
 * Ciclo de vida del documento electronico ante SUNAT (Fase 12 del plan).
 * Desacoplado a proposito: un problema aqui nunca revierte una venta ya registrada.
 * La estructura de campos se validara contra la normativa vigente antes de
 * implementar la emision real (ver database/README.md).
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "documentos_electronicos")
public class DocumentoElectronico extends BaseEntity {

    public enum EstadoDocumentoElectronico {
        PENDIENTE, GENERADO, FIRMADO, ENVIADO, ACEPTADO, RECHAZADO, ANULADO
    }

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "comprobante_id", nullable = false, unique = true)
    private Comprobante comprobante;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    @Builder.Default
    private EstadoDocumentoElectronico estado = EstadoDocumentoElectronico.PENDIENTE;

    @Column(name = "xml_nombre_archivo", length = 150)
    private String xmlNombreArchivo;

    @JdbcTypeCode(SqlTypes.LONGVARCHAR)
    @Column(name = "xml_contenido")
    private String xmlContenido;

    @JdbcTypeCode(SqlTypes.LONGVARCHAR)
    @Column(name = "xml_firmado_contenido")
    private String xmlFirmadoContenido;

    @Column(name = "hash_codigo", length = 100)
    private String hashCodigo;

    @Column(name = "ticket_sunat", length = 50)
    private String ticketSunat;

    @Column(name = "cdr_nombre_archivo", length = 150)
    private String cdrNombreArchivo;

    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "cdr_contenido")
    private byte[] cdrContenido;

    @JdbcTypeCode(SqlTypes.LONGVARCHAR)
    @Column(name = "mensaje_respuesta")
    private String mensajeRespuesta;

    @Column(name = "intentos_envio", nullable = false)
    @Builder.Default
    private Integer intentosEnvio = 0;

    @Column(name = "fecha_generacion")
    private OffsetDateTime fechaGeneracion;

    @Column(name = "fecha_envio")
    private OffsetDateTime fechaEnvio;

    @Column(name = "fecha_respuesta")
    private OffsetDateTime fechaRespuesta;
}
