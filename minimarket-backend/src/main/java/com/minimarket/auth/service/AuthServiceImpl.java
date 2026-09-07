package com.minimarket.auth.service;
import com.minimarket.auth.dto.*;
import com.minimarket.security.JwtUtil;
import com.minimarket.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.OffsetDateTime;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Override @Transactional
    public LoginResponse login(LoginRequest request) {
        var usuario = usuarioRepository.findByUsername(request.username())
            .orElseThrow(() -> new BadCredentialsException("Credenciales inválidas"));
        if (!Boolean.TRUE.equals(usuario.getActivo()) ||
            !passwordEncoder.matches(request.password(), usuario.getPasswordHash())) {
            throw new BadCredentialsException("Credenciales inválidas");
        }
        usuario.setUltimoAcceso(OffsetDateTime.now());
        String token = jwtUtil.generateToken(usuario.getUsername());
        var roles = usuario.getRoles().stream().map(r -> r.getNombre().toUpperCase()).collect(Collectors.toSet());
        var permisos = usuario.getRoles().stream().flatMap(r -> r.getPermisos().stream())
            .map(p -> p.getCodigo().toUpperCase()).collect(Collectors.toSet());
        return new LoginResponse(token, "Bearer", jwtUtil.getExpirationSeconds(), usuario.getId(),
            usuario.getUsername(), usuario.getNombres()+" "+usuario.getApellidos(), roles, permisos);
    }
}
