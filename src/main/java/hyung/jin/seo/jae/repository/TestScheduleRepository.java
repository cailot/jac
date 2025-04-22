package hyung.jin.seo.jae.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.model.TestSchedule;

public interface TestScheduleRepository extends JpaRepository<TestSchedule, Long>{  
	
	List<TestSchedule> findAll();

	// filter TestScheduleDTO by year & week
	// @Query("SELECT new hyung.jin.seo.jae.dto.TestScheduleDTO(t.id, t.year, t.week, t.info, t.active, t.registerDate, t.startDate, t.endDate) FROM TestSchedule t WHERE (?1 = 0 OR t.year = ?1) AND (?2 = 0 OR t.week = ?2)")
	// List<TestScheduleDTO> filterTestScheduleByYearNWeek(int year, int week);

	// filter TestScheduleDTO by time & testGroup
	@Query("SELECT new hyung.jin.seo.jae.dto.TestScheduleDTO(t.id, t.fromDatetime, t.toDatetime, t.grade, t.testGroup, t.week, t.info, t.active, t.registerDate, t.resultDate, t.explanationFromDatetime, t.explanationToDatetime) " +
	"FROM TestSchedule t " +
	"WHERE t.fromDatetime BETWEEN :from AND :to " +
	"AND (:testGroup = '0' OR t.testGroup = :testGroup)")
	List<TestScheduleDTO> filterTestScheduleByTimeNGroup(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to, @Param("testGroup") String testGroup);

	// get TestScheduleDTO by id
	@Query("SELECT new hyung.jin.seo.jae.dto.TestScheduleDTO(t.id, t.fromDatetime, t.toDatetime, t.grade, t.testGroup, t.week, t.info, t.active, t.registerDate, t.resultDate, t.explanationFromDatetime, t.explanationToDatetime) FROM TestSchedule t WHERE t.id = ?1")
	TestScheduleDTO getTestScheduleById(Long id);

	// Bring TestScheduleDTO by grade, week & testGroup - recent top 1 only
	@Query("SELECT new hyung.jin.seo.jae.dto.TestScheduleDTO(t.id, t.fromDatetime, t.toDatetime, t.grade, t.testGroup, t.week, t.info, t.active, t.registerDate, t.explanationFromDatetime, t.explanationToDatetime) " +
	"FROM TestSchedule t WHERE (t.testGroup = '0' OR t.testGroup LIKE CONCAT('%,', :testGroup, ',%') OR t.testGroup LIKE CONCAT(:testGroup, ',%') OR t.testGroup LIKE CONCAT('%,', :testGroup) OR t.testGroup = :testGroup) " +
	"AND (t.grade = :grade) " +
	"AND (t.week = '0' OR t.week LIKE CONCAT('%,', :week, ',%') OR t.week LIKE CONCAT(:week, ',%') OR t.week LIKE CONCAT('%,', :week) OR t.week = :week) " +
	"AND (t.active = true) " +
	"ORDER BY t.registerDate DESC")
	TestScheduleDTO getTestScheduleByGroupNGradeNWeekTop1(@Param("testGroup") String testGroup, @Param("grade") String grade, @Param("week") String week);

}

