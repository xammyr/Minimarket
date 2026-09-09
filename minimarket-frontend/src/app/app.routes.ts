import { Routes } from '@angular/router';

// 1. Componentes principales
import { ProductoLista } from './features/productos/components/producto-lista/producto-lista';
import { DashboardAdmin } from './features/admin/components/dashboard-admin/dashboard-admin';
import { HomeCliente } from './features/cliente/components/home-cliente/home-cliente';
import { LayoutCajero } from './features/cajero/components/layout-cajero/layout-cajero';
import { Facturas } from './features/cajero/components/facturas/facturas';

// 2. Componentes recién creados (Nombres corregidos)
import { Compras } from './features/cajero/components/compras/compras';
import { CorteCaja } from './features/cajero/components/corte-caja/corte-caja';

export const routes: Routes = [
  { 
    path: 'caja', 
    component: LayoutCajero, 
    title: 'Sistema de Caja',
    children: [
      { path: '', component: ProductoLista, title: 'POS - Nueva Venta' },
      { path: 'facturas', component: Facturas, title: 'Facturas y Boletas' },
      { path: 'compras', component: Compras, title: 'Registro de Compras' },
      { path: 'corte', component: CorteCaja, title: 'Corte de Caja' }
    ]
  },
  { path: 'admin', component: DashboardAdmin, title: 'Panel de Control - Admin' },
  { path: 'tienda', component: HomeCliente, title: 'Minimarket - Catálogo en línea' },
  
  // Reglas de seguridad (Rutas por defecto)
  { path: '', redirectTo: '/tienda', pathMatch: 'full' },
  { path: '**', redirectTo: '/tienda' } 
];