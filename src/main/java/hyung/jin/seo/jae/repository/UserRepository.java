package hyung.jin.seo.jae.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.User;

public interface UserRepository extends JpaRepository<User, Long>{  
	
	@SuppressWarnings("null")
	List<User> findAll();
	
	@Query(value = "UPDATE User u SET u.password = ?2 WHERE u.id = ?1 AND ACTIVE = 0", nativeQuery = true)
    void updatePassword(Long id, String password);    

    @Query(value = "SELECT u.id, u.username, u.password, u.enabled, u.firstName, u.lastName, u.role, u.state, u.branch, u.email, u.phone FROM User u WHERE u.username =?1 AND u.enabled = 0", nativeQuery = true)   
	Object[] checkUserAccount(String username);

}

