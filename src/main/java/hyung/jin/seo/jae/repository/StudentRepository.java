package hyung.jin.seo.jae.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Student;

public interface StudentRepository extends JpaRepository<Student, Long>{  
	
	List<Student> findAllByEndDateIsNull();
	
	List<Student> findAllByEndDateIsNotNull();
	
	Student findByIdAndEndDateIsNull(Long id);
	
        // search max Id based on state & branch to assign new student Id
        Long findMaxIdByStateAndBranch(String state, String branch);

	long countByEndDateIsNull();
	
	@Modifying
	@Query("UPDATE Student s SET s.endDate = null WHERE s.id = ?1")
	void setEndDateToNull(Long id);

	@Query(value = "SELECT DISTINCT c.year FROM jac.Cycle c WHERE c.id IN (SELECT l.cycleId FROM Class l WHERE l.id IN (SELECT e.clazzId FROM Enrolment e WHERE e.studentId = ?1))", nativeQuery = true)
        List<Integer> findYearsByStudentId(Long id);	

        @Modifying
        @Query(value = "UPDATE Student s SET s.password = ?2 WHERE s.id = ?1 AND ACTIVE = 0", nativeQuery = true)
        void updatePassword(Long id, String password);    

        @Modifying
        @Query(value = "UPDATE Student s SET s.grade = ?2 WHERE s.id = ?1", nativeQuery = true)
        void updateGrade(Long id, String grade);    


        ///////////////////////////////////////////// Student Stats Start /////////////////////////////////////////////

