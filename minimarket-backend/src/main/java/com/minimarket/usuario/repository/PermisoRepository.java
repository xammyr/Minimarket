package com.minimarket.usuario.repository;
import com.minimarket.usuario.entity.Permiso;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface PermisoRepository extends JpaRepository<Permiso, Long> {
    Optional<Permiso> findByCodigoIgnoreCase(String codigo);
}
