package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.CourseDTO;
import hyung.jin.seo.jae.model.Course;

public interface CourseRepository extends JpaRepository<Course, Long>{  
	
	List<Course> findAll();

	List<Course> findByGrade(String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online) FROM Course c WHERE c.grade = :grade AND c.online = 0")
	List<CourseDTO> findOnsiteByGrade(@Param("grade") String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online) FROM Course c WHERE c.grade = :grade AND c.online = 1")
	List<CourseDTO> findOnlineByGrade(@Param("grade") String grade);

	long count();
}

