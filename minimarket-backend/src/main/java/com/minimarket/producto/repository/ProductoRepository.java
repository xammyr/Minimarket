package com.minimarket.producto.repository;
import com.minimarket.producto.entity.Producto;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    Optional<Producto> findByCodigoBarrasAndActivoTrue(String codigoBarras);
    Optional<Producto> findByCodigoInterno(String codigoInterno);
    Page<Producto> findByActivoTrueOrderByIdAsc(Pageable pageable);
    Page<Producto> findByNombreContainingIgnoreCaseAndActivoTrueOrderByIdAsc(String nombre, Pageable pageable);
    Page<Producto> findByCodigoInternoContainingIgnoreCaseAndActivoTrue(String codigo, Pageable pageable);
    boolean existsByCodigoInternoIgnoreCase(String codigoInterno);
    boolean existsByCodigoBarrasIgnoreCase(String codigoBarras);
    boolean existsByCodigoInternoIgnoreCaseAndIdNot(String codigoInterno, Long id);
    boolean existsByCodigoBarrasIgnoreCaseAndIdNot(String codigoBarras, Long id);

    @org.springframework.data.jpa.repository.Query("SELECT p FROM Producto p WHERE p.activo = true AND p.controlaStock = true AND p.stockActual <= p.stockMinimo ORDER BY p.stockActual ASC")
    java.util.List<Producto> findStockCritico();

    @org.springframework.data.jpa.repository.Query("SELECT MAX(p.id) FROM Producto p")
    Long findMaxId();
}
