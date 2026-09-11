import { Component, inject, OnInit, ChangeDetectorRef } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-corte-caja',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './corte-caja.html',
  styleUrl: './corte-caja.scss',
})
export class CorteCaja implements OnInit {
  private http = inject(HttpClient);
  private cdr = inject(ChangeDetectorRef);
  
  turnoActual: any = null;
  montoInicial: number = 0;
  montoDeclarado: number = 0;
  observaciones: string = '';
  cajaId: number = 1;
  cargando: boolean = true;

  ngOnInit() {
    this.cargarTurnoActual();
  }

  cargarTurnoActual() {
    this.cargando = true;
    this.http.get<any>(`/api/caja-turnos/actual/${this.cajaId}`).subscribe({
      next: (res) => {
        if (res.data) {
          this.turnoActual = res.data;
          this.cargarVentasDelTurno(); // Fetch sales for this shift
        } else {
          this.turnoActual = null;
          this.cargando = false;
          this.cdr.detectChanges(); // FORZAR REFRESCO DE UI
        }
      },
      error: (err) => {
        this.turnoActual = null;
        this.cargando = false;
        this.cdr.detectChanges(); // FORZAR REFRESCO DE UI
      }
    });
  }

  ventasDelTurno: any[] = [];
  ventasCargando: boolean = false;

  cargarVentasDelTurno() {
    this.ventasCargando = true;
    this.http.get<any>('/api/ventas?size=500').subscribe({
      next: (res) => {
        if (res.data && res.data.content) {
          // Filtrar las ventas que pertenecen al turno actual
          this.ventasDelTurno = res.data.content.filter((v: any) => v.cajaTurnoId === this.turnoActual.id);
        }
        this.ventasCargando = false;
        this.cargando = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error("Error al cargar ventas", err);
        this.ventasCargando = false;
        this.cargando = false;
        this.cdr.detectChanges();
      }
    });
  }

  abrirCaja() {
    this.http.post<any>('/api/caja-turnos/abrir', {
      cajaId: this.cajaId,
      montoApertura: this.montoInicial
    }).subscribe({
      next: (res) => {
        Swal.fire({
          toast: true,
          position: 'top-end',
          icon: 'success',
          title: 'Caja abierta con éxito',
          showConfirmButton: false,
          timer: 3000,
          timerProgressBar: true
        });
        this.cargarTurnoActual();
      },
      error: (err) => {
        Swal.fire({
          icon: 'error',
          title: 'Error al abrir caja',
          text: err.error?.message || err.message
        });
      }
    });
  }

  cerrarCaja() {
    if (!this.turnoActual) return;
    
    Swal.fire({
      title: '¿Estás seguro?',
      text: "El turno se cerrará y no podrás registrar más ventas hasta abrir uno nuevo.",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#e74c3c',
      cancelButtonColor: '#95a5a6',
      confirmButtonText: 'Sí, cerrar caja',
      cancelButtonText: 'Cancelar'
    }).then((result) => {
      if (result.isConfirmed) {
        this.http.post<any>(`/api/caja-turnos/${this.turnoActual.id}/cerrar`, {
          montoReal: this.montoDeclarado,
          observaciones: this.observaciones
        }).subscribe({
          next: (res) => {
            Swal.fire({
              icon: 'success',
              title: 'Caja Cerrada',
              text: 'El turno se ha cerrado correctamente.'
            });
            this.cargarTurnoActual();
          },
          error: (err) => {
            Swal.fire({
              icon: 'error',
              title: 'Error al cerrar caja',
              text: err.error?.message || err.message
            });
          }
        });
      }
    });
  }
}
