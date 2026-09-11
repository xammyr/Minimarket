package com.minimarket.producto.service.impl;
import com.minimarket.common.exception.*;
import com.minimarket.producto.dto.*;
import com.minimarket.producto.entity.Categoria;
import com.minimarket.producto.repository.CategoriaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.CacheEvict;

@Service @RequiredArgsConstructor @Transactional(readOnly=true)
public class CategoriaServiceImpl implements com.minimarket.producto.service.CategoriaService {
 private final CategoriaRepository repo;
 @Cacheable("categorias")
 public Page<CategoriaResponseDTO> listar(Pageable p){return repo.findAll(p).map(this::toDto);}
 public CategoriaResponseDTO obtener(Long id){return toDto(find(id));}
 @Transactional @CacheEvict(value="categorias", allEntries=true) public CategoriaResponseDTO crear(CategoriaRequestDTO r){
   if(repo.findByNombreIgnoreCase(r.nombre()).isPresent()) throw new BusinessException("Ya existe la categoría: "+r.nombre());
   Categoria c=Categoria.builder().nombre(r.nombre().trim()).descripcion(r.descripcion()).activo(true).build();
   c.setCategoriaPadre(parent(r.categoriaPadreId(),null)); return toDto(repo.save(c));
 }
 @Transactional @CacheEvict(value="categorias", allEntries=true) public CategoriaResponseDTO actualizar(Long id,CategoriaRequestDTO r){
   Categoria c=find(id); repo.findByNombreIgnoreCase(r.nombre()).filter(x->!x.getId().equals(id))
     .ifPresent(x->{throw new BusinessException("Ya existe la categoría: "+r.nombre());});
   if(id.equals(r.categoriaPadreId())) throw new BusinessException("Una categoría no puede ser su propia categoría padre");
   c.setNombre(r.nombre().trim()); c.setDescripcion(r.descripcion()); c.setCategoriaPadre(parent(r.categoriaPadreId(),id)); return toDto(c);
 }
 @Transactional @CacheEvict(value="categorias", allEntries=true) public void desactivar(Long id){find(id).setActivo(false);}
 private Categoria parent(Long id,Long self){ if(id==null)return null; if(self!=null&&id.equals(self))throw new BusinessException("Categoría padre inválida"); return find(id);}
 private Categoria find(Long id){return repo.findById(id).orElseThrow(()->ResourceNotFoundException.of("Categoria",id));}
 private CategoriaResponseDTO toDto(Categoria c){return new CategoriaResponseDTO(c.getId(),c.getNombre(),c.getDescripcion(),c.getCategoriaPadre()!=null?c.getCategoriaPadre().getId():null,c.getCategoriaPadre()!=null?c.getCategoriaPadre().getNombre():null,c.getActivo(),c.getCreatedAt());}
}
