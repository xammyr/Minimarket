// Interfaz genérica para envolver las respuestas de tu backend
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
}

// Estructura exacta de tu ProductoResponseDTO
export interface Producto {
  id: number;
  codigoInterno: string;
  codigoBarras: string;
  nombre: string;
  descripcion: string | null;
  categoriaId: number;
  categoriaNombre: string;
  marcaId: number;
  marcaNombre: string;
  unidadMedidaId: number;
  unidadMedidaAbreviatura: string;
  precioCompra: number;
  precioVenta: number;
  afectoIgv: boolean;
  stockActual: number;
  stockMinimo: number;
  controlaStock: boolean;
  activo: boolean;
  creadoEn?: string;
}
