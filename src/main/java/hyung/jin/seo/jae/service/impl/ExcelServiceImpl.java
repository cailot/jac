package hyung.jin.seo.jae.service.impl;

import java.io.IOException;
import java.util.List;

import org.apache.commons.io.output.UnsynchronizedByteArrayOutputStream;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.apache.poi.ss.usermodel.Row;

import hyung.jin.seo.jae.dto.StudentTestSummaryDTO;
import hyung.jin.seo.jae.service.ExcelService;
import hyung.jin.seo.jae.utils.JaeUtils;

@Service
public class ExcelServiceImpl implements ExcelService {

    @Override
    public byte[] generateTestSummaryExcel(List<StudentTestSummaryDTO> summaries) {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
			XSSFSheet sheet = workbook.createSheet("Test Results");

			// Create header row
			Row headerRow = sheet.createRow(0);
			String[] columns = {"Name", "Student No.", "Course", "Branch", "ENGLISH", "MATH", "GA/Science"};
			for (int i = 0; i < columns.length; i++) {
				Cell cell = headerRow.createCell(i);
				cell.setCellValue(columns[i]);
			}

			// Create data rows
			int rowNum = 1;
			for (StudentTestSummaryDTO summary : summaries) {
				Row row = sheet.createRow(rowNum++);
				row.createCell(0).setCellValue(summary.getName());
				row.createCell(1).setCellValue(summary.getId());
				row.createCell(2).setCellValue(summary.getCourse()); // Assuming this is constant for now
				row.createCell(3).setCellValue(JaeUtils.getBranchName(summary.getBranch()));
				
				// Add test scores if available
				List<Double> scores = summary.getScores();
				for (int i = 0; i < scores.size(); i++) {
					row.createCell(i + 4).setCellValue(scores.get(i));
				}
			}

			// Auto-size columns
			for (int i = 0; i < columns.length; i++) {
				sheet.autoSizeColumn(i);
			}

			// Convert workbook to byte array
			UnsynchronizedByteArrayOutputStream outputStream = new UnsynchronizedByteArrayOutputStream();
			workbook.write(outputStream);
			return outputStream.toByteArray();
		} catch (IOException e) {
			throw new RuntimeException("Failed to generate Excel report", e);
		}
    }
}