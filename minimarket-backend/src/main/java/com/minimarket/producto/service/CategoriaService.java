package com.minimarket.producto.service;
import com.minimarket.producto.dto.*;
import org.springframework.data.domain.*;
public interface CategoriaService {
 Page<CategoriaResponseDTO> listar(Pageable p); CategoriaResponseDTO obtener(Long id); CategoriaResponseDTO crear(CategoriaRequestDTO r);
 CategoriaResponseDTO actualizar(Long id,CategoriaRequestDTO r); void desactivar(Long id);
}
