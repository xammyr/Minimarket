package com.minimarket.venta.controller;

import com.minimarket.venta.service.FacturaExcelService;
import com.minimarket.venta.service.FacturaExcelService.FacturaExportDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/facturas")
@CrossOrigin(origins = "http://localhost:4200")
public class FacturaController {

    @Autowired
    private FacturaExcelService excelService;

    // Cambiamos a POST y recibimos la lista de facturas
    @PostMapping("/exportar-excel")
    public ResponseEntity<byte[]> descargarExcel(@RequestBody List<FacturaExportDto> facturas) {

        byte[] bytes = excelService.generarExcelFacturas(facturas);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=Reporte_Caja.xlsx");

        return ResponseEntity
                .ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(bytes);
    }
}