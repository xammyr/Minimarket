package com.minimarket.producto.controller;
import org.springframework.security.access.prepost.PreAuthorize;
import com.minimarket.common.ApiResponse; import com.minimarket.producto.dto.*; import com.minimarket.producto.service.CategoriaService;
import jakarta.validation.Valid; import lombok.RequiredArgsConstructor; import org.springframework.data.domain.*; import org.springframework.http.*; import org.springframework.web.bind.annotation.*;
@RestController @PreAuthorize("hasAuthority('CATALOGO_ADMINISTRAR')") @RequestMapping("/api/categorias") @RequiredArgsConstructor
public class CategoriaController {
 private final CategoriaService service;
 @GetMapping public ApiResponse<Page<CategoriaResponseDTO>> listar(Pageable p){return ApiResponse.ok(service.listar(p));}
 @GetMapping("/{id}") public ApiResponse<CategoriaResponseDTO> obtener(@PathVariable Long id){return ApiResponse.ok(service.obtener(id));}
 @PostMapping @ResponseStatus(HttpStatus.CREATED) public ApiResponse<CategoriaResponseDTO> crear(@Valid @RequestBody CategoriaRequestDTO r){return ApiResponse.ok(service.crear(r),"Categoría creada");}
 @PutMapping("/{id}") public ApiResponse<CategoriaResponseDTO> actualizar(@PathVariable Long id,@Valid @RequestBody CategoriaRequestDTO r){return ApiResponse.ok(service.actualizar(id,r),"Categoría actualizada");}
 @DeleteMapping("/{id}") public ApiResponse<Void> desactivar(@PathVariable Long id){service.desactivar(id);return ApiResponse.ok(null,"Categoría desactivada");}
}
