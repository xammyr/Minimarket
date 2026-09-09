import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FacturaService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:8080/api/facturas'; 

  obtenerFacturas(): Observable<any> {
    return this.http.get(`${this.apiUrl}`);
  }

  // Ahora pedimos los datos por parámetro y los enviamos en un POST
  exportarExcel(datosParaExcel: any[]): Observable<Blob> {
    return this.http.post(`${this.apiUrl}/exportar-excel`, datosParaExcel, { responseType: 'blob' });
  }
}