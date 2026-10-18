import { Component, inject, OnInit, signal, computed, HostListener, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { ProductoService } from '../../../productos/services/producto';
import { Producto } from '../../../productos/models/producto.interface';
import { playScannerBeep } from '../../../../core/utils/scanner-audio.util';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-inventario-admin',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './inventario-admin.html',
  styleUrl: './inventario-admin.scss'
})
export class InventarioAdmin implements OnInit {
  private productoService = inject(ProductoService);
  private http = inject(HttpClient);
  private cdr = inject(ChangeDetectorRef);
  
  productos = signal<Producto[]>([]);
  cargando = signal<boolean>(true);
  terminoBusqueda = signal<string>('');

  // Variables para escáner
  private barcodeBuffer = '';
  private lastKeyTime = 0;

  productosFiltrados = computed(() => {
    const rawTerm = this.terminoBusqueda().toLowerCase().trim();
    if (!rawTerm) return this.productos();

    const term = rawTerm.replace(/[-\s]/g, '');
    return this.productos().filter(p => {
      const nombre = p.nombre.toLowerCase();
      const codigoInt = p.codigoInterno.toLowerCase();
      const codigoBar = p.codigoBarras ? p.codigoBarras.toLowerCase() : '';

      return nombre.includes(rawTerm) ||
             codigoInt.includes(rawTerm) ||
             codigoBar.includes(rawTerm) ||
             codigoInt.replace(/[-\s]/g, '').includes(term) ||
             codigoBar.replace(/[-\s]/g, '').includes(term);
    });
  });

  // Catálogos para los selects
  categorias = signal<any[]>([]);
  marcas = signal<any[]>([]);
  unidades = signal<any[]>([]);

  // Estado del Modal
  mostrarModal = signal<boolean>(false);
  modoEdicion = signal<boolean>(false);
  productoEditandoId = signal<number | null>(null);

  // Formulario
  formulario = {
    codigoInterno: '',
    codigoBarras: '',
    nombre: '',
    descripcion: '',
    categoriaId: null,
    marcaId: null,
    unidadMedidaId: null,
    precioCompra: 0,
    precioVenta: 0,
    stockMinimo: 5,
    controlaStock: true,
    afectoIgv: true
  };

  ngOnInit() {
    this.cargarProductos();
    this.cargarCatalogos();
  }

  @HostListener('window:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent) {
    const currentTime = new Date().getTime();
    const timeDiff = currentTime - this.lastKeyTime;

    if (timeDiff > 120) {
      this.barcodeBuffer = '';
    }

    if (event.key === 'Enter') {
      if (this.barcodeBuffer.length >= 2) {
        event.preventDefault();
        this.procesarCodigoEscaneado(this.barcodeBuffer.trim());
        this.barcodeBuffer = '';
      }
    } else if (event.key.length === 1) {
      const target = event.target as HTMLElement;
      const isBarcodeInput = target?.id === 'input-codigo-barras' || target?.getAttribute('name') === 'codigoBarras';
      const isOtherInput = target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement;

      // Si está en otro input (ej. escribiendo nombre), solo capturamos si viene a ráfaga de escáner (<60ms)
      if (!isOtherInput || isBarcodeInput || timeDiff < 60) {
        this.barcodeBuffer += event.key;
      }
    }

    this.lastKeyTime = currentTime;
  }

  procesarCodigoEscaneado(codigo: string) {
    if (!codigo) return;

    if (this.mostrarModal()) {
      // Caso 1: El modal de registro/edición de producto está abierto
      this.formulario.codigoBarras = codigo;
      this.cdr.detectChanges();
      playScannerBeep(true);

      const duplicado = this.productos().find(p => 
        p.codigoBarras && p.codigoBarras.trim().toLowerCase() === codigo.toLowerCase() &&
        (!this.modoEdicion() || p.id !== this.productoEditandoId())
      );

      if (duplicado) {
        Swal.fire({
          icon: 'warning',
          title: 'Código ya registrado',
          text: `El código "${codigo}" ya está asignado a: "${duplicado.nombre}".`,
          timer: 3500
        });
      } else {
        Swal.fire({
          toast: true,
          position: 'top-end',
          icon: 'success',
          title: `Código escaneado: ${codigo}`,
          showConfirmButton: false,
          timer: 1500
        });
      }

      // Enfocar automáticamente el nombre del producto
      setTimeout(() => {
        document.getElementById('input-nombre-producto')?.focus();
      }, 100);

    } else {
      // Caso 2: Vista de tabla de inventario
      this.terminoBusqueda.set(codigo);
      const encontrado = this.productos().find(p => 
        (p.codigoBarras && p.codigoBarras.trim().toLowerCase() === codigo.toLowerCase()) ||
        (p.codigoInterno && p.codigoInterno.trim().toLowerCase() === codigo.toLowerCase())
      );

      if (encontrado) {
        playScannerBeep(true);
        Swal.fire({
          toast: true,
          position: 'top-end',
          icon: 'success',
          title: `Producto: ${encontrado.nombre}`,
          html: `Stock: <b>${encontrado.stockActual}</b> | Precio: <b>S/ ${encontrado.precioVenta.toFixed(2)}</b>`,
          showConfirmButton: false,
          timer: 2000
        });
      } else {
        playScannerBeep(false);
        Swal.fire({
          toast: true,
          position: 'top-end',
          icon: 'info',
          title: 'Código no encontrado en lista',
          text: `Código: ${codigo}`,
          showConfirmButton: false,
          timer: 2000
        });
      }
    }
  }

  actualizarBusqueda(event: any) {
    this.terminoBusqueda.set(event.target.value);
  }

