package com.minimarket.compra.service;

import com.minimarket.compra.dto.CompraRequestDTO;
import com.minimarket.compra.dto.CompraResponseDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CompraService {
    CompraResponseDTO registrarCompra(CompraRequestDTO request);
    CompraResponseDTO obtener(Long id);
    Page<CompraResponseDTO> listar(Pageable pageable);
    void anular(Long id, String motivo);
}
