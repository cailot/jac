package hyung.jin.seo.jae.controller;

import java.text.ParseException;
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

import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("student")
public class StudentController {

	@Autowired
	private StudentService studentService;

	private ObjectMapper objectMapper = new ObjectMapper();
	
	// register new student
	@PostMapping("/register")
	@ResponseBody
	public StudentDTO registerStudent(@RequestBody StudentDTO formData) {
		// 1. create Student without elearning
		Student std = formData.convertToOnlyStudent();
		String password = JaeConstants.DEFAULT_PASSWORD;//formData.getPassword();
		BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		String encodedPassword = passwordEncoder.encode(password);
		std.setPassword(encodedPassword);
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

	// update student password
	@PutMapping("/updatePassword/{id}/{pwd}")
	@ResponseBody
	public void updatePassword(@PathVariable Long id, @PathVariable String pwd) {
		// BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		// String encodedPassword = passwordEncoder.encode(pwd);
		studentService.updatePassword(id, pwd);
	}

	// search student list with state, branch, grade, start date or active
	@GetMapping("/list")
	public String listStudents(@RequestParam(value="listState", required=false) String state, @RequestParam(value="listBranch", required=false) String branch, @RequestParam(value="listGrade", required=false) String grade, @RequestParam(value="listYear", required=false) String year, @RequestParam(value="listActive", required=false) String active, Model model) {
		// return only active enrolled (enrolment.active = true) current/stopped students
		List<StudentDTO> dtos = studentService.listStudents(state, branch, grade, year, active);
		model.addAttribute(JaeConstants.STUDENT_LIST, dtos);
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
