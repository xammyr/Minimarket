package com.minimarket.venta.entity;

import com.minimarket.caja.entity.CajaTurno;
import com.minimarket.cliente.entity.Cliente;
import com.minimarket.common.BaseEntity;
import com.minimarket.usuario.entity.Usuario;
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

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "ventas")
public class Venta extends BaseEntity {

    public enum EstadoVenta { PENDIENTE, COMPLETADA, ANULADA }

    @Column(name = "numero_venta", nullable = false, unique = true, length = 20)
    private String numeroVenta;

    /** null = "Clientes Varios" (publico general). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    /** Cajero que registro la venta. */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "caja_turno_id", nullable = false)
    private CajaTurno cajaTurno;

    @Column(name = "fecha_venta", nullable = false)
    private OffsetDateTime fechaVenta;

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
    private EstadoVenta estado = EstadoVenta.COMPLETADA;

    @Column(name = "motivo_anulacion", length = 200)
    private String motivoAnulacion;
}
