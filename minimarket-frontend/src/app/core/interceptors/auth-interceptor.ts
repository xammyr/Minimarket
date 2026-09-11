import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('token');
  const router = inject(Router);

  let peticionClonada = req;
  if (token) {
    peticionClonada = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }

  return next(peticionClonada).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401 && !req.url.includes('/api/auth/login')) {
        console.error('Token inválido o expirado. Limpiando credenciales...');
        localStorage.removeItem('token');
        localStorage.removeItem('roles');
        router.navigate(['/login']);
      } else if (error.status === 403) {
        console.warn('Acceso denegado a este recurso (403)');
      }
      return throwError(() => error);
    })
  );
};
