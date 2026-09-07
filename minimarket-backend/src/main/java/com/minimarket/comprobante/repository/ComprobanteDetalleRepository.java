package com.minimarket.comprobante.repository;

import com.minimarket.comprobante.entity.ComprobanteDetalle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComprobanteDetalleRepository extends JpaRepository<ComprobanteDetalle, Long> {
    List<ComprobanteDetalle> findByComprobanteId(Long comprobanteId);
}
