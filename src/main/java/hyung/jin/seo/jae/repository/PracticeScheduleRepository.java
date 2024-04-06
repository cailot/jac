package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.PracticeScheduleDTO;
import hyung.jin.seo.jae.model.PracticeSchedule;

public interface PracticeScheduleRepository extends JpaRepository<PracticeSchedule, Long>{  
	
	List<PracticeSchedule> findAll();

	// filter PracticeScheduleDTO by year & week
	@Query("SELECT new hyung.jin.seo.jae.dto.PracticeScheduleDTO(p.id, p.year, p.week, p.info, p.active, p.registerDate) FROM PracticeSchedule p WHERE (?1 = 0 OR p.year = ?1) AND (?2 = 0 OR p.week = ?2)")
	List<PracticeScheduleDTO> filterPracticeScheduleByYearNWeek(int year, int week);

	// List<PracticeSchedule> findByGrade(String grade);

	// @Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online) FROM Course c WHERE c.grade = :grade AND c.online = 0")
	// List<CourseDTO> findOnsiteByGrade(@Param("grade") String grade);

	// @Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online) FROM Course c WHERE c.grade = :grade AND c.online = 1")
	// List<CourseDTO> findOnlineByGrade(@Param("grade") String grade);

	// long count();
}

