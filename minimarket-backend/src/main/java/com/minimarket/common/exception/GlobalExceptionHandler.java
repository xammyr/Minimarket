package com.minimarket.common.exception;
import com.minimarket.common.ApiResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import java.time.OffsetDateTime;
import java.util.*;

@RestControllerAdvice
public class GlobalExceptionHandler {
 @ExceptionHandler(ResourceNotFoundException.class) public ResponseEntity<ApiResponse<Void>> notFound(ResourceNotFoundException e){return body(HttpStatus.NOT_FOUND,e.getMessage());}
 @ExceptionHandler(BusinessException.class) public ResponseEntity<ApiResponse<Void>> business(BusinessException e){return body(HttpStatus.CONFLICT,e.getMessage());}
 @ExceptionHandler(BadCredentialsException.class) public ResponseEntity<ApiResponse<Void>> credentials(){return body(HttpStatus.UNAUTHORIZED,"Credenciales inválidas");}
 @ExceptionHandler(AccessDeniedException.class) public ResponseEntity<ApiResponse<Void>> denied(){return body(HttpStatus.FORBIDDEN,"No tienes permisos para realizar esta operación");}
 @ExceptionHandler(MethodArgumentNotValidException.class) public ResponseEntity<ApiResponse<Map<String,String>>> validation(MethodArgumentNotValidException e){Map<String,String> m=new LinkedHashMap<>();e.getBindingResult().getFieldErrors().forEach(x->m.putIfAbsent(x.getField(),x.getDefaultMessage()));return ResponseEntity.badRequest().body(new ApiResponse<>(false,m,"Error de validación",OffsetDateTime.now()));}
 @ExceptionHandler(DataIntegrityViolationException.class) public ResponseEntity<ApiResponse<Void>> integrity(){return body(HttpStatus.CONFLICT,"La operación viola una restricción de datos");}
 @ExceptionHandler(Exception.class)
 public ResponseEntity<ApiResponse<Void>> generic(Exception e) {
  e.printStackTrace(); // <-- Esto obligará a Java a imprimir el error real en tu consola
  return body(HttpStatus.INTERNAL_SERVER_ERROR, "Error interno del servidor");
 }
 private ResponseEntity<ApiResponse<Void>> body(HttpStatus s,String m){return ResponseEntity.status(s).body(ApiResponse.error(m));}
}
