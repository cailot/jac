package hyung.jin.seo.jae.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.dto.PaymentDTO;
import hyung.jin.seo.jae.model.Attendance;
import hyung.jin.seo.jae.model.Book;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.model.Invoice;
import hyung.jin.seo.jae.model.InvoiceHistory;
import hyung.jin.seo.jae.model.Material;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.AttendanceService;
import hyung.jin.seo.jae.service.BookService;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.InvoiceHistoryService;
import hyung.jin.seo.jae.service.InvoiceService;
import hyung.jin.seo.jae.service.MaterialService;
import hyung.jin.seo.jae.service.PaymentService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("enrolment")
public class EnrolmentController {

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private StudentService studentService;

	@Autowired
	private MaterialService materialService;

	@Autowired
	private InvoiceService invoiceService;

	@Autowired
	private InvoiceHistoryService invoiceHistoryService;

	@Autowired
	private PaymentService paymentService;

	@Autowired
	private BookService bookService;

	@Autowired
	private AttendanceService attendanceService;

	@Autowired
	private CycleService cycleService;

	// @GetMapping("/search/student/{id}")
	// @ResponseBody
	// public List searchEnrolmentByStudent(@PathVariable Long id) {
	// 	// get lastest invoice id
 	// 	Long invoiceId = enrolmentService.findLatestInvoiceIdByStudent(id);

	// 	return fetchEnrolment(id, invoiceId);
	// }

	@GetMapping("/search/student/{studentId}")
	@ResponseBody
	public List searchEnrolmentByStudent(@PathVariable Long studentId) {
		List dtos = new ArrayList();
		// get 3 lastest invoice id
 		Long firstId = enrolmentService.findLatestInvoiceIdByStudent(studentId);
		Long secondId = enrolmentService.find2ndLatestInvoiceIdByStudent(studentId);
		Long thirdId = enrolmentService.find3rdLatestInvoiceIdByStudent(studentId);

		// add 3 enrolments
		if(firstId!=null) dtos.add(fetchInvoice(studentId, firstId));
		if(secondId!=null) dtos.add(fetchInvoice(studentId, secondId));
		if(thirdId!=null) dtos.add(fetchInvoice(studentId, thirdId));

		// return dtos mixed by enrolments
		// System.out.println(dtos);
		return dtos;
	}



	// fetch enrolment by student id and invoice id
	private List fetchInvoice(Long studentId, Long invoiceId) {
		List dtos = new ArrayList(); 
		
		boolean isInvoiceAbsent = ((invoiceId==null) || (invoiceId==0L));
		
		if(isInvoiceAbsent) return dtos; // return empty list if no invoice

		double totalAmount = invoiceService.getInvoiceTotalAmount(invoiceId);
		double paidAmount = invoiceService.getPaidAmount(invoiceId);
		boolean isFullPaid = (totalAmount == paidAmount);

		// 1. get enrolments by invoice id
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoiceAndStudent(invoiceId, studentId);
		for(EnrolmentDTO enrol : enrols){
			// set price = 0 if discount = 100%
			if(StringUtils.defaultString(enrol.getDiscount()).equalsIgnoreCase(JaeConstants.DISCOUNT_FREE)){
				enrol.setPrice(0);
			}
			// 2. check if enrolment is active or not
			// if full paid, set extra as paid
			if(isFullPaid){
				enrol.setExtra(JaeConstants.FULL_PAID);
			}else{
				enrol.setExtra(JaeConstants.OVERDUE);
			}
			dtos.add(enrol);
		}
				
		// 3. get materials by invoice id and add to list dtos
		List<MaterialDTO> materials = materialService.findMaterialByInvoice(invoiceId);
		for(MaterialDTO material : materials){
			// if Extra, assign extra value (user input) to price
			// if(StringUtils.equalsAnyIgnoreCase(JaeConstants.EXTRA, material.getName())){

			// }
			// System.out.println(material);
			// double price = material.getInput();
			// set payment status for materials based on invoice payment status
			if(isFullPaid){
				material.setExtra(JaeConstants.FULL_PAID);
			}else{
				material.setExtra(JaeConstants.OVERDUE);
			}
			dtos.add(material);
		}
		
		// 4. get payments by invoice id and add to list dtos
		List<PaymentDTO> payments = paymentService.getPaymentByInvoice(invoiceId);
		for(PaymentDTO payment : payments){
			payment.setTotal(totalAmount); // override total as total amount in invoice
			double totalPaid = paymentService.getTotalPaidById(Long.parseLong(payment.getId()), invoiceId);
			payment.setUpto(totalPaid);
			dtos.add(payment);
		}

		// 5. return dtos mixed by enrolments and outstandings
		// System.out.println(dtos);
		return dtos;
	}

