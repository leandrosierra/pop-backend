package com.lsi.server.security;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {
  @ExceptionHandler(SecurityException.class)
  public ResponseEntity<Void> handleSecurityException(SecurityException exception) {
    HttpStatus status = "Forbidden".equals(exception.getMessage()) ? HttpStatus.FORBIDDEN : HttpStatus.UNAUTHORIZED;
    return ResponseEntity.status(status).build();
  }
}
