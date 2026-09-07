package com.minimarket.proveedor.entity;

import com.minimarket.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "proveedores")
public class Proveedor extends BaseEntity {

    @Column(name = "tipo_documento", nullable = false, length = 4)
    @Builder.Default
    private String tipoDocumento = "RUC";

    @Column(name = "numero_documento", nullable = false, length = 20)
    private String numeroDocumento;

    @Column(name = "razon_social", nullable = false, length = 150)
    private String razonSocial;

    @Column(name = "nombre_comercial", length = 150)
    private String nombreComercial;

    @Column(length = 200)
    private String direccion;

    @Column(length = 20)
    private String telefono;

    @Column(length = 120)
    private String email;

    @Column(name = "contacto_nombre", length = 100)
    private String contactoNombre;

    @Column(nullable = false)
    @Builder.Default
    private Boolean activo = true;
}
