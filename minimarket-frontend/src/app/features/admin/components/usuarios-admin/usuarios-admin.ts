import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { UsuarioService, Usuario, Rol } from '../../services/usuario.service';

@Component({
  selector: 'app-usuarios-admin',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './usuarios-admin.html',
  styleUrl: './usuarios-admin.scss'
})
export class UsuariosAdmin implements OnInit {
  private router = inject(Router);

  usuarios = signal<Usuario[]>([]);
  roles = signal<Rol[]>([]);
  
  mostrarModal = false;
  modoEdicion = false;
  guardando = false;
  
  usuarioActual: Usuario = {
    username: '',
    nombres: '',
    apellidos: '',
    email: '',
    telefono: '',
    activo: true,
    rolesIds: []
  };

  rolSeleccionadoId: number | null = null;
  public verPassword = false; // Añadido public para forzar refresco


  constructor(private usuarioService: UsuarioService) {}

  ngOnInit(): void {
    const roles = localStorage.getItem('roles') || '';
    if (!roles.includes('ADMIN') && roles.includes('INVENTARIO')) {
      this.router.navigate(['/admin/inventario']);
      return;
    }
    
    this.cargarUsuarios();
    this.cargarRoles();
  }

  cargarUsuarios(): void {
    this.usuarioService.listarUsuarios().subscribe({
      next: (res) => {
        if (res.success && res.data) {
          this.usuarios.set(res.data.content);
        }
      },
      error: (err) => console.error('Error al cargar usuarios', err)
    });
  }

  cargarRoles(): void {
    this.usuarioService.listarRoles().subscribe({
      next: (res) => {
        if (res.success && res.data) {
          // Ahora sí permitimos crear usuarios con rol INVENTARIO
          this.roles.set(res.data);
        }
      },
      error: (err) => console.error('Error al cargar roles', err)
    });
  }

  abrirModalNuevo(): void {
    this.modoEdicion = false;
    this.usuarioActual = {
      username: '',
      password: '',
      nombres: '',
      apellidos: '',
      email: '',
      telefono: '',
      activo: true,
      rolesIds: []
    };
    this.rolSeleccionadoId = null;
    this.verPassword = false;
    this.mostrarModal = true;
  }

  abrirModalEditar(usuario: Usuario): void {
    this.modoEdicion = true;
    this.usuarioActual = { ...usuario, password: '' };
    
    // Buscar si el usuario ya tiene un rol asignado para preseleccionarlo en el combobox
    this.rolSeleccionadoId = null;
    if (usuario.roles && usuario.roles.length > 0) {
      const rolEncontrado = this.roles().find(r => r.nombre === usuario.roles![0]);
      if (rolEncontrado) {
        this.rolSeleccionadoId = rolEncontrado.id;
      }
    }
    
    this.verPassword = false;
    this.mostrarModal = true;
  }

  cerrarModal(): void {
    this.mostrarModal = false;
  }

  guardarUsuario(): void {
    if (this.guardando) return;

    if (!this.usuarioActual.username) {
      this.mostrarError('El nombre de usuario es obligatorio');
      return;
    }
    if (!this.modoEdicion && !this.usuarioActual.password) {
      this.mostrarError('La contraseña es obligatoria para nuevos usuarios');
      return;
    }
    if (!this.rolSeleccionadoId) {
      this.mostrarError('Debe seleccionar un rol para el usuario');
      return;
    }

    // Asignar el rol seleccionado al array que espera el backend
    this.usuarioActual.rolesIds = [this.rolSeleccionadoId];

    // Clonar el usuario para no modificar la UI y limpiar el email
    const payload = { ...this.usuarioActual };
    if (!payload.email || payload.email.trim() === '') {
      payload.email = undefined; // Evita enviar string vacío
    }

    if (this.modoEdicion && payload.id) {
      this.guardando = true;
      this.usuarioService.actualizarUsuario(payload.id, payload).subscribe({
        next: (res) => {
          this.guardando = false;
          if (res.success) {
            this.mostrarExito('Usuario actualizado correctamente');
            this.cargarUsuarios();
            this.cerrarModal();
          }
        },
        error: (err) => {
          this.guardando = false;
          let msj = err.error?.message || 'Error al actualizar usuario';
          if (err.error?.data && typeof err.error.data === 'object') {
            const errores = Object.values(err.error.data).join('<br>');
            msj = `${msj}<br><br><small>${errores}</small>`;
          }
          this.mostrarErrorHTML(msj);
        }
      });
    } else {
      this.guardando = true;
      this.usuarioService.crearUsuario(payload).subscribe({
        next: (res) => {
          this.guardando = false;
          if (res.success) {
            this.mostrarExito('Usuario creado correctamente');
            this.cargarUsuarios();
            this.cerrarModal();
          }
        },
        error: (err) => {
          this.guardando = false;
          let msj = err.error?.message || 'Error al crear usuario';
          if (err.error?.data && typeof err.error.data === 'object') {
            const errores = Object.values(err.error.data).join('<br>');
            msj = `${msj}<br><br><small>${errores}</small>`;
          }
          this.mostrarErrorHTML(msj);
        }
      });
    }
  }

  eliminarUsuario(id: number): void {
    import('sweetalert2').then(Swal => {
      Swal.default.fire({
        title: '¿Eliminar usuario?',
        text: 'Esta acción no se puede deshacer',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#e74c3c',
        cancelButtonColor: '#bdc3c7',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
      }).then((result) => {
        if (result.isConfirmed) {
          this.usuarioService.eliminarUsuario(id).subscribe({
            next: (res) => {
              if (res.success) {
                this.mostrarExito('Usuario eliminado correctamente');
                this.cargarUsuarios();
              }
            },
            error: (err) => this.mostrarError(err.error?.message || 'Error al eliminar usuario')
          });
        }
      });
    });
  }

  private mostrarError(mensaje: string) {
    import('sweetalert2').then(Swal => {
      Swal.default.fire({
        icon: 'error',
        title: 'Error',
        html: mensaje,
        confirmButtonColor: '#e74c3c'
      });
    });
  }

  private mostrarErrorHTML(mensaje: string) {
    this.mostrarError(mensaje);
  }

  private mostrarExito(mensaje: string) {
    import('sweetalert2').then(Swal => {
      Swal.default.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: mensaje,
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true
      });
    });
  }
}
