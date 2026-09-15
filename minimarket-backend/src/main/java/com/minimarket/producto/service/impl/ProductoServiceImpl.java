package com.minimarket.producto.service.impl;

import com.minimarket.common.exception.BusinessException;
import com.minimarket.common.exception.ResourceNotFoundException;
import com.minimarket.producto.dto.ProductoRequestDTO;
import com.minimarket.producto.dto.ProductoResponseDTO;
import com.minimarket.producto.entity.Categoria;
import com.minimarket.producto.entity.Marca;
import com.minimarket.producto.entity.Producto;
import com.minimarket.producto.entity.UnidadMedida;
import com.minimarket.producto.repository.CategoriaRepository;
import com.minimarket.producto.repository.MarcaRepository;
import com.minimarket.producto.repository.ProductoRepository;
import com.minimarket.producto.repository.UnidadMedidaRepository;
import com.minimarket.producto.service.ProductoService;
import com.minimarket.proveedor.entity.Proveedor;
import com.minimarket.proveedor.repository.ProveedorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductoServiceImpl implements ProductoService {

    private final ProductoRepository productoRepository;
    private final CategoriaRepository categoriaRepository;
    private final MarcaRepository marcaRepository;
    private final UnidadMedidaRepository unidadMedidaRepository;
    private final ProveedorRepository proveedorRepository;

    @Override
    public Page<ProductoResponseDTO> listar(String busqueda, Pageable pageable) {
        Page<Producto> pagina = StringUtils.hasText(busqueda)
                ? productoRepository.findByNombreContainingIgnoreCaseAndActivoTrue(busqueda, pageable)
                : productoRepository.findByActivoTrue(pageable);
        return pagina.map(this::toResponse);
    }

    @Override
    public ProductoResponseDTO obtenerPorId(Long id) {
        return toResponse(buscarOFallar(id));
    }

    @Override
    public ProductoResponseDTO obtenerPorCodigoBarras(String codigoBarras) {
        return toResponse(productoRepository.findByCodigoBarrasAndActivoTrue(codigoBarras.trim())
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado para código de barras: " + codigoBarras)));
    }

    @Override
    @Transactional
    public ProductoResponseDTO crear(ProductoRequestDTO request) {
        if (productoRepository.existsByCodigoInternoIgnoreCase(request.codigoInterno())) {
            throw new BusinessException("Ya existe un producto con el codigo interno " + request.codigoInterno());
        }

        if (StringUtils.hasText(request.codigoBarras()) && productoRepository.existsByCodigoBarrasIgnoreCase(request.codigoBarras())) {
            throw new BusinessException("Ya existe un producto con el código de barras " + request.codigoBarras());
        }

        Categoria categoria = categoriaRepository.findById(request.categoriaId())
                .orElseThrow(() -> ResourceNotFoundException.of("Categoria", request.categoriaId()));
        UnidadMedida unidadMedida = unidadMedidaRepository.findById(request.unidadMedidaId())
                .orElseThrow(() -> ResourceNotFoundException.of("UnidadMedida", request.unidadMedidaId()));
        Marca marca = request.marcaId() != null
                ? marcaRepository.findById(request.marcaId())
                        .orElseThrow(() -> ResourceNotFoundException.of("Marca", request.marcaId()))
                : null;
        Proveedor proveedor = request.proveedorId() != null
                ? proveedorRepository.findById(request.proveedorId())
                        .orElseThrow(() -> ResourceNotFoundException.of("Proveedor", request.proveedorId()))
                : null;

        Producto producto = Producto.builder()
                .codigoInterno(request.codigoInterno())
                .codigoBarras(request.codigoBarras())
                .nombre(request.nombre())
                .descripcion(request.descripcion())
                .categoria(categoria)
                .marca(marca)
                .unidadMedida(unidadMedida)
                .proveedor(proveedor)
                .precioCompra(request.precioCompra())
                .precioVenta(request.precioVenta())
                .afectoIgv(request.afectoIgv())
                .stockMinimo(request.stockMinimo())
                .controlaStock(request.controlaStock())
                .build();

        return toResponse(productoRepository.save(producto));
    }

    @Override
    @Transactional
    public ProductoResponseDTO actualizar(Long id, ProductoRequestDTO request) {
        Producto producto = buscarOFallar(id);

        Categoria categoria = categoriaRepository.findById(request.categoriaId())
                .orElseThrow(() -> ResourceNotFoundException.of("Categoria", request.categoriaId()));
        UnidadMedida unidadMedida = unidadMedidaRepository.findById(request.unidadMedidaId())
                .orElseThrow(() -> ResourceNotFoundException.of("UnidadMedida", request.unidadMedidaId()));
        if (productoRepository.existsByCodigoInternoIgnoreCaseAndIdNot(request.codigoInterno(), id)) {
            throw new BusinessException("Ya existe un producto con el código interno " + request.codigoInterno());
        }
        if (StringUtils.hasText(request.codigoBarras()) &&
                productoRepository.existsByCodigoBarrasIgnoreCaseAndIdNot(request.codigoBarras(), id)) {
            throw new BusinessException("Ya existe un producto con el código de barras " + request.codigoBarras());
        }
        Marca marca = request.marcaId() != null ? marcaRepository.findById(request.marcaId())
                .orElseThrow(() -> ResourceNotFoundException.of("Marca", request.marcaId())) : null;
        Proveedor proveedor = request.proveedorId() != null ? proveedorRepository.findById(request.proveedorId())
                .orElseThrow(() -> ResourceNotFoundException.of("Proveedor", request.proveedorId())) : null;

        producto.setCodigoInterno(request.codigoInterno());
        producto.setCodigoBarras(request.codigoBarras());
        producto.setNombre(request.nombre());
        producto.setDescripcion(request.descripcion());
        producto.setCategoria(categoria);
        producto.setMarca(marca);
        producto.setUnidadMedida(unidadMedida);
        producto.setProveedor(proveedor);
        producto.setPrecioCompra(request.precioCompra());
        producto.setPrecioVenta(request.precioVenta());
        producto.setAfectoIgv(request.afectoIgv());
        producto.setStockMinimo(request.stockMinimo());
        producto.setControlaStock(request.controlaStock());
        // Nota: stockActual NO se toca aqui a proposito - solo se modifica via
        // movimientos de inventario (modulo inventario/, Fase 6), nunca por un PUT directo.

        return toResponse(producto);
    }

    @Override
    @Transactional
    public void desactivar(Long id) {
        Producto producto = buscarOFallar(id);
        producto.setActivo(false);
    }

    @Override
    public String generarSiguienteCodigo() {
        Long maxId = productoRepository.findMaxId();
        long nextId = (maxId != null ? maxId : 0) + 1;
        return String.format("PRD-%06d", nextId);
    }

    private Producto buscarOFallar(Long id) {
        return productoRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.of("Producto", id));
    }

    private ProductoResponseDTO toResponse(Producto p) {
        return new ProductoResponseDTO(
                p.getId(),
                p.getCodigoInterno(),
                p.getCodigoBarras(),
                p.getNombre(),
                p.getDescripcion(),
                p.getCategoria().getId(),
                p.getCategoria().getNombre(),
                p.getMarca() != null ? p.getMarca().getId() : null,
                p.getMarca() != null ? p.getMarca().getNombre() : null,
                p.getUnidadMedida().getId(),
                p.getUnidadMedida().getAbreviatura(),
                p.getPrecioCompra(),
                p.getPrecioVenta(),
                p.getAfectoIgv(),
                p.getStockActual(),
                p.getStockMinimo(),
                p.getControlaStock(),
                p.getActivo(),
                p.getCreatedAt()
        );
    }
}
