package hyung.jin.seo.jae.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.PaymentDTO;
import hyung.jin.seo.jae.model.Invoice;
import hyung.jin.seo.jae.model.InvoiceHistory;
import hyung.jin.seo.jae.repository.InvoiceRepository;
import hyung.jin.seo.jae.service.InvoiceService;
import hyung.jin.seo.jae.service.InvoiceHistoryService;
import hyung.jin.seo.jae.service.MaterialService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.PaymentService;
import hyung.jin.seo.jae.service.AttendanceService;

@Service
public class InvoiceServiceImpl implements InvoiceService {
	
	@Autowired
	private InvoiceRepository invoiceRepository;

	@Autowired
	private InvoiceHistoryService invoiceHistoryService;

	@Autowired
	private MaterialService materialService;

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private PaymentService paymentService;

	@Autowired
	private AttendanceService attendanceService;
   
	@Override
	public long checkCount() {
		long count = invoiceRepository.count();
		return count;
	}

	@Override
	public List<InvoiceDTO> allInvoices() {
		List<Invoice> invoices = new ArrayList<>();
		try{
			invoices = invoiceRepository.findAll();
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		// invoiceRepository.findAll();
		List<InvoiceDTO> dtos = new ArrayList<>();
		for(Invoice invoice: invoices){
			InvoiceDTO dto = new InvoiceDTO(invoice);
			dtos.add(dto);
		}
		return dtos;
	}

	// add Invoice
	@Override
	@Transactional
	public Invoice addInvoice(Invoice invoice) {
		Invoice invo = invoiceRepository.save(invoice);
		//InvoiceDTO dto = new InvoiceDTO(invo);
		return invo;
	}

	// find Invoice by id
	// @Override
	// public InvoiceDTO findInvoiceById(Long id) {
	// 	Invoice invoice = invoiceRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Enrolment not found"));
	// 	InvoiceDTO dto = new InvoiceDTO(invoice);
	// 	return dto;
	// }

	@Override
	@Transactional
	public InvoiceDTO updateInvoice(Invoice invoice, Long id) {
		// search by getId
		Invoice existing = invoiceRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Enrolment not found"));
		// Update info
		// credit
		if(invoice.getCredit()!=existing.getCredit()){
			existing.setCredit(invoice.getCredit());
		}
		// discount
		if(invoice.getDiscount()!=existing.getDiscount()){
			existing.setDiscount(invoice.getDiscount());
		}
		// paidAmount
		if(invoice.getPaidAmount()!=existing.getPaidAmount()){
			existing.setPaidAmount(invoice.getPaidAmount());
		}
		// amount
		if(invoice.getAmount()!=existing.getAmount()){
			existing.setAmount(invoice.getAmount());
		}
		// update the existing record
		Invoice updated = invoiceRepository.save(existing);
		InvoiceDTO dto = new InvoiceDTO(updated);
		return dto;
	}

	@Override
	public InvoiceDTO getInvoiceDTOByStudentId(Long studentId) {
		InvoiceDTO dto = null;
		try{
			dto = invoiceRepository.findInvoiceDTOByStudentId(studentId);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		// return invoiceRepository.findInvoiceDTOByStudentId(studentId);
		return dto;
	}

	@Override
	public Long getInvoiceIdByStudentId(Long studentId) {
		Long id = null;
		try{
			id = invoiceRepository.findLatestInvoiceIdByStudentIdPattern(studentId);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		return id;
		// return invoiceRepository.findLatestInvoiceIdByStudentId(studentId);
	}

	@Override
	public Invoice getInvoice(Long id) {
		Invoice invoice = null;
		try {
			invoice = invoiceRepository.findById(id).orElse(null);
		} catch (Exception e) {
			System.out.println("Error retrieving invoice: " + e.getMessage());
		}
		return invoice;
	}

	@Override
	public Invoice getLastActiveInvoiceByStudentId(Long studentId) {
		Invoice invoice = null;
		try{
			invoice = invoiceRepository.findLatestInvoiceByStudentIdPattern(studentId);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		//return invoiceRepository.findLastInvoiceByStudentId(studentId);
		return invoice;
	}

	@Override
	public double getInvoiceOwingAmount(Long id) {
		double amount = 0;
		try{
			amount = invoiceRepository.getInvoiceOwingAmount(id);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		return amount;
	}

	@Override
	public double getInvoiceTotalAmount(Long id) {
		double amount = 0;
		try{
			amount = invoiceRepository.getInvoiceTotalAmount(id);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		return amount;
	}

	// @Override
	// public Invoice getLastInvoiceByStudentId(Long studentId) {
	// 	return invoiceRepository.findLastInvoiceByStudentId(studentId);
	// }

	@Override
	public boolean isFullPaidInvoice(Long id) {
		double balance =0;
		try{
			balance = invoiceRepository.isPaidInvoice(id);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		return (balance <= 0) ? true : false;
	}

	@Override
	public double getPaidAmount(Long id) {
		double balance =0;
		try{
			balance = invoiceRepository.getInvoicePaidAmount(id);
		}catch(Exception e){
			System.out.println("No invoice found");
		}
		return balance;
	}

	@Override
	@Transactional
	public Invoice addInvoiceMigration(Invoice invoice) {
		try {
			// Use native query to insert the invoice with the specified ID
			invoiceRepository.insertInvoiceWithId(
				invoice.getId(),
				invoice.getCredit(),
				invoice.getDiscount(),
				invoice.getAmount(),
				invoice.getPaidAmount(),
				invoice.getRegisterDate(),
				invoice.getPaymentDate(),
				invoice.getInfo()
			);
			
			// Fetch and return the newly inserted invoice
			return invoiceRepository.findById(invoice.getId()).orElse(null);
		} catch (Exception e) {
			throw new RuntimeException("Failed to insert invoice during migration: " + e.getMessage(), e);
		}
	}

	@Override
	@Transactional
	public void deleteInvoice(Long id) {
		try {
			// Get the invoice to verify it exists
			Invoice invoice = invoiceRepository.findById(id)
				.orElseThrow(() -> new EntityNotFoundException("Invoice not found"));

			// Get ALL enrolments associated with this invoice (not just from invoice history)
			List<EnrolmentDTO> allEnrolments = enrolmentService.findAllEnrolmentByInvoiceId(id);
			
			// First delete all attendance records associated with these enrolments
			for (EnrolmentDTO enrolment : allEnrolments) {
				Long enrolmentId = Long.parseLong(enrolment.getId());
				attendanceService.deleteAttendanceByEnrolment(enrolmentId);
			}

			// Delete payments associated with this invoice
			List<PaymentDTO> payments = paymentService.getPaymentByInvoice(id);
			for (PaymentDTO payment : payments) {
				paymentService.deletePayment(Long.parseLong(payment.getId()));
			}

			// Get all invoice histories first (we'll need them to delete associated materials)
			List<InvoiceHistory> histories = invoiceHistoryService.getAllInvoiceHistoriesByInvoice(id);
			
			// Delete materials associated with each invoice history
			for (InvoiceHistory history : histories) {
				List<MaterialDTO> historyMaterials = materialService.findMaterialByInvoiceHistory(history.getId());
				for (MaterialDTO material : historyMaterials) {
					materialService.deleteMaterial(Long.parseLong(material.getId()));
				}
			}

			// Delete materials associated with this invoice (that might not be associated with history)
			List<MaterialDTO> materials = materialService.findMaterialByInvoice(id);
			for (MaterialDTO material : materials) {
				materialService.deleteMaterial(Long.parseLong(material.getId()));
			}

			// Now delete all enrolments
			for (EnrolmentDTO enrolment : allEnrolments) {
				enrolmentService.deleteEnrolment(Long.parseLong(enrolment.getId()));
			}

			// Now delete all invoice histories (materials have been deleted)
			for (InvoiceHistory history : histories) {
				invoiceHistoryService.deleteInvoiceHistory(history.getId());
			}

			// Finally delete the invoice itself
			invoiceRepository.deleteById(id);
		} catch (Exception e) {
			throw new RuntimeException("Failed to delete invoice and related records: " + e.getMessage(), e);
		}
	}

	// for migration only
	@Override
	public Invoice getInvoiceFromInfo(String id) {
		Invoice invoice = null;
		try {
			invoice = invoiceRepository.findByInfo(id);
		} catch (Exception e) {
			System.out.println("Error retrieving invoice: " + e.getMessage());
		}
		return invoice;
	}
}
