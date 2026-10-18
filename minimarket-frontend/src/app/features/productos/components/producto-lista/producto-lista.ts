import { Component, inject, OnInit, signal, computed, HostListener, ViewChild, ElementRef, AfterViewInit } from '@angular/core'; 
import { HttpClient } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { ProductoService } from '../../services/producto';
import { Producto } from '../../models/producto.interface';
import { playScannerBeep } from '../../../../core/utils/scanner-audio.util';
import Swal from 'sweetalert2';

export interface DetalleCarrito {
  producto: Producto;
  cantidad: number;
  precioEditable: number;
  subtotal: number;
}

import { DatePipe } from '@angular/common';

@Component({
  selector: 'app-producto-lista',
  standalone: true,
  imports: [DatePipe, FormsModule],
  templateUrl: './producto-lista.html',
  styleUrl: './producto-lista.scss'
})
export class ProductoLista implements OnInit, AfterViewInit {
  @ViewChild('posSearchInput') posSearchInput?: ElementRef<HTMLInputElement>;

  private productoService = inject(ProductoService);
  private http = inject(HttpClient);
  
  productos = signal<Producto[]>([]);
  carrito = signal<DetalleCarrito[]>([]); 
  ultimoTicket = signal<any>(null); // Para almacenar los datos de la última venta e imprimirlos
  
  terminoBusqueda = signal<string>('');
  metodoPagoSeleccionado = signal<number>(1); // 1 = Efectivo, 2 = Yape

  // Variables para el escáner de código de barras
  private barcodeBuffer = '';
  private lastKeyTime = 0;

  productosFiltrados = computed(() => {
    const rawTerm = this.terminoBusqueda().toLowerCase();
    const term = rawTerm.replace(/[-\s]/g, ''); // Quita guiones y espacios
    
    if (!term && !rawTerm) return this.productos();
    
    return this.productos().filter(p => {
      const nombreLimpio = p.nombre.toLowerCase().replace(/[-\s]/g, '');
      const codigoLimpio = p.codigoInterno.toLowerCase().replace(/[-\s]/g, '');
      const barrasLimpio = p.codigoBarras ? p.codigoBarras.toLowerCase().replace(/[-\s]/g, '') : '';
      
      return nombreLimpio.includes(term) || 
             codigoLimpio.includes(term) ||
             barrasLimpio.includes(term) ||
             p.nombre.toLowerCase().includes(rawTerm);
    });
  });

  total = computed(() => {
    return this.carrito().reduce((suma, item) => suma + item.subtotal, 0);
  });
  
  totalItems = computed(() => {
    return this.carrito().reduce((suma, item) => suma + item.cantidad, 0);
  });

  ngOnInit(): void {
    this.cargarProductos();
  }

  ngAfterViewInit(): void {
    // Enfocar automáticamente el buscador para que el cajero pueda escanear de inmediato
    setTimeout(() => {
      this.posSearchInput?.nativeElement?.focus();
    }, 300);
  }

  // Escuchar eventos globales del teclado (Escáner de Barras)
  @HostListener('window:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    const target = event.target as HTMLElement;
    const isSearchInput = target?.id === 'pos-search-input';

    // Si el foco está en el input de búsqueda, dejamos que el usuario/escáner escriba allí
    // y manejamos la adición al presionar Enter en buscarOAgregarPorEnter()
    if (isSearchInput) {
      if (event.key === 'Enter') {
        this.buscarOAgregarPorEnter(event);
      }
      return;
    }

    // Si está escribiendo en otros inputs (ej. editando cantidad o precio del ticket manualmente),
    // no interferimos a menos que sea una ráfaga de escaneo
    const isOtherInput = target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement;
    const currentTime = new Date().getTime();
    const timeDiff = currentTime - this.lastKeyTime;

    // Si pasó más de 120ms entre teclas, reiniciamos el buffer (es tecleo humano normal)
    if (timeDiff > 120) {
      this.barcodeBuffer = '';
    }

    if (event.key === 'Enter') {
      if (this.barcodeBuffer.length >= 2) {
        event.preventDefault();
        this.procesarCodigoEscaneado(this.barcodeBuffer);
        this.barcodeBuffer = '';
      }
    } else if (event.key.length === 1) {
      if (!isOtherInput || timeDiff < 60) {
        this.barcodeBuffer += event.key;
      }
    }

    this.lastKeyTime = currentTime;
  }

