package hyung.jin.seo.jae.controller;

import java.io.IOException;
import java.text.ParseException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.dto.MoneyDTO;
import hyung.jin.seo.jae.dto.PaymentDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Attendance;
import hyung.jin.seo.jae.model.Book;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.model.Invoice;
import hyung.jin.seo.jae.model.InvoiceHistory;
import hyung.jin.seo.jae.model.Material;
import hyung.jin.seo.jae.model.Payment;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.AttendanceService;
import hyung.jin.seo.jae.service.BookService;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.EmailService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.InvoiceHistoryService;
import hyung.jin.seo.jae.service.InvoiceService;
import hyung.jin.seo.jae.service.MaterialService;
import hyung.jin.seo.jae.service.PaymentService;
import hyung.jin.seo.jae.service.PdfService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("invoice")
public class InvoiceController {

	@Autowired
	private InvoiceService invoiceService;

	@Autowired
	private InvoiceHistoryService invoiceHistoryService;

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private MaterialService materialService;

	@Autowired
	private PaymentService paymentService;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private StudentService studentService;

	@Autowired
	private CodeService	codeService;

	@Autowired
	private PdfService pdfService;
	
	@Autowired
	private EmailService emailService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private AttendanceService attendanceService;

	@Autowired
	private BookService bookService;

	// count records number in database
	@GetMapping("/count")
	@ResponseBody
	long count() {
		long count = invoiceService.checkCount();
		return count;
	}

	// get invoice amount
	@GetMapping("/amount/{id}")
	@ResponseBody
	public double getInvoiceAmount(@PathVariable("id") Long id) {	
		double amount = invoiceService.getInvoiceOwingAmount(id);
		return (amount<0) ? 0 : amount;
	}

	// bring all invoices in database
	@GetMapping("/list")
	@ResponseBody
	public List<InvoiceDTO> listInvoices() {
 		List<InvoiceDTO> dtos = invoiceService.allInvoices();
		return dtos;
	}
		
	// register new invoice
	@GetMapping("/getInfo/{studentId}")
	@ResponseBody
	public String retrieveInvoiceInfo(@PathVariable("studentId") Long studentId) {	
		// 1. get latest invoice by student id
		Invoice invoice = invoiceService.getLastActiveInvoiceByStudentId(studentId);
		// 2. get invoice info
		String info = StringUtils.defaultString(invoice.getInfo());    
		// 3. return info
		return info;
	}

	// payment history
	@GetMapping("/history")
	public String getPayments(@RequestParam("studentKeyword") String studentId, HttpSession session) {
		// 1. flush session from previous payment
		JaeUtils.clearSession(session);
		
		// 2. get student and save it into session
		long stdId = Long.parseLong(studentId);
		Student student = studentService.getStudent(stdId);
		session.setAttribute(JaeConstants.STUDENT_INFO, student);

		// 3. get invoice id by student id
		List<Long> invoiceIds = enrolmentService.findInvoiceIdByStudent(stdId);
		if(invoiceIds.size() == 0) return "studentInvoicePage";

		// 4. get InvoiceDTOs and save it into session
		List<InvoiceDTO> invoiceDTOs = new ArrayList<InvoiceDTO>();
		for(Long invoiceId : invoiceIds){
			Invoice invoice = invoiceService.getInvoice(invoiceId);
			invoiceDTOs.add(new InvoiceDTO(invoice));
		}
		session.setAttribute(JaeConstants.PAYMENT_INVOICES, invoiceDTOs);

		// 5. get payment list and save it into session
		List<PaymentDTO> paymentDTOs = new ArrayList<PaymentDTO>();
		for(Long invoiceId : invoiceIds){
			List<PaymentDTO> payments = paymentService.getPaymentByInvoice(invoiceId);
			
			// 1. associate payment with enrolment
			// 2. update totalPaid amount so far
			for(PaymentDTO payment : payments){
				// get Enrolment list by invoice history id
				long invoiceHistoryId = Long.parseLong(StringUtils.defaultIfBlank(payment.getInvoiceHistoryId(), "0"));	
				List<EnrolmentDTO> enrolments = enrolmentService.findEnrolmentByInvoiceHistory(invoiceHistoryId);
				for(EnrolmentDTO enrol : enrolments){
					// 9-1. set period of enrolment to extra field
					String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
					String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
					enrol.setExtra(start + " ~ " + end);
				}
				payment.setEnrols(enrolments);
				double totalPaid = paymentService.getTotalPaidById(Long.parseLong(payment.getId()), invoiceId);
				payment.setUpto(totalPaid);
			}
			paymentDTOs.addAll(payments);
		}
		session.setAttribute(JaeConstants.PAYMENT_PAYMENTS, paymentDTOs);

		// 6. return redirect page
		return "studentInvoicePage";
	}

