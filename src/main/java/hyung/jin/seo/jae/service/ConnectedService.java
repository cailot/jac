package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.model.Homework;

public interface ConnectedService {
	// list all Homeworks
	List<Homework> allHomeworks();
	
	// retrieve Homework by Id
	Homework getHomework(Long id);
	
	// register Homework
	Homework addHomework(Homework crs);
    
    // update Homework info by Id
 	Homework updateHomework(Homework newWork, Long id);
	
	// delete Homework
	void deleteHomework(Long id);

	// get Homework by subject, year & week
	HomeworkDTO getHomeworkInfo(Long subject, int year, int week);

	// get Video Homework by subject, year & week
	HomeworkDTO getVideoHomeworkInfo(Long subject, int year, int week);

	// get Pdf Homework by subject, year & week
	HomeworkDTO getPdfHomeworkInfo(Long subject, int year, int week);

}
