package com.minimarket.cliente.repository;
import com.minimarket.cliente.entity.Cliente;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    Optional<Cliente> findByTipoDocumentoIdAndNumeroDocumento(Long tipoDocumentoId, String numeroDocumento);
    Optional<Cliente> findFirstByNumeroDocumentoAndActivoTrue(String numeroDocumento);
    Page<Cliente> findByActivoTrue(Pageable pageable);
    Page<Cliente> findByNombreRazonSocialContainingIgnoreCaseAndActivoTrue(String nombre, Pageable pageable);
}