	// count records number in database
	@GetMapping("/count")
	@ResponseBody
	public long count() {
		long count = enrolmentService.checkCount();
		return count;
	}

	// bring all enrolments in database
	@GetMapping("/list")
	@ResponseBody
	public List<EnrolmentDTO> listEnrolments() {
 		List<EnrolmentDTO> dtos = enrolmentService.allEnrolments();
		return dtos;
	}
		
	// register new student
	@PostMapping("/register")
	@ResponseBody
	public EnrolmentDTO registerEnrolment(@RequestBody EnrolmentDTO formData) {
		// System.out.println(formData);
		// 1. create bare Enrolment
		Enrolment enrolment = formData.convertToEnrolment();
		// 2. get Clazz
		Clazz clazz = clazzService.getClazz(Long.parseLong(formData.getClazzId()));
		// 3. get Student
		Student student = studentService.getStudent(Long.parseLong(formData.getStudentId()));
		// 4. assign Clazz & Student
		enrolment.setClazz(clazz);
		enrolment.setStudent(student);
		// 5. save Class
		EnrolmentDTO dto = enrolmentService.addEnrolment(enrolment);
		// 6. return dto;
		return dto;
	}

	// search clazz by student Id
	@GetMapping("/getClazz/student/{id}")
	@ResponseBody
	List<ClazzDTO> searchClazzByStudent(@PathVariable Long id) {
		List<Long> clazzIds = enrolmentService.findClazzIdByStudentId(id);
		List<ClazzDTO> dtos = new ArrayList<ClazzDTO>();
		for (Long clazzId : clazzIds) {
			Clazz clazz = clazzService.getClazz(clazzId);
			ClazzDTO dto = new ClazzDTO(clazz);
			dtos.add(dto);
		}
		return dtos;
	}

	@PostMapping("/associateBook/{studentId}")
	@ResponseBody
	public List<MaterialDTO> associateBook(@PathVariable Long studentId, @RequestBody MaterialDTO[] formData) {
		List<MaterialDTO> dtos = new ArrayList<>();
		
		// 1. get Invoice
		Invoice existingInvo = invoiceService.getLastActiveInvoiceByStudentId(studentId);
		InvoiceHistory existingInvoHistory = invoiceHistoryService.getLastInvoiceHistory(existingInvo.getId());
		
		// 2. remove existing Materials
		if(existingInvo!=null){
			detachBook(existingInvo);	
		}

		// 3. register Books
		for(MaterialDTO material : formData){
			boolean isExtra = false;
			// 3-1. get book
			Book book = bookService.getBook(Long.parseLong(material.getBookId()));
			if(StringUtils.endsWithIgnoreCase(JaeConstants.EXTRA, book.getName())) isExtra = true;
			double price = isExtra ? material.getPrice() : book.getPrice();

			// 3-2. update invoice amount
			existingInvo.setAmount(existingInvo.getAmount() + price);
			// 3-3. create Material
			Material newMaterial = new Material();
			if(isExtra) newMaterial.setInput(price);
			newMaterial.setBook(book);
			newMaterial.setInvoice(existingInvo);
			newMaterial.setInvoiceHistory(existingInvoHistory);
			// 3-4. save Material - Invoice/InvoiceHistory will be automatically updated
			newMaterial = materialService.addMaterial(newMaterial);
			MaterialDTO dto = new MaterialDTO(newMaterial);
			dtos.add(dto);
		}

		// 4. return MaterialDTO list
		return dtos;
	}

	@PostMapping("/associatePayment/{studentId}")
	@ResponseBody
	public List<PaymentDTO> associatePayment(@PathVariable Long studentId) {
		List<PaymentDTO> payments = new ArrayList<>();
		// 1. get Invoice
		Invoice invo = invoiceService.getLastActiveInvoiceByStudentId(studentId);
		// 2. check if invoice has owing amount
		boolean isValidInvoice = (invo !=null) && (invo.getAmount() > invo.getPaidAmount());
		// 3. if invoice is already paid or null, return empty list
		if(!isValidInvoice) return payments;
		// 4. bring all related payments
		payments = paymentService.getPaymentByInvoice(invo.getId());
		// 5. update total amount and upto amount
		for(PaymentDTO payment : payments){
			payment.setTotal(invo.getAmount()); // override total as total amount in invoice
			double totalPaid = paymentService.getTotalPaidById(Long.parseLong(payment.getId()), invo.getId());
			payment.setUpto(totalPaid);
			//payments.add(payment);
		}

		// 6. return PaymentDTO list
		return payments;
	}

