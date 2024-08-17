package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.InvoiceHistoryDTO;
import hyung.jin.seo.jae.model.InvoiceHistory;

public interface InvoiceHistoryService {

	// list all InvoiceHistories
	List<InvoiceHistoryDTO> allInvoiceHistory();
	
	// list InvoiceHistories based on invoice Id
	List<InvoiceHistoryDTO> findInvoiceHistoryDTOByInvoice(Long id);

	// get InvoiceHistory by Id
	InvoiceHistory getInvoiceHistory(Long id);

	// get last InvoiceHistory by Invoice
	InvoiceHistory getLastInvoiceHistory(Long invoiceId);

	// add InvoiceHistory
	InvoiceHistory addInvoiceHistory(InvoiceHistory history);

	// update InvoiceHistory
	InvoiceHistory updateInvoiceHistory(InvoiceHistory history, Long id);

	// delete InvoiceHistory by Id
	void deleteInvoiceHistory(Long id);

}
