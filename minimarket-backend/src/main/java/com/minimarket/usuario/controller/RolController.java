package com.minimarket.usuario.controller;

import com.minimarket.common.ApiResponse;
import com.minimarket.usuario.dto.RolDTO;
import com.minimarket.usuario.repository.RolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/roles")
@RequiredArgsConstructor
public class RolController {
    
    private final RolRepository rolRepository;

    @GetMapping
    @PreAuthorize("hasAuthority('USUARIO_LEER') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<RolDTO>>> listar() {
        List<RolDTO> roles = rolRepository.findAll().stream().map(rol -> {
            RolDTO dto = new RolDTO();
            dto.setId(rol.getId());
            dto.setNombre(rol.getNombre());
            dto.setDescripcion(rol.getDescripcion());
            return dto;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(roles));
    }
}
