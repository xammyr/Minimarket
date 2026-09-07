package com.minimarket.sunat.repository;

import com.minimarket.sunat.entity.DocumentoElectronico;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DocumentoElectronicoRepository extends JpaRepository<DocumentoElectronico, Long> {
    Optional<DocumentoElectronico> findByComprobanteId(Long comprobanteId);
}
