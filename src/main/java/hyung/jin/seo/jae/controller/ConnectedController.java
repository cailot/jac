package hyung.jin.seo.jae.controller;

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
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.model.Grade;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;

@Controller
@RequestMapping("connected")
public class ConnectedController {

	private static final Logger LOG = LoggerFactory.getLogger(ConnectedController.class);

	@Autowired
	private ConnectedService connectedService;

	@Autowired
	private CodeService codeService;


	
	// register homework
	@PostMapping("/addHomework")
	@ResponseBody
	public HomeworkDTO registerHomework(@RequestBody HomeworkDTO formData) {
		// create barebone
		Homework work = formData.convertToHomework();
		// set Subject
		Subject subject = codeService.getSubject(Long.parseLong(formData.getSubject()));
		// set Grade
		Grade grade = codeService.getGrade(Long.parseLong(formData.getGrade()));
		// associate Subject & Grade
		work.setSubject(subject);
		work.setGrade(grade);
		// register Homework
		Homework added = connectedService.addHomework(work);
		// return dto
		HomeworkDTO dto = new HomeworkDTO(added);
		return dto;
	}

	// update existing homework
	@PutMapping("/updateHomework")
	@ResponseBody
	public HomeworkDTO updateHomework(@RequestBody HomeworkDTO formData) {
		Homework work = formData.convertToHomework();
		work = connectedService.updateHomework(work, Long.parseLong(formData.getId()));
		HomeworkDTO dto = new HomeworkDTO(work);
		return dto;
	}
	
	// get homework
	@GetMapping("/getHomework/{id}")
	@ResponseBody
	public HomeworkDTO getHomework(@PathVariable Long id) {
		Homework work = connectedService.getHomework(id);
		HomeworkDTO dto = new HomeworkDTO(work);
		return dto;
	}

	// search homework by subject, year & week
	@GetMapping("/homework/{subject}/{year}/{week}")
	@ResponseBody
	public HomeworkDTO searchHomework(@PathVariable long subject, @PathVariable int year, @PathVariable int week) {
		HomeworkDTO dto = connectedService.getHomeworkInfo(subject, year, week);
		return dto;
	}

	// search video homework by subject, year & week
	@GetMapping("/movieHomework/{subject}/{year}/{week}")
	@ResponseBody
	public HomeworkDTO searchVideoHomework(@PathVariable long subject, @PathVariable int year, @PathVariable int week) {
		HomeworkDTO dto = connectedService.getHomeworkInfo(subject, year, week);
		return dto;
	}

	// search homework by subject, year & week
	@GetMapping("/pdfHomework/{subject}/{year}/{week}")
	@ResponseBody
	public HomeworkDTO searchPdfHomework(@PathVariable long subject, @PathVariable int year, @PathVariable int week) {
		HomeworkDTO dto = connectedService.getHomeworkInfo(subject, year, week);
		return dto;
	}
	
}
