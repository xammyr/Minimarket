package com.minimarket.caja.entity;

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
@Table(name = "caja_turnos")
public class CajaTurno extends BaseEntity {

    public enum EstadoCajaTurno { ABIERTO, CERRADO }

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "caja_id", nullable = false)
    private Caja caja;

    /** Cajero que abrio el turno. */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "monto_apertura", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal montoApertura = BigDecimal.ZERO;

    @Column(name = "fecha_apertura", nullable = false)
    private OffsetDateTime fechaApertura;

    @Column(name = "monto_cierre_esperado", precision = 12, scale = 2)
    private BigDecimal montoCierreEsperado;

    @Column(name = "monto_cierre_real", precision = 12, scale = 2)
    private BigDecimal montoCierreReal;

    private BigDecimal diferencia;

    @Column(name = "fecha_cierre")
    private OffsetDateTime fechaCierre;

    /** Quien cerro el turno (puede diferir del que lo abrio). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_cierre_id")
    private Usuario usuarioCierre;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default
    private EstadoCajaTurno estado = EstadoCajaTurno.ABIERTO;

    @Column(columnDefinition = "TEXT")
    private String observaciones;
}
