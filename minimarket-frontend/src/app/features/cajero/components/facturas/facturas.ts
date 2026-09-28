import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FacturaService } from '../../services/factura';
import { HttpClient } from '@angular/common/http';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-facturas',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './facturas.html',
  styleUrl: './facturas.scss'
})
export class Facturas implements OnInit {
  private facturaService = inject(FacturaService);
  private http = inject(HttpClient);
  
  listaFacturas = signal<any[]>([]);
  terminoBusqueda = signal('');
  facturaSeleccionada: any = null;
  mostrarModal = false;
  seleccionados = signal<string[]>([]);
  cargando = signal(true);

  ngOnInit() {
    this.http.get<any>('/api/ventas?size=50').subscribe({
      next: (res) => {
        if (res.data && res.data.content) {
          this.listaFacturas.set(res.data.content);
        }
        this.cargando.set(false);
      },
      error: (err) => {
        console.error("Error cargando ventas", err);
        this.cargando.set(false);
      }
    });
  }

  facturasFiltradas = computed(() => {
    const termino = this.terminoBusqueda().toLowerCase();
    return this.listaFacturas().filter(factura => 
      factura.numeroVenta?.toLowerCase().includes(termino) || 
      factura.estado?.toLowerCase().includes(termino)
    );
  });

  todasSeleccionadas = computed(() => {
    const filtradas = this.facturasFiltradas();
    return filtradas.length > 0 && filtradas.every(f => this.seleccionados().includes(f.id));
  });

  actualizarBusqueda(event: Event) {
    const input = event.target as HTMLInputElement;
    this.terminoBusqueda.set(input.value);
  }

  toggleSeleccion(id: string) {
    this.seleccionados.update(actuales => 
      actuales.includes(id) ? actuales.filter(item => item !== id) : [...actuales, id]
    );
  }

  toggleTodo(event: Event) {
    const checked = (event.target as HTMLInputElement).checked;
    this.seleccionados.set(checked ? this.facturasFiltradas().map(f => f.id) : []);
  }

  // --- LÓGICA DEL MODAL E IMPRESIÓN ---
  verDetalle(factura: any) {
    this.facturaSeleccionada = factura;
    this.mostrarModal = true;
  }

  cerrarModal() {
    this.mostrarModal = false;
  }

  imprimirFactura(factura: any) {
    this.facturaSeleccionada = factura;
    this.mostrarModal = false; // Cerramos el modal antes de imprimir
    
    setTimeout(() => {
      window.print(); // Llamamos a la impresora
    }, 300);
  }

  aprobarPago(id: number) {
    Swal.fire({
      title: '¿Aprobar pago?',
      text: '¿Confirmas que recibiste el pago por Yape/Plin? Esto restará el stock.',
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: 'Sí, aprobar',
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#27ae60'
    }).then((result) => {
      if (result.isConfirmed) {
        this.cargando.set(true);
        this.http.post(`/api/ventas/${id}/aprobar`, {}).subscribe({
          next: () => {
            Swal.fire('Aprobado', 'El pago ha sido confirmado y la venta completada.', 'success');
            this.ngOnInit(); // Recargar la lista
          },
          error: (err) => {
            console.error(err);
            this.cargando.set(false);
            Swal.fire('Error', 'No se pudo aprobar el pago.', 'error');
          }
        });
      }
    });
  }

  rechazarPago(id: number) {
    Swal.fire({
      title: '¿Rechazar pago?',
      text: 'La venta web se anulará porque el pago no fue recibido.',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Sí, rechazar',
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#e74c3c'
    }).then((result) => {
      if (result.isConfirmed) {
        this.cargando.set(true);
        this.http.post(`/api/ventas/${id}/anular?motivo=Pago%20web%20rechazado`, {}).subscribe({
          next: () => {
            Swal.fire('Rechazado', 'El pago ha sido rechazado y la venta anulada.', 'info');
            this.ngOnInit(); // Recargar la lista
          },
          error: (err) => {
            console.error(err);
            this.cargando.set(false);
            Swal.fire('Error', 'No se pudo rechazar el pago.', 'error');
          }
        });
      }
    });
  }

  descargarExcel() {
    let datosAExportar = this.seleccionados().length > 0 
      ? this.facturasFiltradas().filter(f => this.seleccionados().includes(f.id))
      : this.facturasFiltradas();

    if (datosAExportar.length === 0) {
      Swal.fire('Atención', 'No hay comprobantes para exportar.', 'info');
      return;
    }

    const dtos = datosAExportar.map(v => {
      // Convertir la lista de detalles en un string legible
      let detallesStr = 'Sin detalles';
      if (v.detalles && v.detalles.length > 0) {
        detallesStr = v.detalles.map((d: any) => `${d.cantidad}x ${d.producto}`).join('\n');
      }

      const metodo = v.pagos && v.pagos.length > 0 ? v.pagos[0].metodoPago : 'EFECTIVO';

      return {
        id: v.numeroVenta,
        cliente: 'Cliente General', // Ajusta si tienes cliente
        total: v.total,
        estado: v.estado,
        metodoPago: metodo, // Nuevo campo
        detalleProductos: detallesStr // Nueva columna mapeada
      };
    });

    this.facturaService.exportarExcel(dtos).subscribe({
      next: (archivoBlob: Blob) => {
        const url = window.URL.createObjectURL(archivoBlob);
        const enlace = document.createElement('a');
        enlace.href = url;
        enlace.download = `Reporte_Caja_${new Date().getTime()}.xlsx`;
        enlace.click();
        window.URL.revokeObjectURL(url);
      },
      error: (err: any) => console.error('Error descargando el Excel', err)
    });
  }
}