	@PostMapping("/associateClazz/{studentId}")
	@ResponseBody
	public List<EnrolmentDTO> associateClazz(@PathVariable Long studentId, @RequestBody EnrolmentDTO[] formData) {
		
		List<EnrolmentDTO> dtos = new ArrayList<>();
		// 1. check new Enrolment or not
		boolean isNewEnrolment = true;
		// 1-1. check paid invoiceId is included in formData
		for(EnrolmentDTO data : formData){
			if(StringUtils.isNotBlank(data.getInvoiceId()) && !StringUtils.equalsIgnoreCase("100%", data.getDiscount())){
				isNewEnrolment = false;
				break;
			}
		}

		// 2. get Student to associate to Enrolment later
		Student student = studentService.getStudent(studentId);

		// 3. if new Enrolment, create new Invoice
		if(isNewEnrolment){

			//////////////////////////////////////////// If parents change mind before payment //////////////////////////////////////////
			// 3-0. check if existing invoice is active but never paid before.
			Invoice existingInvo = invoiceService.getLastActiveInvoiceByStudentId(studentId);
			double owingAmount = 0;
			if(existingInvo!=null){
			// double totalAmount = existingInvo.getAmount();
			double paidAmount = existingInvo.getPaidAmount();
				// 3-0-1. remove existing enrolments if paid amount is 0 and enrolment not started yet
				if(paidAmount==0){
					detachEnrolment(existingInvo);
				}else if(paidAmount>0 && paidAmount<existingInvo.getAmount()){
					// if partial paid in previous invoice, can't change until full payment completes
					return dtos;
					// 3-0-2. calculate owing amount
					// owingAmount = existingInvo.getAmount() - paidAmount;
					// // 3-0-3. remove existing enrolments
					// detachEnrolment(existingInvo);

				}
			}
			//////////////////////////////////////////// If parents change mind before payment //////////////////////////////////////////

			// 3-1. create new Invoice
			Invoice newInvo = new Invoice();
			newInvo.setDiscount(owingAmount); // discount from previous invoice
			newInvo.setStudentId(studentId);
			invoiceService.addInvoice(newInvo);

			// 3-1-1. create InvoiceHistory
			InvoiceHistory history = new InvoiceHistory();
			history.setInvoice(newInvo);
			invoiceHistoryService.addInvoiceHistory(history);

			// 3-2. create new Enrolment
			for(EnrolmentDTO data : formData){

				// 3-2-1. get Clazz
				Clazz clazz = clazzService.getClazz(Long.parseLong(data.getClazzId()));
				
				// 3-2-2. update Invoice amount
				// check discount is % or amount value
				String discount =StringUtils.defaultString(data.getDiscount(), "0");
				double discountAmount = 0;
				if(discount.contains("%")){
					discountAmount = (((data.getEndWeek()-data.getStartWeek()+1)-data.getCredit()) * data.getPrice()) * (Double.parseDouble(discount.replace("%", ""))/100);
				}else{
					discountAmount = Double.parseDouble(discount);
				}
				double enrolmentPrice = ((((data.getEndWeek()-data.getStartWeek()+1)-data.getCredit()) * data.getPrice()) - discountAmount);
				int credit = data.getCredit();
				newInvo.setAmount(newInvo.getAmount() + enrolmentPrice);
				newInvo.setCredit(newInvo.getCredit() + credit);
				newInvo.setDiscount(newInvo.getDiscount() + discountAmount);
				
				// 3-2-3. create new Enrolment
				Enrolment enrolment = new Enrolment();
				enrolment.setStartWeek(data.getStartWeek());
				enrolment.setEndWeek(data.getEndWeek());
				enrolment.setCredit(data.getCredit());
				enrolment.setDiscount(data.getDiscount());
				enrolment.setClazz(clazz);
				enrolment.setStudent(student);
				enrolment.setInvoice(newInvo);
				// add invoice history
				enrolment.setInvoiceHistory(history);
				
				// 3-2-4. save new Enrolment - Invoice will be automatically updated
				enrolmentService.addEnrolment(enrolment);
				data.setExtra(JaeConstants.NEW_ENROLMENT);
				data.setId(enrolment.getId()+"");
				data.setInvoiceId(newInvo.getId()+"");
				// update day to code
				data.setDay(clazzService.getDay(clazz.getId()));
				
				// 3-2-5. put into List<EnrolmentDTO>
				dtos.add(data);

				// 4. if onlline class, skip attendance; otherwise create attendance
				if(!data.isOnline()){
					///////////////// Attendance ////////////////////////
					int academicYear = clazzService.getAcademicYear(clazz.getId());
					String clazzDay = clazzService.getDay(clazz.getId());
					for(int i = data.getStartWeek(); i <= data.getEndWeek(); i++){
						Attendance attendance = new Attendance();
						attendance.setWeek(i+"");
						attendance.setStudent(student);
						attendance.setClazz(clazz);
						attendance.setDay(clazzDay); // Use actual class day from the class
						attendance.setStatus(JaeConstants.ATTEND_OTHER);
						LocalDate attendDate = cycleService.getDateByWeekAndDay(academicYear, i, clazzDay);
						attendance.setAttendDate(attendDate);
						attendanceService.addAttendance(attendance);
					}
					//////////////////////////////////////////////////////////
				}
			} // end of processing new enrolments
			// update invoice history's amount & paid amount
			history.setAmount(newInvo.getAmount());
			history.setPaidAmount(newInvo.getPaidAmount());
			invoiceHistoryService.updateInvoiceHistory(history, history.getId());

		}else{ // if invoice exists, get last active Invoice
			Invoice existingInvo = invoiceService.getLastActiveInvoiceByStudentId(studentId);
			
			// 3-1. create InvoiceHistory
			InvoiceHistory history = new InvoiceHistory();
			history.setInvoice(existingInvo);
			invoiceHistoryService.addInvoiceHistory(history);

			// 3-2. remove existing enrolments
			detachEnrolment(existingInvo);

			// 3-3. update existing Enrolment
			for(EnrolmentDTO data : formData){

				// 3-3-1. get Clazz
				Clazz clazz = clazzService.getClazz(Long.parseLong(data.getClazzId()));
				// 3-3-2. update Invoice amount
				// check discount is % or amount value
				String discount =StringUtils.defaultString(data.getDiscount(), "0");
				double discountAmount = 0;
				if(discount.contains("%")){
					discountAmount = (((data.getEndWeek()-data.getStartWeek()+1)-data.getCredit()) * data.getPrice()) * (Double.parseDouble(discount.replace("%", ""))/100);
				}else{	
					discountAmount = Double.parseDouble(discount);
				}
				double enrolmentPrice = ((((data.getEndWeek()-data.getStartWeek()+1)-data.getCredit()) * data.getPrice()) - discountAmount);
				int credit = data.getCredit();
				existingInvo.setAmount(existingInvo.getAmount() + enrolmentPrice);
				existingInvo.setCredit(existingInvo.getCredit() + credit);
				existingInvo.setDiscount(existingInvo.getDiscount() + discountAmount);
				// invoiceService.updateInvoice(existingInvo, existingInvo.getId());
				// 3-3-3. create new Enrolment
				Enrolment enrolment = new Enrolment();
				int startWeek = data.getStartWeek();
				int endWeek = data.getEndWeek();
				enrolment.setStartWeek(startWeek);
				enrolment.setEndWeek(endWeek);
				enrolment.setCredit(data.getCredit());
				enrolment.setDiscount(data.getDiscount());
				enrolment.setClazz(clazz);
				enrolment.setStudent(student);
				enrolment.setInvoice(existingInvo);
				enrolment.setInvoiceHistory(history);
				// 3-3-4. save new Enrolment - Invoice will be automatically updated
				enrolmentService.addEnrolment(enrolment);
				data.setExtra(JaeConstants.NEW_ENROLMENT);
				data.setId(enrolment.getId()+"");
				data.setInvoiceId(existingInvo.getId()+"");
				// update day to code
				data.setDay(clazzService.getDay(clazz.getId()));
				// 3-3-5. put into List<EnrolmentDTO>
				dtos.add(data);
					
				// 3-3-6. if onlline class, skip attendance; otherwise create attendance	
				if(!data.isOnline()){
					///////////////// Attendance ////////////////////////
					int academicYear = clazzService.getAcademicYear(clazz.getId());
					// Get the fresh day value directly from the clazz to ensure it's up-to-date
					String clazzDay = clazzService.getDay(clazz.getId());
					for(int i = startWeek; i <= endWeek; i++){
						// Calculate the attendance date based on the class day
						LocalDate attendDate = cycleService.getDateByWeekAndDay(academicYear, i, clazzDay);
						// Create attendance for all weeks with the correct day
						Attendance attendance = new Attendance();
						attendance.setWeek(i+"");
						attendance.setStudent(student);
						attendance.setClazz(clazz);
						attendance.setDay(clazzDay); // Use the day from the class
						attendance.setStatus(JaeConstants.ATTEND_OTHER);						
						attendance.setAttendDate(attendDate);
						attendanceService.addAttendance(attendance);
					}
					//////////////////////////////////////////////////////////
				}
				
			}// end of EnrolmentDTO loop
		}// end of Invoice check (new/existing)

		return dtos;
	}

