package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.CourseDTO;
import hyung.jin.seo.jae.model.Course;

public interface CourseRepository extends JpaRepository<Course, Long>{  
	
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c")
	List<CourseDTO> getAll();

	@Query(value = "SELECT c FROM Course c WHERE c.cycle.year = :year")
	List<Course> getAll(@Param("year") int year);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE c.grade = :grade")
	List<CourseDTO> getByGrade(@Param("grade") String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE c.grade = :grade AND c.active = true")
	List<CourseDTO> getActiveByGrade(@Param("grade") String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE (:grade = '0' OR c.grade = :grade) AND (:year = 0 OR c.cycle.year = :year)")
	List<CourseDTO> getByGradeNYear(@Param("grade") String grade, @Param("year") int year);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE (:grade = '0' OR c.grade = :grade) AND (:year = 0 OR c.cycle.year = :year) AND c.active = true")
	List<CourseDTO> getActiveByGradeNYear(@Param("grade") String grade, @Param("year") int year);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE c.grade = :grade AND c.online = 0 AND c.active = true")
	List<CourseDTO> findOnsiteByGrade(@Param("grade") String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE c.grade = :grade AND c.online = 1 AND c.active = true")
	List<CourseDTO> findOnlineByGrade(@Param("grade") String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.CourseDTO(c.id, c.name, c.description, c.grade, c.online, c.price, c.cycle.id, c.cycle.year, c.active) FROM Course c WHERE c.cycle.year = :year AND c.online = 1 AND c.active = true")
	List<CourseDTO> findOnlineByYear(@Param("year") int year);

	@Modifying
    @Query("UPDATE Course c SET c.active = false WHERE c.id = :id")
    int updateCourseSetActiveFalseById(@Param("id") Long id);

	@Modifying
    @Query("UPDATE Course c SET c.active = true WHERE c.id = :id")
    int updateCourseSetActiveTrueById(@Param("id") Long id);

	@Query("SELECT c FROM Course c WHERE c.grade = :grade AND c.name = :name AND c.online = :online AND c.cycle.year = :year")
	Course findByGradeAndNameAndOnlineAndCycleYear(@Param("grade") String grade, @Param("name") String name, @Param("online") boolean online, @Param("year") int year);

}

