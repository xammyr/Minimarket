package com.minimarket.compra.service;

import com.minimarket.common.exception.BusinessException;
import com.minimarket.common.exception.ResourceNotFoundException;
import com.minimarket.compra.dto.CompraDetalleResponseDTO;
import com.minimarket.compra.dto.CompraRequestDTO;
import com.minimarket.compra.dto.CompraResponseDTO;
import com.minimarket.compra.entity.Compra;
import com.minimarket.compra.entity.CompraDetalle;
import com.minimarket.compra.repository.CompraDetalleRepository;
import com.minimarket.compra.repository.CompraRepository;
import com.minimarket.inventario.dto.MovimientoInventarioRequest;
import com.minimarket.inventario.entity.InventarioMovimiento.TipoMovimientoInventario;
import com.minimarket.inventario.service.InventarioService;
import com.minimarket.producto.repository.ProductoRepository;
import com.minimarket.proveedor.repository.ProveedorRepository;
import com.minimarket.security.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CompraServiceImpl implements CompraService {

    private static final RoundingMode RM = RoundingMode.HALF_UP;
    private static final BigDecimal IGV_RATE = new BigDecimal("0.18");

    private final CompraRepository compras;
    private final CompraDetalleRepository detalles;
    private final ProveedorRepository proveedores;
    private final ProductoRepository productos;
    private final InventarioService inventario;
    private final CurrentUserService current;

    @Override
    @Transactional
    public CompraResponseDTO registrarCompra(CompraRequestDTO r) {
        var proveedor = proveedores.findById(r.proveedorId())
            .orElseThrow(() -> ResourceNotFoundException.of("Proveedor", r.proveedorId()));
        var usuario = current.getUsuario();

        var compra = Compra.builder()
            .numeroComprobante(r.numeroComprobante())
            .proveedor(proveedor)
            .usuario(usuario)
            .fechaCompra(OffsetDateTime.now())
            .subtotal(BigDecimal.ZERO)
            .igv(BigDecimal.ZERO)
            .total(BigDecimal.ZERO)
            .estado(Compra.EstadoCompra.COMPLETADA)
            .build();

        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal total = BigDecimal.ZERO;

        List<CompraDetalle> ds = new ArrayList<>();
        for (var reqDetalle : r.detalles()) {
            var p = productos.findById(reqDetalle.productoId())
                .orElseThrow(() -> ResourceNotFoundException.of("Producto", reqDetalle.productoId()));

            BigDecimal lineTotal = reqDetalle.cantidad().multiply(reqDetalle.precioUnitario()).setScale(2, RM);
            
            subtotal = subtotal.add(lineTotal);
            total = total.add(lineTotal);

            ds.add(CompraDetalle.builder()
                .compra(compra)
                .producto(p)
                .cantidad(reqDetalle.cantidad())
                .precioUnitario(reqDetalle.precioUnitario())
                .subtotal(lineTotal)
                .build());
        }

        // Simplificado: asumimos que los precios de compra ya incluyen o no incluyen impuestos según como lo registre el cajero.
        // Asignaremos el total como sumatoria de subtotales. Si se requiere IGV desglosado se puede calcular.
        compra.setSubtotal(subtotal);
        compra.setTotal(total);

        compra = compras.save(compra);
        detalles.saveAll(ds);

        // Registrar ingreso a inventario y actualizar stock
        for (var d : ds) {
            if (Boolean.TRUE.equals(d.getProducto().getControlaStock())) {
                inventario.registrar(new MovimientoInventarioRequest(
                    d.getProducto().getId(), 
                    null, 
                    d.getCantidad(), 
                    TipoMovimientoInventario.ENTRADA, 
                    "Compra " + compra.getNumeroComprobante(), 
                    "COMPRA", 
                    compra.getId()
                ));
            }
        }

        return obtener(compra.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public CompraResponseDTO obtener(Long id) {
        var c = compras.findById(id).orElseThrow(() -> ResourceNotFoundException.of("Compra", id));
        return toDto(c);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<CompraResponseDTO> listar(Pageable pageable) {
        // En un caso real buscaríamos por un order By
        return compras.findAll(pageable).map(this::toDto);
    }

    @Override
    @Transactional
    public void anular(Long id, String motivo) {
        var c = compras.findById(id).orElseThrow(() -> ResourceNotFoundException.of("Compra", id));
        if (c.getEstado() == Compra.EstadoCompra.ANULADA) {
            throw new BusinessException("La compra ya está anulada");
        }
        if (motivo == null || motivo.isBlank()) {
            throw new BusinessException("Debe indicar motivo de anulación");
        }

        for (var d : detalles.findByCompraId(id)) {
            if (Boolean.TRUE.equals(d.getProducto().getControlaStock())) {
                inventario.registrar(new MovimientoInventarioRequest(
                    d.getProducto().getId(), 
                    null, 
                    d.getCantidad(), 
                    TipoMovimientoInventario.DEVOLUCION_COMPRA, 
                    "Anulación de compra " + c.getNumeroComprobante(), 
                    "ANULACION_COMPRA", 
                    c.getId()
                ));
            }
        }
        
        c.setEstado(Compra.EstadoCompra.ANULADA);
        c.setMotivoAnulacion(motivo);
    }

    private CompraResponseDTO toDto(Compra c) {
        var ds = detalles.findByCompraId(c.getId()).stream()
            .map(x -> new CompraDetalleResponseDTO(
                x.getId(), x.getProducto().getId(), x.getProducto().getNombre(), 
                x.getCantidad(), x.getPrecioUnitario(), x.getSubtotal()
            )).collect(Collectors.toList());

        return new CompraResponseDTO(
            c.getId(), c.getNumeroComprobante(), 
            c.getProveedor().getId(), c.getProveedor().getRazonSocial(),
            c.getUsuario().getId(), c.getUsuario().getNombres(),
            c.getSubtotal(), c.getIgv(), c.getTotal(),
            c.getEstado().name(), c.getFechaCompra(), ds
        );
    }
}
