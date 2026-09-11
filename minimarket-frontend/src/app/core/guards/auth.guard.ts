import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

export const authGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const token = localStorage.getItem('token');
  
  if (!token) {
    router.navigate(['/login']);
    return false;
  }
  
  // Si está tratando de acceder a /admin, verificamos el rol
  if (state.url.startsWith('/admin')) {
    try {
      const rolesStr = localStorage.getItem('roles');
      const roles: string[] = rolesStr ? JSON.parse(rolesStr) : [];
      
      const esAdmin = roles.includes('ADMIN');
      const esInventario = roles.includes('INVENTARIO');

      if (!esAdmin && !esInventario) {
        router.navigate(['/caja']);
        return false;
      }
      
      // Si es solo inventario y trata de acceder a una ruta de admin que no sea inventario, bloquear
      if (!esAdmin && esInventario && state.url !== '/admin/inventario') {
        router.navigate(['/admin/inventario']);
        return false;
      }
      
    } catch (e) {
      router.navigate(['/login']);
      return false;
    }
  }

  return true;
};