        @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student WHERE (registerDate <= :toDate AND active = 0) OR (endDate >= :fromDate AND registerDate <= :toDate AND active = 1) GROUP BY state, branch, grade", nativeQuery = true)
        List<Object[]> getActiveStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);

        @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student  WHERE endDate >= :fromDate AND registerDate <= :toDate AND active = 1 GROUP BY state, branch, grade", nativeQuery = true)
        List<Object[]> getInactiveStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);

        @Query(value = "SELECT s.state, s.branch, s.grade, COUNT(DISTINCT s.id) AS figures FROM Student s JOIN Enrolment e ON s.id = e.studentId JOIN Invoice i ON e.invoiceId = i.id WHERE i.paymentDate BETWEEN :fromDate AND :toDate GROUP BY s.state, s.branch, s.grade", nativeQuery = true)
        List<Object[]> getInvoiceStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);
        
        // retrieve active student by state, branch & grade called for statistics
	@Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.endDate, s.email1, s.contactNo1) FROM Student s WHERE (?1 = '0' OR s.branch = ?1) AND (?2 = '0' OR s.grade = ?2) AND ((registerDate <= ?4 AND active = 0) OR (endDate >= ?3 AND registerDate <= ?4 AND active = 1))")
	List<StudentDTO> listActiveStudent4Stats(String branch, String grade, LocalDate from, LocalDate to);

        // retrieve inactive student by state, branch & grade called for statistics
	@Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.endDate, s.email1, s.contactNo1) FROM Student s WHERE (?1 = '0' OR s.branch = ?1) AND (?2 = '0' OR s.grade = ?2) AND (endDate >= ?3) AND (registerDate <= ?4) AND (active = 1)")
	List<StudentDTO> listInactiveStudent4Stats(String branch, String grade, LocalDate from, LocalDate to);
        
        // retrieve invoice student by state, branch & grade called for statistics
        @Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.endDate, s.email1, s.contactNo1) FROM Student s JOIN Enrolment e ON s.id = e.student.id JOIN Invoice i ON e.invoice.id = i.id WHERE (?1 = '0' OR s.branch = ?1) AND (?2 = '0' OR s.grade = ?2) AND i.paymentDate BETWEEN ?3 AND ?4")
        List<StudentDTO> listInvoiceStudent4Stats(String branch, String grade, LocalDate from, LocalDate to);

        // retrieve overdue student by state, branch & grade called for statistics
        @Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.endDate, s.email1, s.contactNo1) FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "JOIN Invoice i ON i.id = e.invoice.id " +
        "JOIN Clazz clazz ON clazz.id = e.clazz.id " +
        "JOIN Course course ON course.id = clazz.course.id " +
        "JOIN Cycle cycle ON cycle.id = course.cycle.id " +
        "WHERE (i.amount > i.paidAmount) " +
        "AND (?1 = '0' OR s.branch = ?1) " +
        "AND (?2 = '0' OR s.grade = ?2) " +
        "AND ((cycle.year < ?3) OR (cycle.year = ?3 AND e.startWeek <= ?4))") 
        List<StudentDTO> listOverdueStudent4Stats(String branch, String grade, int year, int week);

        ///////////////////////////////////////////// Student Stats End /////////////////////////////////////////////


        // retrieve overdue student by state, branch & grade called from paymentList.jsp
        @Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.state, s.branch, p.registerDate, p.method, p.amount, i.id, p.id) FROM Student s " +
        "JOIN s.enrolments e " +  // Assuming Student has a 'Set<Enrolment> enrolments' relationship
        "JOIN e.invoice i " +
        "JOIN i.payments p " +  // Assuming Invoice has a 'Set<Payment> payments' relationship
        "WHERE (?1 = '0' OR s.branch = ?1) " +
        "AND (?2 = '0' OR s.grade = ?2) " +
        "AND (p.registerDate BETWEEN ?3 AND ?4)")
        List<StudentDTO> listPaymentStudent(String branch, String grade, LocalDate from, LocalDate to);

        // retrieve overdue student by state, branch & grade called from overdueList.jsp
        @Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.contactNo1, s.email1, s.state, s.branch, e.startWeek, e.endWeek, clazz.name) FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "JOIN Invoice i ON i.id = e.invoice.id " +
        "JOIN Clazz clazz ON clazz.id = e.clazz.id " +
        "JOIN Course course ON course.id = clazz.course.id " +
        "JOIN Cycle cycle ON cycle.id = course.cycle.id " +
        "WHERE (i.amount > i.paidAmount) " +
        "AND (e.discount != '100%') " +
        "AND (?1 = '0' OR s.branch = ?1) " +
        "AND (?2 = '0' OR s.grade = ?2) " +
        "AND ((cycle.year < ?3) OR (cycle.year = ?3 AND e.startWeek <= ?4))") 
        List<StudentDTO> listOverdueStudent(String branch, String grade, int year, int week);



        // search student by keyword for Id
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE (s.id = ?1) AND (?2 = '0' OR s.state = ?2) AND (?3 = '0' OR s.branch = ?3)")
	List<StudentDTO> searchStudentByKeywordId(Long keyword, String state, String branch);

        @Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE s.id = ?1")
	StudentDTO searchStudentById(Long keyword);

        // search student by keyword for Name
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE (s.firstName LIKE ?1 OR s.lastName LIKE ?1) AND (?2 = '0' OR s.state = ?2) AND (?3 = '0' OR s.branch = ?3)")
	List<StudentDTO> searchStudentByKeywordName(String keyword, String state, String branch);

        // list active enrolled student, PASSWORD is replaced with enrolment date, contactNo2 is replaced with clazz name 
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentDTO" +
        "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, e.clazz.name, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, e.registerDate, s.active, e.startWeek, e.endWeek) " +
        "FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "WHERE s.endDate IS NULL " +
        "AND (:state = '0' OR s.state = :state) " +
        "AND (:branch = '0' OR s.branch = :branch) " +
        "AND (:grade = '0' OR s.grade = :grade) " +
        "AND e.old = false " +
        "AND e.discount != '" + "100%" + "' " +
        "AND e.clazz.id IN (" +
        "SELECT cla.id FROM Clazz cla WHERE cla.course.cycle.id IN (" +
        "SELECT cyc.id FROM Cycle cyc WHERE cyc.year = :year))")
	List<StudentDTO> listActiveStudent(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade, @Param("year") int year);

        // list inactive enrolled student, PASSWORD is replaced with enrolment date, contactNo2 is replaced with clazz name 
	@Query("SELECT new hyung.jin.seo.jae.dto.StudentDTO" +
        "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, e.clazz.name, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, e.registerDate, s.active, e.startWeek, e.endWeek) " +
        "FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "WHERE s.endDate IS NOT NULL " +
        "AND (:state = '0' OR s.state = :state) " +
        "AND (:branch = '0' OR s.branch = :branch) " +
        "AND (:grade = '0' OR s.grade = :grade) " +
        "AND e.old = false " +
        "AND e.discount != '" + "100%" + "' " +
        "AND e.clazz.id IN (" +
        "SELECT cla.id FROM Clazz cla WHERE cla.course.cycle.id IN (" +
        "SELECT cyc.id FROM Cycle cyc WHERE cyc.year = :year))")
	List<StudentDTO> listInactiveStudent(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade, @Param("year") int year);

	// retrieve active student by state, branch & grade called from studentList.jsp
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.password, s.active) FROM Student s WHERE (?1 = '0' OR s.state = ?1) AND (?2 = '0' OR s.branch = ?2) AND (?3 = '0' OR s.grade = ?3) AND s.active = 0")
	List<StudentDTO> listActiveStudent(String state, String branch, String grade);

	// retrieve inactive student by state, branch & grade called from studentList.jsp
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.password, s.active) FROM Student s WHERE (?1 = '0' OR s.state = ?1) AND (?2 = '0' OR s.branch = ?2) AND (?3 = '0' OR s.grade = ?3) AND s.active = 1")
	List<StudentDTO> listInactiveStudent(String state, String branch, String grade);

        @Modifying
        @Query(value = "UPDATE Student s SET s.active = 1, s.endDate = CURDATE() WHERE s.id NOT IN (SELECT DISTINCT e.studentId FROM Enrolment e WHERE e.registerDate >= DATE_SUB(CURDATE(), INTERVAL ?1 DAY))", nativeQuery = true)
        int updateInactiveStudent(int days);    

}
