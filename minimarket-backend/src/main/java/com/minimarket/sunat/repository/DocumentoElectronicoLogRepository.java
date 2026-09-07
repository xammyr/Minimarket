package com.minimarket.sunat.repository;

import com.minimarket.sunat.entity.DocumentoElectronicoLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DocumentoElectronicoLogRepository extends JpaRepository<DocumentoElectronicoLog, Long> {
    List<DocumentoElectronicoLog> findByDocumentoElectronicoIdOrderByCreatedAtAsc(Long documentoElectronicoId);
}
