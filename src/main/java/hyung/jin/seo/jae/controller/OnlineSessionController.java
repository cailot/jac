package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.OnlineSessionDTO;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.OnlineSession;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.OnlineSessionService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("onlineSession")
public class OnlineSessionController {

	//private static final Logger LOG = LoggerFactory.getLogger(JaeBookController.class);

	@Autowired
	private OnlineSessionService onlineSessionService;

	@Autowired
	private ClazzService clazzService;

	// search all online sessions
	@GetMapping("/all")
	@ResponseBody
	List<OnlineSessionDTO> listOnlineSessions() {
		List<OnlineSessionDTO> dtos = onlineSessionService.allOnlineSessions();
		return dtos;
	}	
	
	// get online session by Id
	@GetMapping("/get/{id}")
	@ResponseBody
	OnlineSessionDTO getOnlineSession(@PathVariable("id") Long id) {
		OnlineSessionDTO session = onlineSessionService.getOnlineSession(id);	
		return session;
	}

	// count records number in database
	@GetMapping("/count")
	@ResponseBody
	long coutFees() {
		long count = onlineSessionService.checkCount();
		return count;
	}

	
	// bring all online sessions in database
	@GetMapping("/filterSession")
	public String filterOnlineSessions(
			@RequestParam(value = "listGrade", required = false) String grade,
			@RequestParam(value = "listYear", required = false) String year, 
			Model model) {
		List<OnlineSessionDTO> dtos = new ArrayList();
		String filteredGrade = StringUtils.defaultString(grade);
		String filteredYear = StringUtils.defaultString(year, "0");
	    if ("0".equalsIgnoreCase(filteredGrade) && "0".equalsIgnoreCase(filteredYear)) {
			// grade & year = all
			dtos = onlineSessionService.allOnlineSessions();
		} else if ("0".equalsIgnoreCase(filteredGrade)) {
			// grade = all, year = some
			dtos = onlineSessionService.filterOnlineSessionByYear(Integer.parseInt(filteredYear));
		} else if ("0".equalsIgnoreCase(filteredYear)) {
			// grade = some, year = all
			dtos = onlineSessionService.filterOnlineSessionByGrade(grade);
		} else {
			// grade = some, year = some
			dtos = onlineSessionService.filterOnlineSessionByGradeNYear(grade, Integer.parseInt(filteredYear));
		}
		model.addAttribute(JaeConstants.ONLINE_LIST, dtos);
		return "onlineListPage";
	}


	// register online session
	@PostMapping("/register")
	@ResponseBody
	public ResponseEntity<String> registerOnline(@RequestBody OnlineSessionDTO formData) {
		try {
			// 1. create OnlineSession
			OnlineSession session = formData.convertToOnlineSession();
			// 2. set active to true as default
			session.setActive(true);
			// 3. get Clazz
			Clazz clazz = clazzService.getOnlineByGradeNYear(formData.getGrade(), formData.getYear());
			if(clazz==null){
				return ResponseEntity.status(HttpStatus.EXPECTATION_FAILED).body("\"Please register online class first\"");
			}else{
			// 4. assign Clazz
			session.setClazz(clazz);
			// 5. add OnlineSession
			onlineSessionService.addOnlineSession(session);
			// 6. return success;
			return ResponseEntity.ok("\"Online Session register success\"");
			}
		} catch (Exception e) {
			String message = "Error registering Online Session: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// update existing class
	@PutMapping("/update")
	@ResponseBody
	public ResponseEntity<String> updateOnline(@RequestBody OnlineSessionDTO formData) {
		try {
			// 1. create bare OnlineSession
			OnlineSession session = formData.convertToOnlineSession();
			// 2. get Clazz
			Clazz clazz = clazzService.getClazz(Long.parseLong(formData.getClazzId()));
			// 3. assign Clazz
			session.setClazz(clazz);
			// 4. save OnlineSession
			onlineSessionService.updateOnlineSession(session, Long.parseLong(formData.getId()));
			// 5. return flag
			return ResponseEntity.ok("\"Online Session update success\"");
		} catch (Exception e) {
			String message = "Error updating Online Session : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	@DeleteMapping(value = "/delete/{onlineId}")
	@ResponseBody
    public ResponseEntity<String> removeOnline(@PathVariable String onlineId) {
        Long id = Long.parseLong(StringUtils.defaultString(onlineId, "0"));
		onlineSessionService.deleteOnlineSession(id);
		return ResponseEntity.ok("\"Online Session deleted successfully\"");
    }
}
