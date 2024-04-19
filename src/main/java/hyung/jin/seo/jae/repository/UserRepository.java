package hyung.jin.seo.jae.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.UserDTO;
import hyung.jin.seo.jae.model.User;

public interface UserRepository extends JpaRepository<User, String>{  
	
	@SuppressWarnings("null")
	List<User> findAll();
	
	@Query(value = "UPDATE User u SET u.password = ?2 WHERE u.id = ?1 AND ACTIVE = 0", nativeQuery = true)
    void updatePassword(Long id, String password);    

    @Query(value = "SELECT u.username, u.password, u.enabled, u.firstName, u.lastName, u.role, u.state, u.branch, u.email, u.phone FROM User u WHERE u.username =?1 AND u.enabled = 0", nativeQuery = true)   
	Object[] checkUserAccount(String username);

	// search by role
	@Query("SELECT new hyung.jin.seo.jae.dto.UserDTO(u.username, u.firstName, u.lastName, u.enabled, u.phone, u.email, u.role, u.state, u.branch) FROM User u WHERE (?1 = 'All' OR u.role = ?1) AND (?2 = 'All' OR u.state = ?2) AND (?3 = 'All' OR u.branch = ?3)")
	List<UserDTO> listUsers(String role, String state, String branch);


}

