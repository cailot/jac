package hyung.jin.seo.jae.controller;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;

import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.PropertiesService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("student")
public class StudentController {

	@Autowired
	private StudentService studentService;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private PropertiesService propertiesService;

	private ObjectMapper objectMapper = new ObjectMapper();

	// private String password = JaeConstants.DEFAULT_PASSWORD;//formData.getPassword();
	private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

	
	// register new student
	@PostMapping("/register")
	@ResponseBody
	public StudentDTO registerStudent(@RequestBody StudentDTO formData) {
		// 1. create Student without elearning
		Student std = formData.convertToOnlyStudent();
		// String password = JaeConstants.DEFAULT_PASSWORD;//formData.getPassword();
		// BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		String encodedPassword = passwordEncoder.encode(JaeConstants.DEFAULT_PASSWORD);
		std.setPassword(encodedPassword);
		std.setActive(JaeConstants.ACTIVE);
		std = studentService.addStudent(std);
		StudentDTO dto = new StudentDTO(std);
		return dto;
	}

	// search student with keyword - ID, firstName & lastName
	@GetMapping("/search")
	@ResponseBody
	List<StudentDTO> searchStudents(@RequestParam("keyword") String keyword,
									@RequestParam("state") String state,
									@RequestParam("branch") String branch) {
		List<StudentDTO> dtos = studentService.searchByKeyword(keyword, state, branch);
		return dtos;
	}
	
	// search student by ID
	@GetMapping("/get/{id}")
	@ResponseBody
	StudentDTO getStudents(@PathVariable Long id) {
		Student std = studentService.getStudent(id);
		if(std==null) return new StudentDTO(); // return empty if not found
		StudentDTO dto = new StudentDTO(std);
		return dto;
	}
	
