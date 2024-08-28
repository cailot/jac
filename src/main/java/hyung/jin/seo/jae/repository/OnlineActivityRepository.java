package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.OnlineActivityDTO;
import hyung.jin.seo.jae.model.OnlineActivity;

public interface OnlineActivityRepository extends JpaRepository<OnlineActivity, Long>{  
    
    // find by student id and onlinesession id
    OnlineActivity findByStudentIdAndOnlineSessionId(Long studentId, Long onlineSessionId);

    @Query("SELECT new hyung.jin.seo.jae.dto.OnlineActivityDTO(o.id, o.student.id, s.firstName, s.lastName, s.grade, os.id, os.title, o.registerDate, o.status, o.startDateTime, o.endDateTime) " +
    "FROM OnlineActivity o " +
    "JOIN Student s ON o.student.id = s.id " +
    "JOIN Enrolment e ON e.student.id = s.id " +
    "JOIN OnlineSession os ON o.onlineSession.id = os.id " +
    "WHERE (:branch = '0' OR s.branch = :branch) " + 
    "AND (:grade = '0' OR s.grade = :grade) " + 
    "AND (e.clazz.course.online = true) " + 
    "AND (os.week = :week) " + 
    "ORDER BY o.student.id")
    List<OnlineActivityDTO> findStudentStatus(@Param("branch") String branch, @Param("grade") String grade, @Param("week") int week);
}