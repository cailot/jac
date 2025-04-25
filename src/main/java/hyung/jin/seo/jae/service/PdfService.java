package hyung.jin.seo.jae.service;

import java.util.List;
import java.util.Map;

public interface PdfService {

	// generate invoice pdf file
	byte[] generateInvoicePdf(Map<String, Object> data);

	// generate reciept pdf file
	byte[] generateReceiptPdf(Map<String, Object> data);

	// generate empty test result pdf file
	byte[] generateEmptyTestResult(Long studentId);

	// generate test result pdf file
	byte[] generateTestResultPdf(Map<String, Object> data);

	// Merge multiple PDF files into a single PDF file
	byte[] mergePdfFiles(List<byte[]> pdfList);

}
