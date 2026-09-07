package com.minimarket.caja.repository;

import com.minimarket.caja.entity.CajaMovimiento;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CajaMovimientoRepository extends JpaRepository<CajaMovimiento, Long> {
    List<CajaMovimiento> findByCajaTurnoId(Long cajaTurnoId);
}
