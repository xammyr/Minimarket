import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface CompraResponseDTO {
  id: number;
  numeroComprobante: string;
  proveedorId: number;
  proveedorNombre: string;
  usuarioId: number;
  usuarioNombre: string;
  subtotal: number;
  igv: number;
  total: number;
  estado: string;
  fechaCompra: string;
  detalles: CompraDetalleResponseDTO[];
}

export interface CompraDetalleResponseDTO {
  id: number;
  productoId: number;
  productoNombre: string;
  cantidad: number;
  precioUnitario: number;
  subtotal: number;
}

export interface CompraRequestDTO {
  proveedorId: number;
  numeroComprobante: string;
  detalles: CompraDetalleRequestDTO[];
}

export interface CompraDetalleRequestDTO {
  productoId: number;
  cantidad: number;
  precioUnitario: number;
}

@Injectable({
  providedIn: 'root'
})
export class CompraService {
  private http = inject(HttpClient);
  private apiUrl = '/api/v1/compras';

  registrarCompra(request: CompraRequestDTO): Observable<any> {
    return this.http.post<any>(this.apiUrl, request);
  }

  listar(page: number = 0, size: number = 20): Observable<any> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('size', size.toString())
      .set('sort', 'fechaCompra,desc');
    return this.http.get<any>(this.apiUrl, { params });
  }

  obtener(id: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/${id}`);
  }

  anular(id: number, motivo: string): Observable<any> {
    let params = new HttpParams().set('motivo', motivo);
    return this.http.post<any>(`${this.apiUrl}/${id}/anular`, {}, { params });
  }
}
