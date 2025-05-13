package hyung.jin.seo.jae.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.EnrolmentMigrateDTO;
import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.dto.MaterialMigrateDTO;
import hyung.jin.seo.jae.dto.MigrateDTO;
import hyung.jin.seo.jae.dto.PaymentMigrateDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.model.Invoice;
import hyung.jin.seo.jae.model.InvoiceHistory;
import hyung.jin.seo.jae.model.Material;
import hyung.jin.seo.jae.model.Payment;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.InvoiceHistoryService;
import hyung.jin.seo.jae.service.InvoiceService;
import hyung.jin.seo.jae.service.MaterialService;
import hyung.jin.seo.jae.service.PaymentService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("migration")
public class MigrationController {

	@Autowired
	private StudentService studentService;

	@Autowired
	private InvoiceService invoiceService;

	@Autowired
	private InvoiceHistoryService invoiceHistoryService;

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private PaymentService paymentService;

	@Autowired
	private MaterialService materialService;

	// Make the class public static and add proper getters/setters
	public static class MigrationError {
		private String studentId;
		private int lineNumber;
		private String errorMessage;
		private String fieldName;

		public MigrationError(String studentId, int lineNumber, String errorMessage, String fieldName) {
			this.studentId = studentId;
			this.lineNumber = lineNumber;
			this.errorMessage = errorMessage;
			this.fieldName = fieldName;
		}

		// Add proper getters following JavaBean convention
		public String getStudentId() { 
			return studentId; 
		}

		public int getLineNumber() { 
			return lineNumber; 
		}

		public String getErrorMessage() { 
			return errorMessage; 
		}

		public String getFieldName() { 
			return fieldName; 
		}

		// Add setters in case needed
		public void setStudentId(String studentId) {
			this.studentId = studentId;
		}

		public void setLineNumber(int lineNumber) {
			this.lineNumber = lineNumber;
		}

		public void setErrorMessage(String errorMessage) {
			this.errorMessage = errorMessage;
		}

		public void setFieldName(String fieldName) {
			this.fieldName = fieldName;
		}
	}

