package com.minimarket.common.exception;

/** Se lanza cuando se busca una entidad por id y no existe. Mapea a HTTP 404. */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }

    public static ResourceNotFoundException of(String entidad, Object id) {
        return new ResourceNotFoundException(entidad + " no encontrado con id: " + id);
    }
}
