package com.minimarket.usuario.controller;

import com.minimarket.common.ApiResponse;
import com.minimarket.usuario.dto.UsuarioRequestDTO;
import com.minimarket.usuario.dto.UsuarioResponseDTO;
import com.minimarket.usuario.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping
    @PreAuthorize("hasAuthority('USUARIO_LEER') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<UsuarioResponseDTO>>> listar(Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(usuarioService.listarUsuarios(pageable)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('USUARIO_LEER') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UsuarioResponseDTO>> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(usuarioService.obtenerPorId(id)));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('USUARIO_CREAR') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UsuarioResponseDTO>> crear(@Valid @RequestBody UsuarioRequestDTO request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(usuarioService.crearUsuario(request), "Usuario creado exitosamente"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('USUARIO_ACTUALIZAR') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UsuarioResponseDTO>> actualizar(@PathVariable Long id, @Valid @RequestBody UsuarioRequestDTO request) {
        return ResponseEntity.ok(ApiResponse.ok(usuarioService.actualizarUsuario(id, request), "Usuario actualizado exitosamente"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('USUARIO_ELIMINAR') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> eliminar(@PathVariable Long id) {
        usuarioService.eliminarUsuario(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "Usuario eliminado exitosamente"));
    }
}
