package com.minimarket.comprobante.repository;

import com.minimarket.comprobante.entity.Comprobante;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ComprobanteRepository extends JpaRepository<Comprobante, Long> {
    Optional<Comprobante> findBySerieIdAndNumero(Long serieId, Long numero);
    Optional<Comprobante> findByVentaId(Long ventaId);
}
