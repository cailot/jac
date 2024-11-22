package hyung.jin.seo.jae.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.HomeworkScheduleDTO;
import hyung.jin.seo.jae.model.HomeworkSchedule;

public interface HomeworkScheduleRepository extends JpaRepository<HomeworkSchedule, Long>{  
	
	@SuppressWarnings("null")
	List<HomeworkSchedule> findAll();
	
	@SuppressWarnings("null")
	Optional<HomeworkSchedule> findById(Long id);
	
	@Query("SELECT new hyung.jin.seo.jae.dto.HomeworkScheduleDTO(h.id, h.fromDatetime, h.toDatetime, h.grade, h.subject, h.subjectDisplay, h.answerDisplay, h.info, h.active, h.registerDate) " + 
	"FROM HomeworkSchedule h WHERE h.fromDatetime BETWEEN :from AND :to " +
	"ORDER BY h.id")
	List<HomeworkScheduleDTO> filterHomeworkScheduleByYear(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

}