	/////////////////////////////////////////////////////////
	// detach already registered enrolments
	// 1. Update Invoice credit, discount, amount
	// 2. Update Attendance
	// 3. Update Enrolment : old = true
	///////////////////////////////////////////////////////
	private void detachEnrolment(Invoice invoice){
		// 1. get registered enrolment by invoice id
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByInvoice(invoice.getId());

		// 2. archive enrolments by updating old = true
		for(EnrolmentDTO enrol : enrols){
			// 3. get enrolled info
			Long enrolId = Long.parseLong(StringUtils.defaultIfBlank(enrol.getId(), "0"));
			boolean isFree = enrol.isOnline() && enrol.getDiscount().equalsIgnoreCase(JaeConstants.DISCOUNT_FREE);
			
			int existStart = enrol.getStartWeek();
			int existEnd = enrol.getEndWeek();
			int existCredit = isFree ? 0: enrol.getCredit();
			// check discount is % or amount value
			String existDiscount =StringUtils.defaultString(enrol.getDiscount(), "0");
			double existDCAmount = 0;
			// check if discount is 100% & online class
			if(isFree){
				existDCAmount = 0;
			}else{
				if(existDiscount.contains("%")){
					existDCAmount = (((existEnd-existStart+1)-existCredit) * enrol.getPrice()) * (Double.parseDouble(existDiscount.replace("%", ""))/100);
				}else{
					existDCAmount = Double.parseDouble(existDiscount);
				}
			}
			double existTotal = isFree ? 0 : ((((existEnd-existStart+1)-existCredit) * enrol.getPrice()) - existDCAmount);
			// 4. update invoice amount
			invoice.setCredit(invoice.getCredit() - existCredit);
			invoice.setDiscount(invoice.getDiscount() - existDCAmount);
			invoice.setAmount(invoice.getAmount() - existTotal);
			// 5. update invoice
			invoiceService.updateInvoice(invoice, invoice.getId()); // need??
			// 6. update attendance
			// if online class, skip attendance; otherwise remove attandance
			if(!enrol.isOnline()){
				
				long studentId = Long.parseLong(StringUtils.defaultIfBlank(enrol.getStudentId(), "0"));
				long clazzId = Long.parseLong(StringUtils.defaultIfBlank(enrol.getClazzId(), "0"));
				
				// Remove all attendance records for this student and class
				// This ensures when class day changes, old attendance records are purged
				List<AttendanceDTO> attendances = attendanceService.findAttendanceByStudentAndClazz(studentId, clazzId);
				for(AttendanceDTO attendance : attendances){
					long attendId = Long.parseLong(attendance.getId());
					attendanceService.deleteAttendance(attendId);
				}
			}
			// 7. update enrolment
			enrolmentService.archiveEnrolment(enrolId);
		}

	}

	/////////////////////////////////////////////////////////
	// detach already registered books
	// 1. Update Invoice amount
	// 2. Update Material : old = true
	///////////////////////////////////////////////////////
	private void detachBook(Invoice invoice){
		// 1. get registered material by invoice id
		List<MaterialDTO> books = materialService.findMaterialByInvoice(invoice.getId());
		// 2. archive enrolments by updating old = true
		for(MaterialDTO book : books){
			// 3. get enrolled info
			Long bookId = Long.parseLong(StringUtils.defaultIfBlank(book.getId(), "0"));
			double price = book.getPrice();
			// 4. update invoice amount
			invoice.setAmount(invoice.getAmount() - price);
			// 5. update invoice
			invoiceService.updateInvoice(invoice, invoice.getId()); // need??
			// 6. update material
			materialService.archiveMaterial(bookId);
		}
	}


}
