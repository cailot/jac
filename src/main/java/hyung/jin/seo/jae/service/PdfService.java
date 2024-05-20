package hyung.jin.seo.jae.service;

import java.util.Map;

public interface PdfService {

	// generate pdf file
	void generatePdf(String name, Map<String, Object> data);

	byte[] generatePdf(Map<String, Object> data);

}
