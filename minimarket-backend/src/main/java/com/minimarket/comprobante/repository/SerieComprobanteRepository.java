package com.minimarket.comprobante.repository;

import com.minimarket.comprobante.entity.SerieComprobante;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SerieComprobanteRepository extends JpaRepository<SerieComprobante, Long> {
    Optional<SerieComprobante> findByTipoComprobanteIdAndSerie(Long tipoComprobanteId, String serie);
}
