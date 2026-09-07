package com.minimarket.security;
import com.minimarket.common.exception.BusinessException;
import com.minimarket.usuario.entity.Usuario;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class CurrentUserService {
    public Usuario getUsuario() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof SecurityUser user)) {
            throw new BusinessException("No hay un usuario autenticado");
        }
        return user.getUsuario();
    }
    public Long getUsuarioId() { return getUsuario().getId(); }
}
