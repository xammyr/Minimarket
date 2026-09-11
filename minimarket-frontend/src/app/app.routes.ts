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

// 3. Login y Guardias
import { Login } from './features/auth/components/login/login';
import { authGuard } from './core/guards/auth.guard';

import { InventarioAdmin } from './features/admin/components/inventario-admin/inventario-admin';
import { ResumenAdmin } from './features/admin/components/resumen-admin/resumen-admin';
import { UsuariosAdmin } from './features/admin/components/usuarios-admin/usuarios-admin';

export const routes: Routes = [
  { path: 'login', component: Login, title: 'Iniciar Sesión' },
  { 
    path: 'caja', 
    component: LayoutCajero, 
    title: 'Sistema de Caja',
    canActivate: [authGuard],
    children: [
      { path: '', component: ProductoLista, title: 'POS - Nueva Venta' },
      { path: 'facturas', component: Facturas, title: 'Facturas y Boletas' },
      { path: 'compras', component: Compras, title: 'Registro de Compras' },
      { path: 'corte', component: CorteCaja, title: 'Corte de Caja' }
    ]
  },
  { 
    path: 'admin', 
    component: DashboardAdmin, 
    title: 'Panel de Control - Admin',
    canActivate: [authGuard],
    children: [
      { path: '', component: ResumenAdmin, title: 'Admin - Resumen' },
      { path: 'inventario', component: InventarioAdmin, title: 'Admin - Inventario' },
      { path: 'usuarios', component: UsuariosAdmin, title: 'Admin - Usuarios' }
    ]
  },
  { path: 'tienda', component: HomeCliente, title: 'Minimarket - Catálogo en línea' },
  
  // Reglas de seguridad (Rutas por defecto)
  { path: '', redirectTo: '/tienda', pathMatch: 'full' },
  { path: '**', redirectTo: '/tienda' } 
];
