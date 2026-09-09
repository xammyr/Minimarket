import { Component, inject, OnInit, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-corte-caja',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './corte-caja.html',
  styleUrl: './corte-caja.scss',
})
export class CorteCaja implements OnInit {
  private http = inject(HttpClient);
  
  turnoActual: any = null;
  montoInicial: number = 0;
  montoDeclarado: number = 0;
  observaciones: string = '';
  cajaId: number = 1;

  ngOnInit() {
    this.cargarTurnoActual();
  }

  cargarTurnoActual() {
    this.http.get<any>(`http://localhost:8080/api/caja-turnos/actual/${this.cajaId}`).subscribe({
      next: (res) => {
        if (res.data) {
          this.turnoActual = res.data;
        } else {
          this.turnoActual = null;
        }
      },
      error: (err) => {
        this.turnoActual = null;
      }
    });
  }

  abrirCaja() {
    this.http.post<any>('http://localhost:8080/api/caja-turnos/abrir', {
      cajaId: this.cajaId,
      montoApertura: this.montoInicial
    }).subscribe({
      next: (res) => {
        alert("Caja abierta");
        this.cargarTurnoActual();
      },
      error: (err) => alert("Error al abrir caja: " + err.message)
    });
  }

  cerrarCaja() {
    if (!this.turnoActual) return;
    this.http.post<any>(`http://localhost:8080/api/caja-turnos/${this.turnoActual.id}/cerrar`, {
      montoReal: this.montoDeclarado,
      observaciones: this.observaciones
    }).subscribe({
      next: (res) => {
        alert("Caja cerrada");
        this.cargarTurnoActual();
      },
      error: (err) => alert("Error al cerrar caja: " + err.message)
    });
  }
}
