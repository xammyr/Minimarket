package com.minimarket.common;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.OffsetDateTime;

/**
 * Superclase para entidades con id BIGSERIAL y auditoria created_at/updated_at,
 * siguiendo la regla de diseno de la seccion 6 del plan (todas las tablas
 * relevantes deben registrar created_at/updated_at).
 *
 * created_at/updated_at los mantiene Hibernate via @CreatedDate/@LastModifiedDate
 * (AuditingEntityListener) - EN PARALELO, la base de datos tambien los actualiza
 * por trigger (fn_set_updated_at) como segunda linea de defensa si alguna fila
 * se modifica fuera del backend.
 */
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
}
