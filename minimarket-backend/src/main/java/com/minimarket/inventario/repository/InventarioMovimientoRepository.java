package com.minimarket.inventario.repository;

import com.minimarket.inventario.entity.InventarioMovimiento;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventarioMovimientoRepository extends JpaRepository<InventarioMovimiento, Long> {
    Page<InventarioMovimiento> findByProductoIdOrderByCreatedAtDesc(Long productoId, Pageable pageable);
}