	// migrate student
	@RequestMapping(value = "/student", method = {RequestMethod.POST})
	public String migrateStudents(@RequestParam(value = "file", required = false) MultipartFile file, Model model) {
		// 1. validate uploaded file	
		if (file != null && !file.isEmpty()) {
			String originalFilename = file.getOriginalFilename();
			if (originalFilename != null) {
				String fileExtension = originalFilename.substring(originalFilename.lastIndexOf(".") + 1);
				if (!"csv".equalsIgnoreCase(fileExtension)) {
					model.addAttribute(JaeConstants.ERROR, "Invalid file format. Please upload a CSV file.");
					return "migrationStudentPage";
				}
			} else {
				model.addAttribute(JaeConstants.ERROR, "File name not found. Please try again.");
				return "migrationStudentPage";
			}
		} else {
			model.addAttribute(JaeConstants.ERROR, "No file uploaded. Please select a file to upload.");
			return "migrationStudentPage";
		}
		
		// 2. process student migration
		List<StudentDTO> dtos = new ArrayList<StudentDTO>();
		List<MigrationError> failedRecords = new ArrayList<>(); // Changed to use MigrationError class
		int lineCount = 0;
		DateTimeFormatter[] dateFormatters = new DateTimeFormatter[] {
			DateTimeFormatter.ofPattern("yyyy-MM-dd"),
			DateTimeFormatter.ofPattern("dd/MM/yyyy"),
			DateTimeFormatter.ofPattern("MM/dd/yyyy")
		};
		
		try {
			// Create a CSVReader with proper handling of quoted fields
			CSVReader reader = new CSVReaderBuilder(new InputStreamReader(file.getInputStream()))
				.withSkipLines(1) // Skip header
				.build();
			
			String[] columns;
			while ((columns = reader.readNext()) != null) {
				lineCount++;
				String oldStudentId = ""; // Store original ID for error reporting
				
				try {
					// Transform the Student_ID from MS SQL format to MySQL format
					oldStudentId = columns[0].trim(); // Assuming Student_ID is the first column
					String newStudentId = transformStudentId(oldStudentId);
					
					// Create Student with transformed ID
					Student std = new Student();
					std.setId(Long.parseLong(newStudentId));
					
					// Map other fields from CSV with validation
					try {
						if(StringUtils.isNotBlank(columns[5])) std.setFirstName(columns[5].trim());
						if(StringUtils.isNotBlank(columns[6])) std.setLastName(columns[6].trim());
					} catch (Exception e) {
						throw new Exception("Error in name fields: " + e.getMessage());
					}
					
					// Set default password
					String password = JaeConstants.DEFAULT_PASSWORD;
					BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
					String encodedPassword = passwordEncoder.encode(password);
					std.setPassword(encodedPassword);
					
					try {
						// Map grade with transformation
						String originalGrade = StringUtils.isNotBlank(columns[8]) ? columns[8].trim() : "";
						std.setGrade(mapGrade(originalGrade));
					} catch (Exception e) {
						throw new Exception("Error in grade field: " + e.getMessage());
					}
					
					try {
						if(StringUtils.isNotBlank(columns[11])) std.setBranch(columns[11].trim());
					} catch (Exception e) {
						throw new Exception("Error in branch field: " + e.getMessage());
					}
					
					try {
						// Parse dates
						if(StringUtils.isNotBlank(columns[12])) {
							LocalDate registerDate = parseDate(columns[12].trim(), dateFormatters);
							if(registerDate != null) {
								std.setRegisterDate(registerDate);
							}
						}
						if(StringUtils.isNotBlank(columns[13])) {
							LocalDate endDate = parseDate(columns[13].trim(), dateFormatters);
							if(endDate != null) {
								std.setEndDate(endDate);
							}
						}
					} catch (Exception e) {
						throw new Exception("Error in date fields: " + e.getMessage());
					}
					
					// Set active status
					if(StringUtils.isEmpty(columns[13])) {
						std.setActive(1); // active
					} else {
						std.setActive(0); // inactive
					}
					
					try {
						// Handle email addresses
						String originalEmail = StringUtils.isNotBlank(columns[15]) ? columns[15].trim() : "";
						List<String> splitEmails = splitEmailAddresses(originalEmail);
						std.setEmail1(splitEmails.get(0));
						if(splitEmails.size() > 1) std.setEmail2(splitEmails.get(1));
					} catch (Exception e) {
						throw new Exception("Error in email fields: " + e.getMessage());
					}
					
					try {
						// Map contact numbers
						if(StringUtils.isNotBlank(columns[16])) std.setContactNo1(columns[16].trim());
						if(StringUtils.isNotBlank(columns[17])) std.setContactNo2(columns[17].trim());
					} catch (Exception e) {
						throw new Exception("Error in contact number fields: " + e.getMessage());
					}
					
					try {
						// Handle address
						if(StringUtils.isNotBlank(columns[18])) {
							String fullAddress = columns[18].trim();
							// System.out.println("Setting address: " + fullAddress);
							std.setAddress(fullAddress);
						}
					} catch (Exception e) {
						throw new Exception("Error in address field: " + e.getMessage());
					}
					
					try {
						if(StringUtils.isNotBlank(columns[19])) std.setMemo(columns[19].trim());
					} catch (Exception e) {
						throw new Exception("Error in memo field: " + e.getMessage());
					}
					
					// Set default state
					std.setState(JaeConstants.VICTORIA_CODE);
					
					// register Student	
					try {
						std = studentService.addStudentMigration(std);
						dtos.add(new StudentDTO(std));
					} catch (Exception e) {
						String errorMsg = e.getMessage();
						if (errorMsg.contains("Duplicate entry") && errorMsg.contains("PRIMARY")) {
							errorMsg = "Student ID " + std.getId() + " already exists in the database";
							failedRecords.add(new MigrationError(oldStudentId, lineCount, errorMsg, "Student ID (Duplicate)"));
						} else {
							failedRecords.add(new MigrationError(oldStudentId, lineCount, "Database error: " + errorMsg, "Database"));
						}
						continue;
					}
				} catch (Exception e) {
					// Add detailed error information
					String errorField = "Unknown";
					String errorMsg = e.getMessage();
					
					// Determine which field caused the error
					if (errorMsg.contains("name")) errorField = "Name";
					else if (errorMsg.contains("grade")) errorField = "Grade";
					else if (errorMsg.contains("date")) errorField = "Date";
					else if (errorMsg.contains("email")) errorField = "Email";
					else if (errorMsg.contains("address")) errorField = "Address";
					else if (errorMsg.contains("contact")) errorField = "Contact";
					else if (errorMsg.contains("PRIMARY") || errorMsg.contains("Duplicate entry")) errorField = "Student ID (Duplicate)";
					
					failedRecords.add(new MigrationError(oldStudentId, lineCount, errorMsg, errorField));
					continue;
				}
			}
			reader.close();

			// Add migration results to the model
			model.addAttribute("totalProcessed", lineCount);
			model.addAttribute("successCount", dtos.size());
			model.addAttribute("failureCount", failedRecords.size());
			model.addAttribute("failedRecords", failedRecords);
			if (failedRecords.size() > 0) {
				model.addAttribute("migrationErrors", "true");
			}

		} catch (Exception e) {
			e.printStackTrace();
			model.addAttribute(JaeConstants.ERROR, "Error processing file: " + e.getMessage());
			return "migrationStudentPage";
		}
		
		model.addAttribute(JaeConstants.BATCH_LIST, dtos);
		return "migrationStudentPage";
	}

