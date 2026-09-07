package com.minimarket.caja.repository;

import com.minimarket.caja.entity.CajaTurno;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CajaTurnoRepository extends JpaRepository<CajaTurno, Long> {
    Optional<CajaTurno> findByCajaIdAndEstado(Long cajaId, CajaTurno.EstadoCajaTurno estado);
}
