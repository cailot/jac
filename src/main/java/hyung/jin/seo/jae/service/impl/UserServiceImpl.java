package hyung.jin.seo.jae.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
	public User getUser(Long id) {
		User std = null;
		try{
			std = userRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No User found");
		}
		return std;
	}

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
	public User getUser(String username) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'getUser'");
	}

	@Override
	public List<User> getAllUsers() {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'getAllUsers'");
	}


	@Override
	@Transactional
	public int modifyUser(User user) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'modifyUser'");
	}

	@Override
	@Transactional
	public int deleteUser(String username) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'deleteUser'");
	}
}
