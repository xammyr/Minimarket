import { Component, inject, OnInit, ChangeDetectorRef } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { forkJoin, catchError, of } from 'rxjs';
import { Router } from '@angular/router';

@Component({
  selector: 'app-resumen-admin',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './resumen-admin.html',
  styleUrl: './resumen-admin.scss'
})
export class ResumenAdmin implements OnInit {
  private http = inject(HttpClient);
  private cdr = inject(ChangeDetectorRef);
  
  totalVentas: number = 0;
  montoTotalVentas: number = 0;
  totalProductos: number = 0;
  ventasRecientes: any[] = [];
  cargando: boolean = true;
  
  // Datos para el gráfico
  dias: string[] = [];
  ventasPorDia: number[] = [];
  maxVentaDia: number = 0;
  
  // Guardamos las ventas agrupadas por día para mostrarlas al clickear
  ventasAgrupadasPorDia: { [key: string]: any[] } = {};
  fechasOrdenadas: string[] = [];

  private router = inject(Router);

  ngOnInit() {
    const roles = localStorage.getItem('roles') || '';
    if (!roles.includes('ADMIN') && roles.includes('INVENTARIO')) {
      this.router.navigate(['/admin/inventario']);
      return;
    }
    this.cargarDatos();
  }

  cargarDatos() {
    this.cargando = true;
    this.cdr.detectChanges();
    
    const ventas$ = this.http.get<any>('/api/ventas?size=500').pipe(
      catchError(err => {
        console.error("Error ventas", err);
        return of(null);
      })
    );
    
    const productos$ = this.http.get<any>('/api/productos?size=1').pipe(
      catchError(err => {
        console.error("Error productos", err);
        return of(null);
      })
    );

    forkJoin([ventas$, productos$]).subscribe(([resVentas, resProductos]) => {
      if (resVentas && resVentas.data && resVentas.data.content) {
        const ventas = resVentas.data.content;
        this.ventasRecientes = ventas.slice(0, 5);
        this.totalVentas = ventas.length;
        
        const ventasCompletadas = ventas.filter((v: any) => v.estado === 'COMPLETADA');
        
        this.montoTotalVentas = ventasCompletadas.reduce((sum: number, v: any) => sum + v.total, 0);
        
        this.procesarDatosGrafico(ventasCompletadas);
      }

      if (resProductos && resProductos.data) {
        this.totalProductos = resProductos.data.totalElements || 0;
      }

      this.cargando = false;
      this.cdr.detectChanges();
    });
  }

  procesarDatosGrafico(ventas: any[]) {
    this.ventasAgrupadasPorDia = {};
    
    ventas.forEach(v => {
      if (!v.fechaVenta) return;
      const fechaObj = new Date(v.fechaVenta);
      const fecha = fechaObj.toISOString().split('T')[0];
      
      if (!this.ventasAgrupadasPorDia[fecha]) {
        this.ventasAgrupadasPorDia[fecha] = [];
      }
      this.ventasAgrupadasPorDia[fecha].push(v);
    });

    const todasFechas = Object.keys(this.ventasAgrupadasPorDia).sort();
    this.fechasOrdenadas = todasFechas.slice(-7);
    
    this.dias = [];
    this.ventasPorDia = [];
    
    this.fechasOrdenadas.forEach(f => {
      const parts = f.split('-');
      this.dias.push(`${parts[2]}/${parts[1]}`);
      
      const totalDia = this.ventasAgrupadasPorDia[f].reduce((sum, v) => sum + v.total, 0);
      this.ventasPorDia.push(totalDia);
    });
    
    if (this.dias.length === 0) {
      this.dias = ['Sin datos'];
      this.ventasPorDia = [0];
    }
    
    this.maxVentaDia = Math.max(...this.ventasPorDia, 1);
  }

  // --- NUEVA FUNCIÓN PARA MOSTRAR DETALLE AL CLICKEAR LA BARRA ---
  verDetalleDia(index: number) {
    if (this.dias[index] === 'Sin datos' || this.ventasPorDia[index] === 0) return;
    
    const fecha = this.fechasOrdenadas[index];
    const ventasDelDia = this.ventasAgrupadasPorDia[fecha] || [];
    
    // Sumar todos los productos vendidos ese día
    const productosVendidos: { [key: string]: { cant: number, total: number } } = {};
    
    ventasDelDia.forEach(venta => {
      if (venta.detalles) {
        venta.detalles.forEach((det: any) => {
          if (!productosVendidos[det.producto]) {
            productosVendidos[det.producto] = { cant: 0, total: 0 };
          }
          productosVendidos[det.producto].cant += det.cantidad;
          productosVendidos[det.producto].total += det.total;
        });
      }
    });
    
    let htmlContent = '<div style="text-align: left; max-height: 300px; overflow-y: auto;">';
    htmlContent += '<table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">';
    htmlContent += '<tr style="border-bottom: 1px solid #eee;"><th>Producto</th><th>Cant.</th><th>Total</th></tr>';
    
    Object.keys(productosVendidos).forEach(prod => {
      const d = productosVendidos[prod];
      htmlContent += `<tr style="border-bottom: 1px solid #f9f9f9;">
        <td style="padding: 5px 0;">${prod}</td>
        <td style="text-align: center;">${d.cant}</td>
        <td style="text-align: right;">S/ ${d.total.toFixed(2)}</td>
      </tr>`;
    });
    
    htmlContent += '</table></div>';

    import('sweetalert2').then(Swal => {
      Swal.default.fire({
        title: `Ventas del ${this.dias[index]}`,
        html: htmlContent,
        confirmButtonText: 'Cerrar',
        confirmButtonColor: '#3498db'
      });
    });
  }
}
