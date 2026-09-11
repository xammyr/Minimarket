import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FacturaService } from '../../services/factura';
import { HttpClient } from '@angular/common/http';

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

  ngOnInit() {
    this.http.get<any>('/api/ventas?size=50').subscribe({
      next: (res) => {
        if (res.data && res.data.content) {
          this.listaFacturas.set(res.data.content);
        }
      },
      error: (err) => console.error("Error cargando ventas", err)
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

  descargarExcel() {
    let datosAExportar = this.seleccionados().length > 0 
      ? this.facturasFiltradas().filter(f => this.seleccionados().includes(f.id))
      : this.facturasFiltradas();

    if (datosAExportar.length === 0) return alert('No hay comprobantes para exportar.');

    const dtos = datosAExportar.map(v => {
      // Convertir la lista de detalles en un string legible
      let detallesStr = 'Sin detalles';
      if (v.detalles && v.detalles.length > 0) {
        detallesStr = v.detalles.map((d: any) => `${d.cantidad}x ${d.producto}`).join('\n');
      }

      return {
        id: v.numeroVenta,
        cliente: 'Cliente General', // Ajusta si tienes cliente
        total: v.total,
        estado: v.estado,
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
