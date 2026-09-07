package com.minimarket.cliente.repository;

import com.minimarket.cliente.entity.TipoDocumentoIdentidad;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TipoDocumentoIdentidadRepository extends JpaRepository<TipoDocumentoIdentidad, Long> {
    Optional<TipoDocumentoIdentidad> findByCodigo(String codigo);
}
