package hyung.jin.seo.jae.service;

import java.util.Map;

public interface PdfService {

	// generate invoice pdf file
	void generateInvoicePdf(String name, Map<String, Object> data);

	byte[] generateInvoicePdf(Map<String, Object> data);

}
