package com.minimarket.security;
import com.minimarket.usuario.entity.Usuario;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.*;

@Getter
public class SecurityUser implements UserDetails {
    private final Usuario usuario;
    private final Collection<? extends GrantedAuthority> authorities;

    public SecurityUser(Usuario usuario) {
        this.usuario = usuario;
        Set<GrantedAuthority> auth = new HashSet<>();
        usuario.getRoles().forEach(rol -> {
            auth.add(new SimpleGrantedAuthority("ROLE_" + rol.getNombre().toUpperCase()));
            rol.getPermisos().forEach(p -> auth.add(new SimpleGrantedAuthority(p.getCodigo().toUpperCase())));
        });
        this.authorities = auth;
    }
    @Override public Collection<? extends GrantedAuthority> getAuthorities() { return authorities; }
    @Override public String getPassword() { return usuario.getPasswordHash(); }
    @Override public String getUsername() { return usuario.getUsername(); }
    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled() { return Boolean.TRUE.equals(usuario.getActivo()); }
}
