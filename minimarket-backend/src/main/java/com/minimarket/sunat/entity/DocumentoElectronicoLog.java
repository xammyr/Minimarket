package com.minimarket.sunat.entity;

import com.minimarket.common.BaseCreatedEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

/** Trazabilidad evento a evento del envio a SUNAT (util para diagnosticar fallos, seccion 10 del plan). */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "documentos_electronicos_log")
public class DocumentoElectronicoLog extends BaseCreatedEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "documento_electronico_id", nullable = false)
    private DocumentoElectronico documentoElectronico;

    @Column(nullable = false, length = 50)
    private String evento;

    @JdbcTypeCode(SqlTypes.LONGVARCHAR)
    @Column(name = "detalle")
    private String detalle;
}
