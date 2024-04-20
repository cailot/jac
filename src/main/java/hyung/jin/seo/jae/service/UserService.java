package hyung.jin.seo.jae.service;

import java.util.List;

import org.springframework.security.core.userdetails.UserDetailsService;

import hyung.jin.seo.jae.dto.UserDTO;
import hyung.jin.seo.jae.model.User;

public interface UserService extends UserDetailsService{
	
	// list Users
	List<UserDTO> listUsers(String role, String state, String branch);

	// retrieve user
	UserDTO getUser(String username);

	// update password
	void updatePassword(Long id, String password);

	// show all user list
	List<User> getAllUsers();
	
	// add user
	User addUser(User user);

	// modify user 
	User updateUser(User user, String username);
	
	// delete user
	int deleteUser(String username);
	
}