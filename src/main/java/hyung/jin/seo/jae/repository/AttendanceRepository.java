package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.model.Attendance;

public interface AttendanceRepository extends JpaRepository<Attendance, Long>{  


	// bring AttendanceDTO by clazz id
	@Query("SELECT new hyung.jin.seo.jae.dto.AttendanceDTO(a.id, a.attendDate, a.status, a.week, a.info, a.student.id, a.student.firstName, a.student.lastName, a.clazz.id, a.clazz.day, a.clazz.course.grade, a.clazz.name) FROM Attendance a WHERE a.clazz.id = ?1 ORDER BY a.attendDate") 
	List<AttendanceDTO> findAttendanceByClazzId(long clazzId);

	// bring AttendanceDTO by student id
	@Query("SELECT new hyung.jin.seo.jae.dto.AttendanceDTO(a.id, a.attendDate, a.status, a.week, a.info, a.student.id, a.student.firstName, a.student.lastName, a.clazz.id, a.clazz.day, a.clazz.course.grade, a.clazz.name) FROM Attendance a WHERE a.student.id = ?1 ORDER BY a.attendDate") 
	List<AttendanceDTO> findAttendanceByStudentId(long studentId);

	// bring AttendanceDTO by student id & clazz id
	@Query("SELECT new hyung.jin.seo.jae.dto.AttendanceDTO(a.id, a.attendDate, a.status, a.week, a.info, a.student.id, a.student.firstName, a.student.lastName, a.clazz.id, a.clazz.day, a.clazz.course.grade, a.clazz.name) FROM Attendance a WHERE a.student.id = ?1 AND a.clazz.id = ?2 ORDER BY a.attendDate") 
	List<AttendanceDTO> findAttendanceByStudentIdAndClazzId(long studentId, long clazzId);	

	// return attendance id by clazz id
	@Query("SELECT a.id FROM Attendance a WHERE a.clazz.id = ?1")
	List<Long> findAttendanceIdByClazzId(long clazzId);

	// return attendance id by student id
	@Query("SELECT a.id FROM Attendance a WHERE a.student.id = ?1")
	List<Long> findAttendanceIdByStudentId(long studentId);

	// return attendance id by student id & clazz id
	@Query("SELECT a.id FROM Attendance a WHERE a.student.id = ?1 AND a.clazz.id = ?2")
	List<Long> findAttendanceIdByStudentIdAndClazzId(long studentId, long clazzId);

	// return student id by clazz id
	@Query("SELECT DISTINCT a.student.id FROM Attendance a WHERE a.clazz.id = ?1")
	List<Long> findStudentIdByClazzId(long clazzId);

	


}
