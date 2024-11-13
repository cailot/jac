package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.NoticeEmailDTO;
import hyung.jin.seo.jae.model.NoticeEmail;

public interface NoticeEmailRepository extends JpaRepository<NoticeEmail, Long>{  
	
	// list emails except body
	@Query("SELECT new hyung.jin.seo.jae.dto.NoticeEmailDTO(n.id, n.title, n.grade, n.state, n.branch, n.sender, n.registerDate) " +
		"FROM NoticeEmail n " +
		"WHERE (n.state = ?1) " +
		"AND (?2 = '0' OR n.sender = ?2) " +
		"AND (?3 = '0' OR n.grade = ?3) " +
		"ORDER BY n.registerDate DESC")
	List<NoticeEmailDTO> findEmails(String state, String sender, String grade);
}
