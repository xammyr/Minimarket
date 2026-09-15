import { Component, inject, OnInit, signal, computed, HostListener } from '@angular/core'; 
import { HttpClient } from '@angular/common/http';
import { ProductoService } from '../../services/producto';
import { Producto } from '../../models/producto.interface';
import Swal from 'sweetalert2';

export interface DetalleCarrito {
  producto: Producto;
  cantidad: number;
  subtotal: number;
}

@Component({
  selector: 'app-producto-lista',
  standalone: true,
  templateUrl: './producto-lista.html',
  styleUrl: './producto-lista.scss'
})
export class ProductoLista implements OnInit {
  private productoService = inject(ProductoService);
  private http = inject(HttpClient);
  
  productos = signal<Producto[]>([]);
  carrito = signal<DetalleCarrito[]>([]); 
  ultimoTicket = signal<any>(null); // Para almacenar los datos de la última venta e imprimirlos
  
  // Variables para el escáner de código de barras
  private barcodeBuffer = '';
  private lastKeyTime = 0;

  total = computed(() => {
    return this.carrito().reduce((suma, item) => suma + item.subtotal, 0);
  });
  
  totalItems = computed(() => {
    return this.carrito().reduce((suma, item) => suma + item.cantidad, 0);
  });

  ngOnInit(): void {
    this.cargarProductos();
  }

  // Escuchar eventos globales del teclado (Escáner de Barras)
  @HostListener('window:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    // Si el usuario está escribiendo en un input, no interferimos
    if (event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement) {
      return;
    }

    const currentTime = new Date().getTime();
    
    // Si pasó mucho tiempo (ej: más de 100ms), reiniciamos el buffer porque fue tecleo humano
    if (currentTime - this.lastKeyTime > 100) {
      this.barcodeBuffer = '';
    }
    
    if (event.key === 'Enter') {
      if (this.barcodeBuffer.length > 0) {
        event.preventDefault(); // Evitar que el Enter dispare clics accidentales en botones
        this.procesarCodigoEscaneado(this.barcodeBuffer);
        this.barcodeBuffer = '';
      }
    } else if (event.key.length === 1) { // Evitar Shift, Ctrl, etc.
      this.barcodeBuffer += event.key;
    }

    this.lastKeyTime = currentTime;
  }

  procesarCodigoEscaneado(codigo: string) {
    const producto = this.productos().find(p => p.codigoBarras === codigo || p.codigoInterno === codigo);
    
    if (producto) {
      this.agregarAlCarrito(producto);
      Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: `${producto.nombre} agregado`,
        showConfirmButton: false,
        timer: 1500
      });
    } else {
      Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'error',
        title: 'Producto no encontrado',
        text: `Código: ${codigo}`,
        showConfirmButton: false,
        timer: 2500
      });
    }
  }

  cargarProductos() {
    this.productoService.obtenerProductos().subscribe({
      next: (response: any) => {
        this.productos.set(response.data.content);
      },
      error: (err) => console.error('Error al cargar el catálogo:', err)
    });
  }

  agregarAlCarrito(productoSeleccionado: Producto) {
    this.carrito.update((itemsActuales) => {
      const indice = itemsActuales.findIndex(item => item.producto.id === productoSeleccionado.id);
      if (indice !== -1) {
        const nuevosItems = [...itemsActuales];
        nuevosItems[indice].cantidad += 1;
        nuevosItems[indice].subtotal = nuevosItems[indice].cantidad * productoSeleccionado.precioVenta;
        return nuevosItems;
      } else {
        return [...itemsActuales, {
          producto: productoSeleccionado,
          cantidad: 1,
          subtotal: productoSeleccionado.precioVenta
        }];
      }
    });
  }

  eliminarDelCarrito(productoId: number) {
    this.carrito.update(items => items.filter(item => item.producto.id !== productoId));
  }

  cobrar() {
    if (this.carrito().length === 0) return;
    
    // Primero obtenemos el turno actual de la caja
    this.http.get<any>('/api/caja-turnos/actual/1').subscribe({
      next: (turnoRes) => {
        if (!turnoRes.data || !turnoRes.data.id) {
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'No hay un turno de caja abierto.'
          });
          return;
        }

        const cajaTurnoId = turnoRes.data.id;
        const totalApagar = this.total();

        // Crear la petición de venta con el formato correcto de CrearVentaRequest
        const request = {
          clienteId: 1, // Cliente Genérico
          cajaTurnoId: cajaTurnoId,
          detalles: this.carrito().map(item => ({
            productoId: item.producto.id,
            cantidad: item.cantidad,
            descuento: 0 // El backend espera "descuento", no "precioUnitario"
          })),
          pagos: [
            {
              metodoPagoId: 1, // Efectivo
              monto: totalApagar
            }
          ]
        };

        this.http.post<any>('/api/ventas', request).subscribe({
          next: (res) => {
            Swal.fire({
              toast: true,
              position: 'top-end',
              icon: 'success',
              title: `Venta ${res.data.numeroComprobante} registrada`,
              showConfirmButton: false,
              timer: 3000,
              timerProgressBar: true
            });
            this.ultimoTicket.set(res.data);
            
            // Limpiar carrito y refrescar catálogo
            this.carrito.set([]); 
            this.cargarProductos();
            
            // Disparar la impresión después de un pequeño delay para que Angular renderice el DOM oculto
            setTimeout(() => {
              window.print();
            }, 500);
          },
          error: (err) => {
            console.error("Error al registrar venta", err);
            Swal.fire({
              icon: 'error',
              title: 'Error al registrar venta',
              text: err.error?.message || err.message
            });
          }
        });

      },
      error: (err) => {
        console.error("Error al obtener turno actual", err);
        Swal.fire({
          icon: 'warning',
          title: 'Caja Cerrada',
          text: 'Debes abrir turno de caja antes de vender.'
        });
      }
    });
  }
}
