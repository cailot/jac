package hyung.jin.seo.jae.controller;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import hyung.jin.seo.jae.dto.LoginActivityDTO;
import hyung.jin.seo.jae.dto.OnlineActivityDTO;
import hyung.jin.seo.jae.dto.OnlineSessionDTO;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.LoginActivityService;
import hyung.jin.seo.jae.service.OnlineActivityService;
import hyung.jin.seo.jae.service.OnlineSessionService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("loginCheck")
public class LoginActivityController {

	@Autowired
	private LoginActivityService loginActivityService;

	@Autowired
	private OnlineActivityService onlineActivityService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private OnlineSessionService onlineSessionService;


	@GetMapping("/onlineAttend")
	public String loginStudents(@RequestParam("listBranch") String branch, 
									@RequestParam("listGrade") String grade,
									@RequestParam("listYear") int year,
									@RequestParam("listSet") int set, Model model
									) {

		List<OnlineActivityDTO> dtos = new ArrayList<>();								
		// 1. get clazz id
		Long clazzId = clazzService.getOnlineId(grade, year);
		
		// 2. get online session list
		List<OnlineSessionDTO> sessions = onlineSessionService.findSessionByClazzNWeek(clazzId, set);
		for(OnlineSessionDTO session : sessions){
			
			// 3. get student list
			List<Long> studentIds = enrolmentService.findStudentIdByClazzId(clazzId);
			
			// 4. check student attends online class at the week
			for(Long studentId : studentIds) {
				Integer enrolCnt = enrolmentService.isStudentAttendOnlineClazz(studentId, clazzId, set);
				if(enrolCnt > 0){
			
					// 5. check online activity status
					// System.out.println(studentId + " attends online class");
					OnlineActivityDTO activity = onlineActivityService.getStudentStatus(studentId, session);
			
					// 6. add online activity dto
					dtos.add(activity);					
				}
			}
		}
		model.addAttribute(JaeConstants.BRANCH_INFO, branch);
		model.addAttribute(JaeConstants.GRADE_INFO, grade);
		model.addAttribute(JaeConstants.YEAR_INFO, year);
		model.addAttribute(JaeConstants.SET_INFO, set);
		model.addAttribute(JaeConstants.LOGIN_LIST, dtos);
		return "onlineStatusListPage";
	}

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
		model.addAttribute(JaeConstants.BRANCH_INFO, branch);
		model.addAttribute(JaeConstants.GRADE_INFO, grade);
		model.addAttribute(JaeConstants.START_DATE_INFO, start);
		model.addAttribute(JaeConstants.END_DATE_INFO, end);
		model.addAttribute(JaeConstants.LOGIN_LIST, dtos);
		return "connectedAttendListPage";
	}

}
