package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

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

	// return attendance by student id, clazz id and week
	@Query("SELECT a FROM Attendance a WHERE a.student.id = ?1 AND a.clazz.id = ?2 AND a.week = ?3")
	Attendance getAttendanceByStudentIdAndClazzIdAndWeek(long studentId, long clazzId, String week);


	// update status by student id, clazz id and week
	// @Modifying
    // @Transactional
    // @Query("UPDATE Attendance a SET a.status = :newStatus WHERE a.student.id = :studentId AND a.clazz.id = :clazzId AND a.week = :week")
    // void updateStatusByStudentIdAndClazzIdAndWeek(
    //         @Param("studentId") long studentId,
    //         @Param("clazzId") long clazzId,
    //         @Param("week") int week,
    //         @Param("newStatus") String newStatus);

	@Modifying
    @Transactional
    @Query("UPDATE Attendance a SET a.status = ?4 WHERE a.student.id = ?1 AND a.clazz.id = ?2 AND a.week = ?3")
    void updateStatusByStudentIdAndClazzIdAndWeek(
            long studentId,
            long clazzId,
            String week,
            String newStatus);

			
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
