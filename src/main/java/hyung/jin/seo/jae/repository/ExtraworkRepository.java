package hyung.jin.seo.jae.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.ExtraworkDTO;
import hyung.jin.seo.jae.model.Extrawork;

public interface ExtraworkRepository extends JpaRepository<Extrawork, Long>{  
	
	@SuppressWarnings("null")
	List<Extrawork> findAll();
	
	@SuppressWarnings("null")
	Optional<Extrawork> findById(Long id);
	
	// bring HomeworkDTO by id
	// @Query("SELECT new hyung.jin.seo.jae.dto.HomeworkDTO(h.id, h.videoPath, h.pdfPath, h.week, h.year, h.info, h.active, h.grade.id, h.subject.id, h.registerDate) FROM Homework h WHERE h.subject.id = ?1 AND h.year = ?2  AND h.week = ?3")
	// ExtraworkDTO findExtrawork(long subjectId, int year, int week);

	// filter ExtraworkDTO by grade
	@Query("SELECT new hyung.jin.seo.jae.dto.ExtraworkDTO(e.id, e.videoPath, e.pdfPath, e.name, e.active, e.grade.code, e.registerDate) FROM Extrawork e WHERE ?1 = 'All' OR e.grade.code = ?1")
	List<ExtraworkDTO> filterExtraworkByGrade(String grade);

}
