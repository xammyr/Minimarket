import { Component, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';

@Component({
  selector: 'app-layout-cajero',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './layout-cajero.html',
  styleUrl: './layout-cajero.scss'
})
export class LayoutCajero {
  private router = inject(Router);

  // 1. Declaramos la variable que pide el HTML con la fecha de hoy formateada en español
  fechaActual = new Intl.DateTimeFormat('es-ES', { 
    weekday: 'long', 
    day: 'numeric', 
    month: 'long', 
    year: 'numeric' 
  }).format(new Date());

  nombreCajero = localStorage.getItem('nombreCompleto') || 'Cajero';
  
  esAdmin = false;

  constructor() {
    const rolesStr = localStorage.getItem('roles');
    if (rolesStr && rolesStr.includes('ADMIN')) {
      this.esAdmin = true;
    }
  }

  // 2. Lógica del menú hamburguesa
  sidebarAbierto = signal(false);

  toggleSidebar() {
    this.sidebarAbierto.update(valor => !valor);
  }

  cerrarSidebar() {
    this.sidebarAbierto.set(false);
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('roles');
    localStorage.removeItem('nombreCompleto');
    this.router.navigate(['/login']);
  }
}