  procesarCodigoEscaneado(codigo: string) {
    const cleanCode = (codigo || '').trim();
    if (!cleanCode) return;

    const targetCode = cleanCode.toLowerCase();
    const producto = this.productos().find(p => 
      (p.codigoBarras && p.codigoBarras.trim().toLowerCase() === targetCode) || 
      (p.codigoInterno && p.codigoInterno.trim().toLowerCase() === targetCode)
    );

    if (producto) {
      this.agregarAlCarrito(producto);
      playScannerBeep(true);
      this.terminoBusqueda.set('');
      Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: `+1 ${producto.nombre}`,
        html: `<b style="color: #27ae60;">S/ ${producto.precioVenta.toFixed(2)}</b> (Stock: ${producto.stockActual})`,
        showConfirmButton: false,
        timer: 1300
      });
      this.posSearchInput?.nativeElement?.focus();
    } else {
      // Intentar consultar al servidor si es un código recién registrado
      this.productoService.obtenerPorCodigoBarras(cleanCode).subscribe({
        next: (res) => {
          if (res.data) {
            const nuevoProd = res.data;
            this.productos.update(prods => [nuevoProd, ...prods]);
            this.agregarAlCarrito(nuevoProd);
            playScannerBeep(true);
            this.terminoBusqueda.set('');
            Swal.fire({
              toast: true,
              position: 'top-end',
              icon: 'success',
              title: `+1 ${nuevoProd.nombre}`,
              html: `<b style="color: #27ae60;">S/ ${nuevoProd.precioVenta.toFixed(2)}</b>`,
              showConfirmButton: false,
              timer: 1300
            });
            this.posSearchInput?.nativeElement?.focus();
          } else {
            this.notificarCodigoNoEncontrado(cleanCode);
          }
        },
        error: () => {
          this.notificarCodigoNoEncontrado(cleanCode);
        }
      });
    }
  }

  notificarCodigoNoEncontrado(codigo: string) {
    playScannerBeep(false);
    Swal.fire({
      toast: true,
      position: 'top-end',
      icon: 'error',
      title: 'Producto no encontrado',
      text: `Código: ${codigo}`,
      showConfirmButton: false,
      timer: 2500
    });
    this.posSearchInput?.nativeElement?.focus();
  }

  buscarOAgregarPorEnter(event?: Event) {
    if (event) event.preventDefault();
    const query = this.terminoBusqueda().trim();
    if (!query) return;

    // 1. Coincidencia exacta con código de barras o código interno
    const exacto = this.productos().find(p => 
      (p.codigoBarras && p.codigoBarras.trim().toLowerCase() === query.toLowerCase()) ||
      (p.codigoInterno && p.codigoInterno.trim().toLowerCase() === query.toLowerCase())
    );

    if (exacto) {
      this.procesarCodigoEscaneado(query);
      return;
    }

    // 2. Si sólo hay un producto filtrado en la vista, registrarlo directamente al ticket
    const filtrados = this.productosFiltrados();
    if (filtrados.length === 1) {
      this.agregarAlCarrito(filtrados[0]);
      playScannerBeep(true);
      this.terminoBusqueda.set('');
      Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: `+1 ${filtrados[0].nombre}`,
        html: `<b style="color: #27ae60;">S/ ${filtrados[0].precioVenta.toFixed(2)}</b>`,
        showConfirmButton: false,
        timer: 1300
      });
      this.posSearchInput?.nativeElement?.focus();
      return;
    }

    // 3. Si no coincide localmente, buscar en backend por si es un código de barras
    this.procesarCodigoEscaneado(query);
  }

  cargando = signal<boolean>(true);

  cargarProductos() {
    this.cargando.set(true);
    // Cargar catálogo completo para escaneo instantáneo
    this.productoService.obtenerProductos(0, 1000).subscribe({
      next: (response: any) => {
        const list = response.data?.content || response.data || [];
        this.productos.set(list);
        this.cargando.set(false);
      },
      error: (err) => {
        console.error('Error al cargar el catálogo:', err);
        this.cargando.set(false);
      }
    });
  }

  actualizarBusqueda(event: any) { this.terminoBusqueda.set(event.target.value); }

  seleccionarMetodo(id: number) { this.metodoPagoSeleccionado.set(id); }

  agregarAlCarrito(productoSeleccionado: Producto) {
    this.carrito.update((itemsActuales) => {
      const indice = itemsActuales.findIndex(item => item.producto.id === productoSeleccionado.id);
      if (indice !== -1) {
        const nuevosItems = [...itemsActuales];
        nuevosItems[indice].cantidad += 1;
        nuevosItems[indice].subtotal = nuevosItems[indice].cantidad * nuevosItems[indice].precioEditable;
        return nuevosItems;
      } else {
        return [...itemsActuales, {
          producto: productoSeleccionado,
          cantidad: 1,
          precioEditable: productoSeleccionado.precioVenta,
          subtotal: productoSeleccionado.precioVenta
        }];
      }
    });
  }

  recalcularSubtotal(item: DetalleCarrito) {
    this.carrito.update(items => {
      const index = items.findIndex(i => i.producto.id === item.producto.id);
      if (index !== -1) {
        items[index].subtotal = items[index].cantidad * items[index].precioEditable;
      }
      return [...items];
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
          detalles: this.carrito().map(item => {
            const precioOriginal = item.producto.precioVenta;
            const descuentoTotalPorItem = (precioOriginal - item.precioEditable) * item.cantidad;
            return {
              productoId: item.producto.id,
              cantidad: item.cantidad,
              descuento: descuentoTotalPorItem > 0 ? descuentoTotalPorItem : 0
            };
          }),
          pagos: [
            {
              metodoPagoId: this.metodoPagoSeleccionado(), 
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
              title: `Venta ${res.data.numeroVenta} registrada`,
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
