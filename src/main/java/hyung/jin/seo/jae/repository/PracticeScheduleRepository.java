package hyung.jin.seo.jae.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.PracticeScheduleDTO;
import hyung.jin.seo.jae.model.PracticeSchedule;

public interface PracticeScheduleRepository extends JpaRepository<PracticeSchedule, Long>{  
	
	List<PracticeSchedule> findAll();

	// filter PracticeScheduleDTO by time & practiceGroup
	// @Query("SELECT new hyung.jin.seo.jae.dto.PracticeScheduleDTO(p.id, p.fromDatetime, p.toDatetime, p.grade, p.practiceGroup, p.week, p.info, p.active, p.registerDate) " +
	// "FROM PracticeSchedule p " +
	// "WHERE p.fromDatetime BETWEEN :from AND :to " +
	// "AND (:practiceGroup = '0' OR p.practiceGroup = :practiceGroup OR p.practiceGroup LIKE CONCAT('%,', :practiceGroup, ',%') OR p.practiceGroup LIKE CONCAT(:practiceGroup, ',%') OR p.practiceGroup LIKE CONCAT('%,', :practiceGroup))")
	// List<PracticeScheduleDTO> filterPracticeScheduleByTimeNGroup(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to, @Param("practiceGroup") String practiceGroup, Pageable pageable);

	// filter PracticeScheduleDTO by time & practiceGroup
	@Query("SELECT new hyung.jin.seo.jae.dto.PracticeScheduleDTO(p.id, p.fromDatetime, p.toDatetime, p.grade, p.practiceGroup, p.week, p.info, p.active, p.registerDate) " +
	"FROM PracticeSchedule p " +
	"WHERE p.fromDatetime BETWEEN :from AND :to " +
	"AND (:practiceGroup = '0' OR p.practiceGroup = :practiceGroup OR p.practiceGroup LIKE CONCAT('%,', :practiceGroup, ',%') OR p.practiceGroup LIKE CONCAT(:practiceGroup, ',%') OR p.practiceGroup LIKE CONCAT('%,', :practiceGroup))")
	List<PracticeScheduleDTO> filterPracticeScheduleByTimeNGroup(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to, @Param("practiceGroup") String practiceGroup);

}

