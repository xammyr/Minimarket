import { Component, inject, OnInit, signal, computed } from '@angular/core'; 
import { HttpClient } from '@angular/common/http';
import { ProductoService } from '../../services/producto';
import { Producto } from '../../models/producto.interface';

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

  total = computed(() => {
    return this.carrito().reduce((suma, item) => suma + item.subtotal, 0);
  });
  
  totalItems = computed(() => {
    return this.carrito().reduce((suma, item) => suma + item.cantidad, 0);
  });

  ngOnInit(): void {
    this.cargarProductos();
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

  cobrar() {
    if (this.carrito().length === 0) return;
    
    // Primero obtenemos el turno actual de la caja
    this.http.get<any>('http://localhost:8080/api/caja-turnos/actual/1').subscribe({
      next: (turnoRes) => {
        if (!turnoRes.data || !turnoRes.data.id) {
          alert("Error: No hay un turno de caja abierto.");
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

        this.http.post<any>('http://localhost:8080/api/ventas', request).subscribe({
          next: (res) => {
            alert("Venta registrada con éxito: " + res.data.numeroComprobante);
            this.carrito.set([]); // Limpiar carrito
            this.cargarProductos(); // Refrescar stock
          },
          error: (err) => {
            console.error("Error al registrar venta", err);
            alert("Error al registrar la venta: " + (err.error?.message || err.message));
          }
        });

      },
      error: (err) => {
        console.error("Error al obtener turno actual", err);
        alert("Error: ¿La caja está abierta?");
      }
    });
  }
}