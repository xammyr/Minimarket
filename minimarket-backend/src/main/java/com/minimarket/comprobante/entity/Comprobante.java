package com.minimarket.comprobante.entity;

import com.minimarket.cliente.entity.Cliente;
import com.minimarket.common.BaseEntity;
import com.minimarket.venta.entity.Venta;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

/**
 * Documento tributario (boleta/factura/nota). Independiente de Venta y de
 * DocumentoElectronico (que maneja el ciclo con SUNAT). Ver seccion 6 del plan.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "comprobantes")
public class Comprobante extends BaseEntity {

    public enum EstadoComprobante { EMITIDO, ANULADO }

    /** Puede ser null: una nota de credito/debito referencia otro comprobante, no una venta. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venta_id")
    private Venta venta;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tipo_comprobante_id", nullable = false)
    private TipoComprobante tipoComprobante;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "serie_id", nullable = false)
    private SerieComprobante serie;

    @Column(nullable = false)
    private Long numero;

    /** Para notas de credito/debito: el comprobante original al que afectan. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comprobante_referencia_id")
    private Comprobante comprobanteReferencia;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @Column(name = "fecha_emision", nullable = false)
    private OffsetDateTime fechaEmision;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal descuento = BigDecimal.ZERO;

    @Column(nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal igv = BigDecimal.ZERO;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal total;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    @Builder.Default
    private EstadoComprobante estado = EstadoComprobante.EMITIDO;

    @Column(name = "motivo_anulacion", length = 200)
    private String motivoAnulacion;
}
