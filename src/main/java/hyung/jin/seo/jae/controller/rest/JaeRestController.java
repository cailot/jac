package hyung.jin.seo.jae.controller.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

import hyung.jin.seo.jae.dto.AttendanceRollClazzDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.StudentService;

import java.util.ArrayList;
import java.util.List;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("api")
public class JaeRestController {

	// @Autowired
	// private StudentService studentService;

	@GetMapping("/clazzList/{id}")
	List<AttendanceRollClazzDTO> getClazzList(@PathVariable Long id) {
		List<AttendanceRollClazzDTO> dtos = new ArrayList<>();
		AttendanceRollClazzDTO dto1 = new AttendanceRollClazzDTO(1, "Monday", "Math", "1", "Math", 7);
		AttendanceRollClazzDTO dto2 = new AttendanceRollClazzDTO(2, "Tuesday", "English", "2", "English", 6);
		AttendanceRollClazzDTO dto3 = new AttendanceRollClazzDTO(3, "Wednesday", "Korean", "3", "Korean", 10);
		AttendanceRollClazzDTO dto4 = new AttendanceRollClazzDTO(4, "Thursday", "Science", "4", "Science", 9);
		AttendanceRollClazzDTO dto5 = new AttendanceRollClazzDTO(5, "Friday", "History", "5", "History", 8);
		dtos.add(dto1);
		dtos.add(dto2);
		dtos.add(dto3);
		dtos.add(dto4);
		dtos.add(dto5);

		return dtos;
	}

	// @GetMapping("/student/{id}")
	// Student getAttendList(@PathVariable Long id) {
	// Student std = studentService.getStudent(id);
	// return std;
	// }

	// @PutMapping("/student")
	// Student updateStudentAttend(@RequestBody Student std) {
	// Student add = studentService.addStudent(std);
	// return add;
	// }

	// @PutMapping("/student/{id}")
	// Student updateTeacher(@RequestBody Student newStudent, @PathVariable Long id)
	// {
	// Student updated = studentService.updateStudent(newStudent, id);
	// return updated;
	// }

}
