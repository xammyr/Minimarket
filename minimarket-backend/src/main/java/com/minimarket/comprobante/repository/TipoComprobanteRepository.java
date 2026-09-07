package com.minimarket.comprobante.repository;

import com.minimarket.comprobante.entity.TipoComprobante;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TipoComprobanteRepository extends JpaRepository<TipoComprobante, Long> {
    Optional<TipoComprobante> findByCodigo(String codigo);
}
