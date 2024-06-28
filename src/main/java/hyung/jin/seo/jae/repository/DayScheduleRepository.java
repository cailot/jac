package hyung.jin.seo.jae.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.DaySchedule;

public interface DayScheduleRepository extends JpaRepository<DaySchedule, Long>{  
	
	List<DaySchedule> findAll();
	
	@Query(value = "SELECT d.name, d.code FROM DaySchedule d", nativeQuery = true)   
	List<Object[]> loadDay();
}
