package hyung.jin.seo.jae.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("batch")
public class BatchController {

	@Autowired
	private StudentService studentService;

	@Value("${inactive.student.enrolment.days}")
	private int days;

	// migrate student
	@RequestMapping(value = "/upload", method = {RequestMethod.POST})
	public String migrateStudents(@RequestParam(value = "file", required = false) MultipartFile file, Model model) {
			// 1. validate uploaded file	
			if (file != null && !file.isEmpty()) {
	            String originalFilename = file.getOriginalFilename();
	            if (originalFilename != null) {
	                String fileExtension = originalFilename.substring(originalFilename.lastIndexOf(".") + 1);
	                if ("csv".equalsIgnoreCase(fileExtension)) {
	                    // File extension is CSV, proceed with further processing
	                } else {
	                    // Invalid file extension
	                    model.addAttribute(JaeConstants.ERROR, "Invalid file format. Please upload a CSV file.");
	                    return "batchHpiiPage"; // Redirect to the batchHpii endpoint to display the error message
	                }
	            } else {
	                // File name not found
	                model.addAttribute(JaeConstants.ERROR, "File name not found. Please try again.");
	                return "batchHpiiPage"; // Redirect to the batchHpii endpoint to display the error message
	            }
	        } else {
	            // No file uploaded
	            model.addAttribute(JaeConstants.ERROR, "No file uploaded. Please select a file to upload.");
	            return "batchHpiiPage"; // Redirect to the batchHpii endpoint to display the error message
	        }
			
			// 2. proccess student migration
			List<StudentDTO> dtos = new ArrayList<StudentDTO>();
			int lineCount = 0;
            int hpiiCount = 0;
            if (file != null && !file.isEmpty()) {
	            try {
	            	// Create a BufferedReader to read the lines from the uploaded CSV file
	            	BufferedReader reader = new BufferedReader(new InputStreamReader(file.getInputStream()));
	                String line;
	                while ((line = reader.readLine()) != null) {
	                    lineCount++;
	                    String[] columns = line.split(",");
	                    
	                    // if (!((columns.length == 3) || (columns.length == 4))) {
	                    //     // If a line doesn't have 3 columns, throw an error
	                    //     model.addAttribute(JaeConstants.ERROR, "Invalid format on line " + lineCount);
	                    //     dtos = null;
	                    //     break;
	                    // }
	                    if(lineCount ==1) continue; // skip header in csv
	                    String firstName = columns[0];
						String lastName = columns[1];
	                    String password = columns[2];
	                    String grade = columns[3];
						String contactNo1 = columns[4];
	                    String contactNo2 = columns[5];
	                    String email1 = columns[6];
						String email2 = columns[7];
	                    String relation1 = columns[8];
	                    String relation2 = columns[9];
						String address = columns[10];
	                    String state = columns[11];
	                    String branch = columns[12];
						String memo = columns[13];
	                    String gender = columns[14];
	                    String registerDate = columns[15];
	                    String endDate = columns[16];
						String active = columns[17];
	                    // create Student
	                    Student std =  new Student();
						if(StringUtils.isNotBlank(firstName)) std.setFirstName(firstName);
						if(StringUtils.isNotBlank(lastName)) std.setLastName(lastName);
						BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
						String encodedPassword = passwordEncoder.encode(password);
						std.setPassword(encodedPassword);	
						if(StringUtils.isNotBlank(grade)) std.setGrade(grade);
						if(StringUtils.isNotBlank(contactNo1)) std.setContactNo1(contactNo1);
						if(StringUtils.isNotBlank(contactNo2)) std.setContactNo2(contactNo2);
						if(StringUtils.isNotBlank(email1)) std.setEmail1(email1);
						if(StringUtils.isNotBlank(email2)) std.setEmail2(email2);
						if(StringUtils.isNotBlank(relation1)) std.setRelation1(relation1);
						if(StringUtils.isNotBlank(relation2)) std.setRelation2(relation2);
						if(StringUtils.isNotBlank(address)) std.setAddress(address);
						if(StringUtils.isNotBlank(state)) std.setState(state);
						if(StringUtils.isNotBlank(branch)) std.setBranch(branch);
						if(StringUtils.isNotBlank(memo)) std.setMemo(memo);
						if(StringUtils.isNotBlank(gender)) std.setGender(gender);
						if(StringUtils.isNotBlank(registerDate)) std.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
    					if(StringUtils.isNotBlank(endDate)) std.setEndDate(LocalDate.parse(endDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
						if(StringUtils.isNotBlank(active)) std.setActive(Integer.parseInt(active));
						
						// register Student	
	                    std = studentService.addStudent(std);
	                    dtos.add(new StudentDTO(std));
	                }
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
	        }
			// model.addAttribute(JaeConstants.BATCH_SUCCESS, hpiiCount);
			// model.addAttribute(JaeConstants.BATCH_TOTAL, (lineCount-1));// except 1st line header
			model.addAttribute(JaeConstants.BATCH_LIST, dtos);
		
		return "migrationPage";
	}

	// count records number in database
	@GetMapping("/updateInactiveStudent")
	@ResponseBody
	int coutUpdateInactiveStudent() {
		int count = 10;//studentService.updateInactiveStudent(days);
		return count;
	}
}
