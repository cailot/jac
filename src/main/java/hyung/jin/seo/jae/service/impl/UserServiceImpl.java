package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.UserDTO;
import hyung.jin.seo.jae.model.User;
import hyung.jin.seo.jae.repository.UserRepository;
import hyung.jin.seo.jae.service.UserService;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserRepository userRepository;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		User account = null;
		try{
			Object[] result = userRepository.checkUserAccount(username);
			if(result!=null && result.length > 0){
				Object[] obj = (Object[])result[0];
				account = new User(obj);
			}
		}catch(Exception e){
			throw new UsernameNotFoundException("User : " + username + " was not found in the database");
		}
		return account;
	}

	@Override
	@Transactional
	public User addUser(User user) {
		User add = userRepository.save(user);
		return add;
	}

	@Override
	public List<UserDTO> listUsers(String role, String state, String branch) {
		List<UserDTO> users = new ArrayList<>();
		try {
			users = userRepository.listUsers(role, state, branch);
		} catch (Exception e) {
			System.out.println("No user found");
		}
		return users;
	}

	@Override
	public UserDTO getUser(String username) {
		UserDTO dto = null;
		try{
			User user = userRepository.findByUsername(username);
			dto = new UserDTO(user);
		}catch(Exception e){
			System.out.println("No user found");
		}
		return dto;
	}

	@Override
	@Transactional
	public User updateUser(User newVal, String username) {
		// search by getId
		User existing = userRepository.findByUsername(username);
		// Update info
		String newFirstName = StringUtils.defaultString(newVal.getFirstName());
		existing.setFirstName(newFirstName);
		String newLastName = StringUtils.defaultString(newVal.getLastName());
		existing.setLastName(newLastName);
		// String newRole = StringUtils.defaultString(newVal.getRole());
		// existing.setRole(newRole);
		String newPhone = StringUtils.defaultString(newVal.getPhone());
		existing.setPhone(newPhone);
		String newEmail = StringUtils.defaultString(newVal.getEmail());
		existing.setEmail(newEmail);
		// String newState = StringUtils.defaultString(newVal.getState());
		// existing.setState(newState);
		// String newBranch = StringUtils.defaultString(newVal.getBranch());
		// existing.setBranch(newBranch);
		int newEnabled = newVal.getEnabled();
		existing.setEnabled(newEnabled);
		// update the existing record
		User updated = userRepository.save(existing);
		return updated;
	}

	

	// @Override
	// public User getUser(Long id) {
	// 	User std = null;
	// 	try{
	// 		std = userRepository.findById(id).get();
	// 	}catch(Exception e){
	// 		System.out.println("No User found");
	// 	}
	// 	return std;
	// }

	@Override
	@Transactional
	public void updatePassword(Long id, String password) {
		BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		String encodedPassword = passwordEncoder.encode(password);
		try{
			userRepository.updatePassword(id, encodedPassword);
		}catch(Exception e){
			System.out.println("No User found");
		}	
	}

	@Override
	public List<User> getAllUsers() {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'getAllUsers'");
	}


	

	@Override
	@Transactional
	public int deleteUser(String username) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'deleteUser'");
	}


}
