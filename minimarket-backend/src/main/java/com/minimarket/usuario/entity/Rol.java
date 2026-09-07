package com.minimarket.usuario.entity;

import com.minimarket.common.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import java.util.HashSet;
import java.util.Set;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @SuperBuilder
@Entity @Table(name = "roles")
public class Rol extends BaseEntity {
    @Column(nullable = false, unique = true, length = 40)
    private String nombre;
    @Column(length = 200)
    private String descripcion;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "rol_permiso",
            joinColumns = @JoinColumn(name = "rol_id"),
            inverseJoinColumns = @JoinColumn(name = "permiso_id"))
    @Builder.Default
    private Set<Permiso> permisos = new HashSet<>();
}
