package com.minimarket.venta.service;
import com.minimarket.caja.entity.*; import com.minimarket.caja.repository.*; import com.minimarket.cliente.repository.ClienteRepository; import com.minimarket.common.exception.*; import com.minimarket.inventario.dto.MovimientoInventarioRequest; import com.minimarket.inventario.entity.InventarioMovimiento.TipoMovimientoInventario; import com.minimarket.inventario.service.InventarioService; import com.minimarket.producto.repository.ProductoRepository; import com.minimarket.security.CurrentUserService; import com.minimarket.venta.dto.*; import com.minimarket.venta.entity.*; import com.minimarket.venta.repository.*; import lombok.RequiredArgsConstructor; import org.springframework.data.domain.*; import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional; import java.math.*; import java.time.OffsetDateTime; import java.util.*;
@Service @RequiredArgsConstructor public class VentaServiceImpl implements VentaService{
 private static final BigDecimal IGV_RATE=new BigDecimal("0.18"); private static final RoundingMode RM=RoundingMode.HALF_UP;
 private final VentaRepository ventas; private final VentaDetalleRepository detalles; private final VentaPagoRepository pagos; private final MetodoPagoRepository metodos; private final ProductoRepository productos; private final ClienteRepository clientes; private final CajaTurnoRepository turnos; private final CajaMovimientoRepository cajaMov; private final CurrentUserService current; private final InventarioService inventario;
 @Override @Transactional public VentaResponseDTO crear(CrearVentaRequest r){
   var turno=turnos.findById(r.cajaTurnoId()).orElseThrow(()->ResourceNotFoundException.of("CajaTurno",r.cajaTurnoId()));
   if(turno.getEstado()!=CajaTurno.EstadoCajaTurno.ABIERTO)throw new BusinessException("El turno de caja no está abierto");
   var cliente=r.clienteId()==null?null:clientes.findById(r.clienteId()).orElseThrow(()->ResourceNotFoundException.of("Cliente",r.clienteId()));
   var usuario=current.getUsuario();
   var venta=Venta.builder().numeroVenta(numero()).cliente(cliente).usuario(usuario).cajaTurno(turno).fechaVenta(OffsetDateTime.now()).subtotal(BigDecimal.ZERO).descuento(BigDecimal.ZERO).igv(BigDecimal.ZERO).total(BigDecimal.ZERO).estado(Venta.EstadoVenta.COMPLETADA).build();
   BigDecimal base=BigDecimal.ZERO, desc=BigDecimal.ZERO, tax=BigDecimal.ZERO, gross=BigDecimal.ZERO;
   List<VentaDetalle> ds=new ArrayList<>();
   for(var x:r.detalles()){
     var p=productos.findById(x.productoId()).orElseThrow(()->ResourceNotFoundException.of("Producto",x.productoId()));
     if(!Boolean.TRUE.equals(p.getActivo()))throw new BusinessException("Producto inactivo: "+p.getNombre());
     if(Boolean.TRUE.equals(p.getControlaStock()) && p.getStockActual().compareTo(x.cantidad())<0)throw new BusinessException("Stock insuficiente para: "+p.getNombre());
     BigDecimal lineGross=p.getPrecioVenta().multiply(x.cantidad()).subtract(x.descuento()).setScale(2,RM);
     if(lineGross.signum()<0)throw new BusinessException("Descuento mayor al importe del producto: "+p.getNombre());
     BigDecimal lineBase=Boolean.TRUE.equals(p.getAfectoIgv())?lineGross.divide(BigDecimal.ONE.add(IGV_RATE),2,RM):lineGross;
     BigDecimal lineTax=Boolean.TRUE.equals(p.getAfectoIgv())?lineGross.subtract(lineBase):BigDecimal.ZERO;
     desc=desc.add(x.descuento());base=base.add(lineBase);tax=tax.add(lineTax);gross=gross.add(lineGross);
     ds.add(VentaDetalle.builder().venta(venta).producto(p).cantidad(x.cantidad()).precioUnitario(p.getPrecioVenta()).descuento(x.descuento()).igv(lineTax).subtotal(lineBase).total(lineGross).build());
   }
   BigDecimal paid=r.pagos().stream().map(VentaPagoRequest::monto).reduce(BigDecimal.ZERO,BigDecimal::add).setScale(2,RM);
   gross=gross.setScale(2,RM); if(paid.compareTo(gross)!=0)throw new BusinessException("La suma de pagos debe ser igual al total de la venta");
   venta.setSubtotal(base.setScale(2,RM));venta.setDescuento(desc.setScale(2,RM));venta.setIgv(tax.setScale(2,RM));venta.setTotal(gross);
   venta=ventas.save(venta); detalles.saveAll(ds);
   BigDecimal efectivo=BigDecimal.ZERO;
   for(var x:r.pagos()){var mp=metodos.findById(x.metodoPagoId()).orElseThrow(()->ResourceNotFoundException.of("MetodoPago",x.metodoPagoId()));if(!Boolean.TRUE.equals(mp.getActivo()))throw new BusinessException("Método de pago inactivo");if((mp.getCodigo().equalsIgnoreCase("EFECTIVO")))efectivo=efectivo.add(x.monto());pagos.save(VentaPago.builder().venta(venta).metodoPago(mp).monto(x.monto()).referencia(x.referencia()).build());}
   for(var d:ds){if(Boolean.TRUE.equals(d.getProducto().getControlaStock())) inventario.registrar(new MovimientoInventarioRequest(d.getProducto().getId(),null,d.getCantidad(),TipoMovimientoInventario.VENTA,"Venta "+venta.getNumeroVenta(),"VENTA",venta.getId()));}
   if(efectivo.signum()>0)cajaMov.save(CajaMovimiento.builder().cajaTurno(turno).tipoMovimiento(CajaMovimiento.TipoMovimientoCaja.VENTA).monto(efectivo).concepto("Venta "+venta.getNumeroVenta()).referenciaTipo("VENTA").referenciaId(venta.getId()).usuario(usuario).build());
   return obtener(venta.getId());
 }
 @Transactional(readOnly=true) public VentaResponseDTO obtener(Long id){var v=ventas.findById(id).orElseThrow(()->ResourceNotFoundException.of("Venta",id));return d(v);}
 @Transactional(readOnly=true) public Page<VentaResponseDTO> listar(Pageable p){return ventas.findAllByOrderByFechaVentaDesc(p).map(this::d);}
 @Transactional public void anular(Long id,String motivo){
   var v=ventas.findById(id).orElseThrow(()->ResourceNotFoundException.of("Venta",id));
   if(v.getEstado()==Venta.EstadoVenta.ANULADA)throw new BusinessException("La venta ya está anulada");
   if(motivo==null||motivo.isBlank())throw new BusinessException("Debe indicar motivo de anulación");
   for(var d:detalles.findByVentaId(id)){
      if(Boolean.TRUE.equals(d.getProducto().getControlaStock())) {
         inventario.registrar(new MovimientoInventarioRequest(d.getProducto().getId(),null,d.getCantidad(),TipoMovimientoInventario.DEVOLUCION_VENTA,"Anulación "+v.getNumeroVenta(),"ANULACION_VENTA",v.getId()));
      }
   }
   BigDecimal efectivo=pagos.findByVentaId(id).stream()
      .filter(x->"EFECTIVO".equalsIgnoreCase(x.getMetodoPago().getCodigo()))
      .map(VentaPago::getMonto).reduce(BigDecimal.ZERO,BigDecimal::add);
   if(efectivo.signum()>0){
      cajaMov.save(CajaMovimiento.builder().cajaTurno(v.getCajaTurno()).tipoMovimiento(CajaMovimiento.TipoMovimientoCaja.EGRESO)
         .monto(efectivo.negate()).concepto("Anulación "+v.getNumeroVenta()).referenciaTipo("ANULACION_VENTA")
         .referenciaId(v.getId()).usuario(current.getUsuario()).build());
   }
   v.setEstado(Venta.EstadoVenta.ANULADA);v.setMotivoAnulacion(motivo);
}
 private String numero(){return "V"+UUID.randomUUID().toString().replace("-", "").substring(0,19).toUpperCase();} 
 private VentaResponseDTO d(Venta v){var ds=detalles.findByVentaId(v.getId()).stream().map(x->new VentaDetalleResponseDTO(x.getId(),x.getProducto().getId(),x.getProducto().getNombre(),x.getCantidad(),x.getPrecioUnitario(),x.getDescuento(),x.getIgv(),x.getSubtotal(),x.getTotal())).toList();var ps=pagos.findByVentaId(v.getId()).stream().map(x->new VentaPagoResponseDTO(x.getId(),x.getMetodoPago().getId(),x.getMetodoPago().getNombre(),x.getMonto(),x.getReferencia())).toList();return new VentaResponseDTO(v.getId(),v.getNumeroVenta(),v.getCliente()!=null?v.getCliente().getId():null,v.getUsuario().getId(),v.getCajaTurno().getId(),v.getSubtotal(),v.getDescuento(),v.getIgv(),v.getTotal(),v.getEstado().name(),v.getFechaVenta(),ds,ps);}
}
