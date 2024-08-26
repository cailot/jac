package hyung.jin.seo.jae.controller;

import java.text.ParseException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import hyung.jin.seo.jae.dto.LoginActivityDTO;
import hyung.jin.seo.jae.service.LoginActivityService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("loginCheck")
public class LoginActivityController {

	@Autowired
	private LoginActivityService loginActivityService;

	// connected login activity list for studyList.jsp
	@GetMapping("/connectedAttend")
	public String loginStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate, Model model
									) {
		String start = null;
		try {
			start = JaeUtils.convertToyyyyMMddFormat(fromDate);
		} catch (ParseException e) {			
			start = "2000-01-01";
		}
		String end = null;
		try {
			end = JaeUtils.convertToyyyyMMddFormat(toDate);
		} catch (ParseException e){
			end = "2099-12-31";
		}
		List<LoginActivityDTO> dtos = loginActivityService.listStudentLogin(branch, grade, start, end);
		model.addAttribute(JaeConstants.LOGIN_LIST, dtos);
		return "connectedAttendListPage";
	}

}