	// get payment history
	@GetMapping("/receiptInfo")
	public String receiptHistory(@RequestParam(value = "invoiceId", defaultValue = "0") Long invoiceId,
    							@RequestParam(value = "invoiceHistoryId", defaultValue = "0") Long invoiceHistoryId, 
								@RequestParam(value = "paymentId", defaultValue = "0") Long paymentId, @RequestParam("branchCode") String branchCode, HttpSession session) {
		// 1. flush session from previous payment
		JaeUtils.clearSession(session);

		// 2. Create MoneyDTO for header
		MoneyDTO header = new MoneyDTO();
		List<String> headerGrade = new ArrayList<String>();
		String headerDueDate = JaeUtils.getToday();

		//3. bring to EnrolmentDTO - get list by invoice history id
		// List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(Long.parseLong(invoiceId));
		List<EnrolmentDTO> enrolments = new ArrayList<EnrolmentDTO>();
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoiceHistory(invoiceHistoryId);

		for(EnrolmentDTO enrol : enrols){
			// if free online course, skip it
			boolean isFreeOnline = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			if(isFreeOnline) continue;
			
			// 3-1. set period of enrolment to extra field
			String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
			String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
			enrol.setExtra(start + " ~ " + end);
			// 3-2. set headerGrade
			if(!headerGrade.contains(enrol.getGrade())){
				headerGrade.add(enrol.getGrade().toUpperCase());
			}
			// 3-3. set earliest start date to headerDueDate
			try {
				if(JaeUtils.isEarlier(start, headerDueDate)){
					headerDueDate = start;
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
			// 3-4. add to dtos
			enrolments.add(enrol);
		}	
		// 3-5. set EnrolmentDTO objects into session for payment receipt
		session.setAttribute(JaeConstants.PAYMENT_ENROLMENTS, enrolments);

		// payment note based on branch code
		BranchDTO branchInfo = codeService.getBranch(branchCode);
		String note = branchInfo.getInfo().replace("\n", "<br/>"); // note
		branchInfo.setInfo(note);
		session.setAttribute(JaeConstants.INVOICE_BRANCH, branchInfo);

		
		// 4. Header Info - Due Date & Grade
		header.setRegisterDate(headerDueDate);
		header.setInfo(String.join(", ", headerGrade));
		session.setAttribute(JaeConstants.PAYMENT_HEADER, header);
		
		// 5. bring to MaterialDTO - bring materials by invoice id from Book_Invoice table, list will be brought by invoice history id
		List<MaterialDTO> materials = materialService.findMaterialByInvoiceHistory(invoiceHistoryId);
		// 5-1. set MaterialDTO objects into session for payment receipt
		session.setAttribute(JaeConstants.PAYMENT_MATERIALS, materials);


		// 17. get payment
		List<PaymentDTO> payments = new ArrayList<>();
		List<PaymentDTO> pays = paymentService.getPaymentByInvoice(invoiceId);
		// update upto & total
		for(PaymentDTO pay : pays){
			Long payId = Long.parseLong(pay.getId());
			if(payId <= paymentId){ // only show payments before or equal to payment id
				payments.add(pay);
			}
		}
	
		session.setAttribute(JaeConstants.PAYMENT_PAYMENTS, payments);

		// 7. display receipt page
		return "receiptPage";
	}

	// make payment and return updated invoice
	@PostMapping("/payment/{studentId}/{branchCode}")
	@ResponseBody
	public List makePayment(@PathVariable("studentId") Long studentId, @PathVariable("branchCode") String branchCode, @RequestBody PaymentDTO formData, HttpSession session) {
		// 1. flush session from previous payment
		JaeUtils.clearSession(session);

		// 2. create basket
		List dtos = new ArrayList();
		// List<EnrolmentDTO> enrolments = new ArrayList<EnrolmentDTO>();
		
		// 3. get lastest invoice id by student id
		Long invoId = invoiceService.getInvoiceIdByStudentId(studentId);
		double paidAmount = formData.getAmount();
		
		// 4. get Invoice
		Invoice invoice = invoiceService.getInvoice(invoId);
		// 5. get invoice history
		InvoiceHistory history = invoiceHistoryService.getLastInvoiceHistory(invoId);

		// 6. check total amount in invoice
		double totalAmount = invoice.getAmount();
		
		// 7. create payment
		Payment payment = formData.convertToPayment();
		payment.setTotal(totalAmount);
		String paymentRegisterDate = formData.getRegisterDate();
		if(StringUtils.isBlank(paymentRegisterDate)){
			paymentRegisterDate = JaeUtils.getToday();
		}
		// convert to LocalDate
		payment.setRegisterDate(LocalDate.parse(paymentRegisterDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
		Payment paid = paymentService.addPayment(payment);	
		
		// 8. update Invoice
		invoice.setPaidAmount(paidAmount + invoice.getPaidAmount());
		invoice.addPayment(paid);
		invoice.setPaymentDate(LocalDate.now());
		// 9. update InvoiceHistory
		history.setPaidAmount(invoice.getPaidAmount());
		history.setAmount(invoice.getAmount());
		history.addPayment(payment);
		invoiceService.updateInvoice(invoice, invoId);
		// update InvoiceHistory is done automatically

		// 10. payment note based on branch code
		BranchDTO branchInfo = codeService.getBranch(branchCode);
		String note = branchInfo.getInfo().replace("\n", "<br/>"); // note
		branchInfo.setInfo(note);
		session.setAttribute(JaeConstants.INVOICE_BRANCH, branchInfo);

		// 11. Create MoneyDTO for header
		MoneyDTO header = new MoneyDTO();
		List<String> headerGrade = new ArrayList<String>();
		String headerDueDate = JaeUtils.getToday();
		
		// 12. bring to EnrolmentDTO
		List<EnrolmentDTO> enrolments = new ArrayList<>();
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(invoId);
		for(EnrolmentDTO enrol : enrols){
			// if free online course, skip it
			boolean isFreeOnline = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			if(isFreeOnline) continue;
		
			enrol.setInvoiceId(String.valueOf(invoId));				
			// 12-1. set period of enrolment to extra field
			String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
			String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
			enrol.setExtra(start + " ~ " + end);

			// 12-2. set headerGrade
			if(!headerGrade.contains(enrol.getGrade())){
				headerGrade.add(enrol.getGrade().toUpperCase());
			}
			// 12-3. set earliest start date to headerDueDate
			try {
				if(JaeUtils.isEarlier(start, headerDueDate)){
					headerDueDate = start;
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
			// 12-4. add to dtos
			enrolments.add(enrol);
		}

		// 13. set EnrolmentDTO objects into session for payment receipt
		session.setAttribute(JaeConstants.PAYMENT_ENROLMENTS, enrolments);
			
		// 14. get book - bring materials by invoice id from Book_Invoice table
		List<MaterialDTO> materials = materialService.findMaterialByInvoice(invoId);
		
		// 15. set MaterialDTO payment date
		for(MaterialDTO material : materials){
			material.setPaymentDate(JaeUtils.getToday());
			// material update
			Material mat = materialService.getMaterial(Long.parseLong(material.getId()));
			mat.setPaymentDate(LocalDate.now());
			materialService.updateMaterial(mat, Long.parseLong(material.getId()));
		}
		
		// 16. set MaterialDTO objects into session for payment receipt
		session.setAttribute(JaeConstants.PAYMENT_MATERIALS, materials);
			
		// 17. get payment
		List<PaymentDTO> payments = paymentService.getPaymentByInvoice(invoId);
		// update upto & total
		for(PaymentDTO pay : payments){
			pay.setTotal(totalAmount); // override total as total amount in invoice
			double totalPaid = paymentService.getTotalPaidById(Long.parseLong(pay.getId()), invoId);
			pay.setUpto(totalPaid);
		}

		// 18. set PaymentDTO objects into session for payment receipt
		session.setAttribute(JaeConstants.PAYMENT_PAYMENTS, payments);

		// 19. Header Info - Due Date & Grade
		header.setRegisterDate(headerDueDate);
		header.setInfo(String.join(", ", headerGrade));
		session.setAttribute(JaeConstants.PAYMENT_HEADER, header);
			
		// 20. return
		dtos.addAll(enrols);
		dtos.addAll(materials);
		dtos.addAll(payments);
		return dtos;
	}

	// register new invoice
	@PostMapping("/issue/{studentId}/{branchCode}")
	@ResponseBody
	public ResponseEntity<String> issueInvoice(@PathVariable("studentId") Long studentId, @PathVariable("branchCode") String branchCode, @RequestBody(required = false) String info, HttpSession session) {
		/*
		// 1. flush session from previous payment
		JaeUtils.clearSession(session);

		// 2. get latest invoice by student id
		Invoice invoice = invoiceService.getLastActiveInvoiceByStudentId(studentId);	
		invoice.setInfo(info);
		invoiceService.updateInvoice(invoice, invoice.getId());
		String lfStr = StringUtils.defaultString(invoice.getInfo()).replace("\n", "<br/>"); 
		InvoiceDTO newInvo = new InvoiceDTO(invoice);
		newInvo.setInfo(lfStr);
		session.setAttribute(JaeConstants.INVOICE_INFO, newInvo);

		// 3. payment note based on branch code
		BranchDTO branchInfo = codeService.getBranch(branchCode);
		String note = branchInfo.getInfo().replace("\n", "<br/>"); // note
		branchInfo.setInfo(note);
		session.setAttribute(JaeConstants.INVOICE_BRANCH, branchInfo);

		// 4. create MoneyDTO for header
		MoneyDTO header = new MoneyDTO();
		List<String> headerGrade = new ArrayList<String>();
		String headerDueDate = JaeUtils.getToday();

		// 5. bring EnrolmentDTO
		List<EnrolmentDTO> enrolments = new ArrayList<>();
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(invoice.getId());

		for(EnrolmentDTO enrol : enrols){
			// 5-1. if free online course, no need to add to invoice
			boolean isFreeOnline = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			if(isFreeOnline) continue;
			
			String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
			String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
			enrol.setExtra(start + " ~ " + end);

			if(!headerGrade.contains(enrol.getGrade())){
				headerGrade.add(enrol.getGrade().toUpperCase());
			}
			try {
				if(JaeUtils.isEarlier(start, headerDueDate)){
					headerDueDate = start;
				}
			} catch (ParseException e) {
				return ResponseEntity.ok("Error - Date parsing error");
			}
			enrolments.add(enrol);
		}
		header.setRegisterDate(headerDueDate);
		header.setInfo(String.join(", ", headerGrade));
		session.setAttribute(JaeConstants.PAYMENT_HEADER, header);
		session.setAttribute(JaeConstants.PAYMENT_ENROLMENTS, enrolments);

		// 6. bring MaterialDTO
		List<MaterialDTO> materials = materialService.findMaterialByInvoice(invoice.getId());
		session.setAttribute(JaeConstants.PAYMENT_MATERIALS, materials);
		
		// 7. bring PaymentDTO
		List<PaymentDTO> payments = paymentService.getPaymentByInvoice(invoice.getId());
		// update upto & total
		for(PaymentDTO pay : payments){
			pay.setTotal(invoice.getAmount()); // override total as total amount in invoice
			double totalPaid = paymentService.getTotalPaidById(Long.parseLong(pay.getId()), invoice.getId());
			pay.setUpto(totalPaid);
		}
		session.setAttribute(JaeConstants.PAYMENT_PAYMENTS, payments);		
		*/

		// set invoice info into session
		setInvoiceSession(studentId, branchCode, info, session);
		
		// 4. return ok
		return ResponseEntity.ok("Invoice page launched");
	}

	private Map<String, Object> invoicePdfIngredients(Long studentId, String branchCode) {
		// 1. create basket
		Map<String, Object> data = new HashMap<String, Object>();
		// 2. get latest invoice by student id
		Invoice invoice = invoiceService.getLastActiveInvoiceByStudentId(studentId);	
		data.put(JaeConstants.INVOICE_INFO, new InvoiceDTO(invoice));
		// 3. set student info
		Student student = studentService.getStudent(studentId);
		data.put(JaeConstants.STUDENT_INFO, new StudentDTO(student));
		// 4. set branch info
		BranchDTO branchInfo = codeService.getBranch(branchCode);
		String note = branchInfo.getInfo().replace("\n", "<br/>"); // note
		branchInfo.setInfo(note);
		data.put(JaeConstants.INVOICE_BRANCH, branchInfo);
		
		// 5. set header
		MoneyDTO header = new MoneyDTO();
		List<String> headerGrade = new ArrayList<String>();
		String headerDueDate = JaeUtils.getToday();
		
		// 6. bring EnrolmentDTO
		List<EnrolmentDTO> enrolments = new ArrayList<EnrolmentDTO>();
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(invoice.getId());
		
		for(EnrolmentDTO enrol : enrols){
			// 6-1. if free online course, no need to add to invoice
			boolean isFreeOnline = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			if(isFreeOnline) continue;
			
			String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
			String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
			enrol.setExtra(start + " ~ " + end);

			if(!headerGrade.contains(enrol.getGrade())){
				headerGrade.add(enrol.getGrade().toUpperCase());
			}
			try {
				if(JaeUtils.isEarlier(start, headerDueDate)){
					headerDueDate = start;
				}
			} catch (ParseException e) {
				System.out.println(e);
				// return null;
			}
			enrolments.add(enrol);
		}
		header.setRegisterDate(headerDueDate);
		header.setInfo(String.join(", ", headerGrade));
		data.put(JaeConstants.PAYMENT_HEADER, header);
		data.put(JaeConstants.PAYMENT_ENROLMENTS, enrolments);
		
		// 7. bring MaterialDTO
		List<MaterialDTO> materials = materialService.findMaterialByInvoice(invoice.getId());
		data.put(JaeConstants.PAYMENT_MATERIALS, materials);

		// 8. bring PaymentDTO
		List<PaymentDTO> payments = paymentService.getPaymentByInvoice(invoice.getId());
		// update upto & total
		for(PaymentDTO pay : payments){
			pay.setTotal(invoice.getAmount()); // override total as total amount in invoice
			double totalPaid = paymentService.getTotalPaidById(Long.parseLong(pay.getId()), invoice.getId());
			pay.setUpto(totalPaid);
		}
		data.put(JaeConstants.PAYMENT_PAYMENTS, payments);
		// 7. return collections
		return data;
	}

	public Map<String, Object> receiptPdfIngredients(Long studentId, Long invoiceId, Long invoiceHistoryId, Long paymentId, String branchCode) {
		// 1. create basket
		Map<String, Object> data = new HashMap<String, Object>();
		// 2. get latest invoice by student id
		Invoice invoice = invoiceService.getInvoice(invoiceId);	
		data.put(JaeConstants.INVOICE_INFO, new InvoiceDTO(invoice));
		// 3. set student info
		Student student = studentService.getStudent(studentId);
		data.put(JaeConstants.STUDENT_INFO, new StudentDTO(student));
		// 4. set branch info 
		BranchDTO branchInfo = codeService.getBranch(branchCode);
		String note = branchInfo.getInfo().replace("\n", "<br/>"); // note
		branchInfo.setInfo(note);
		data.put(JaeConstants.INVOICE_BRANCH, branchInfo);
		// 5. set header
		MoneyDTO header = new MoneyDTO();
		List<String> headerGrade = new ArrayList<String>();
		String headerDueDate = JaeUtils.getToday();
		
		// 5. set payment elements related to receipt
		List<EnrolmentDTO> enrolments = new ArrayList<EnrolmentDTO>();
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoiceHistory(invoiceHistoryId);
		
		for(EnrolmentDTO enrol : enrols){
			// if free online course, skip it
			boolean isFreeOnline = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			if(isFreeOnline) continue;			
			// 3-1. set period of enrolment to extra field
			String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
			String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
			enrol.setExtra(start + " ~ " + end);
			// 3-2. set headerGrade
			if(!headerGrade.contains(enrol.getGrade())){
				headerGrade.add(enrol.getGrade().toUpperCase());
			}
			// 3-3. set earliest start date to headerDueDate
			try {
				if(JaeUtils.isEarlier(start, headerDueDate)){
					headerDueDate = start;
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
			// 3-4. add to dtos
			enrolments.add(enrol);
		}	
		header.setRegisterDate(headerDueDate);
		header.setInfo(String.join(", ", headerGrade));
		data.put(JaeConstants.PAYMENT_HEADER, header);
		data.put(JaeConstants.PAYMENT_ENROLMENTS, enrolments);

		// 6. bring to MaterialDTO - bring materials by invoice id from Book_Invoice table, list will be brought by invoice history id
		List<MaterialDTO> materials = materialService.findMaterialByInvoiceHistory(invoiceHistoryId);	
		data.put(JaeConstants.PAYMENT_MATERIALS, materials);
		
		// 7. get payment
		List<PaymentDTO> payments = new ArrayList<>();
		List<PaymentDTO> pays = paymentService.getPaymentByInvoice(invoiceId);
		// update upto & total
		for(PaymentDTO pay : pays){
			Long payId = Long.parseLong(pay.getId());
			if(payId <= paymentId){ // only show payments before or equal to payment id
				payments.add(pay);
			}
		}
		data.put(JaeConstants.PAYMENT_PAYMENTS, payments);

		// 8. return collections
		return data;
	}

	@GetMapping("/exportInvoice")
    public void exportInvoicePdf(@RequestParam String studentId, @RequestParam String branchCode, HttpServletResponse response) throws IOException {
		// Set the content type and attachment header.
		response.setContentType("application/pdf");
		response.setHeader("Content-Disposition", "inline; filename=invoice.pdf");
		Map<String, Object> data = invoicePdfIngredients(Long.parseLong(studentId), branchCode);
       	byte[] pdfData = pdfService.generateInvoicePdf(data);
		if(pdfData != null){
			response.getOutputStream().write(pdfData);
			response.getOutputStream().flush();
		}
    }

	@GetMapping("/exportReceipt")
    public void exportReceiptPdf(@RequestParam String studentId, @RequestParam String invoiceId, @RequestParam String invoiceHistoryId, @RequestParam String paymentId, @RequestParam String branchCode, HttpServletResponse response) throws IOException {
		// Set the content type and attachment header.
		response.setContentType("application/pdf");
		response.setHeader("Content-Disposition", "inline; filename=receipt.pdf");
		Map<String, Object> data = receiptPdfIngredients(Long.parseLong(studentId), Long.parseLong(invoiceId), Long.parseLong(invoiceHistoryId), Long.parseLong(paymentId), branchCode);
       	byte[] pdfData = pdfService.generateReceiptPdf(data);
		if(pdfData != null){
			response.getOutputStream().write(pdfData);
			response.getOutputStream().flush();
		}
    }

	@GetMapping("/emailInvoice")
	@ResponseBody
    public ResponseEntity<String> emailInvoice(@RequestParam String studentId, @RequestParam String branchCode){
		try{
			Map<String, Object> data = invoicePdfIngredients(Long.parseLong(studentId), branchCode);
			String fromEmail = codeService.getBranchEmail(branchCode);
			byte[] pdfData = pdfService.generateInvoicePdf(data);
			emailService.sendEmailWithAttachment(fromEmail, "cailot@naver.com", "Sending from Spring Boot", "This is a test messasge", "invoice.pdf", pdfData);
			return ResponseEntity.ok("ok");
		}catch(Exception e){
			String message = "\"Error sending email : " + e.getMessage() + "\"";
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
    }

	@GetMapping("/emailReceipt")
	@ResponseBody
    public ResponseEntity<String> emailReceipt(@RequestParam String studentId, @RequestParam String invoiceId, @RequestParam String invoiceHistoryId, @RequestParam String paymentId, @RequestParam String branchCode){
		try{
			Map<String, Object> data = receiptPdfIngredients(Long.parseLong(studentId), Long.parseLong(invoiceId), Long.parseLong(invoiceHistoryId), Long.parseLong(paymentId), branchCode);
			byte[] pdfData = pdfService.generateReceiptPdf(data);
			emailService.sendEmailWithAttachment("jin@gmail.com", "cailot@naver.com", "Sending from Spring Boot", "This is a test messasge", "receipt.pdf", pdfData);
			return ResponseEntity.ok("ok");
		}catch(Exception e){
			String message = "\"Error sending email : " + e.getMessage() + "\"";
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
    }

	// update additional memo for Enrolment or Payment
	@PostMapping("/updateInfo/{dataType}/{dataId}")
	@ResponseBody
	public ResponseEntity<String> updateInformation(@PathVariable("dataType") String dataType, @PathVariable("dataId") Long dataId, @RequestBody(required = false) String info){
		// 1. check dataType
		if(JaeConstants.ENROLMENT.equalsIgnoreCase(dataType)){
			// 2-1. get Enrolment
			Enrolment enrolment = enrolmentService.getEnrolment(dataId);
			enrolment.setInfo(info);
			// 3-1. update Enrolment
			enrolmentService.updateEnrolment(enrolment, dataId);
			// 4-1. return flag
			return ResponseEntity.ok("Enrolment Info Update Success");
		}else if(JaeConstants.BOOK.equalsIgnoreCase(dataType)){
			// 2-3. get Material
			Material material = materialService.getMaterial(dataId);
			// 3-3. update Material
			material.setInfo(info);
			materialService.updateMaterial(material, dataId);
			// 4-2. return flag
			return ResponseEntity.ok("Material Info Update Success");
		}else if(JaeConstants.PAYMENT.equalsIgnoreCase(dataType)){
			// 2-3. get Payment
			Payment payment = paymentService.findPaymentById(dataId);
			// 3-3. update Payment
			payment.setInfo(info);
			paymentService.updatePayment(payment, dataId);
			// 4-2. return flag
			return ResponseEntity.ok("Payment Info Update Success");
		}else{
			return ResponseEntity.ok("Error");
		}
	}

	// payment list for paymentList.jsp
	@GetMapping("/paymentList")
	public String paymentStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate, Model model
									) {
		String start = null;
		try {
			start = JaeUtils.convertToyyyyMMddFormat(fromDate);
		} catch (ParseException e) {			
			start = "2000-01-01";
		}
		String end = null;
		try {
			end = JaeUtils.convertToyyyyMMddFormat(toDate);
		} catch (ParseException e){
			end = "2099-12-31";
		}
		List<StudentDTO> dtos = studentService.listPaymentStudent(branch, grade, start, end);
		model.addAttribute(JaeConstants.STUDENT_LIST, dtos);
		return "paymentListPage";
	}

	// overdue list for overdueList.jsp
	@GetMapping("/overdueList")
	public String overdueStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade, Model model) {
		int year = cycleService.academicYear();
		int week = cycleService.academicWeeks();
		List<StudentDTO> dtos = studentService.listOverdueStudent(branch, grade, year, week);
		model.addAttribute(JaeConstants.STUDENT_LIST, dtos);
		return "overdueListPage";
	}

	// renew list for renewList.jsp
	@GetMapping("/renewList")
	public String renewStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("book") String book, 
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate, Model model){
		int fromYear = cycleService.academicYear(fromDate);
		int fromWeek = cycleService.academicWeeks(fromDate);
		int toYear = cycleService.academicYear(toDate);
		int toWeek = cycleService.academicWeeks(toDate);
		List<StudentDTO> dtos = studentService.listRenewStudent(branch, grade, fromYear, fromWeek, toYear, toWeek);
		model.addAttribute(JaeConstants.STUDENT_LIST, dtos);
		return "renewListPage";
	}

	// renew invoice for student, return renewed invoice id
	@PostMapping("/renewInvoice/{studentId}/{book}/{branchCode}")
	@ResponseBody
	public ResponseEntity<String> renewInvoice(@PathVariable("studentId") Long studentId, @PathVariable("book") int book, @PathVariable("branchCode") String branchCode, HttpSession session){
		// 1. get Student
		Student student = studentService.getStudent(studentId);

		// 2. check last active invoice
		Invoice invoice = invoiceService.getLastActiveInvoiceByStudentId(studentId);
		if(invoice == null) return ResponseEntity.ok(JaeConstants.STATUS_EMPTY);
		
		// 3. check full paid or not; if not, return
		double invoiceAmount = invoice.getAmount();
		double invoicePaidAmount = invoice.getPaidAmount();
		boolean fullPaid =  (invoiceAmount - invoicePaidAmount) <= 0;
		if(!fullPaid) return ResponseEntity.ok(JaeConstants.STATUS_EMPTY);

		// 4. get enrolments by invoice
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(invoice.getId());
		if(enrols.size() == 0) return ResponseEntity.ok(JaeConstants.STATUS_EMPTY);

		// 5. create new invoice
		Invoice newInvo = new Invoice();
		newInvo.setStudentId(studentId);
		invoiceService.addInvoice(newInvo);

		// 6. create InvoiceHistory
		InvoiceHistory history = new InvoiceHistory();
		history.setInvoice(newInvo);
		invoiceHistoryService.addInvoiceHistory(history);

		String grade = "";
		// 7. create new Enrolment
		for(EnrolmentDTO data : enrols){

			// 7-0. get grade
			grade = data.getGrade();
			
			// 7-1. get Clazz
			Clazz clazz = clazzService.getClazz(Long.parseLong(data.getClazzId()));
			
			// 7-2. update Invoice amount
			int newStartWeek = data.getEndWeek() + 1;
			// int newEndWeek = newStartWeek + 9;
			int newEndWeek = newStartWeek + (data.getEndWeek() - data.getStartWeek() - data.getCredit()); // same period as previous enrolment
			int academicYear = clazzService.getAcademicYear(clazz.getId());
			int lastAcademicWeek = cycleService.lastAcademicWeek(academicYear);
			if(newEndWeek > lastAcademicWeek){
				newEndWeek = lastAcademicWeek;
			}

			// no discount for renew
			String discount =StringUtils.defaultString(data.getDiscount(), "0");
			boolean isFreeOnline = data.isOnline() && StringUtils.equalsIgnoreCase(JaeConstants.DISCOUNT_FREE, discount);
			double discountAmount = 0;
			if(isFreeOnline){ // if free online class, discount is 100%
				discountAmount = ((newEndWeek-newStartWeek+1) * data.getPrice());
			}
			double enrolmentPrice = (((newEndWeek-newStartWeek+1) * data.getPrice()) - discountAmount);	
			
			newInvo.setAmount(newInvo.getAmount() + enrolmentPrice);
			newInvo.setCredit(0);

			// 7-3. create new Enrolment
			Enrolment enrolment = new Enrolment();
			enrolment.setStartWeek(newStartWeek);
			enrolment.setEndWeek(newEndWeek);
			enrolment.setCredit(0);
			if(isFreeOnline){
				enrolment.setDiscount(JaeConstants.DISCOUNT_FREE);
			}else{
				enrolment.setDiscount("0");
			} 
			enrolment.setClazz(clazz);
			enrolment.setStudent(student);
			enrolment.setInvoice(newInvo);
			// add invoice history
			enrolment.setInvoiceHistory(history);
				
			// 7-4. save new Enrolment - Invoice will be automatically updated
			enrolmentService.addEnrolment(enrolment);
			data.setExtra(JaeConstants.NEW_ENROLMENT);
			data.setId(enrolment.getId()+"");
			data.setInvoiceId(newInvo.getId()+"");
			// update day to code
			data.setDay(clazzService.getDay(clazz.getId()));
			
			// 7-5. if onlline class, skip attendance; otherwise create attendance
			if(!data.isOnline()){
				///////////////// Attendance ////////////////////////
				// int academicYear = clazzService.getAcademicYear(clazz.getId());
				String clazzDay = clazzService.getDay(clazz.getId());
				for(int i = newStartWeek; i <= newEndWeek; i++){
					Attendance attendance = new Attendance();
					attendance.setWeek(i+"");
					attendance.setStudent(student);
					attendance.setClazz(clazz);
					attendance.setDay(clazzDay);
					attendance.setStatus(JaeConstants.ATTEND_OTHER);
					LocalDate attendDate = cycleService.getDateByWeekAndDay(academicYear, i, clazzDay);
					attendance.setAttendDate(attendDate);
					attendanceService.addAttendance(attendance);
				}
				//////////////////////////////////////////////////////////
			}
		} // end of processing new enrolments

		// 8. create new Material if book is not 0
		if(book > 0){
			// 8-1. get book Id 
			long bookId = bookService.getBookIdByGradeNOrder(Integer.parseInt(StringUtils.defaultString(grade, "0")), book);
			// 8-2. get Book
			Book bookInfo = bookService.getBook(bookId);
			// 8-3. update Invoice amount
			newInvo.setAmount(newInvo.getAmount() + bookInfo.getPrice());
			// 8-3. create Material
			Material material = new Material();
			material.setBook(bookInfo);
			material.setInvoice(newInvo);
			material.setInvoiceHistory(history);
			// 8-4. save Material
			materialService.addMaterial(material);
		}	

		// 9. update invoice history's amount & paid amount
		history.setAmount(newInvo.getAmount());
		history.setPaidAmount(newInvo.getPaidAmount());
		invoiceHistoryService.updateInvoiceHistory(history, history.getId());
		//Min 9075 2302 010

		// 10. set invoice info into session
		setInvoiceSession(studentId, branchCode, null, session);

		// 11. return flag
		return ResponseEntity.ok(newInvo.getId()+"");

	}

	// register new invoice
	@GetMapping("/last/{studentId}")
	@ResponseBody
	public boolean lastInvoiceChecl(@PathVariable("studentId") Long studentId) {	
		// 1. get latest invoice by student id
		Invoice invoice = invoiceService.getLastActiveInvoiceByStudentId(studentId);
		// 2. check full paid or not
		double amount = invoice.getAmount();
		double paidAmount = invoice.getPaidAmount();
		boolean fullPaid =  (amount - paidAmount) <= 0;
		// 3. return info
		return fullPaid;
	}








	// set invoice info into session
	private void setInvoiceSession(Long studentId, String branchCode, String info, HttpSession session){
		// 1. flush session from previous payment
		JaeUtils.clearSession(session);

		// 2. get latest invoice by student id
		Invoice invoice = invoiceService.getLastActiveInvoiceByStudentId(studentId);	
		if(info!=null) invoice.setInfo(info);
		invoiceService.updateInvoice(invoice, invoice.getId());
		String lfStr = StringUtils.defaultString(invoice.getInfo()).replace("\n", "<br/>"); 
		InvoiceDTO newInvo = new InvoiceDTO(invoice);
		newInvo.setInfo(lfStr);
		session.setAttribute(JaeConstants.INVOICE_INFO, newInvo);

		// 3. payment note based on branch code
		BranchDTO branchInfo = codeService.getBranch(branchCode);
		String note = branchInfo.getInfo().replace("\n", "<br/>"); // note
		branchInfo.setInfo(note);
		session.setAttribute(JaeConstants.INVOICE_BRANCH, branchInfo);

		// 4. create MoneyDTO for header
		MoneyDTO header = new MoneyDTO();
		List<String> headerGrade = new ArrayList<String>();
		String headerDueDate = JaeUtils.getToday();

		// 5. bring EnrolmentDTO
		List<EnrolmentDTO> enrolments = new ArrayList<>();
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(invoice.getId());

		for(EnrolmentDTO enrol : enrols){
			// 5-1. if free online course, no need to add to invoice
			boolean isFreeOnline = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			if(isFreeOnline) continue;
			
			String start = cycleService.academicStartMonday(enrol.getYear(), enrol.getStartWeek());
			String end = cycleService.academicEndSunday(enrol.getYear(), enrol.getEndWeek());
			enrol.setExtra(start + " ~ " + end);

			if(!headerGrade.contains(enrol.getGrade())){
				headerGrade.add(enrol.getGrade().toUpperCase());
			}
			try {
				if(JaeUtils.isEarlier(start, headerDueDate)){
					headerDueDate = start; 
				}
			} catch (ParseException e) {
				//return ResponseEntity.ok("Error - Date parsing error ");
			}
			enrolments.add(enrol);
		}
		header.setRegisterDate(headerDueDate);
		header.setInfo(String.join(", ", headerGrade));
		session.setAttribute(JaeConstants.PAYMENT_HEADER, header);
		session.setAttribute(JaeConstants.PAYMENT_ENROLMENTS, enrolments);

		// 6. bring MaterialDTO
		List<MaterialDTO> materials = materialService.findMaterialByInvoice(invoice.getId());
		session.setAttribute(JaeConstants.PAYMENT_MATERIALS, materials);
		
		// 7. bring PaymentDTO
		List<PaymentDTO> payments = paymentService.getPaymentByInvoice(invoice.getId());
		// update upto & total
		for(PaymentDTO pay : payments){
			pay.setTotal(invoice.getAmount()); // override total as total amount in invoice
			double totalPaid = paymentService.getTotalPaidById(Long.parseLong(pay.getId()), invoice.getId());
			pay.setUpto(totalPaid);
		}
		session.setAttribute(JaeConstants.PAYMENT_PAYMENTS, payments);			
	}
	
}