	@PutMapping("/update")
	@ResponseBody
	public ResponseEntity<String> updateStudent(@RequestBody Map<String, Object> formData) {
		try{
			// 1. get StudentDTO
			StudentDTO request = objectMapper.convertValue(formData.get("student"), StudentDTO.class);
			// 2. get user
			String user = (String) formData.get("user");
			// 3. update Student
			studentService.updateStudent(request, user);
			// 4. return flag
			return ResponseEntity.ok("\"Student updated successfully\"");
		}catch(Exception e){
			String message = "\"Error updating Student : " + e.getMessage() + "\"";
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}
	
	// de-activate student by Id
	@PutMapping("/inactivate/{id}")
	@ResponseBody
	public void inactivateStudent(@PathVariable Long id) {
		studentService.deactivateStudent(id);
	}
	

	// de-activate student by Id
	@PutMapping("/activate/{id}")
	@ResponseBody
	public StudentDTO activateStudent(@PathVariable Long id) {
		Student std = studentService.activateStudent(id);
		StudentDTO dto = new StudentDTO(std);
		return dto;
	}


	@GetMapping("/getPassword/{id}")
	@ResponseBody
	public String getPassword(@PathVariable Long id) {
		String password = studentService.getStudentPassword(id);
		return password;
	}

	// update student password
	@PutMapping("/updatePassword/{id}/{pwd}")
	@ResponseBody
	public void updatePassword(@PathVariable Long id, @PathVariable String pwd) {
		// BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		// String encodedPassword = passwordEncoder.encode(pwd);
		studentService.updatePassword(id, pwd);
	}

	// search all student list with state, branch, grade, active
	@GetMapping("/all")
	public String allStudents(@RequestParam(value="listState", required=false) String state, @RequestParam(value="listBranch", required=false) String branch, @RequestParam(value="listGrade", required=false) String grade, @RequestParam(value="listYear", required=false) int year, @RequestParam(value="listWeek", required=false) int week, @RequestParam(value="listActive", required=false) String active, Model model) {		
		String day = cycleService.academicStartMonday(year, week);
		List<StudentDTO> dtos = studentService.listAllStudents(state, branch, grade, day, active);
		model.addAttribute(JaeConstants.STUDENT_LIST, dtos);
		return "studentListPage";
	}

	// list grade figures for student list
	@GetMapping("/gradeList")
	@ResponseBody
	public List<SimpleBasketDTO> gradeListStudents(@RequestParam(value="listState", required=true, defaultValue = "0") String state,
		@RequestParam(value="listBranch", required=true, defaultValue = "0") String branch,
		@RequestParam(value="listYear", required=true, defaultValue = "0") Integer year,
		@RequestParam(value="listWeek", required=true, defaultValue = "0") Integer week,
		@RequestParam(value="listActive", required=true, defaultValue = "0") String active) {	

		String day = cycleService.academicStartMonday(year, week);
		List<SimpleBasketDTO> dtos = studentService.countAllStudents(state, branch, day, active);
		Collections.sort(dtos, new Comparator<SimpleBasketDTO>() {
			@Override
			public int compare(SimpleBasketDTO o1, SimpleBasketDTO o2) {
				try {
					int name1 = Integer.parseInt(o1.getName());
					int name2 = Integer.parseInt(o2.getName());
					return Integer.compare(name1, name2);
				} catch (NumberFormatException e) {
					// Handle the case where the name is not a valid integer
					return o1.getName().compareTo(o2.getName());
				}
			}
		});
		return dtos;
	}

	// list student by condition
	@GetMapping("/listByCondition")
	@ResponseBody
	public List<StudentWithEnrolmentDTO> listStudentByCondition(@RequestParam(value="listState", required=true, defaultValue = "0") String state,
		@RequestParam(value="listBranch", required=true, defaultValue = "0") String branch,
		@RequestParam(value="listGrade", required=true, defaultValue = "0") String grade,
		@RequestParam(value="listYear", required=true, defaultValue = "0") Integer year,
		@RequestParam(value="listWeek", required=true, defaultValue = "0") Integer week,
		@RequestParam(value="listActive", required=true, defaultValue = "0") String active) {	

		String day = cycleService.academicStartMonday(year, week);
		// List<StudentDTO> dtos = studentService.listAllStudents(state, branch, grade, day, active);
		List<StudentWithEnrolmentDTO> dtos = studentService.overallStudentWithEnrolment(state, branch, grade, active, year, week, day);		
		return dtos;
	}

	// search enrolment student list with state, branch, grade, active
	@GetMapping("/list")
	public String listStudents(@RequestParam(value="listState", required=false) String state, @RequestParam(value="listBranch", required=false) String branch, @RequestParam(value="listGrade", required=false) String grade, Model model) {
		int year = cycleService.academicYear();;
		int week = cycleService.academicWeeks();
		List<StudentWithEnrolmentDTO> dtos = studentService.listEnrolmentStudents(state, branch, grade, year, week);
		model.addAttribute(JaeConstants.STUDENT_LIST, dtos);
		model.addAttribute("jacStudyEndpoint", propertiesService.getElearningEndpoint());
		return "studentEnrolPage";
	}

	// list student list with state, branch, grade
	@GetMapping("/upgrade")
	public String gradeStudents(@RequestParam(value="listState", required=false) String state, @RequestParam(value="listBranch", required=false) String branch, @RequestParam(value="listCurrentGrade", required=false) String grade, Model model) {
		List<StudentDTO> dtos = studentService.showGradeStudents(state, branch, grade);
		if(dtos==null || dtos.isEmpty()){
			model.addAttribute(JaeConstants.UPGRADE_LIST, null);
		}else{
			model.addAttribute(JaeConstants.UPGRADE_LIST, dtos);
		}
		return "studentGradePage";
	}

	@PostMapping("/updateGrade/{listTo}")
	public String updateGrade(@PathVariable("listTo") String listTo, @RequestBody List<Long> ids, Model model) {
		String grade = listTo;
		studentService.batchUpdateGrade(ids, grade);
		return "studentGradePage";
	}
	
}
