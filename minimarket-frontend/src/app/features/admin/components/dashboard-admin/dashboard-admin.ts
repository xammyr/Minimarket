import { Component, inject } from '@angular/core';
import { Router, RouterModule } from '@angular/router';

import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-dashboard-admin',
  standalone: true,
  imports: [RouterModule, CommonModule],
  templateUrl: './dashboard-admin.html',
  styleUrl: './dashboard-admin.scss',
})
export class DashboardAdmin {
  private router = inject(Router);

  nombreAdmin = localStorage.getItem('nombreCompleto') || 'Usuario';
  esAdmin = (localStorage.getItem('roles') || '').includes('ADMIN');

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('roles');
    localStorage.removeItem('nombreCompleto');
    this.router.navigate(['/login']);
  }
}
