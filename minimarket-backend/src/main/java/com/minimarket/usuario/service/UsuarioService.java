package com.minimarket.usuario.service;

import com.minimarket.common.exception.ResourceNotFoundException;
import com.minimarket.usuario.dto.UsuarioRequestDTO;
import com.minimarket.usuario.dto.UsuarioResponseDTO;
import com.minimarket.usuario.entity.Rol;
import com.minimarket.usuario.entity.Usuario;
import com.minimarket.usuario.repository.RolRepository;
import com.minimarket.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public Page<UsuarioResponseDTO> listarUsuarios(Pageable pageable) {
        return usuarioRepository.findAll(pageable).map(this::mapToDTO);
    }

    @Transactional(readOnly = true)
    public UsuarioResponseDTO obtenerPorId(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con ID: " + id));
        return mapToDTO(usuario);
    }

    @Transactional
    public UsuarioResponseDTO crearUsuario(UsuarioRequestDTO request) {
        if (usuarioRepository.existsByUsernameIgnoreCase(request.getUsername())) {
            throw new IllegalArgumentException("El nombre de usuario ya está en uso");
        }
        if (request.getEmail() != null && !request.getEmail().trim().isEmpty() && usuarioRepository.existsByEmailIgnoreCase(request.getEmail())) {
            throw new IllegalArgumentException("El email ya está en uso");
        }

        Usuario usuario = new Usuario();
        usuario.setUsername(request.getUsername());
        
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            usuario.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        } else {
            throw new IllegalArgumentException("La contraseña es obligatoria para nuevos usuarios");
        }
        
        usuario.setNombres(request.getNombres());
        usuario.setApellidos(request.getApellidos());
        
        // Evitar violación de constraint UNIQUE con strings vacíos
        if (request.getEmail() != null && request.getEmail().trim().isEmpty()) {
            usuario.setEmail(null);
        } else {
            usuario.setEmail(request.getEmail());
        }
        usuario.setTelefono(request.getTelefono());
        usuario.setActivo(request.getActivo() != null ? request.getActivo() : true);

        asignarRoles(usuario, request.getRolesIds());

        return mapToDTO(usuarioRepository.save(usuario));
    }

    @Transactional
    public UsuarioResponseDTO actualizarUsuario(Long id, UsuarioRequestDTO request) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con ID: " + id));

        if (!usuario.getUsername().equalsIgnoreCase(request.getUsername()) &&
                usuarioRepository.existsByUsernameIgnoreCase(request.getUsername())) {
            throw new IllegalArgumentException("El nombre de usuario ya está en uso");
        }
        if (request.getEmail() != null && !request.getEmail().trim().isEmpty() && !request.getEmail().equalsIgnoreCase(usuario.getEmail()) &&
                usuarioRepository.existsByEmailIgnoreCase(request.getEmail())) {
            throw new IllegalArgumentException("El email ya está en uso");
        }

        usuario.setUsername(request.getUsername());
        usuario.setNombres(request.getNombres());
        usuario.setApellidos(request.getApellidos());
        
        // Evitar violación de constraint UNIQUE con strings vacíos
        if (request.getEmail() != null && request.getEmail().trim().isEmpty()) {
            usuario.setEmail(null);
        } else {
            usuario.setEmail(request.getEmail());
        }
        usuario.setTelefono(request.getTelefono());
        
        if (request.getActivo() != null) {
            usuario.setActivo(request.getActivo());
        }

        if (request.getPassword() != null && !request.getPassword().trim().isEmpty()) {
            usuario.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }

        asignarRoles(usuario, request.getRolesIds());

        return mapToDTO(usuarioRepository.save(usuario));
    }

    @Transactional
    public void eliminarUsuario(Long id) {
        if (!usuarioRepository.existsById(id)) {
            throw new ResourceNotFoundException("Usuario no encontrado con ID: " + id);
        }
        // En lugar de borrar físicamente, podríamos desactivarlo, pero el requerimiento es eliminar
        usuarioRepository.deleteById(id);
    }

    private void asignarRoles(Usuario usuario, java.util.Set<Long> rolesIds) {
        usuario.getRoles().clear();
        if (rolesIds != null && !rolesIds.isEmpty()) {
            List<Rol> roles = rolRepository.findAllById(rolesIds);
            usuario.getRoles().addAll(roles);
        }
    }

    private UsuarioResponseDTO mapToDTO(Usuario usuario) {
        UsuarioResponseDTO dto = new UsuarioResponseDTO();
        dto.setId(usuario.getId());
        dto.setUsername(usuario.getUsername());
        dto.setNombres(usuario.getNombres());
        dto.setApellidos(usuario.getApellidos());
        dto.setEmail(usuario.getEmail());
        dto.setTelefono(usuario.getTelefono());
        dto.setActivo(usuario.getActivo());
        dto.setUltimoAcceso(usuario.getUltimoAcceso());
        dto.setRoles(usuario.getRoles().stream()
                .map(Rol::getNombre)
                .collect(Collectors.toList()));
        return dto;
    }
}
