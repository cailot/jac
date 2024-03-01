package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.model.Homework;

public interface ElearningService {
	// list all elearnings
	List<Homework> allElearnings();
	
	// list elearnings belong to grade
	List<Homework> gradeElearnings(String grade);
	
	// list elearnings by student id
	List<Homework> studentElearnings(Long id);

	// retrieve elearning by Id
	public Homework getElearning(Long id);
	
	// register elearning
	Homework addElearning(Homework crs);
    
    // get total number of elearnings
 	long checkCount();
    
 	// update elearning info by Id
 	Homework updateElearning(Homework newCourse, Long id);
	
	// delete elearning
	void deleteElearning(Long id);

}
