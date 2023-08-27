package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.dto.OutstandingDTO;
import hyung.jin.seo.jae.model.Book;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Elearning;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.model.Invoice;
import hyung.jin.seo.jae.model.Material;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.BookService;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.ElearningService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.InvoiceService;
import hyung.jin.seo.jae.service.MaterialService;
import hyung.jin.seo.jae.service.OutstandingService;
import hyung.jin.seo.jae.service.StudentService;

@Controller
@RequestMapping("enrolment")
public class JaeEnrolmentController {

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private StudentService studentService;

	@Autowired
	private ElearningService elearningService;

	@Autowired
	private OutstandingService outstandingService;

	@Autowired
	private MaterialService materialService;

	@Autowired
	private InvoiceService invoiceService;

	@Autowired
	private BookService bookService;

	// search enrolment by student Id and return mixed list of materials, enrolments, outstandings
	@GetMapping("/search/student/{id}")
	@ResponseBody
	public List searchEnrolmentByStudent(@PathVariable Long id) {
		List dtos = new ArrayList();
		List<String> invoiceIds = new ArrayList();
		// 1. get enrolments
		List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByStudent(id);
		// 2. get invoice id and add to list dtos
		for(EnrolmentDTO enrol : enrols){
			invoiceIds.add(enrol.getInvoiceId());
			dtos.add(enrol);
		}
		// 3. when returns, dtos keep order of materials, enrolments, outstandings
		// 3-A. get materials by invoice id and add to list dtos
		for(String invoiceId : invoiceIds){
			List<MaterialDTO> materials = materialService.findMaterialByInvoice(Long.parseLong(invoiceId));
			for(MaterialDTO material : materials){
				dtos.add(material);
			}
		}
		// 3-B. add enrolments to list dtos
		// for(EnrolmentDTO enrol : enrols){
		// 	dtos.add(enrol);
		// }
		// 3-C. add outstandings to list dtos
		for(String invoiceId : invoiceIds){
			List<OutstandingDTO> stands = outstandingService.getOutstandingtByInvoice(Long.parseLong(invoiceId));
			for(OutstandingDTO stand : stands){
				dtos.add(stand);
			}
		}
		// 4. return dtos mixed by enrolments and outstandings
	//	System.out.println(dtos);
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
		System.out.println(formData);
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

	/////////////////////////////////////////////////////////
	// Enrolment
	////////////////////////////////////////////////////////
	// associate elearnings with student
	@PostMapping("/associateElearning/{studentId}")
	@ResponseBody
	public ResponseEntity<String> associateElearning(@PathVariable Long studentId, @RequestBody Long[] elearningIds) {
		// 1. get student
		Student std = studentService.getStudent(studentId);
		// 2. empty elearning list
		Set<Elearning> elearningSet = std.getElearnings();
		elearningSet.clear();
		// 3. associate elearnings
		for(Long elearningId : elearningIds) {
			Elearning elearning = elearningService.getElearning(elearningId);
			elearningSet.add(elearning);
		}
		// 4. update student
		studentService.updateStudent(std, studentId);
		// 5. return success
		return ResponseEntity.ok("eLearning Success");
	}

	// associate book with Invoice
	// @PostMapping("/associateBook/{studentId}")
	// @ResponseBody
	// public List<MaterialDTO> associateBook(@PathVariable Long studentId, @RequestBody Long[] bookIds) {
	// 	List<MaterialDTO> dtos = new ArrayList<>();
	// 	// 1. get Invoice
	// 	Invoice invo = invoiceService.getInvoiceByStudentId(studentId);
	// 	// if no invoice or no book, return empty list
	// 	if((invo==null) || (bookIds==null)) return dtos;
		
	// 	// 2. bring all registered Book - bookId & invoiceId
	// 	List<MaterialDTO> alreadys = materialService.findMaterialByInvoice(invo.getId());
	// 	// 3, store list for registered book Ids
	// 	List<Long> registeredIds = new ArrayList<Long>();
	// 	for(MaterialDTO dto : alreadys){
	// 		registeredIds.add(Long.parseLong(dto.getBookId()));
	// 	}
	// 	for(Long bookId : bookIds){
	// 		boolean isExist = false;
	// 		for(Long registeredId : registeredIds){
	// 		// 3-1. if bookId is in the list and passed parameters then skip - already exist
	// 			if(bookId == registeredId){
	// 				isExist = true;
	// 				// add book price as re-initialized by Enrolment
	// 				Book book = bookService.getBook(bookId);
	// 				// System.out.println("Before - invo.getAmout() : " + invo.getAmount());
	// 				invo.setAmount(invo.getAmount() + book.getPrice());
	// 				// System.out.println("After - invo.getAmout() : " + invo.getAmount());
	// 				// amount update for invoice
	// 				invoiceService.updateInvoice(invo, invo.getId());
	// 				registeredIds.remove(registeredId);
	// 				break;			
	// 			}	
	// 		}
	// 		if(isExist) continue; // keep outter loop
	// 		// 3-2. if bookId not in the list then add - new book
	// 		// 4-2. get Book
	// 		Book book = bookService.getBook(bookId);
	// 		// 5-2. update invoice amount

	// 		// System.out.println("Before - invo.getAmout() : " + invo.getAmount());
	// 		invo.setAmount(invo.getAmount() + book.getPrice());
	// 		// System.out.println("After - invo.getAmout() : " + invo.getAmount());
			
	// 		// 6-2. create Material
	// 		Material material = new Material();
	// 		material.setBook(book);
	// 		material.setInvoice(invo);
	// 		// 7-2. save Material
	// 		material = materialService.addMaterial(material);		
	// 	}
	// 	// 3-3. if bookId is in the list but no passed then delete - delete book
	// 	for(Long deleteId : registeredIds){
	// 		// 4-3. remove Material by bookId & invoiceId
	// 		materialService.deleteMaterial(invo.getId(), deleteId);
	// 	}
	// 	// add MaterialDTO to return list
	// 	Set<Material> materials = invo.getMaterials();
	// 	for (Material material : materials) {
	// 		dtos.add(new MaterialDTO(material));
	// 	}
	// 	return dtos;
	// }

	@PostMapping("/associateBook/{studentId}")
	@ResponseBody
	public List<MaterialDTO> associateBook(@PathVariable Long studentId, @RequestBody Long[] bookIds) {
		List<MaterialDTO> dtos = new ArrayList<>();
		// 1. get Invoice
		Invoice invo = invoiceService.getInvoiceByStudentId(studentId);
		// if no invoice or no book, return empty list
		if((invo==null) || (bookIds==null)) return dtos;
		
		// 2. bring all registered Book - bookId & invoiceId
		List<MaterialDTO> alreadys = materialService.findMaterialByInvoice(invo.getId());
		// 3, store list for registered book Ids
		List<Long> registeredIds = new ArrayList<Long>();
		for(MaterialDTO dto : alreadys){
			registeredIds.add(Long.parseLong(dto.getBookId()));
		}
		for(Long bookId : bookIds){
			boolean isExist = false;
			for(Long registeredId : registeredIds){
			// 3-1. if bookId is in the list and passed parameters then skip - already exist
				if(bookId == registeredId){
					isExist = true;
					// add book price as re-initialized by Enrolment
					Book book = bookService.getBook(bookId);
					// System.out.println("Before - invo.getAmout() : " + invo.getAmount());
					invo.setAmount(invo.getAmount() + book.getPrice());
					// System.out.println("After - invo.getAmout() : " + invo.getAmount());
					// amount update for invoice
					invoiceService.updateInvoice(invo, invo.getId());
					registeredIds.remove(registeredId);
					break;			
				}	
			}
			if(isExist) continue; // keep outter loop
			// 3-2. if bookId not in the list then add - new book
			// 4-2. get Book
			Book book = bookService.getBook(bookId);
			// 5-2. update invoice amount

			// System.out.println("Before - invo.getAmout() : " + invo.getAmount());
			invo.setAmount(invo.getAmount() + book.getPrice());
			// System.out.println("After - invo.getAmout() : " + invo.getAmount());
			
			// 6-2. create Material
			Material material = new Material();
			material.setBook(book);
			material.setInvoice(invo);
			// 7-2. save Material
			material = materialService.addMaterial(material);		
		}
		// 3-3. if bookId is in the list but no passed then delete - delete book
		for(Long deleteId : registeredIds){
			// 4-3. remove Material by bookId & invoiceId
			materialService.deleteMaterial(invo.getId(), deleteId);
		}
		// add MaterialDTO to return list
		Set<Material> materials = invo.getMaterials();
		for (Material material : materials) {
			dtos.add(new MaterialDTO(material));
		}
		return dtos;
	}

/* 
	@PostMapping("/associateClazz/{studentId}")
	@ResponseBody
	public List<EnrolmentDTO> associateClazz(@PathVariable Long studentId, @RequestBody EnrolmentDTO[] formData) {
		// 1. get student
		Student std = studentService.getStudent(studentId);
		// 2. get enrolmentIds by studentId
		List<Long> enrolmentIds = enrolmentService.findEnrolmentIdByStudentId(studentId);
		// 3. create or update Enrolment
		for(EnrolmentDTO data : formData) {
			try{
				// New Enrolment if no id comes in
				if(data.getId()==null) {
				// 4-A. associate clazz with student
				Clazz clazz = clazzService.getClazz(Long.parseLong(data.getClazzId()));
				// 5-A. create Enrolment
				Enrolment enrolment = new Enrolment();
				// 6-A. associate enrolment with clazz and student
				enrolment.setClazz(clazz);
				enrolment.setStudent(std);
				enrolment.setStartWeek(data.getStartWeek());
				enrolment.setEndWeek(data.getEndWeek());
				// 7-A. save enrolment
				enrolmentService.addEnrolment(enrolment);
				}else {	// Update Enrolment if id comes in
					// 4-B. get Enrolment
					Enrolment enrolment = data.convertToEnrolment();
					// 5-B. update Enrolment
					enrolment = enrolmentService.updateEnrolment(enrolment, enrolment.getId());
					// 6-B remove enrolmentId from enrolmentIds
					enrolmentIds.remove(enrolment.getId());
				}
			}catch(NoSuchElementException e){
				String message = "Error registering Course: " + e.getMessage();
				return null;
			}				
		}
		// 7. archive enrolments not in formData
		for(Long enrolmentId : enrolmentIds) {
			enrolmentService.archiveEnrolment(enrolmentId);
		}
		// 8. trigger Invoice
		List<EnrolmentDTO> dtos = triggerInvoice(studentId);
		// 9. return success
		return dtos;
	}
*/

	@PostMapping("/associateClazz/{studentId}")
	@ResponseBody
	public List<EnrolmentDTO> associateClazz(@PathVariable Long studentId, @RequestBody EnrolmentDTO[] formData) {
		
		List<EnrolmentDTO> dtos = new ArrayList<>();
		// check Invoice available
		boolean isInvoiceExist = false;
		// 1. get latest Invoice by studentId
		Invoice invo = invoiceService.getInvoiceByStudentId(studentId);
		// 2. check whether Invoice is already created and still available
		if((invo!=null) && (invo.getAmount() > invo.getPaidAmount())){
			isInvoiceExist = true;
		}
		// get Student to associate to Enrolment later
		Student student = studentService.getStudent(studentId);
		// if no Invoice or Invoice is already paid, create new Invoice; otherwise use existing Invoice
		Invoice invoice = (isInvoiceExist) ? invo : invoiceService.addInvoice(new Invoice());

		for(EnrolmentDTO data : formData){
			// if Invoice is already created and still available, use it
			if(isInvoiceExist){
				// check class already belong to Invoice
				List<EnrolmentDTO> enrols = enrolmentService.findEnrolmentByClazzAndInvoice(Long.parseLong(StringUtils.defaultString(data.getClazzId(), "0")), invoice.getId());
				// if class already belong to Invoice, update Enrolment
				
				/* 
				if((enrols!=null) && (enrols.size()>0)){
					// 1. get Enrolment
					Enrolment enrolment = enrolmentService.getEnrolment(Long.parseLong(enrols.get(0).getId()));
					// 2. assign start-week, end-week, amount, credit, discount
					enrolment.setStartWeek(data.getStartWeek());
					enrolment.setEndWeek(data.getEndWeek());
					double cred = data.getCredit();
					// enrolment.setCredit(cred);
					double disc = data.getDiscount();
					// enrolment.setDiscount(disc);
					// double amount = data.getAmount();
					// if amount is changed, update Invoice amount
					// if(amount!=enrolment.getAmount()){
					// 	invoice.setAmount(invoice.getAmount() + (amount - enrolment.getAmount()));
					// 	invoiceService.updateInvoice(invoice, invoice.getId());
					// }
					// 3. update Enrolment
					enrolment = enrolmentService.updateEnrolment(enrolment, enrolment.getId());
					// 4. put into List<EnrolmentDTO> after adding price,grade,name,year - no need to get from DB
					EnrolmentDTO dto = new EnrolmentDTO(enrolment);
					dto.setPrice(data.getPrice());
					dto.setGrade(data.getGrade());
					dto.setName(data.getName());
					dto.setYear(data.getYear());
					dtos.add(dto);
				*/




				// if class not belong to Invoice, create new Enrolment

				









			}else{ // if no Invoice or Invoice is already paid, create new Invoice		
				// 1. create new Enrolment
				Clazz clazz = clazzService.getClazz(Long.parseLong(data.getClazzId()));
				// 2. associate new Enrolment with Clazz,Student,Invoice
				Enrolment enrolment = new Enrolment();
				enrolment.setStartWeek(data.getStartWeek());
				enrolment.setEndWeek(data.getEndWeek());
				enrolment.setClazz(clazz);
				enrolment.setStudent(student);
				enrolment.setInvoice(invoice);
				// 3. save new Enrolment
				enrolmentService.addEnrolment(enrolment);
				// 4.  put into List<EnrolmentDTO> after adding price,grade,name,year - no need to get from DB
				EnrolmentDTO dto = new EnrolmentDTO(enrolment);
				dto.setPrice(data.getPrice());
				dto.setGrade(data.getGrade());
				dto.setName(data.getName());
				dto.setYear(data.getYear());
				dtos.add(dto);
				// 5. update Invoice amount
				double enrolmentPrice = (data.getEndWeek()-data.getStartWeek()+1)*data.getPrice();
				invoice.setAmount(invoice.getAmount() + enrolmentPrice);
				invoiceService.updateInvoice(invoice, invoice.getId());
			}
		}
		
		return dtos;
		
		// // 1. get student
		// Student std = studentService.getStudent(studentId);
		// // 2. get enrolmentIds by studentId
		// List<Long> enrolmentIds = enrolmentService.findEnrolmentIdByStudentId(studentId);
		// // 3. create or update Enrolment
		// for(EnrolmentDTO data : formData) {
		// 	try{
		// 		// New Enrolment if no id comes in
		// 		if(data.getId()==null) {
		// 		// 4-A. associate clazz with student
		// 		Clazz clazz = clazzService.getClazz(Long.parseLong(data.getClazzId()));
		// 		// 5-A. create Enrolment
		// 		Enrolment enrolment = new Enrolment();
		// 		// 6-A. associate enrolment with clazz and student
		// 		enrolment.setClazz(clazz);
		// 		enrolment.setStudent(std);
		// 		enrolment.setStartWeek(data.getStartWeek());
		// 		enrolment.setEndWeek(data.getEndWeek());
		// 		// 7-A. save enrolment
		// 		enrolmentService.addEnrolment(enrolment);
		// 		}else {	// Update Enrolment if id comes in
		// 			// 4-B. get Enrolment
		// 			Enrolment enrolment = data.convertToEnrolment();
		// 			// 5-B. update Enrolment
		// 			enrolment = enrolmentService.updateEnrolment(enrolment, enrolment.getId());
		// 			// 6-B remove enrolmentId from enrolmentIds
		// 			enrolmentIds.remove(enrolment.getId());
		// 		}
		// 	}catch(NoSuchElementException e){
		// 		String message = "Error registering Course: " + e.getMessage();
		// 		return null;
		// 	}				
		// }
		// // 7. archive enrolments not in formData
		// for(Long enrolmentId : enrolmentIds) {
		// 	enrolmentService.archiveEnrolment(enrolmentId);
		// }
		// // 8. trigger Invoice
		// List<EnrolmentDTO> dtos = triggerInvoice(studentId);
		// // 9. return success
		// return dtos;




	}











		// as soon as Enrolment created or updated, it will trigger invoice
	private List<EnrolmentDTO> triggerInvoice(Long studentId){
		// 1. get latest Enrolment
		List<EnrolmentDTO> dtos = enrolmentService.findEnrolmentByStudent(studentId);
		
		// 2. create Invoice
		InvoiceDTO invoiceDTO = checkInvoice(studentId, dtos);

		// 3. assign invoice id to enrolment
		for(EnrolmentDTO data : dtos){
			data.setInvoiceId(invoiceDTO.getId());
			data.setAmount(invoiceDTO.getAmount());
		}
		return dtos;
	}


	// copy from InvoiceController
	public InvoiceDTO checkInvoice(Long studentId, List<EnrolmentDTO> formData){

		Long invoId = invoiceService.getInvoiceIdByStudentId(studentId);
		///////////////////////////////////////////////////////
		// if no data comes, it means no enrolment in invoice
		///////////////////////////////////////////////////////
		if((formData==null) || (formData.size()==0)) {
			// 1. get Enrolment by invoice Id
			// for(Long invoId : invoiceIds){
				if(invoId!=null){
					// 2. get enrolment Id by invoice Id
					List<Long> enrolmentIds = enrolmentService.findEnrolmentIdByInvoiceId(invoId);
					for(Long data : enrolmentIds) {
						// 3. archive Enrolment
						enrolmentService.archiveEnrolment(data);
					}
				}
			// }
			return null;
		}

		// 1. check whether Enrolment is already invoiced
		double total = 0;
		double credit = 0;
		double discount = 0;
		boolean alreadyInvoiced = false;
		long invoiceId = 0;
		// any null included, it should re-issue invoice
		alreadyInvoiced = (invoId==null) ? false : true;
		if(alreadyInvoiced){ // if already invoiced, get first invoice id
			// for(Long invoId : invoiceIds){
			// 	if(invoId!=null){
			 		invoiceId = invoId;
			// 		break;
			// 	}
			// }
			// 2. find Invoice if Enrolment is invoiced
			Invoice invoice = invoiceService.getInvoice(invoiceId);

			// update Invoice in case of any change from client

			for(EnrolmentDTO data : formData) {
				// 4. get Enrolment
				Enrolment enrolment = enrolmentService.getEnrolment(Long.parseLong(data.getId()));
				// 5. assign start-week, end-week, amount, credit, discount
				enrolment.setStartWeek(data.getStartWeek());
				enrolment.setEndWeek(data.getEndWeek());
				double cred = data.getCredit();
				// enrolment.setCredit(cred);
				double disc = data.getDiscount();
				// enrolment.setDiscount(disc);
				// double amount = data.getAmount();
				double amount = (data.getEndWeek()-data.getStartWeek()+1)*data.getPrice();
				
				// enrolment.setAmount(amount);
				// 6. sum total amount
				credit += cred;
				discount += disc;
				total += amount;
				// 7. add Enrolments to Invoice
				invoice.addEnrolment(enrolment);
			}
			// 8. update total
			invoice.setCredit(credit);
			invoice.setDiscount(discount);
			invoice.setAmount(total);
			// 9. update Invoice
			InvoiceDTO dto = invoiceService.updateInvoice(invoice, invoiceId);
			// return dto
			return dto;
		}else{

			// 3. create new invoice when no Invoice is found
			Invoice invoice = new Invoice();
			for(EnrolmentDTO data : formData) {
				// 4. get Enrolment
				Enrolment enrolment = enrolmentService.getEnrolment(Long.parseLong(data.getId()));
				// 5. assign start-week, end-week, amount, credit, discount
				enrolment.setStartWeek(data.getStartWeek());
				enrolment.setEndWeek(data.getEndWeek());
				double cred = data.getCredit();
				// enrolment.setCredit(cred);
				double disc = data.getDiscount();
				// enrolment.setDiscount(disc);
				double amount = (data.getAmount()==0) ? data.getPrice() * (data.getEndWeek() - data.getStartWeek() + 1) : data.getAmount();
				//double amount = data.getAmount();
				// enrolment.setAmount(amount);
				// 6. sum total amount
				credit += cred;
				discount += disc;
				total += amount;
				// 7. add Enrolments to Invoice
				invoice.addEnrolment(enrolment);
			}
			// 8. update total
			invoice.setCredit(credit);
			invoice.setDiscount(discount);
			invoice.setAmount(total);
			// 9. create Invoice
			InvoiceDTO dto = null;//invoiceService.addInvoice(invoice);
			// 10. return flag;
			return dto;
		}
	}

}
