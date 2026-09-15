import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { ProductoService } from '../../../productos/services/producto';
import { Producto } from '../../../productos/models/producto.interface';

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
  
  productos = signal<Producto[]>([]);
  cargando = signal<boolean>(true);

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

  cargarCatalogos() {
    this.http.get<any>('/api/categorias').subscribe(res => this.categorias.set(res.data?.content || []));
    this.http.get<any>('/api/marcas').subscribe(res => this.marcas.set(res.data?.content || []));
    this.http.get<any>('/api/unidades-medida').subscribe(res => this.unidades.set(res.data?.content || []));
  }

  cargarProductos() {
    this.cargando.set(true);
    this.productoService.obtenerProductos().subscribe({
      next: (res: any) => {
        this.productos.set(res.data.content);
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
        error: (err) => alert('Error: ' + err.error?.message)
      });
    } else if (this.promptTipo() === 'marca') {
      this.http.post<any>('/api/marcas', { nombre: this.promptDatos.nombre }).subscribe({
        next: (res) => {
          this.marcas.set([...this.marcas(), res.data]);
          this.formulario.marcaId = res.data.id;
          this.cerrarPrompt();
        },
        error: (err) => alert('Error: ' + err.error?.message)
      });
    } else if (this.promptTipo() === 'unidad') {
      if (!this.promptDatos.abreviatura) return;
      this.http.post<any>('/api/unidades-medida', { nombre: this.promptDatos.nombre, abreviatura: this.promptDatos.abreviatura }).subscribe({
        next: (res) => {
          this.unidades.set([...this.unidades(), res.data]);
          this.formulario.unidadMedidaId = res.data.id;
          this.cerrarPrompt();
        },
        error: (err) => alert('Error: ' + err.error?.message)
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
          this.formulario.codigoInterno = res.data;
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
        },
        error: (err) => alert('Error al actualizar: ' + err.error?.message)
      });
    } else {
      this.productoService.crearProducto(this.formulario).subscribe({
        next: () => {
          this.cerrarModal();
          this.cargarProductos();
        },
        error: (err) => alert('Error al crear: ' + err.error?.message)
      });
    }
  }
}
