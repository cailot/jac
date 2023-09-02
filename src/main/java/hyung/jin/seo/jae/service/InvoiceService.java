package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.model.Invoice;

public interface InvoiceService {
	
	// list all Invoice
	List<InvoiceDTO> allInvoices();
	
	// get total number of cycle
 	long checkCount();

	// get InvoiceDTO by student Id
	InvoiceDTO getInvoiceDTOByStudentId(Long studentId);

	// get Invoice by student Id
	Invoice getInvoiceByStudentId(Long studentId);

	// get Invoice Id by student Id
	Long getInvoiceIdByStudentId(Long studentId);

	// add Invoice
	Invoice addInvoice(Invoice invoice);

	// update Invoice
	InvoiceDTO updateInvoice(Invoice invoice, Long id);

	// find Invoice by Id
	InvoiceDTO findInvoiceById(Long id);

	// get Invoice by Id
    Invoice getInvoice(Long id);



}
