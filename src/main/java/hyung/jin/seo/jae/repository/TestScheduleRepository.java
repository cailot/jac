package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.model.TestSchedule;

public interface TestScheduleRepository extends JpaRepository<TestSchedule, Long>{  
	
	List<TestSchedule> findAll();

	// filter TestScheduleDTO by year & week
	@Query("SELECT new hyung.jin.seo.jae.dto.TestScheduleDTO(t.id, t.year, t.week, t.info, t.active, t.registerDate, t.startDate, t.endDate) FROM TestSchedule t WHERE (?1 = 0 OR t.year = ?1) AND (?2 = 0 OR t.week = ?2)")
	List<TestScheduleDTO> filterTestScheduleByYearNWeek(int year, int week);

}

