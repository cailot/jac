package hyung.jin.seo.jae.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import hyung.jin.seo.jae.service.PropertiesService;

@Controller
@RequestMapping("config")
public class PropertiesController {

	@Autowired
	private PropertiesService propertiesService;

	// get Homework Normal value
	@GetMapping("/homeworkNormal")
	public String getHomeworkNormal(){
		return propertiesService.getHomeworkNormal();
    }

	// get Homework Short value
	@GetMapping("/homeworkShort")
	public String getHomeworkShort(){
		return propertiesService.getHomeworkShort();
    }
	
}