  cargarCatalogos() {
    this.http.get<any>('/api/categorias').subscribe(res => this.categorias.set(res.data?.content || []));
    this.http.get<any>('/api/marcas').subscribe(res => this.marcas.set(res.data?.content || []));
    this.http.get<any>('/api/unidades-medida').subscribe(res => this.unidades.set(res.data?.content || []));
  }

  cargarProductos() {
    this.cargando.set(true);
    // Cargar hasta 1000 productos para que el inventario completo esté disponible
    this.productoService.obtenerProductos(0, 1000).subscribe({
      next: (res: any) => {
        const list = res.data?.content || res.data || [];
        this.productos.set(list);
        this.cargando.set(false);
      },
      error: (err) => {
        console.error('Error cargando inventario', err);
        this.cargando.set(false);
      }
    });
  }

  // Custom Prompt Modal
  promptActivo = signal<boolean>(false);
  promptTipo = signal<'categoria' | 'marca' | 'unidad'>('categoria');
  promptDatos = { nombre: '', abreviatura: '' };

  agregarCategoria() {
    this.promptTipo.set('categoria');
    this.promptDatos = { nombre: '', abreviatura: '' };
    this.promptActivo.set(true);
  }

  agregarMarca() {
    this.promptTipo.set('marca');
    this.promptDatos = { nombre: '', abreviatura: '' };
    this.promptActivo.set(true);
  }

  agregarUnidad() {
    this.promptTipo.set('unidad');
    this.promptDatos = { nombre: '', abreviatura: '' };
    this.promptActivo.set(true);
  }

  cerrarPrompt() {
    this.promptActivo.set(false);
  }

  guardarPrompt() {
    if (!this.promptDatos.nombre) return;

    if (this.promptTipo() === 'categoria') {
      this.http.post<any>('/api/categorias', { nombre: this.promptDatos.nombre }).subscribe({
        next: (res) => {
          this.categorias.set([...this.categorias(), res.data]);
          this.formulario.categoriaId = res.data.id;
          this.cerrarPrompt();
        },
        error: (err) => Swal.fire('Error', err.error?.message || 'Error al guardar', 'error')
      });
    } else if (this.promptTipo() === 'marca') {
      this.http.post<any>('/api/marcas', { nombre: this.promptDatos.nombre }).subscribe({
        next: (res) => {
          this.marcas.set([...this.marcas(), res.data]);
          this.formulario.marcaId = res.data.id;
          this.cerrarPrompt();
        },
        error: (err) => Swal.fire('Error', err.error?.message || 'Error al guardar', 'error')
      });
    } else if (this.promptTipo() === 'unidad') {
      if (!this.promptDatos.abreviatura) return;
      this.http.post<any>('/api/unidades-medida', { nombre: this.promptDatos.nombre, abreviatura: this.promptDatos.abreviatura }).subscribe({
        next: (res) => {
          this.unidades.set([...this.unidades(), res.data]);
          this.formulario.unidadMedidaId = res.data.id;
          this.cerrarPrompt();
        },
        error: (err) => Swal.fire('Error', err.error?.message || 'Error al guardar', 'error')
      });
    }
  }

  abrirModalNuevo() {
    this.modoEdicion.set(false);
    this.productoEditandoId.set(null);
    this.formulario = {
      codigoInterno: 'Cargando...', 
      codigoBarras: '', nombre: '', descripcion: '',
      categoriaId: null, marcaId: null, unidadMedidaId: null,
      precioCompra: 0, precioVenta: 0, stockMinimo: 5,
      controlaStock: true, afectoIgv: true
    };
    this.mostrarModal.set(true);

    this.productoService.generarCodigo().subscribe({
      next: (res) => {
        if (res.success && res.data) {
          // Reasignar el objeto completo fuerza a Angular a detectar el cambio inmediatamente
          this.formulario = {
            ...this.formulario,
            codigoInterno: res.data
          };
          this.cdr.detectChanges();
        }
      }
    });
  }

  abrirModalEditar(p: any) {
    this.modoEdicion.set(true);
    this.productoEditandoId.set(p.id);
    this.formulario = {
      codigoInterno: p.codigoInterno,
      codigoBarras: p.codigoBarras,
      nombre: p.nombre,
      descripcion: p.descripcion,
      categoriaId: p.categoriaId,
      marcaId: p.marcaId,
      unidadMedidaId: p.unidadMedidaId,
      precioCompra: p.precioCompra,
      precioVenta: p.precioVenta,
      stockMinimo: p.stockMinimo,
      controlaStock: p.controlaStock,
      afectoIgv: p.afectoIgv
    };
    this.mostrarModal.set(true);
  }

  cerrarModal() {
    this.mostrarModal.set(false);
  }

  guardarProducto() {
    if (this.modoEdicion() && this.productoEditandoId()) {
      this.productoService.actualizarProducto(this.productoEditandoId()!, this.formulario).subscribe({
        next: () => {
          this.cerrarModal();
          this.cargarProductos();
          Swal.fire({ toast: true, position: 'top-end', icon: 'success', title: 'Producto actualizado', showConfirmButton: false, timer: 3000 });
        },
        error: (err) => Swal.fire('Error', err.error?.message || 'Error al actualizar', 'error')
      });
    } else {
      this.productoService.crearProducto(this.formulario).subscribe({
        next: () => {
          this.cerrarModal();
          this.cargarProductos();
          Swal.fire({ toast: true, position: 'top-end', icon: 'success', title: 'Producto creado', showConfirmButton: false, timer: 3000 });
        },
        error: (err) => Swal.fire('Error', err.error?.message || 'Error al crear', 'error')
      });
    }
  }
}
