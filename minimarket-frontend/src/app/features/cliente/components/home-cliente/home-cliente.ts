import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { ProductoService } from '../../../productos/services/producto'; 
import { Producto } from '../../../productos/models/producto.interface';

export interface DetalleCarrito {
  producto: Producto;
  cantidad: number;
  subtotal: number;
}

@Component({
  selector: 'app-home-cliente',
  standalone: true,
  templateUrl: './home-cliente.html',
  styleUrl: './home-cliente.scss'
})
export class HomeCliente implements OnInit {
  private productoService = inject(ProductoService);
  
  // Estados principales
  productos = signal<Producto[]>([]);
  isCartOpen = signal<boolean>(false);
  carrito = signal<DetalleCarrito[]>([]); 

  // Estados de Filtros y Búsqueda
  categorias = ['Todos', 'Abarrotes', 'Bebidas', 'Limpieza', 'Snacks'];
  categoriaSeleccionada = signal<string>('Todos');
  terminoBusqueda = signal<string>('');
  ordenamiento = signal<string>('defecto');

  // Estados de Paginación
  paginaActual = signal<number>(0);
  hayMasPaginas = signal<boolean>(true); // Asumimos que hay más hasta que el backend diga lo contrario

  // El "Cerebro" Reactivo: Aplica Categoría + Búsqueda + Ordenamiento al mismo tiempo
  productosFiltrados = computed(() => {
    let lista = this.productos();

    // 1. Filtro por Categoría
    if (this.categoriaSeleccionada() !== 'Todos') {
      lista = lista.filter(p => p.categoriaNombre === this.categoriaSeleccionada());
    }

    // 2. Filtro por Búsqueda (ignorando mayúsculas/minúsculas)
    const termino = this.terminoBusqueda().toLowerCase().trim();
    if (termino) {
      lista = lista.filter(p => 
        p.nombre.toLowerCase().includes(termino) || 
        p.codigoInterno.toLowerCase().includes(termino)
      );
    }

    // 3. Ordenamiento
    lista = [...lista]; // Hacemos una copia para no mutar el estado original
    if (this.ordenamiento() === 'precio-asc') {
      lista.sort((a, b) => a.precioVenta - b.precioVenta);
    } else if (this.ordenamiento() === 'precio-desc') {
      lista.sort((a, b) => b.precioVenta - a.precioVenta);
    } else if (this.ordenamiento() === 'az') {
      lista.sort((a, b) => a.nombre.localeCompare(b.nombre));
    }

    return lista;
  });

  totalItems = computed(() => this.carrito().reduce((sum, item) => sum + item.cantidad, 0));
  totalPagar = computed(() => this.carrito().reduce((sum, item) => sum + item.subtotal, 0));

  ngOnInit(): void {
    this.cargarProductos(0); // Cargamos la primera página al iniciar
  }

  // Ahora recibe la página que queremos buscar
  cargarProductos(page: number) {
    // NOTA: Si tu productoService.obtenerProductos() aún no acepta el parámetro 'page', 
    // puedes pasarlo temporalmente vacío, pero la lógica ya está preparada.
    this.productoService.obtenerProductos().subscribe({
      next: (response: any) => {
        const nuevosProductos = response.data.content;
        
        if (page === 0) {
          this.productos.set(nuevosProductos);
        } else {
          // Si es la página 1, 2, etc., los agregamos al final de la lista existente
          this.productos.update(actuales => [...actuales, ...nuevosProductos]);
        }

        // Verificamos si es la última página según Spring Boot
        this.hayMasPaginas.set(!response.data.last);
        this.paginaActual.set(page);
      },
      error: (err) => console.error('Error al cargar la tienda:', err)
    });
  }

  cargarMas() {
    this.cargarProductos(this.paginaActual() + 1);
  }

  // Eventos de la UI
  seleccionarCategoria(categoria: string) { this.categoriaSeleccionada.set(categoria); }
  
  actualizarBusqueda(event: any) { this.terminoBusqueda.set(event.target.value); }
  
  actualizarOrden(event: any) { this.ordenamiento.set(event.target.value); }

  agregarAlCarrito(productoSeleccionado: Producto) {
    this.carrito.update((itemsActuales) => {
      const indice = itemsActuales.findIndex(item => item.producto.id === productoSeleccionado.id);
      if (indice !== -1) {
        const nuevosItems = [...itemsActuales];
        nuevosItems[indice].cantidad += 1;
        nuevosItems[indice].subtotal = nuevosItems[indice].cantidad * productoSeleccionado.precioVenta;
        return nuevosItems;
      } else {
        return [...itemsActuales, { producto: productoSeleccionado, cantidad: 1, subtotal: productoSeleccionado.precioVenta }];
      }
    });
  }
  
  toggleCart() { this.isCartOpen.update(isOpen => !isOpen); }
  
  eliminarDelCarrito(productoId: number) {
     this.carrito.update(items => items.filter(item => item.producto.id !== productoId));
  }

  procederPago() {
    alert("¡Simulación de pago exitosa!\nGracias por tu compra.");
    this.carrito.set([]);
    this.isCartOpen.set(false);
  }
}