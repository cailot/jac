package hyung.jin.seo.jae.controller.rest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;


import hyung.jin.seo.jae.model.Elearning;
import hyung.jin.seo.jae.service.ElearningService;

import java.util.List;


@RestController
@RequestMapping("api")
public class ElearningRestController {

	@Autowired
	private ElearningService elearningService;
	
	private static final Logger LOG = LoggerFactory.getLogger(ElearningRestController.class);
	
	@GetMapping("/elearnings")
	List<Elearning> allCourses() {
        List<Elearning> courses = elearningService.allElearnings();
        return courses;
	}
	
    @GetMapping("/elearning/{id}")
    Elearning getCourse(@PathVariable Long id) {
    	Elearning course = elearningService.getElearning(id);
        return course;
	}
	
    @PostMapping("/elearning")
	void addCourse(@RequestBody Elearning course) {
    	elearningService.addElearning(course);
	}
    
    @GetMapping("/elearning/count")
	long checkCount() {
        long count = elearningService.checkCount();
        return count;
	}
    
    
    @PutMapping("/elearning/{id}")
    Elearning updateCourse(@RequestBody Elearning newCourse, @PathVariable Long id) {
    	Elearning updated = elearningService.updateElearning(newCourse, id);
    	return updated;
    }
    
    @DeleteMapping("/elearning/{id}")
	void deleteCourse(@PathVariable Long id) {
    	elearningService.deleteElearning(id);
	}
    
}
