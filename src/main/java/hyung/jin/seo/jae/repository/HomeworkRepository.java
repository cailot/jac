package hyung.jin.seo.jae.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.model.Homework;

public interface HomeworkRepository extends JpaRepository<Homework, Long>{  
	
	@SuppressWarnings("null")
	List<Homework> findAll();
	
	@SuppressWarnings("null")
	Optional<Homework> findById(Long id);
	
	// bring HomeworkDTO by id
	@Query("SELECT new hyung.jin.seo.jae.dto.HomeworkDTO(h.id, h.videoPath, h.pdfPath, h.week, h.info, h.active, h.grade.code, h.subject.id, h.registerDate) FROM Homework h WHERE h.subject.id = ?1 AND h.week = ?2")
	HomeworkDTO findHomework(Integer subject, int week);

	@Query("SELECT new hyung.jin.seo.jae.dto.HomeworkDTO(h.id, h.videoPath, h.pdfPath, h.week, h.info, h.active, h.grade.code, h.subject.id, h.registerDate) " + 
	" FROM Homework h WHERE (?1 = 0 OR h.subject.id = ?1) AND (?2 = '0' OR h.grade.id = ?2) AND (?3 = 0 OR h.week = ?3) " +
	"ORDER BY h.week")
	List<HomeworkDTO> filterHomeworkBySubjectNGradeNYearNWeek(Integer subject, String grade, int week);

}
