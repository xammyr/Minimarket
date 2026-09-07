package com.minimarket.auditoria.repository;

import com.minimarket.auditoria.entity.AuditoriaLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditoriaLogRepository extends JpaRepository<AuditoriaLog, Long> {
    Page<AuditoriaLog> findByEntidadAndEntidadId(String entidad, Long entidadId, Pageable pageable);
}
