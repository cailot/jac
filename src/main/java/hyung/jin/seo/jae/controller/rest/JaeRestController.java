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

import hyung.jin.seo.jae.dto.mobile.AttendanceRollClazzDTO;
import hyung.jin.seo.jae.dto.mobile.AttendanceRollStudentDTO;
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
		AttendanceRollClazzDTO dto1 = new AttendanceRollClazzDTO(1, "Monday", "Math", "p2", "Math", 7);
		AttendanceRollClazzDTO dto2 = new AttendanceRollClazzDTO(2, "Tuesday", "English", "s7", "English", 6);
		AttendanceRollClazzDTO dto3 = new AttendanceRollClazzDTO(3, "Wednesday", "Korean", "p3", "Korean", 10);
		AttendanceRollClazzDTO dto4 = new AttendanceRollClazzDTO(4, "Thursday", "Science", "tt6", "Science", 9);
		AttendanceRollClazzDTO dto5 = new AttendanceRollClazzDTO(5, "Friday", "History", "p5", "History", 8);
		AttendanceRollClazzDTO dto6 = new AttendanceRollClazzDTO(6, "Saturday", "Art", "s10", "Art", 5);
		AttendanceRollClazzDTO dto7 = new AttendanceRollClazzDTO(7, "Sunday", "Music", "jmssi", "Music", 4);

		dtos.add(dto1);
		dtos.add(dto2);
		dtos.add(dto3);
		dtos.add(dto4);
		dtos.add(dto5);
		dtos.add(dto6);
		dtos.add(dto7);

		return dtos;
	}

	@GetMapping("/attendList/{id}/{date}")
	List<AttendanceRollStudentDTO> getAttendList(@PathVariable Long id, @PathVariable String date) {
		List<AttendanceRollStudentDTO> dtos = new ArrayList<>();

		AttendanceRollStudentDTO dto1 = new AttendanceRollStudentDTO(1, "2020-01-01", "Y", 101321, "John Malcom");
		AttendanceRollStudentDTO dto2 = new AttendanceRollStudentDTO(2, "2020-01-01", "Y", 102112, "Mary Go-round");
		AttendanceRollStudentDTO dto3 = new AttendanceRollStudentDTO(3, "2020-01-01", "Y", 103134, "Jane Ngune");
		AttendanceRollStudentDTO dto4 = new AttendanceRollStudentDTO(4, "2020-01-01", "N", 104343, "Peter Williams");
		AttendanceRollStudentDTO dto5 = new AttendanceRollStudentDTO(5, "2020-01-01", "Y", 105643, "Paul Smith");
		AttendanceRollStudentDTO dto6 = new AttendanceRollStudentDTO(6, "2020-01-01", "Y", 106334, "James Bond");
		AttendanceRollStudentDTO dto7 = new AttendanceRollStudentDTO(7, "2020-01-01", "Y", 107532, "Simon Peter");
		AttendanceRollStudentDTO dto8 = new AttendanceRollStudentDTO(8, "2020-01-01", "Y", 108432, "Judas Iscariot");
		AttendanceRollStudentDTO dto9 = new AttendanceRollStudentDTO(9, "2020-01-01", "N", 109674, "Thomas Didymus");
		AttendanceRollStudentDTO dto10 = new AttendanceRollStudentDTO(10, "2020-01-01", "N", 110332,
				"Andrew the Apostle");
		AttendanceRollStudentDTO dto11 = new AttendanceRollStudentDTO(11, "2020-01-01", "Y", 111274,
				"Bartholomew the Apostle");
		AttendanceRollStudentDTO dto12 = new AttendanceRollStudentDTO(12, "2020-01-01", "Y", 112212,
				"Matthew the Apostle");
		AttendanceRollStudentDTO dto13 = new AttendanceRollStudentDTO(13, "2020-01-01", "Y", 113480,
				"Philip the Apostle");
		AttendanceRollStudentDTO dto14 = new AttendanceRollStudentDTO(14, "2020-01-01", "Y", 114093, "James the Less");

		dtos.add(dto1);
		dtos.add(dto2);
		dtos.add(dto3);
		dtos.add(dto4);
		dtos.add(dto5);
		dtos.add(dto6);
		dtos.add(dto7);
		dtos.add(dto8);
		dtos.add(dto9);
		dtos.add(dto10);
		dtos.add(dto11);
		dtos.add(dto12);
		dtos.add(dto13);
		dtos.add(dto14);
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
