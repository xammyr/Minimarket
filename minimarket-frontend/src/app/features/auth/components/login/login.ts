import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class Login {
  private http = inject(HttpClient);
  private router = inject(Router);

  username = '';
  password = '';
  errorMsg = '';
  loading = false;
  showPassword = false;

  togglePassword() {
    this.showPassword = !this.showPassword;
  }

  volverTienda() {
    this.router.navigate(['/tienda']);
  }

  onSubmit() {
    if (!this.username || !this.password) {
      this.errorMsg = 'Por favor ingrese usuario y contraseña';
      return;
    }

    this.loading = true;
    this.errorMsg = '';

    this.http.post<any>('/api/auth/login', {
      username: this.username,
      password: this.password
    }).subscribe({
      next: (res) => {
        this.loading = false;
        if (res.success && res.data && res.data.token) {
          localStorage.setItem('token', res.data.token);
          localStorage.setItem('nombreCompleto', res.data.nombreCompleto || res.data.username || 'Cajero');
          
          const roles = res.data.roles || [];
          localStorage.setItem('roles', JSON.stringify(roles));
          
          if (roles.includes('ADMIN')) {
            this.router.navigate(['/admin']);
          } else if (roles.includes('INVENTARIO')) {
            this.router.navigate(['/admin/inventario']);
          } else {
            this.router.navigate(['/caja']);
          }
        }
      },
      error: (err) => {
        this.loading = false;
        this.errorMsg = err.error?.message || 'Usuario o contraseña incorrectos';
      }
    });
  }
}
