package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.BookDTO;
import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.dto.OnlineSessionDTO;
import hyung.jin.seo.jae.model.Book;
import hyung.jin.seo.jae.model.OnlineSession;
import hyung.jin.seo.jae.service.BookService;
import hyung.jin.seo.jae.service.OnlineSessionService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("onlineSesion")
public class OnlineSessionController {

	//private static final Logger LOG = LoggerFactory.getLogger(JaeBookController.class);

	@Autowired
	private OnlineSessionService onlineSessionService;

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
	OnlineSession getOnlineSession(@PathVariable("id") Long id) {
		OnlineSession session = onlineSessionService.getOnlineSession(id);	
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
		String filteredYear = StringUtils.defaultString(year, "0");
		if(JaeConstants.ALL.equalsIgnoreCase(filteredYear)){
			dtos = onlineSessionService.filterOnlineSessionByGrade(grade);
		}else{
			dtos = onlineSessionService.filterOnlineSessionByGradeNYear(grade, Integer.parseInt(filteredYear));
		}
		model.addAttribute(JaeConstants.ONLINE_LIST, dtos);
		return "onlineListPage";
	}

}
