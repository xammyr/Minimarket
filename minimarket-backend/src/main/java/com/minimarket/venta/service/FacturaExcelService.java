package com.minimarket.venta.service;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

@Service
public class FacturaExcelService {

    // Estructura exacta de los datos que nos enviará Angular
    public record FacturaExportDto(String id, String cliente, double total, String estado) {}

    // Ahora recibimos la lista dinámica por parámetro
    public byte[] generarExcelFacturas(List<FacturaExportDto> listaFacturas) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Historial de Caja");

            // 1. ESTILO PARA LA CABECERA
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // 2. ESTILO PARA LAS CELDAS DE DATOS
            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);

            // 3. ESTILO PARA MONEDA
            CellStyle moneyStyle = workbook.createCellStyle();
            moneyStyle.cloneStyleFrom(dataStyle);
            DataFormat format = workbook.createDataFormat();
            moneyStyle.setDataFormat(format.getFormat("\"S/\" #,##0.00"));

            // --- CREACIÓN DE LA FILA CABECERA ---
            Row headerRow = sheet.createRow(0);
            String[] columnas = {"Comprobante", "Cliente", "Total", "Estado"};
            for (int i = 0; i < columnas.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columnas[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- BUCLE PARA CREAR FILAS BASADAS EN LO QUE ENVIÓ ANGULAR ---
            int rowIndex = 1;
            for (FacturaExportDto factura : listaFacturas) {
                Row row = sheet.createRow(rowIndex++);

                Cell cell0 = row.createCell(0);
                cell0.setCellValue(factura.id()); // <-- Toma el ID enviado
                cell0.setCellStyle(dataStyle);

                Cell cell1 = row.createCell(1);
                cell1.setCellValue(factura.cliente()); // <-- Toma el cliente enviado
                cell1.setCellStyle(dataStyle);

                Cell cell2 = row.createCell(2);
                cell2.setCellValue(factura.total()); // <-- Toma el total enviado
                cell2.setCellStyle(moneyStyle);

                Cell cell3 = row.createCell(3);
                cell3.setCellValue(factura.estado()); // <-- Toma el estado enviado
                cell3.setCellStyle(dataStyle);
            }

            for (int i = 0; i < columnas.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("Error al generar el archivo Excel", e);
        }
    }
}