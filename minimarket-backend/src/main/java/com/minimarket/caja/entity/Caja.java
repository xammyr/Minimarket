package com.minimarket.caja.entity;

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
@Table(name = "cajas")
public class Caja extends BaseEntity {

    @Column(nullable = false, length = 60)
    private String nombre;

    @Column(length = 120)
    private String ubicacion;

    @Column(nullable = false)
    @Builder.Default
    private Boolean activo = true;
}
