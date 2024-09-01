package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.criteria.CriteriaBuilder.In;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.dto.OnlineActivityDTO;
import hyung.jin.seo.jae.dto.OnlineSessionDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.OnlineActivityService;
import hyung.jin.seo.jae.service.OnlineSessionService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("onlineCheck")
public class OnlineActivityController {

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
					System.out.println(studentId + " attends online class");
					List<OnlineActivityDTO> activities = onlineActivityService.getStudentStatus(studentId, set);
					// 6. add dto info in case
					for(OnlineActivityDTO activity : activities){
						if(activity.getOnlineSessionId().equalsIgnoreCase("0L")){
							activity.setOnlineSessionId(session.getId());
						}
						if(activity.getOnlineName().equalsIgnoreCase("")){
							activity.setOnlineName(session.getTitle());
						}
						if(activity.getSet()==0){
						activity.setSet(set);
						}
					}
					// 7. add online activity dto
					dtos.addAll(activities);
					
				}
			}
		}
		model.addAttribute(JaeConstants.LOGIN_LIST, dtos);
		return "onlineStatusListPage";
	}

}
