package hyung.jin.seo.jae.controller;

import java.text.ParseException;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.UserDTO;
import hyung.jin.seo.jae.model.User;
import hyung.jin.seo.jae.service.StatsService;
import hyung.jin.seo.jae.service.UserService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("user")
public class UserController {

	@Autowired
	private UserService userService;



	// register new user
	@PostMapping("/register")
	@ResponseBody
	public UserDTO registerTeacher(@RequestBody UserDTO formData) {
		User user = formData.convertToUser();
		// user.setUsername("sign");
		// String role = formData.getRole();
		// if (role.equals("1")) {
		// 	user.setRole(JaeConstants.ROLE_ADMIN);
		// } else if (role.equals("2")) {
		// 	user.setRole(JaeConstants.ROLE_STAFF);
		// }
		user = userService.addUser(user);
		UserDTO dto = new UserDTO(user);
		return dto;
	}


	// search user list with state, branch or active
	@GetMapping("/list")
	public String listUsers(@RequestParam(value = "listRole", required = false) String role,
		@RequestParam(value = "listState", required = false) String state,
		@RequestParam(value = "listBranch", required = false) String branch,		
		Model model) {
		List<UserDTO> dtos = userService.listUsers(role, state, branch);
		model.addAttribute(JaeConstants.USER_LIST, dtos);
		return "userListPage";
	}

	// search user by username
	@GetMapping("/get/{username}")
	@ResponseBody
	UserDTO getUser(@PathVariable String username) {
		UserDTO dto = userService.getUser(username);
		return dto;
	}

	// update existing user
	@PutMapping("/update")
	@ResponseBody
	public ResponseEntity<String> updateUser(@RequestBody UserDTO formData) {
		try{
			// 1. create barebone User
			User user = formData.convertToUser();
			// 2. update User
			user = userService.updateUser(user, user.getUsername());
			// 3.return flag
			return ResponseEntity.ok("\"Extrawork updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Extrawork : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}


	/*

	// search registration
	@PostMapping("/activeSearch")
	@ResponseBody
	public List<StatsDTO> searchActiveStats(@RequestParam String fromDate, @RequestParam String toDate) {
		// 1. get convert date format
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
		// 2. get Stats
		List<StatsDTO> dtos = statsService.getActiveStats(start, end);
		// 3. return dtos
		return dtos;
	}

	// search inactive
	@PostMapping("/inactiveSearch")
	@ResponseBody
	public List<StatsDTO> searchInactiveStats(@RequestParam String fromDate, @RequestParam String toDate) {
		// 1. get convert date format
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
		// 2. get Stats
		List<StatsDTO> dtos = statsService.getInactiveStats(start, end);
		// 3. return dtos
		return dtos;
	}

	// search active student with branch, grade, start/endDate
	@GetMapping("/activeStudent")
	@ResponseBody
	List<StudentDTO> listActiveStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate) {
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
		List<StudentDTO> dtos = statsService.listActiveStudent4Stats(branch, grade, start, end);
		return dtos;
	}

	// search inactive student with branch, grade, start/endDate
	@GetMapping("/inactiveStudent")
	@ResponseBody
	List<StudentDTO> listInactiveStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate) {
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
		List<StudentDTO> dtos = statsService.listInactiveStudent4Stats(branch, grade, start, end);
		return dtos;
	}



*/




}
