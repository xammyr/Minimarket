package com.minimarket.inventario.repository;

import com.minimarket.inventario.entity.Lote;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LoteRepository extends JpaRepository<Lote, Long> {
    List<Lote> findByProductoIdAndActivoTrue(Long productoId);
}
