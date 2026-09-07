package com.minimarket.common.exception;

/**
 * Se lanza cuando se viola una regla de negocio (ej: stock insuficiente,
 * intentar cerrar una caja ya cerrada, pagos que no cuadran con el total).
 * Mapea a HTTP 409/422 segun corresponda.
 */
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
