package com.minimarket.venta.repository;

import com.minimarket.venta.entity.VentaPago;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VentaPagoRepository extends JpaRepository<VentaPago, Long> {
    List<VentaPago> findByVentaId(Long ventaId);
}
