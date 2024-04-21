package hyung.jin.seo.jae.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
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

import hyung.jin.seo.jae.dto.UserDTO;
import hyung.jin.seo.jae.model.User;
import hyung.jin.seo.jae.service.UserService;
import hyung.jin.seo.jae.utils.JaeConstants;

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
		String password = formData.getPassword();
		BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		String encodedPassword = passwordEncoder.encode(password);
		user.setPassword(encodedPassword);
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

	// update user password
	@PutMapping("/updatePassword/{id}/{pwd}")
	@ResponseBody
	public void updatePassword(@PathVariable String id, @PathVariable String pwd) {
		userService.updatePassword(id, pwd);
	}

	// remove user by username
	@PutMapping("/delete/{id}")
	@ResponseBody
	public ResponseEntity<String> deleteUser(@PathVariable("id") String id) {
		try{
			userService.deleteUser(id);
			return ResponseEntity.ok("User delete success");				
		}catch(Exception e){
			String message = "Error deleting branch: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}
	
}
