import { Component, signal, computed, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CompraService, CompraResponseDTO, CompraRequestDTO, CompraDetalleRequestDTO } from '../../services/compra.service';
import { ProveedorService } from '../../../admin/services/proveedor.service';
import { ProductoService } from '../../../productos/services/producto';
import { Producto } from '../../../productos/models/producto.interface';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-compras',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './compras.html',
  styleUrl: './compras.scss'
})
export class Compras implements OnInit {
  
  private compraService = inject(CompraService);
  private proveedorService = inject(ProveedorService);
  private productoService = inject(ProductoService);

  listaCompras = signal<CompraResponseDTO[]>([]);
  listaProveedores = signal<any[]>([]);
  listaProductos = signal<Producto[]>([]);

  terminoBusqueda = signal('');

  // --- VARIABLES PARA LOS MODALES ---
  mostrarModalDetalle = false;
  mostrarModalNueva = false;
  compraSeleccionada: CompraResponseDTO | null = null;

  // Objeto temporal para el formulario de nueva compra
  nuevaCompraForm: {
    proveedorId: number | null,
    comprobante: string,
    detalles: CompraDetalleRequestDTO[]
  } = {
    proveedorId: null,
    comprobante: '',
    detalles: []
  };

  productoTemporalId: number | null = null;
  cantidadTemporal: number = 1;
  precioTemporal: number = 0;

  ngOnInit() {
    this.cargarDatos();
  }

  cargarDatos() {
    this.compraService.listar().subscribe({
      next: (res) => {
        if(res.data && res.data.content) {
          this.listaCompras.set(res.data.content);
        }
      },
      error: (err) => console.error("Error cargando compras", err)
    });

    this.proveedorService.listar().subscribe({
      next: (res) => {
        if(res.data && res.data.content) {
           this.listaProveedores.set(res.data.content);
        } else if (res.data) {
           this.listaProveedores.set(res.data);
        }
      },
      error: (err) => console.error("Error cargando proveedores", err)
    });

    this.productoService.obtenerProductos().subscribe({
      next: (res) => {
         if (res.data) {
             // Handle if res.data is an array or object with content
             this.listaProductos.set((res.data as any).content || res.data);
         }
      },
      error: (err) => console.error("Error cargando productos", err)
    });
  }

  comprasFiltradas = computed(() => {
    const termino = this.terminoBusqueda().toLowerCase();
    return this.listaCompras().filter(compra => 
      (compra.proveedorNombre && compra.proveedorNombre.toLowerCase().includes(termino)) || 
      (compra.numeroComprobante && compra.numeroComprobante.toLowerCase().includes(termino))
    );
  });

  actualizarBusqueda(event: Event) {
    const input = event.target as HTMLInputElement;
    this.terminoBusqueda.set(input.value);
  }

  // --- LÓGICA DE DETALLE ---
  abrirDetalle(compra: CompraResponseDTO) {
    this.compraSeleccionada = compra;
    this.mostrarModalDetalle = true;
  }

  cerrarDetalle() {
    this.mostrarModalDetalle = false;
    this.compraSeleccionada = null;
  }

  // --- LÓGICA DE NUEVA COMPRA ---
  abrirNuevaCompra() {
    this.nuevaCompraForm = { proveedorId: null, comprobante: '', detalles: [] };
    this.productoTemporalId = null;
    this.cantidadTemporal = 1;
    this.precioTemporal = 0;
    this.mostrarModalNueva = true;
  }

  cerrarNuevaCompra() {
    this.mostrarModalNueva = false;
  }

  agregarProducto() {
    if (!this.productoTemporalId || this.cantidadTemporal <= 0 || this.precioTemporal <= 0) {
      Swal.fire('Atención', 'Seleccione un producto y especifique cantidad y precio válidos.', 'warning');
      return;
    }
    this.nuevaCompraForm.detalles.push({
      productoId: Number(this.productoTemporalId),
      cantidad: this.cantidadTemporal,
      precioUnitario: this.precioTemporal
    });
    // Reset inputs
    this.productoTemporalId = null;
    this.cantidadTemporal = 1;
    this.precioTemporal = 0;
  }

  eliminarProducto(index: number) {
    this.nuevaCompraForm.detalles.splice(index, 1);
  }

  getNombreProducto(id: number): string {
    const p = this.listaProductos().find(x => x.id === id);
    return p ? p.nombre : 'Desconocido';
  }

  getTotalNuevaCompra(): number {
    return this.nuevaCompraForm.detalles.reduce((acc, curr) => acc + (curr.cantidad * curr.precioUnitario), 0);
  }

  guardarCompra() {
    if (!this.nuevaCompraForm.comprobante || !this.nuevaCompraForm.proveedorId || this.nuevaCompraForm.detalles.length === 0) {
      Swal.fire('Atención', 'Por favor, completa todos los campos correctamente y agrega al menos un producto.', 'warning');
      return;
    }

    const request: CompraRequestDTO = {
      proveedorId: Number(this.nuevaCompraForm.proveedorId),
      numeroComprobante: this.nuevaCompraForm.comprobante,
      detalles: this.nuevaCompraForm.detalles
    };

    this.compraService.registrarCompra(request).subscribe({
      next: (res) => {
        Swal.fire({ toast: true, position: 'top-end', icon: 'success', title: 'Compra registrada exitosamente', showConfirmButton: false, timer: 3000 });
        this.cargarDatos(); // reload
        this.cerrarNuevaCompra();
      },
      error: (err) => {
        console.error(err);
        Swal.fire('Error', 'Error al registrar la compra: ' + (err.error?.message || err.message), 'error');
      }
    });
  }

  anularCompra(id: number) {
    Swal.fire({
      title: '¿Estás seguro?',
      text: 'Se anulará esta compra y el inventario se revertirá.',
      icon: 'warning',
      input: 'text',
      inputPlaceholder: 'Motivo de la anulación',
      showCancelButton: true,
      confirmButtonText: 'Sí, anular',
      cancelButtonText: 'Cancelar',
      preConfirm: (motivo) => {
        if (!motivo) {
          Swal.showValidationMessage('Debes ingresar un motivo');
        }
        return motivo;
      }
    }).then((result) => {
      if (result.isConfirmed) {
        this.compraService.anular(id, result.value).subscribe({
          next: () => {
             Swal.fire({ toast: true, position: 'top-end', icon: 'success', title: 'Compra anulada', showConfirmButton: false, timer: 3000 });
             this.cargarDatos();
          },
          error: (err) => Swal.fire('Error', err.error?.message || err.message, 'error')
        });
      }
    });
  }
}
