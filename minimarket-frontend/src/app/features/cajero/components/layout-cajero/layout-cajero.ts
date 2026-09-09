import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-layout-cajero',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './layout-cajero.html',
  styleUrl: './layout-cajero.scss'
})
export class LayoutCajero {
  
  // 1. Declaramos la variable que pide el HTML con la fecha de hoy formateada en español
  fechaActual = new Intl.DateTimeFormat('es-ES', { 
    weekday: 'long', 
    day: 'numeric', 
    month: 'long', 
    year: 'numeric' 
  }).format(new Date());

  // 2. Lógica del menú hamburguesa
  sidebarAbierto = signal(false);

  toggleSidebar() {
    this.sidebarAbierto.update(valor => !valor);
  }

  cerrarSidebar() {
    this.sidebarAbierto.set(false);
  }
}