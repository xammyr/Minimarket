package com.minimarket.producto.entity;

import com.minimarket.common.BaseCreatedEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
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
@Table(name = "unidades_medida")
public class UnidadMedida extends BaseCreatedEntity {

    @Column(nullable = false, unique = true, length = 30)
    private String nombre;

    @Column(nullable = false, unique = true, length = 10)
    private String abreviatura;
}
