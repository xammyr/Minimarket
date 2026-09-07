package com.minimarket.comprobante.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

/** Catalogo estatico (TICKET, BOLETA, FACTURA, NOTA_CREDITO, NOTA_DEBITO). */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "tipos_comprobante")
public class TipoComprobante {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 15)
    private String codigo;

    @Column(nullable = false, length = 50)
    private String nombre;

    @Column(name = "requiere_cliente_ruc", nullable = false)
    @Builder.Default
    private Boolean requiereClienteRuc = false;

    @Column(name = "es_electronico", nullable = false)
    @Builder.Default
    private Boolean esElectronico = false;
}
