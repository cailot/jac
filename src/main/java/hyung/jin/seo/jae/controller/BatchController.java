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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.CourseDTO;
import hyung.jin.seo.jae.dto.CycleDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Course;
import hyung.jin.seo.jae.model.Cycle;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.CourseService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("batch")
public class BatchController {

	@Autowired
	private StudentService studentService;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private CodeService codeService;

	@Autowired
	private CourseService courseService;

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

	// create course template
	@GetMapping("/createCourse/{year}")
	@ResponseBody
	public ResponseEntity<String> createCourseTemplate(@PathVariable("year") int year) {
		try {
			// 1. get Cycle
			Cycle cycle = cycleService.findCycleByYear(year);
			// 2. create Course
			List<Course> courses = getP2Online(cycle);
			// 3. add Course
			for (Course course : courses) {
				courseService.addCourse(course);
			}
			// 4. return success message// // 3. return success;
			return ResponseEntity.ok("Course template generated success");
		} catch (Exception e) {
			String message = "Error registering Class: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	private List<Course> getP2Online(Cycle cycle) {
		List<Course> courses = new ArrayList<>();
		Subject eng = codeService.getSubject(1L);
		Subject math = codeService.getSubject(2L);
		Subject ga = codeService.getSubject(3L);
		Subject wrt = codeService.getSubject(4L);
		Subject sci = codeService.getSubject(5L);
		Subject all = codeService.getSubject(6L);
		Subject one = codeService.getSubject(7L);
		Subject two = codeService.getSubject(8L);
		Subject three = codeService.getSubject(9L);
		// P2
		// Onsite Course
		Course p2Onsite = new Course();
		p2Onsite.setGrade("1");
		p2Onsite.setName("P2 Onsite");
		p2Onsite.setDescription("Onsite 3 Subjects");
		p2Onsite.setOnline(false);
		p2Onsite.setPrice(0);
		p2Onsite.setCycle(cycle);
		p2Onsite.addSubject(eng);
		p2Onsite.addSubject(math);
		p2Onsite.addSubject(ga);
		courses.add(p2Onsite);
		// Online Course
		Course p2Online = new Course();
		p2Online.setGrade("1");
		p2Online.setName("P2 Online");
		p2Online.setDescription("E-Learning Class");
		p2Online.setOnline(true);
		p2Online.setPrice(0);
		p2Online.setCycle(cycle);
		p2Online.addSubject(eng);
		p2Online.addSubject(math);
		p2Online.addSubject(ga);
		courses.add(p2Online);
		// P3
		// Onsite Course
		Course p3Onsite = new Course();
		p3Onsite.setGrade("2");
		p3Onsite.setName("P3 Onsite");
		p3Onsite.setDescription("Onsite 3 Subjects");
		p3Onsite.setOnline(false);
		p3Onsite.setPrice(0);
		p3Onsite.setCycle(cycle);
		p3Onsite.addSubject(eng);
		p3Onsite.addSubject(math);
		p3Onsite.addSubject(ga);
		courses.add(p3Onsite);
		// Online Course
		Course p3Online = new Course();
		p3Online.setGrade("2");
		p3Online.setName("P3 Online");
		p3Online.setDescription("E-Learning Class");
		p3Online.setOnline(true);
		p3Online.setPrice(0);
		p3Online.setCycle(cycle);
		p3Online.addSubject(eng);
		p3Online.addSubject(math);
		p3Online.addSubject(ga);
		courses.add(p3Online);
		// P4
		// Onsite Course
		Course p4Onsite = new Course();
		p4Onsite.setGrade("3");
		p4Onsite.setName("P4 Onsite");
		p4Onsite.setDescription("Onsite 3 Subjects");
		p4Onsite.setOnline(false);
		p4Onsite.setPrice(0);
		p4Onsite.setCycle(cycle);
		p4Onsite.addSubject(eng);
		p4Onsite.addSubject(math);
		p4Onsite.addSubject(ga);
		courses.add(p4Onsite);
		// Online Course
		Course p4Online = new Course();
		p4Online.setGrade("3");
		p4Online.setName("P4 Online");
		p4Online.setDescription("E-Learning Class");
		p4Online.setOnline(true);
		p4Online.setPrice(0);
		p4Online.setCycle(cycle);
		p4Online.addSubject(eng);
		p4Online.addSubject(math);
		p4Online.addSubject(ga);
		courses.add(p4Online);
		// P5
		// Onsite Course
		Course p5Onsite = new Course();
		p5Onsite.setGrade("4");
		p5Onsite.setName("P5 Onsite");
		p5Onsite.setDescription("Onsite 3 Subjects");
		p5Onsite.setOnline(false);
		p5Onsite.setPrice(0);
		p5Onsite.setCycle(cycle);
		p5Onsite.addSubject(eng);
		p5Onsite.addSubject(math);
		p5Onsite.addSubject(ga);
		courses.add(p5Onsite);
		// Online Course
		Course p5Online = new Course();
		p5Online.setGrade("4");
		p5Online.setName("P5 Online");
		p5Online.setDescription("E-Learning Class");
		p5Online.setOnline(true);
		p5Online.setPrice(0);
		p5Online.setCycle(cycle);
		p5Online.addSubject(eng);
		p5Online.addSubject(math);
		p5Online.addSubject(ga);
		courses.add(p5Online);
		// P6
		// Onsite Course
		Course p6Onsite = new Course();
		p6Onsite.setGrade("5");
		p6Onsite.setName("P6 Onsite");
		p6Onsite.setDescription("Onsite 3 Subjects");
		p6Onsite.setOnline(false);
		p6Onsite.setPrice(0);
		p6Onsite.setCycle(cycle);
		p6Onsite.addSubject(eng);
		p6Onsite.addSubject(math);
		p6Onsite.addSubject(ga);
		courses.add(p6Onsite);
		// Online Course
		Course p6Online = new Course();
		p6Online.setGrade("5");
		p6Online.setName("P6 Online");
		p6Online.setDescription("E-Learning Class");
		p6Online.setOnline(true);
		p6Online.setPrice(0);
		p6Online.setCycle(cycle);
		p6Online.addSubject(eng);
		p6Online.addSubject(math);
		p6Online.addSubject(ga);
		courses.add(p6Online);
		// S7
		// Onsite Course
		Course s7Onsite3 = new Course();
		s7Onsite3.setGrade("6");
		s7Onsite3.setName("S7 Onsite (3)");
		s7Onsite3.setDescription("Onsite 3 Subjects");
		s7Onsite3.setOnline(false);
		s7Onsite3.setPrice(0);
		s7Onsite3.setCycle(cycle);
		s7Onsite3.addSubject(eng);
		s7Onsite3.addSubject(math);
		s7Onsite3.addSubject(sci);
		courses.add(s7Onsite3);
		Course s7Onsite2 = new Course();
		s7Onsite2.setGrade("6");
		s7Onsite2.setName("S7 Onsite (2)");
		s7Onsite2.setDescription("Onsite 2 Subjects");
		s7Onsite2.setOnline(false);
		s7Onsite2.setPrice(0);
		s7Onsite2.setCycle(cycle);
		s7Onsite2.addSubject(two);
		courses.add(s7Onsite2);
		Course s7Onsite1 = new Course();
		s7Onsite1.setGrade("6");
		s7Onsite1.setName("S7 Onsite (1)");
		s7Onsite1.setDescription("Onsite 1 Subject");
		s7Onsite1.setOnline(false);
		s7Onsite1.setPrice(0);
		s7Onsite1.setCycle(cycle);
		s7Onsite1.addSubject(one);
		courses.add(s7Onsite1);		
		// Online Course
		Course s7Online = new Course();
		s7Online.setGrade("6");
		s7Online.setName("S7 Online");
		s7Online.setDescription("E-Learning Class");
		s7Online.setOnline(true);
		s7Online.setPrice(0);
		s7Online.setCycle(cycle);
		s7Online.addSubject(eng);
		s7Online.addSubject(math);
		s7Online.addSubject(sci);
		courses.add(s7Online);
		// S8
		// Onsite Course
		Course s8Onsite3 = new Course();
		s8Onsite3.setGrade("7");
		s8Onsite3.setName("S8 Onsite (3)");
		s8Onsite3.setDescription("Onsite 3 Subjects");
		s8Onsite3.setOnline(false);
		s8Onsite3.setPrice(0);
		s8Onsite3.setCycle(cycle);
		s8Onsite3.addSubject(eng);
		s8Onsite3.addSubject(math);
		s8Onsite3.addSubject(sci);
		courses.add(s8Onsite3);
		Course s8Onsite2 = new Course();
		s8Onsite2.setGrade("7");
		s8Onsite2.setName("S8 Onsite (2)");
		s8Onsite2.setDescription("Onsite 2 Subjects");
		s8Onsite2.setOnline(false);
		s8Onsite2.setPrice(0);
		s8Onsite2.setCycle(cycle);
		s8Onsite2.addSubject(two);
		courses.add(s8Onsite2);
		Course s8Onsite1 = new Course();
		s8Onsite1.setGrade("7");
		s8Onsite1.setName("S8 Onsite (1)");
		s8Onsite1.setDescription("Onsite 1 Subject");
		s8Onsite1.setOnline(false);
		s8Onsite1.setPrice(0);
		s8Onsite1.setCycle(cycle);
		s8Onsite1.addSubject(one);
		courses.add(s8Onsite1);		
		// Online Course
		Course s8Online = new Course();
		s8Online.setGrade("7");
		s8Online.setName("S8 Online");
		s8Online.setDescription("E-Learning Class");
		s8Online.setOnline(true);
		s8Online.setPrice(0);
		s8Online.setCycle(cycle);
		s8Online.addSubject(eng);
		s8Online.addSubject(math);
		s8Online.addSubject(sci);
		courses.add(s8Online);
		// S9
		// Onsite Course
		Course s9Onsite3 = new Course();
		s9Onsite3.setGrade("8");
		s9Onsite3.setName("S9 Onsite (3)");
		s9Onsite3.setDescription("Onsite 3 Subjects");
		s9Onsite3.setOnline(false);
		s9Onsite3.setPrice(0);
		s9Onsite3.setCycle(cycle);
		s9Onsite3.addSubject(eng);
		s9Onsite3.addSubject(math);
		s9Onsite3.addSubject(sci);
		courses.add(s9Onsite3);
		Course s9Onsite2 = new Course();
		s9Onsite2.setGrade("8");
		s9Onsite2.setName("S9 Onsite (2)");
		s9Onsite2.setDescription("Onsite 2 Subjects");
		s9Onsite2.setOnline(false);
		s9Onsite2.setPrice(0);
		s9Onsite2.setCycle(cycle);
		s9Onsite2.addSubject(two);
		courses.add(s9Onsite2);
		Course s9Onsite1 = new Course();
		s9Onsite1.setGrade("8");
		s9Onsite1.setName("S9 Onsite 1");
		s9Onsite1.setDescription("Onsite 1 Subject");
		s9Onsite1.setOnline(false);
		s9Onsite1.setPrice(0);
		s9Onsite1.setCycle(cycle);
		s9Onsite1.addSubject(one);
		courses.add(s9Onsite1);		
		// Online Course
		Course s9Online = new Course();
		s9Online.setGrade("8");
		s9Online.setName("S9 Online");
		s9Online.setDescription("E-Learning Class");
		s9Online.setOnline(true);
		s9Online.setPrice(0);
		s9Online.setCycle(cycle);
		s9Online.addSubject(eng);
		s9Online.addSubject(math);
		s9Online.addSubject(sci);
		courses.add(s9Online);
		// S10
		// Onsite Course
		Course s10Onsite3 = new Course();
		s10Onsite3.setGrade("9");
		s10Onsite3.setName("S10 Onsite 3");
		s10Onsite3.setDescription("Onsite 3 Subjects");
		s10Onsite3.setOnline(false);
		s10Onsite3.setPrice(0);
		s10Onsite3.setCycle(cycle);
		s10Onsite3.addSubject(eng);
		s10Onsite3.addSubject(math);
		s10Onsite3.addSubject(sci);
		courses.add(s10Onsite3);
		Course s10Onsite2 = new Course();
		s10Onsite2.setGrade("9");
		s10Onsite2.setName("S10 Onsite 2");
		s10Onsite2.setDescription("Onsite 2 Subjects");
		s10Onsite2.setOnline(false);
		s10Onsite2.setPrice(0);
		s10Onsite2.setCycle(cycle);
		s10Onsite2.addSubject(two);
		courses.add(s10Onsite2);
		Course s10Onsite1 = new Course();
		s10Onsite1.setGrade("9");
		s10Onsite1.setName("S10 Onsite 1");
		s10Onsite1.setDescription("Onsite 1 Subject");
		s10Onsite1.setOnline(false);
		s10Onsite1.setPrice(0);
		s10Onsite1.setCycle(cycle);
		s10Onsite1.addSubject(one);
		courses.add(s10Onsite1);		
		// Online Course
		Course s10Online = new Course();
		s10Online.setGrade("9");
		s10Online.setName("S10 Online");
		s10Online.setDescription("E-Learning Class");
		s10Online.setOnline(true);
		s10Online.setPrice(0);
		s10Online.setCycle(cycle);
		s10Online.addSubject(eng);
		s10Online.addSubject(math);
		s10Online.addSubject(sci);
		courses.add(s10Online);
		// S10E
		// Onsite Course
		Course s10eOnsite3 = new Course();
		s10eOnsite3.setGrade("10");
		s10eOnsite3.setName("S10E Onsite");
		s10eOnsite3.setDescription("Onsite 3 Subjects");
		s10eOnsite3.setOnline(false);
		s10eOnsite3.setPrice(0);
		s10eOnsite3.setCycle(cycle);
		s10eOnsite3.addSubject(eng);
		s10eOnsite3.addSubject(math);
		s10eOnsite3.addSubject(sci);
		courses.add(s10eOnsite3);
		// TT6
		// Onsite Course
		Course tt6Onsite = new Course();
		tt6Onsite.setGrade("11");
		tt6Onsite.setName("TT6 Onsite");
		tt6Onsite.setDescription("Onsite TT6");
		tt6Onsite.setOnline(false);
		tt6Onsite.setPrice(0);
		tt6Onsite.setCycle(cycle);
		tt6Onsite.addSubject(eng);
		tt6Onsite.addSubject(math);
		courses.add(tt6Onsite);
		// Online Course
		Course tt6Online = new Course();
		tt6Online.setGrade("11");
		tt6Online.setName("TT6 Online");
		tt6Online.setDescription("E-Learning Class");
		tt6Online.setOnline(true);
		tt6Online.setPrice(0);
		tt6Online.setCycle(cycle);
		tt6Online.addSubject(eng);
		tt6Online.addSubject(math);
		courses.add(tt6Online);
		// TT8
		// Onsite Course
		Course tt8Onsite = new Course();
		tt8Onsite.setGrade("12");
		tt8Onsite.setName("TT8 Onsite");
		tt8Onsite.setDescription("Onsite TT8");
		tt8Onsite.setOnline(false);
		tt8Onsite.setPrice(0);
		tt8Onsite.setCycle(cycle);
		tt8Onsite.addSubject(eng);
		tt8Onsite.addSubject(math);
		courses.add(tt8Onsite);
		// Online Course
		Course tt8Online = new Course();
		tt8Online.setGrade("12");
		tt8Online.setName("TT8 Online");
		tt8Online.setDescription("E-Learning Class");
		tt8Online.setOnline(true);
		tt8Online.setPrice(0);
		tt8Online.setCycle(cycle);
		tt8Online.addSubject(eng);
		tt8Online.addSubject(math);
		courses.add(tt8Online);

		// JMSS
		// Onsite Course
		Course jmssOnsite = new Course();
		jmssOnsite.setGrade("19");
		jmssOnsite.setName("JMSS Onsite");
		jmssOnsite.setDescription("Onsite JMSS");
		jmssOnsite.setOnline(false);
		jmssOnsite.setPrice(0);
		jmssOnsite.setCycle(cycle);
		jmssOnsite.addSubject(sci);
		jmssOnsite.addSubject(math);
		courses.add(jmssOnsite);
		// Online Course
		Course jmssOnline = new Course();
		jmssOnline.setGrade("19");
		jmssOnline.setName("JMSS Online");
		jmssOnline.setDescription("E-Learning Class");
		jmssOnline.setOnline(true);
		jmssOnline.setPrice(0);
		jmssOnline.setCycle(cycle);
		jmssOnline.addSubject(sci);
		jmssOnline.addSubject(math);
		courses.add(jmssOnline);

		// VCE
		// Onsite Course
		Course vceOnsite3 = new Course();
		vceOnsite3.setGrade("20");
		vceOnsite3.setName("VCE 3 Sub");
		vceOnsite3.setDescription("Onsite 3 Subjects");
		vceOnsite3.setOnline(false);
		vceOnsite3.setPrice(0);
		vceOnsite3.setCycle(cycle);
		vceOnsite3.addSubject(three);
		courses.add(vceOnsite3);
		Course vceOnsite2 = new Course();
		vceOnsite2.setGrade("20");
		vceOnsite2.setName("VCE 2 Sub");
		vceOnsite2.setDescription("Onsite 2 Subjects");
		vceOnsite2.setOnline(false);
		vceOnsite2.setPrice(0);
		vceOnsite2.setCycle(cycle);
		vceOnsite2.addSubject(two);
		courses.add(vceOnsite2);
		Course vceOnsite1 = new Course();
		vceOnsite1.setGrade("20");
		vceOnsite1.setName("VCE 1 Sub");
		vceOnsite1.setDescription("Onsite 1 Subject");
		vceOnsite1.setOnline(false);
		vceOnsite1.setPrice(0);
		vceOnsite1.setCycle(cycle);
		vceOnsite1.addSubject(one);
		courses.add(vceOnsite1);

		return courses;
	}

}
