import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
}

export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export interface Usuario {
  id?: number;
  username: string;
  nombres: string;
  apellidos: string;
  email?: string;
  telefono?: string;
  activo: boolean;
  ultimoAcceso?: string;
  roles?: string[];
  rolesIds?: number[];
  password?: string;
}

export interface Rol {
  id: number;
  nombre: string;
  descripcion: string;
}

@Injectable({
  providedIn: 'root'
})
export class UsuarioService {
  private apiUrl = '/api/usuarios';
  private rolesUrl = '/api/roles';

  constructor(private http: HttpClient) {}

  listarUsuarios(page: number = 0, size: number = 20): Observable<ApiResponse<PageResponse<Usuario>>> {
    return this.http.get<ApiResponse<PageResponse<Usuario>>>(`${this.apiUrl}?page=${page}&size=${size}`);
  }

  crearUsuario(usuario: Usuario): Observable<ApiResponse<Usuario>> {
    return this.http.post<ApiResponse<Usuario>>(this.apiUrl, usuario);
  }

  actualizarUsuario(id: number, usuario: Usuario): Observable<ApiResponse<Usuario>> {
    return this.http.put<ApiResponse<Usuario>>(`${this.apiUrl}/${id}`, usuario);
  }

  eliminarUsuario(id: number): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.apiUrl}/${id}`);
  }

  listarRoles(): Observable<ApiResponse<Rol[]>> {
    return this.http.get<ApiResponse<Rol[]>>(this.rolesUrl);
  }
}
