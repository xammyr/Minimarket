package com.minimarket.proveedor.repository;
import com.minimarket.proveedor.entity.Proveedor;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface ProveedorRepository extends JpaRepository<Proveedor, Long> {
    boolean existsByTipoDocumentoAndNumeroDocumento(String tipoDocumento, String numeroDocumento);
    boolean existsByTipoDocumentoAndNumeroDocumentoAndIdNot(String tipoDocumento, String numeroDocumento, Long id);
    Optional<Proveedor> findByTipoDocumentoAndNumeroDocumento(String tipoDocumento, String numeroDocumento);
    Page<Proveedor> findByActivoTrue(Pageable pageable);
}
