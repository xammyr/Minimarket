import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { ProductoService } from '../../../productos/services/producto'; 
import { Producto } from '../../../productos/models/producto.interface';
import { RouterModule } from '@angular/router';

export interface DetalleCarrito {
  producto: Producto;
  cantidad: number;
  subtotal: number;
}

@Component({
  selector: 'app-home-cliente',
  standalone: true,
  imports: [RouterModule],
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
    this.productoService.obtenerProductos(page, 10).subscribe({
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

  async procederPago() {
    const Swal = (await import('sweetalert2')).default;
    Swal.fire({
      icon: 'success',
      title: '¡Simulación de pago exitosa!',
      text: 'Gracias por tu compra.',
      confirmButtonText: 'Continuar'
    });
    this.carrito.set([]);
    this.isCartOpen.set(false);
  }

  async mostrarTerminos() {
    const Swal = (await import('sweetalert2')).default;
    Swal.fire({
      title: 'Términos y Condiciones',
      html: `
        <div style="text-align: left; font-size: 0.95rem; line-height: 1.5;">
          <p><strong>1. Uso del sitio web:</strong> El uso de esta tienda virtual implica la aceptación de los presentes términos y condiciones.</p>
          <p><strong>2. Precios y disponibilidad:</strong> Los precios están expresados en moneda local (Soles). Nos reservamos el derecho de modificar los precios en cualquier momento. La disponibilidad de los productos puede variar.</p>
          <p><strong>3. Envíos y entregas:</strong> Las entregas se realizan dentro de las zonas de cobertura indicadas. El tiempo estimado de entrega será confirmado al momento de realizar la compra.</p>
          <p><strong>4. Cambios y devoluciones:</strong> Solo se aceptarán devoluciones de productos defectuosos dentro de las 24 horas posteriores a la entrega presentando el comprobante de pago electrónico.</p>
        </div>
      `,
      confirmButtonText: 'Aceptar',
      confirmButtonColor: '#3498db',
      width: '600px'
    });
  }

  async mostrarPrivacidad() {
    const Swal = (await import('sweetalert2')).default;
    Swal.fire({
      title: 'Política de Privacidad',
      html: `
        <div style="text-align: left; font-size: 0.95rem; line-height: 1.5;">
          <p><strong>1. Uso de datos:</strong> Los datos personales (nombre, correo, dirección) solicitados al momento de registro o compra serán utilizados única y exclusivamente para el procesamiento de los pedidos y el envío de información sobre el estado de los mismos.</p>
          <p><strong>2. Seguridad:</strong> Nos comprometemos a proteger su información personal. No compartimos, vendemos ni alquilamos bases de datos de clientes a terceros.</p>
          <p><strong>3. Cookies:</strong> Nuestro sitio utiliza cookies esenciales para mantener el carrito de compras y la sesión activa durante su navegación.</p>
          <p><strong>4. Derechos ARCO:</strong> Usted puede solicitar el acceso, rectificación, cancelación u oposición al uso de sus datos comunicándose con nuestro equipo de soporte.</p>
        </div>
      `,
      confirmButtonText: 'Aceptar',
      confirmButtonColor: '#3498db',
      width: '600px'
    });
  }
}
