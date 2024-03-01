package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.service.ConnectedService;

@Controller
@RequestMapping("elearning")
public class JaeElearningController {

	private static final Logger LOG = LoggerFactory.getLogger(JaeElearningController.class);

	@Autowired
	private ConnectedService elearningService;

	
	// register new student
	@PostMapping("/register")
	@ResponseBody
	public HomeworkDTO registerStudent(@RequestBody HomeworkDTO formData) {
		Homework crs = formData.convertToElearning();
		crs = elearningService.addElearning(crs);
		HomeworkDTO dto = new HomeworkDTO(crs);
		return dto;
	}


	// search elearning with grade
	@GetMapping("/grade")
	@ResponseBody
	List<HomeworkDTO> gradeCourses(@RequestParam("grade") String keyword) {
		List<Homework> crss = elearningService.gradeElearnings(keyword);
		List<HomeworkDTO> dtos = new ArrayList<HomeworkDTO>();
		for (Homework crs : crss) {
			HomeworkDTO dto = new HomeworkDTO(crs);
			dtos.add(dto);
		}
		return dtos;
	}

	
	// update existing course
	@PutMapping("/update")
	@ResponseBody
	public HomeworkDTO updateStudent(@RequestBody HomeworkDTO formData) {
		Homework crs = formData.convertToElearning();
		crs = elearningService.updateElearning(crs, crs.getId());
		HomeworkDTO dto = new HomeworkDTO(crs);
		return dto;
	}
	
	
	// list all courses
	@GetMapping("/list")
	@ResponseBody
	List<HomeworkDTO> allCourses() {
		List<Homework> crss = elearningService.allElearnings();
		List<HomeworkDTO> dtos = new ArrayList<HomeworkDTO>();
		for(Homework crs : crss) {
			HomeworkDTO dto = new HomeworkDTO(crs);	
			dtos.add(dto);
		}
        return dtos;
	}

	// search e-learning by student Id
	@GetMapping("/search/student/{id}")
	@ResponseBody
	List<HomeworkDTO> searchElearningByStudent(@PathVariable Long id) {
		List<Homework> crss = elearningService.studentElearnings(id);
		List<HomeworkDTO> dtos = new ArrayList<HomeworkDTO>();
		for(Homework crs : crss) {
			HomeworkDTO dto = new HomeworkDTO(crs);	
			dtos.add(dto);
		}
        return dtos;
	}
	
}
