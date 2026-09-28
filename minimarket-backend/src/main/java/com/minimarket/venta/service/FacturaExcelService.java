package com.minimarket.venta.service;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

@Service
public class FacturaExcelService {

    public record FacturaExportDto(String id, String cliente, double total, String estado, String detalleProductos, String metodoPago) {}

    public byte[] generarExcelFacturas(List<FacturaExportDto> listaFacturas) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Historial de Caja");

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

            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            dataStyle.setWrapText(true);

            CellStyle moneyStyle = workbook.createCellStyle();
            moneyStyle.cloneStyleFrom(dataStyle);
            DataFormat format = workbook.createDataFormat();
            moneyStyle.setDataFormat(format.getFormat("\"S/\" #,##0.00"));

            Row headerRow = sheet.createRow(0);
            String[] columnas = {"Comprobante", "Cliente", "Total", "Estado", "Método de Pago", "Detalle de Productos"};
            for (int i = 0; i < columnas.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columnas[i]);
                cell.setCellStyle(headerStyle);
            }

            int rowIndex = 1;
            for (FacturaExportDto factura : listaFacturas) {
                Row row = sheet.createRow(rowIndex++);

                Cell cell0 = row.createCell(0);
                cell0.setCellValue(factura.id());
                cell0.setCellStyle(dataStyle);

                Cell cell1 = row.createCell(1);
                cell1.setCellValue(factura.cliente());
                cell1.setCellStyle(dataStyle);

                Cell cell2 = row.createCell(2);
                cell2.setCellValue(factura.total());
                cell2.setCellStyle(moneyStyle);

                Cell cell3 = row.createCell(3);
                cell3.setCellValue(factura.estado());
                cell3.setCellStyle(dataStyle);

                Cell cell4 = row.createCell(4);
                cell4.setCellValue(factura.metodoPago() != null ? factura.metodoPago() : "EFECTIVO");
                cell4.setCellStyle(dataStyle);

                Cell cell5 = row.createCell(5);
                cell5.setCellValue(factura.detalleProductos());
                cell5.setCellStyle(dataStyle);
            }

            for (int i = 0; i < columnas.length; i++) {
                sheet.autoSizeColumn(i);
            }
            sheet.setColumnWidth(5, 15000); // Detalles

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("Error al generar el archivo Excel", e);
        }
    }
}