	/**
	 * Transforms the student ID from MS SQL format to MySQL format
	 * Examples: 
	 * 182857 -> 11802857 (1 + 18 + 02857)
	 * 220883 -> 12200883 (1 + 22 + 00883)
	 * 350228 -> 13500228 (1 + 35 + 00228)
	 */
	private String transformStudentId(String oldId) {
		if (oldId == null || oldId.length() < 2) {
			throw new IllegalArgumentException("Invalid student ID format");
		}
		
		// Extract the first two digits (branch code)
		String branchPart = oldId.substring(0, 2);
		// Extract the remaining digits
		String remainingPart = oldId.substring(2);
		
		// Add '0' to the remaining part to make it 4 digits
		// remainingPart = "0" + remainingPart;
			// Pad the remaining part with zeros to make it 5 digits
			remainingPart = String.format("%05d", Integer.parseInt(remainingPart));
	
		// Construct the new ID: 1 + branch + padded remaining digits
		return "1" + branchPart + remainingPart;
	}

	/**
	 * Try parsing a date string with multiple formats
	 * Also handles special format like '6052025' -> '2025-05-06'
	 */
	private LocalDate parseDate(String dateStr, DateTimeFormatter[] formatters) {
		if (dateStr == null || dateStr.trim().isEmpty()) {
			return null;
		}

		// First try to parse special format like '6052025'
		if (dateStr.matches("\\d{7}") || dateStr.matches("\\d{8}")) {
			try {
				// Add '0' at the beginning to make it 8 digits if length is 7
				if (dateStr.length() == 7) {
					dateStr = "0" + dateStr;
				}

				// Extract day (positions 0-1)
				String day = dateStr.substring(0, 2);
				
				// Extract month (positions 2-3)
				String month = dateStr.substring(2, 4);
				
				// Extract year (positions 4-8)
				String year = dateStr.substring(4);
				
				// Construct date string in yyyy-MM-dd format
				String formattedDate = year + "-" + month + "-" + day;
				return LocalDate.parse(formattedDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
			} catch (Exception e) {
				System.err.println("Error parsing special date format: " + dateStr + " - " + e.getMessage());
			}
		}

		// Try standard formatters if special format fails
		for (DateTimeFormatter formatter : formatters) {
			try {
				return LocalDate.parse(dateStr, formatter);
			} catch (DateTimeParseException e) {
				continue;
			}
		}
		
		System.err.println("Failed to parse date: " + dateStr);
		return null;
	}

	// split email addresses by comma or semicolon
	private List<String> splitEmailAddresses(String emailAddresses) {
		List<String> emailList = new ArrayList<>();
		if (StringUtils.isNotBlank(emailAddresses)) {
			String[] emails = emailAddresses.split("[,;]");
			for (String email : emails) {
				emailList.add(email.trim());
			}
		}
		if (emailList.isEmpty()) {
			emailList.add(""); // Add empty string as default
		}
		return emailList;
	}

	// map grade from MS SQL format to MySQL format
	private String mapGrade(String grade) {
		switch(grade) {
			case "2": // P2
				return "1";
			case "3": // P3
				return "2";
			case "4": // P4
				return "3";
			case "5": // P5
				return "4";
			case "6": // P6
				return "5";
			case "7": // S7
				return "6";
			case "8": // S8
				return "7";
			case "9": // S9
				return "8";
			case "10": // S10
				return "9";
			case "108": // S10E
				return "10";
			case "66": // TT6
				return "11";
			case "88": // TT8
				return "12";
			case "107": // TT8E
				return "13";
			case "104": // SRW4
				return "14";
			case "105": // SRW5
				return "15";
			case "102": // SRW6
				return "16";
			case "103": // SRW8
				return "18";
			case "99": // JMSS
				return "19";
			case "100": // VCE
				return "20";
			default:
				return "1";					
		}		
	}
	@SuppressWarnings("null")
	@RequestMapping(value = "/invoice", method = {RequestMethod.POST})
	public String migrateInvoice(
			@RequestParam(value = "file", required = false) MultipartFile file, 
			Model model) {
		if (file == null || file.isEmpty()) {
			model.addAttribute(JaeConstants.ERROR, "No file uploaded. Please select a file to upload.");
			return "migrationInvoicePage";
		}
		String originalFilename = file.getOriginalFilename();
		if (originalFilename == null || !originalFilename.endsWith(".csv")) {
			model.addAttribute(JaeConstants.ERROR, "Invalid file format. Please upload a CSV file.");
			return "migrationInvoicePage";
		}
	
		List<InvoiceDTO> dtos = new ArrayList<>();
		List<MigrationError> failedRecords = new ArrayList<>();
		int lineCount = 0;
		int successCount = 0;
		int failureCount = 0;
		DateTimeFormatter[] dateFormatters = new DateTimeFormatter[] {
			DateTimeFormatter.ofPattern("yyyy-MM-dd"),
			DateTimeFormatter.ofPattern("dd/MM/yyyy"),
			DateTimeFormatter.ofPattern("MM/dd/yyyy")
		};
	
		try (CSVReader reader = new CSVReaderBuilder(new InputStreamReader(file.getInputStream()))
				.withSkipLines(1).build()) {
			String[] columns;
			
			// Process in smaller batches and log progress
			int batchSize = 50;
			int currentBatch = 0;
			
			while ((columns = reader.readNext()) != null) {
				lineCount++;
				try {
					boolean isNew = false;
					// 1. Invoice
					// check if invoice exists
					Invoice exisInvoice = invoiceService.getInvoice(Long.parseLong(columns[0].trim()));
					if (exisInvoice == null) {
						isNew = true;
					}
					// Map columns to Invoice fields
					Invoice invoice = isNew ? new Invoice() : exisInvoice;
					if(isNew) invoice.setId(Long.parseLong(columns[0].trim()));
					double amount = parseDouble(columns[9]);
					invoice.setAmount(amount);
					invoice.setDiscount(parseDouble(columns[11]));
					invoice.setInfo(columns[13].trim());
					double paidAmount = parseDouble(columns[7]);
					invoice.setPaidAmount(isNew ? paidAmount : invoice.getPaidAmount()+paidAmount);					
					if (columns[5].matches("\\d{8}")) {
						invoice.setPaymentDate(parseYYYYMMDDDateFormat(columns[5]));
						invoice.setRegisterDate(parseYYYYMMDDDateFormat(columns[5]));	
					} else {
						invoice.setPaymentDate(parseDate(columns[5], dateFormatters));
						invoice.setRegisterDate(parseDate(columns[5], dateFormatters));
					}					
					
					
					// 1. Create/Update Invoice
					if(isNew){
						invoiceService.addInvoiceMigration(invoice);
					}else{
						invoiceService.updateInvoice(invoice, invoice.getId());
					} 
					dtos.add(new InvoiceDTO(invoice));
					// 2. Create InvoiceHistory	
					InvoiceHistory history = new InvoiceHistory();
					history.setPaidAmount(paidAmount);
					history.setAmount(amount);
					history.setInvoice(invoice);					
					invoiceHistoryService.addInvoiceHistory(history);
					// 3. Create Payment
					Payment paid = null;
					if(paidAmount > 0){
						paid = new Payment();
						paid.setTotal(amount);
						paid.setAmount(paidAmount);
						paid.setMethod(getMigratePaymentMethod(columns[6].trim()));
						paid.setRegisterDate(parseYYYYMMDDDateFormat(columns[5]));
						paid.setInvoice(invoice);
						paid.setInvoiceHistory(history);
						paymentService.addPayment(paid);
					}
					// 4. Enrolment
					Enrolment enrolment = new Enrolment();
					String studentId = columns[1].trim();
					Student student = studentService.getStudent(Long.parseLong(transformStudentId(studentId)));
					enrolment.setStudent(student);
					enrolment.setInvoice(invoice);
					enrolment.setInvoiceHistory(history);
					enrolmentService.addEnrolment(enrolment);
					successCount++;					

				} catch (Exception e) {
					failureCount++;
					String invoiceId = columns.length > 0 ? columns[0] : "Unknown";
					String errorMsg = e.getMessage();
					
					// Output the failure directly to the console
					System.out.println("MIGRATION FAILURE - Invoice ID: " + invoiceId + 
					                   " at line " + lineCount + " - Reason: " + errorMsg);
					
					failedRecords.add(new MigrationError(
						invoiceId,
						lineCount,
						errorMsg,
						"Invoice"
					));
				}
				
				// Print progress info every batch
				if (lineCount % batchSize == 0) {
					currentBatch++;
					System.out.println("Processed batch " + currentBatch + 
					                   " (" + lineCount + " records, " + 
					                   successCount + " successful, " + 
					                   failureCount + " failed)");
				}
			}
		} catch (Exception e) {
			model.addAttribute(JaeConstants.ERROR, "Error processing file: " + e.getMessage());
			return "migrationInvoicePage";
		}
	
		model.addAttribute("totalProcessed", lineCount);
		model.addAttribute("successCount", successCount);
		model.addAttribute("failureCount", failureCount);
		model.addAttribute("failedRecords", failedRecords);
		if (!failedRecords.isEmpty()) {
			model.addAttribute("migrationErrors", "true");
		}
		model.addAttribute(JaeConstants.BATCH_LIST, dtos);
		return "migrationInvoicePage";
	}
	
	// Helper methods
	private Double parseDouble(String s) {
		try { return StringUtils.isNotBlank(s) ? Double.parseDouble(s.trim()) : null; }
		catch (Exception e) { return null; }
	}
	private Integer parseInt(String s) {
		try { return StringUtils.isNotBlank(s) ? Integer.parseInt(s.trim()) : null; }
		catch (Exception e) { return null; }
	}


	@RequestMapping(value = "/enrol", method = {RequestMethod.POST})
	public String migrateEnrolment(
			@RequestParam(value = "file", required = false) MultipartFile file, 
			Model model) {
		if (file == null || file.isEmpty()) {
			model.addAttribute(JaeConstants.ERROR, "No file uploaded. Please select a file to upload.");
			return "migrationInvoicePage";
		}
		String originalFilename = file.getOriginalFilename();
		if (originalFilename == null || !originalFilename.endsWith(".csv")) {
			model.addAttribute(JaeConstants.ERROR, "Invalid file format. Please upload a CSV file.");
			return "migrationInvoicePage";
		}
	
		List<MigrateDTO> dtos = new ArrayList<>();
		List<MigrationError> failedRecords = new ArrayList<>();
		int lineCount = 0;
		int successCount = 0;
		int failureCount = 0;
		DateTimeFormatter[] dateFormatters = new DateTimeFormatter[] {
			DateTimeFormatter.ofPattern("yyyy-MM-dd"),
			DateTimeFormatter.ofPattern("dd/MM/yyyy"),
			DateTimeFormatter.ofPattern("MM/dd/yyyy")
		};
	
		try (CSVReader reader = new CSVReaderBuilder(new InputStreamReader(file.getInputStream()))
				.withSkipLines(1).build()) {
			String[] columns;
			
			// Process in smaller batches and log progress
			int batchSize = 50;
			int currentBatch = 0;
			
			while ((columns = reader.readNext()) != null) {
				lineCount++;
				try {
					// 1. check it is a valid enrolment
					String type = columns[13].trim(); // if 10 = Enrolment, 20 = Material, 30 = Outstanding 
					Long studentId = Long.parseLong(transformStudentId(columns[1].trim()));
					Long invoiceId = Long.parseLong(columns[9].trim());
					List<Enrolment> enrolments = enrolmentService.findEnrolmentMigrationByInvoiceAndStudent(invoiceId, studentId);
					if (enrolments != null && enrolments.size() > 0) {
						for(Enrolment enrolment : enrolments){
							Long invoiceHistoryId = enrolment.getInvoiceHistory().getId();
							double price = Double.parseDouble(columns[16].trim());
							String name = columns[15].trim();			
												
							switch(type){
								case "10": // Enrolment
									EnrolmentMigrateDTO enrolmentMigrateDTO = new EnrolmentMigrateDTO();
									int year = Integer.parseInt(columns[4].trim());
									int startWeek = Integer.parseInt(columns[5].trim());
									int endWeek = Integer.parseInt(columns[6].trim());
									int credit = Integer.parseInt(columns[7].trim());
									double discount = Double.parseDouble(columns[20].trim());
									double total = Double.parseDouble(columns[18].trim());
									enrolmentMigrateDTO.setYear(year);
									enrolmentMigrateDTO.setStartWeek(startWeek);
									enrolmentMigrateDTO.setEndWeek(endWeek);
									enrolmentMigrateDTO.setCredit(credit);
									enrolmentMigrateDTO.setDiscount(discount);
									enrolmentMigrateDTO.setPrice(price);
									enrolmentMigrateDTO.setTotal(total);
									enrolmentMigrateDTO.setName(name);
									enrolmentMigrateDTO.setStudentId(studentId);
									enrolmentMigrateDTO.setInvoiceId(invoiceId);
									enrolmentMigrateDTO.setInvoiceHistoryId(invoiceHistoryId);
									// 3. Update enrolment
									enrolment.setStartWeek(startWeek);
									enrolment.setEndWeek(endWeek);
									enrolment.setCredit(credit);
									enrolment.setDiscount(discount+"");
									enrolment.setCancellationReason(enrolmentMigrateDTO.toString());
									enrolmentService.updateEnrolment(enrolment, enrolment.getId());		
									// 4. add enrolment to dtos
									dtos.add(enrolmentMigrateDTO);
									break;
								case "20": // Material
									MaterialMigrateDTO materialMigrateDTO = new MaterialMigrateDTO();
									int quantity = Integer.parseInt(columns[17].trim());
									materialMigrateDTO.setPrice(price);
									materialMigrateDTO.setQuantity(quantity);
									materialMigrateDTO.setName(name);
									materialMigrateDTO.setStudentId(studentId);
									materialMigrateDTO.setInvoiceId(invoiceId);
									materialMigrateDTO.setInvoiceHistoryId(invoiceHistoryId);
									// Create Material
									Material material = new Material();
									LocalDate paymentDate = parseYYYYMMDDDateFormat(columns[10].trim());									
									material.setPaymentDate(paymentDate);
									material.setRegisterDate(paymentDate);
									Invoice invoice = invoiceService.getInvoice(invoiceId);
									material.setInvoice(invoice);
									InvoiceHistory invoiceHistory = invoiceHistoryService.getInvoiceHistory(invoiceHistoryId);
									material.setInvoiceHistory(invoiceHistory);
									material.setInfo(materialMigrateDTO.toString());
									materialService.addMaterial(material);
									// add material to dtos
									dtos.add(materialMigrateDTO);
									break;
								case "30": // Outstanding









									break;


								case "40": // Outstanding
									double paidAmount = Double.parseDouble(columns[22].trim());
									PaymentMigrateDTO paymentMigrateDTO = new PaymentMigrateDTO();
									paymentMigrateDTO.setPaidAmount(paidAmount);
									paymentMigrateDTO.setStudentId(studentId);
									paymentMigrateDTO.setInvoiceId(invoiceId);
									paymentMigrateDTO.setInvoiceHistoryId(invoiceHistoryId);
									// get existing payment to get total amount & method
									String paymentMethod = paymentService.methodOldestPaymentByInvoiceIdAndInvoiceHistoryId(invoiceId, invoiceHistoryId);
									double totalAmount = paymentService.totalAmountLatestPaymentByInvoiceIdAndInvoiceHistoryId(invoiceId, invoiceHistoryId);
									// Create Payment
									Payment paid = new Payment();
									paid.setTotal(totalAmount);
									paid.setAmount(paidAmount);
									paid.setMethod(paymentMethod);
									paid.setRegisterDate(parseYYYYMMDDDateFormat(columns[10].trim()));
									Invoice existingInvoice = invoiceService.getInvoice(invoiceId);
									paid.setInvoice(existingInvoice);
									InvoiceHistory existingInvoiceHistory = invoiceHistoryService.getInvoiceHistory(invoiceHistoryId);
									paid.setInvoiceHistory(existingInvoiceHistory);
									paymentService.addPayment(paid);
									// add payment to dtos
									dtos.add(paymentMigrateDTO);
									break;
							}
						}

					}












					successCount++;					

				} catch (Exception e) {
					failureCount++;
					String enrolmentId = columns.length > 0 ? columns[0] : "Unknown";
					String errorMsg = e.getMessage();
					
					// Output the failure directly to the console
					System.out.println("MIGRATION FAILURE - Enrolment ID: " + enrolmentId + 
					                   " at line " + lineCount + " - Reason: " + errorMsg);
					
					failedRecords.add(new MigrationError(
						enrolmentId,
						lineCount,
						errorMsg,
						"Invoice"
					));
				}
				
				// Print progress info every batch
				if (lineCount % batchSize == 0) {
					currentBatch++;
					System.out.println("Processed batch " + currentBatch + 
					                   " (" + lineCount + " records, " + 
					                   successCount + " successful, " + 
					                   failureCount + " failed)");
				}
			}
				
		} catch (Exception e) {
			model.addAttribute(JaeConstants.ERROR, "Error processing file: " + e.getMessage());
			return "migrationEnrolPage";
		}
	
		model.addAttribute("totalProcessed", lineCount);
		model.addAttribute("successCount", successCount);
		model.addAttribute("failureCount", failureCount);
		model.addAttribute("failedRecords", failedRecords);
		if (!failedRecords.isEmpty()) {
			model.addAttribute("migrationErrors", "true");
		}
		model.addAttribute(JaeConstants.BATCH_LIST, dtos);
		return "migrationEnrolPage";
	}
	
	private LocalDate parseYYYYMMDDDateFormat(String dateStr) {
		if (dateStr == null || !dateStr.matches("\\d{8}")) {
			throw new IllegalArgumentException("Invalid date format");
		}
		String year = dateStr.substring(0, 4);
		String month = dateStr.substring(4, 6);
		String day = dateStr.substring(6, 8);
		return LocalDate.of(Integer.parseInt(year), Integer.parseInt(month), Integer.parseInt(day));
	}

	// get value from migrateDTOString
	private String getValueFromMigrateDTOString(String dtoString, String key) {
		if (dtoString == null || dtoString.isEmpty() || key == null || key.isEmpty()) {
			return "";
		}
		String[] keyValuePairs = dtoString.split(",");
		for (String pair : keyValuePairs) {
			String[] keyValue = pair.split("=");
			if (keyValue.length == 2 && keyValue[0].trim().equals(key)) {
				return keyValue[1].trim();
			}
		}
		return "";
	}

	// get migrate payment method
	private String getMigratePaymentMethod(String method) {
		String paymentMethod = "";
		switch(method) {
			case "1": paymentMethod = "cash"; break;
			case "2": paymentMethod = "bank"; break;
			case "3": paymentMethod = "card"; break;
			case "4": paymentMethod = "cheque"; break;
		}
		return paymentMethod;
	}

}
