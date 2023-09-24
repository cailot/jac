package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.model.Clazz;

public interface ClazzRepository extends JpaRepository<Clazz, Long>{  
	
	
	// list all class for grade
	@Query("SELECT new hyung.jin.seo.jae.dto.ClazzDTO(c.id, c.state, c.branch, c.course.price, c.day, c.name, c.startDate, c.active, c.course.id, c.cycle.id, c.course.grade, c.course.description, c.cycle.year) FROM Clazz c WHERE c.course.grade = ?1")
	List<ClazzDTO> findClassForGrade(String grade);

	// list all class for year
	@Query("SELECT new hyung.jin.seo.jae.dto.ClazzDTO(c.id, c.state, c.branch, c.course.price, c.day, c.name, c.startDate, c.active, c.course.id, c.cycle.id, c.course.grade, c.course.description, c.cycle.year) FROM Clazz c WHERE c.cycle.year = ?1")
	List<ClazzDTO> findClassForYear(int year);

	// list all class for grade & year
	@Query("SELECT new hyung.jin.seo.jae.dto.ClazzDTO(c.id, c.state, c.branch, c.course.price, c.day, c.name, c.startDate, c.active, c.course.id, c.cycle.id, c.course.grade, c.course.description, c.cycle.year) FROM Clazz c WHERE c.course.grade = ?1 AND c.cycle.year = ?2")
	List<ClazzDTO> findClassForGradeNCycle(String grade, int year);

	@Query("SELECT new hyung.jin.seo.jae.dto.ClazzDTO(c.id, c.state, c.branch, c.course.price, c.day, c.name, c.startDate, c.active, c.course.id, c.cycle.id, c.course.grade, c.course.description, c.cycle.year) FROM Clazz c WHERE c.course.id = ?1 AND c.cycle.year = ?2")
	List<ClazzDTO> findClassForCourseIdNCycle(Long id, int year);


	// list all class for state, branch, grade
	@Query("SELECT new hyung.jin.seo.jae.dto.ClazzDTO(c.id, c.state, c.branch, c.course.price, c.day, c.name, c.startDate, c.active, c.course.id, c.cycle.id, c.course.grade, c.course.description, c.cycle.year) FROM Clazz c WHERE (?1 = 'All' OR c.state = ?1) AND (?2 = 'All' OR c.branch = ?2) AND (?3 = 'All' OR c.course.grade = ?3)")
	List<ClazzDTO> findClassForStateNBranchNGrade(String state, String branch, String grade);

	// list all class for state, branch, grade, year
	@Query("SELECT new hyung.jin.seo.jae.dto.ClazzDTO(c.id, c.state, c.branch, c.course.price, c.day, c.name, c.startDate, c.active, c.course.id, c.cycle.id, c.course.grade, c.course.description, c.cycle.year) FROM Clazz c WHERE (?1 = 'All' OR c.state = ?1) AND (?2 = 'All' OR c.branch = ?2) AND (?3 = 'All' OR c.course.grade = ?3) AND c.cycle.year = ?4")
	List<ClazzDTO> findClassForStateNBranchNGradeNYear(String state, String branch, String grade, int year);

	// get price by class id
	@Query(value = "SELECT cos.price FROM Course cos where cos.id = (SELECT c.courseId FROM Class c WHERE c.id = :clazzId)", nativeQuery = true)
	double getPrice(Long clazzId);

	// get academic year by class id
	@Query(value = "SELECT c.cycle.year FROM Clazz c where c.id = ?1")
	int getYear(Long clazzId);

}