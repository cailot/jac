package hyung.jin.seo.jae.controller.rest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.StudentService;

import java.util.List;


@RestController
@RequestMapping("api")
public class StudentRestController {

	@Autowired
	private StudentService studentService;
	
	private static final Logger LOG = LoggerFactory.getLogger(StudentRestController.class);
	
	// @GetMapping("/students")
	// List<Student> allStudents(@RequestParam("state") String state, @RequestParam("branch") String branch, @RequestParam("grade") String grade, @RequestParam("year") String year, @RequestParam("active") String active) {
    //     System.out.println(state+"\t"+branch+"\t"+grade+"\t"+year+"\t"+active+"\t");
	// 	List<Student> students = studentService.listStudents(state, branch, grade, year, active);
    //     return students;
	// }
	
    @GetMapping("/student/{id}")
	Student getStudent(@PathVariable Long id) {
		Student std = studentService.getStudent(id);
        return std;
	}
    
    @GetMapping("/student")
    List<Student> searchStudents(@RequestParam("keyword") String keyword) {
        System.out.println(keyword);
		List<Student> students = studentService.searchStudents(keyword);
        return students;
	}
    
    
    @PostMapping("/student")
	Student addStudent(@RequestBody Student std) {
        Student add = studentService.addStudent(std);
        return add;
	}
    
    @GetMapping("/student/count")
	long checkCount() {
        long count = studentService.checkCount();
        return count;
	}
    
    
    @PutMapping("/student/{id}")
	Student updateStudent(@RequestBody Student newStudent, @PathVariable Long id) {
    	Student updated = studentService.updateStudent(newStudent, id);
    	return updated;
    }
    
    @PutMapping("/student/discharge/{id}")
	void dischargeStudent(@PathVariable Long id) {
    	studentService.deactivateStudent(id);
    }
    
    @DeleteMapping("/student/{id}")
	void deleteStudent(@PathVariable Long id) {
		studentService.deleteStudent(id);
	}
    
    
}
