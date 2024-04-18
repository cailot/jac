package hyung.jin.seo.jae.service;

import java.util.List;

import org.springframework.security.core.userdetails.UserDetailsService;

import hyung.jin.seo.jae.model.User;

public interface UserService extends UserDetailsService{
	
	// get User info
	User getUser(Long id);

	// retrieve user
	User getUser(String username);

	// update password
	void updatePassword(Long id, String password);

	// show all user list
	List<User> getAllUsers();
	
	// add user
	User addUser(User user);

	// modify user 
	int modifyUser(User user);
	
	// delete user
	int deleteUser(String username);
	
}