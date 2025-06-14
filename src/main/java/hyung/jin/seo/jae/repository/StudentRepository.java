package hyung.jin.seo.jae.repository;

import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO;
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
        @Query(value = "UPDATE Student s SET s.password = ?2 WHERE s.id = ?1 AND ACTIVE = 1", nativeQuery = true)
        void updatePassword(Long id, String password);    

        @Modifying
        @Query(value = "UPDATE Student s SET s.grade = ?2 WHERE s.id = ?1", nativeQuery = true)
        void updateGrade(Long id, String grade);    


        ///////////////////////////////////////////// Student Stats Start /////////////////////////////////////////////
         
        @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student WHERE ((registerDate <= :toDate AND active = 1) OR (endDate >= :fromDate AND registerDate <= :toDate AND active = 0)) AND branch = :branch GROUP BY state, branch, grade", nativeQuery = true)
        List<Object[]> getActiveStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate, @Param("branch") String branch); 

        // @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student WHERE (registerDate <= :toDate AND active = 1) OR (endDate >= :fromDate AND registerDate <= :toDate AND active = 0) GROUP BY state, branch, grade", nativeQuery = true)
        @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student WHERE (registerDate <= :toDate) " +
        "AND (active = 1 OR (active = 0 AND endDate > :fromDate)) " + 
        "GROUP BY state, branch, grade", nativeQuery = true)
        List<Object[]> getActiveStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);

        // @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student WHERE endDate >= :fromDate AND registerDate <= :toDate AND active = 0 GROUP BY state, branch, grade", nativeQuery = true)
        @Query(value = "SELECT state, branch, grade, COUNT(*) AS figures FROM Student WHERE (registerDate <= :fromDate) " +
        "AND (active = 0) AND (endDate <= :toDate) " +
        "GROUP BY state, branch, grade", nativeQuery = true)
        List<Object[]> getInactiveStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);

        @Query(value = "SELECT s.state, s.branch, s.grade, COUNT(DISTINCT s.id) AS figures FROM Student s JOIN Enrolment e ON s.id = e.studentId JOIN Invoice i ON e.invoiceId = i.id WHERE i.paymentDate BETWEEN :fromDate AND :toDate GROUP BY s.state, s.branch, s.grade", nativeQuery = true)
        List<Object[]> getInvoiceStudentStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);
        
        // retrieve active student by state, branch & grade called for statistics
	@Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.endDate, s.email1, s.contactNo1) FROM Student s WHERE (?1 = '0' OR s.branch = ?1) AND (?2 = '0' OR s.grade = ?2) AND ((registerDate <= ?4 AND active = 1) OR (endDate >= ?3 AND registerDate <= ?4 AND active = 0))")
	List<StudentDTO> listActiveStudent4Stats(String branch, String grade, LocalDate from, LocalDate to);

        // retrieve inactive student by state, branch & grade called for statistics
	@Query("SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.endDate, s.email1, s.contactNo1) FROM Student s " +
        "WHERE (?1 = '0' OR s.branch = ?1) AND (?2 = '0' OR s.grade = ?2) " +
        "AND (s.registerDate <= ?3) " +
        "AND s.active = 0 AND s.endDate <= ?4")
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


        // retrieve payment student by state, branch & grade called from paymentList.jsp
        @Query(value = "SELECT DISTINCT s.id AS studentId, s.firstName, s.lastName, s.grade, s.state, s.branch, " +
        "p.registerDate, p.method, p.amount, i.id AS invoiceId, p.invoiceHistoryId, p.id AS paymentId " +
        "FROM Student s " +
        "LEFT JOIN Enrolment e ON s.id = e.studentId " +
        "LEFT JOIN Invoice i ON e.invoiceId = i.id " +
        "LEFT JOIN Payment p ON i.id = p.invoiceId " +
        "WHERE (:branch = '0' OR s.branch = :branch) " +
        "AND (:grade = '0' OR s.grade = :grade) " +
        "AND ((:dateType = 'registerDate' AND p.registerDate BETWEEN :fromTime AND :toTime) " +
        "     OR (:dateType = 'payDate' AND p.payDate BETWEEN :fromTime AND :toTime))",
        nativeQuery = true)
        List<Object[]> listPaymentStudent(@Param("branch") String branch, @Param("grade") String grade, 
                                        @Param("dateType") String dateType,
                                        @Param("fromTime") LocalDate fromTime, @Param("toTime") LocalDate toTime);

        // retrieve payment student by state, branch & grade called from paymentList.jsp
        @Query(value = "SELECT DISTINCT s.id AS studentId, s.firstName, s.lastName, s.grade, s.state, s.branch, " +
        "p.registerDate, p.method, p.amount, i.id AS invoiceId, p.invoiceHistoryId, p.id AS paymentId, p.payDate " +
        "FROM Student s " +
        "LEFT JOIN Enrolment e ON s.id = e.studentId " +
        "LEFT JOIN Invoice i ON e.invoiceId = i.id " +
        "LEFT JOIN Payment p ON i.id = p.invoiceId " +
        "WHERE (:branch = '0' OR s.branch = :branch) " +
        "AND (:grade = '0' OR s.grade = :grade) " +
        "AND (:payment = '0' OR p.method = :payment) " +
        "AND ((:dateType = 'registerDate' AND p.registerDate BETWEEN :fromTime AND :toTime) " +
        "     OR (:dateType = 'payDate' AND p.payDate BETWEEN :fromTime AND :toTime))",
        nativeQuery = true)
        List<Object[]> listPaymentStudent(@Param("branch") String branch, @Param("grade") String grade, 
                                        @Param("payment") String payment, @Param("dateType") String dateType,
                                        @Param("fromTime") LocalDate fromTime, @Param("toTime") LocalDate toTime);

        // retrieve overdue student by state, branch & grade called from overdueList.jsp
        @Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(" +
        "s.id, s.firstName, s.lastName, s.grade, s.contactNo1, " +
        "(i.amount - i.paidAmount) AS overdueAmount, " +
        "s.email1, s.state, s.branch, e.startWeek, e.endWeek, clazz.name, " +
        "CASE WHEN i.paidAmount = 0 THEN 'Unpaid' ELSE 'OS' END) " +
        "FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "JOIN Invoice i ON i.id = e.invoice.id " +
        "JOIN Clazz clazz ON clazz.id = e.clazz.id " +
        "JOIN Course course ON course.id = clazz.course.id " +
        "JOIN Cycle cycle ON cycle.id = course.cycle.id " +
        "WHERE (i.amount > i.paidAmount) " +
        "AND (e.discount != '100%') " +
        "AND (?1 = '0' OR s.branch = ?1) " +
        "AND (?2 = '0' OR s.grade = ?2) " +
        "AND (?3 = 'all' OR (?3 = 'unpaid' AND i.paidAmount = 0) OR (?3 = 'os' AND i.paidAmount > 0)) " +
        "AND ((cycle.year < ?4) OR (cycle.year = ?4 AND e.startWeek <= ?5)) " +
        "AND e.startWeek = (SELECT MAX(en.startWeek) FROM Enrolment en WHERE en.student.id = s.id)")
        List<StudentDTO> listOverdueStudent(String branch, String grade, String type, int year, int week);

        // retrieve renew student by state, branch & grade called from renewList.jsp
        @Query(value = "SELECT DISTINCT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.contactNo1, s.email1, s.state, s.branch, e.startWeek, e.endWeek, clazz.name) FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "JOIN Invoice i ON i.id = e.invoice.id " +
        "JOIN Clazz clazz ON clazz.id = e.clazz.id " +
        "JOIN Course course ON course.id = clazz.course.id " +
        "JOIN Cycle cycle ON cycle.id = course.cycle.id " +
        "WHERE (e.discount != '100%') " +
        "AND (?1 = '0' OR s.branch = ?1) " +
        "AND (?2 = '0' OR s.grade = ?2) " +
        "AND (cycle.year = ?3 AND e.endWeek >= ?4)" +
        // "AND (cycle.year = ?5 AND e.endWeek <= ?6)") 
        "AND (cycle.year = ?5 AND e.endWeek <= ?6)" +
        "AND e.endWeek = (SELECT MAX(en.endWeek) FROM Enrolment en WHERE en.student.id = s.id)") 
        List<StudentDTO> listRenewStudent(String branch, String grade, int fromYear, int fromWeek, int toYear, int toWeek);

        // retrieve student login activity by state, branch & grade called from studyList.jsp
        @Query(value = "SELECT DISTINCT s.id AS studentId, s.firstName, s.lastName, s.grade, s.state, s.branch, " +
        "l.registerDate, s.firstName, s.lastName, l.id AS loginId, l.studentId, s.id AS paymentId " +
        "FROM Student s " +
        "LEFT JOIN LoginActivity l ON s.id = l.studentId " +
        "WHERE (:branch = '0' OR s.branch = :branch) " +
        "AND (:grade = '0' OR s.grade = :grade) " +
        "AND (l.registerDate BETWEEN :fromTime AND :toTime)",
        nativeQuery = true)
        List<Object[]> listStudentLogin(@Param("branch") String branch, @Param("grade") String grade, @Param("fromTime") LocalDate fromTime, @Param("toTime") LocalDate toTime);

        // search student by keyword for Id
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE (s.id = ?1) AND (?2 = '0' OR s.state = ?2) AND (?3 = '0' OR s.branch = ?3)")
	List<StudentDTO> searchStudentByKeywordId(Long keyword, String state, String branch);

        @Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE s.id = ?1")
	StudentDTO searchStudentById(Long keyword);

        // search student by keyword for Name
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE (LOWER(s.firstName) LIKE LOWER(CONCAT('%', ?1, '%')) OR LOWER(s.lastName) LIKE LOWER(CONCAT('%', ?1, '%'))) AND (?2 = '0' OR s.state = ?2) AND (?3 = '0' OR s.branch = ?3)")
	List<StudentDTO> searchStudentByKeywordName(String keyword, String state, String branch);
	
        // search student by keyword for email
        @Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE (s.email1 LIKE ?1 OR s.email2 LIKE ?1) AND (?2 = '0' OR s.state = ?2) AND (?3 = '0' OR s.branch = ?3)")
        List<StudentDTO> searchStudentByKeywordEmail(String keyword, String state, String branch);

        // search student by keyword for contact number with partial match
        @Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo, s.relation1, s.relation2) FROM Student s WHERE (LOWER(REPLACE(s.contactNo1, ' ', '')) LIKE LOWER(CONCAT('%', REPLACE(?1, ' ', ''), '%')) OR LOWER(REPLACE(s.contactNo2, ' ', '')) LIKE LOWER(CONCAT('%', REPLACE(?1, ' ', ''), '%'))) AND (?2 = '0' OR s.state = ?2) AND (?3 = '0' OR s.branch = ?3)")
        List<StudentDTO> searchStudentByKeywordContact(String keyword, String state, String branch);

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

        // list active enrolled student, PASSWORD is replaced with enrolment date, contactNo2 is replaced with clazz name 
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO" +
                "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, e.registerDate, s.email1, s.contactNo1, s.address, s.active, e.startWeek, e.endWeek, e.clazz.name) " +
                "FROM Student s " +
                "JOIN Enrolment e ON s.id = e.student.id " +
                "WHERE e.id = (" +
                "    SELECT MAX(en.id) FROM Enrolment en " +
                "    WHERE en.student.id = s.id " +
                "    AND en.old = false " +
                "    AND en.discount != '100%' " +
                "    AND (:week = 0 OR :week BETWEEN en.startWeek AND en.endWeek) " +
                "    AND en.clazz.id IN (" +
                "        SELECT cla.id FROM Clazz cla WHERE cla.course.cycle.id IN (" +
                "            SELECT cyc.id FROM Cycle cyc WHERE cyc.year = :year" +
                "        )" +
                "    )" +
                ") " +
                "AND (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (:grade = '0' OR s.grade = :grade)")
        List<StudentWithEnrolmentDTO> listEnroledStudent(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade, @Param("year") int year, @Param("week") int week);

        // list active enrolled student, PASSWORD is replaced with enrolment date, contactNo2 is replaced with clazz name 
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentDTO" +
        "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, " +
        "MAX(e.clazz.name), s.email1, s.email2, s.state, s.branch, " +
        "s.registerDate, s.endDate, MAX(e.registerDate), s.active, " +
        "MAX(e.startWeek), MAX(e.endWeek)) " +
        "FROM Student s " +
        "JOIN Enrolment e ON s.id = e.student.id " +
        "WHERE (:state = '0' OR s.state = :state) " +
        "AND (:branch = '0' OR s.branch = :branch) " +
        "AND (:grade = '0' OR s.grade = :grade) " +
        "AND e.old = false " +
        "AND e.discount != '100%' " +
        "GROUP BY s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.active")
        List<StudentDTO> listAllStudent(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade);

	// retrieve active student by state, branch & grade called from studentList.jsp
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo) FROM Student s WHERE (?1 = '0' OR s.state = ?1) AND (?2 = '0' OR s.branch = ?2) AND (?3 = '0' OR s.grade = ?3) AND s.active = 1")
	List<StudentDTO> listActiveStudent(String state, String branch, String grade);
        
	// retrieve inactive student by state, branch & grade called from studentList.jsp
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo) FROM Student s WHERE (?1 = '0' OR s.state = ?1) AND (?2 = '0' OR s.branch = ?2) AND (?3 = '0' OR s.grade = ?3) AND s.active = 0")
	List<StudentDTO> listInactiveStudent(String state, String branch, String grade);

        // retrieve all student by state, branch & grade called from studentList.jsp
	@Query(value = "SELECT new hyung.jin.seo.jae.dto.StudentDTO(s.id, s.firstName, s.lastName, s.grade, s.gender, s.contactNo1, s.contactNo2, s.email1, s.email2, s.state, s.branch, s.registerDate, s.endDate, s.address, s.active, s.memo) FROM Student s WHERE (?1 = '0' OR s.state = ?1) AND (?2 = '0' OR s.branch = ?2) AND (?3 = '0' OR s.grade = ?3)")
	List<StudentDTO> listStudent(String state, String branch, String grade);

        @Modifying
        @Query(value = "UPDATE Student s SET s.active = 1, s.endDate = CURDATE() WHERE s.id NOT IN (SELECT DISTINCT e.studentId FROM Enrolment e WHERE e.registerDate >= DATE_SUB(CURDATE(), INTERVAL ?1 DAY))", nativeQuery = true)
        int updateInactiveStudent(int days);  
        
        // get email list for student (email1 & email2)
        @Query(value = "SELECT DISTINCT s.email1 FROM Student s WHERE (:state = '0' OR s.state = :state) AND (:branch = '0' OR s.branch = :branch) AND (:grade = '0' OR s.grade = :grade) AND s.email1 IS NOT NULL AND s.active = true " +
                       "UNION " +
                       "SELECT DISTINCT s.email2 FROM Student s WHERE (:state = '0' OR s.state = :state) AND (:branch = '0' OR s.branch = :branch) AND (:grade = '0' OR s.grade = :grade) AND s.email2 IS NOT NULL AND s.active = true", nativeQuery = true)
        List<String> findValidEmailsByBranch(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade);
     
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /// Student List by State, Branch, Grade, Active, Date - studentList.jsp 
        // get all active student list 
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentDTO" +
               "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.email1, s.contactNo1, s.address, s.active) " +
               "FROM Student s " +
               "WHERE (:state = '0' OR s.state = :state) " +
               "AND (:branch = '0' OR s.branch = :branch) " +
               "AND (:grade = '0' OR s.grade = :grade) " +
               "AND (s.registerDate <= :weekDate)")
        List<StudentDTO> listAllStudentByStateNBranchNGrade(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade, @Param("weekDate") LocalDate weekDate);
        
        // get all active student list 
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentDTO" +
               "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.email1, s.contactNo1, s.address, s.active) " +
               "FROM Student s " +
               "WHERE (:state = '0' OR s.state = :state) " +
               "AND (:branch = '0' OR s.branch = :branch) " +
               "AND (:grade = '0' OR s.grade = :grade) " +
               "AND (s.registerDate <= :weekDate) " +
               "AND (s.active = 1 OR (s.active = 0 AND s.endDate > :weekDate))")
        List<StudentDTO> listAllActiveStudentByStateNBranchNGradeNDate(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade, @Param("weekDate") LocalDate weekDate);

        // get all in-active student list 
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentDTO" +
               "(s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, s.registerDate, s.email1, s.contactNo1, s.address, s.active) " +
               "FROM Student s " +
               "WHERE (:state = '0' OR s.state = :state) " +
               "AND (:branch = '0' OR s.branch = :branch) " +
               "AND (:grade = '0' OR s.grade = :grade) " +
               "AND (s.registerDate <= :weekDate) " +
               "AND s.active = 0 AND s.endDate <= :weekDate")
        List<StudentDTO> listAllInactiveStudentByStateNBranchNGradeNDate(@Param("state") String state, @Param("branch") String branch, @Param("grade") String grade, @Param("weekDate") LocalDate weekDate);
        /// Student List by State, Branch, Grade, Active, Date - studentList.jsp
        /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // get 'FirstName + LastName' by studentId
        @Query(value = "SELECT CONCAT(s.firstName, ' ', s.lastName) FROM Student s WHERE s.id = ?1", nativeQuery = true)
        String findStudentNameById(Long id);

        // get main email by studentId
        @Query(value = "SELECT s.email1 FROM Student s WHERE s.id = ?1", nativeQuery = true)
        String findStudentEmailById(Long id);

        // get student email recipients by studentId
        @Query(value = "SELECT s.email1, s.email2 FROM Student s WHERE s.id = ?1", nativeQuery = true)
        Object[] findStudentReceiptientById(Long id);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /// count summary by State, Branch, Grade, Active, Date - studentBranchList.jsp 
        @Query("SELECT s.grade, COUNT(s) " +
                "FROM Student s " +
                "WHERE (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (s.registerDate <= :weekDate) " +
                "GROUP BY s.grade")
        List<Object[]> countStudentsByGrade(@Param("state") String state, @Param("branch") String branch, @Param("weekDate") LocalDate weekDate);

        @Query("SELECT s.grade, COUNT(s) " +
                "FROM Student s " +
                "WHERE (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (s.registerDate <= :weekDate) " +
                "AND (s.active = 1 OR (s.active = 0 AND s.endDate > :weekDate)) " +
                "GROUP BY s.grade")
        List<Object[]> countActiveStudentsByGrade(@Param("state") String state, @Param("branch") String branch, @Param("weekDate") LocalDate weekDate);

        @Query("SELECT s.grade, COUNT(s) " +
                "FROM Student s " +
                "WHERE (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (s.registerDate <= :weekDate) " +
                "AND s.active = 0 " + 
                "AND s.endDate <= :weekDate " +
                "GROUP BY s.grade")
        List<Object[]> countInactiveStudentsByGrade(@Param("state") String state, @Param("branch") String branch, @Param("weekDate") LocalDate weekDate);

        // get student list with enrolment by grade                                                            
        @Query("SELECT new hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO(" +
                "s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, " +
                "s.registerDate, s.email1, s.contactNo1, s.address, s.active, " +
                "COALESCE((SELECT MAX(e.startWeek) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), 0), " +
                "COALESCE((SELECT MAX(e.endWeek) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), 0), " +
                "COALESCE((SELECT MAX(e.clazz.name) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), '')) " +
                "FROM Student s " +
                "WHERE (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (s.registerDate <= :weekDate) " +
                "AND (:grade = '0' OR s.grade = :grade) " +
                "ORDER BY s.id")
        List<StudentWithEnrolmentDTO> listAllStudentsWithEnrolmentByGradeAndWeek(@Param("state") String state, 
                @Param("branch") String branch, 
                @Param("grade") String grade,
                @Param("year") int year, 
                @Param("week") int week,
                @Param("weekDate") LocalDate weekDate);

        @Query("SELECT new hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO(" +
                "s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, " +
                "s.registerDate, s.email1, s.contactNo1, s.address, s.active, " +
                "COALESCE((SELECT MAX(e.startWeek) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), 0), " +
                "COALESCE((SELECT MAX(e.endWeek) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), 0), " +
                "COALESCE((SELECT MAX(e.clazz.name) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), '')) " +
                "FROM Student s " +
                "WHERE (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (s.registerDate <= :weekDate) " +
                "AND (:grade = '0' OR s.grade = :grade) " +
                "AND (s.active = 1 OR (s.active = 0 AND s.endDate > :weekDate))" + 
                "ORDER BY s.id")
        List<StudentWithEnrolmentDTO> listActiveStudentsWithEnrolmentByGradeAndWeek(@Param("state") String state, 
                @Param("branch") String branch, 
                @Param("grade") String grade,
                @Param("year") int year, 
                @Param("week") int week,
                @Param("weekDate") LocalDate weekDate);
        

        @Query("SELECT new hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO(" +
                "s.id, s.firstName, s.lastName, s.grade, s.gender, s.state, s.branch, " +
                "s.registerDate, s.email1, s.contactNo1, s.address, s.active, " +
                "COALESCE((SELECT MAX(e.startWeek) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), 0), " +
                "COALESCE((SELECT MAX(e.endWeek) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), 0), " +
                "COALESCE((SELECT MAX(e.clazz.name) FROM Enrolment e WHERE e.student = s AND e.clazz.course.cycle.year = :year), '')) " +
                "FROM Student s " +
                "WHERE (:state = '0' OR s.state = :state) " +
                "AND (:branch = '0' OR s.branch = :branch) " +
                "AND (s.registerDate <= :weekDate) " +
                "AND (:grade = '0' OR s.grade = :grade) " +              
                "AND s.active = 0 " +
                "AND s.endDate <= :weekDate " +
                "ORDER BY s.id")
        List<StudentWithEnrolmentDTO> listInactiveStudentsWithEnrolmentByGradeAndWeek(@Param("state") String state, 
                @Param("branch") String branch, 
                @Param("grade") String grade,
                @Param("year") int year, 
                @Param("week") int week,
                @Param("weekDate") LocalDate weekDate);
        ///
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // get student password by id
        @Query(value = "SELECT s.password FROM Student s WHERE s.id = ?1", nativeQuery = true)
        String findStudentPasswordById(Long id);

        // get branch by student id
        @Query(value = "SELECT s.branch FROM Student s WHERE s.id = ?1", nativeQuery = true)
        String findBranchById(Long id);

        @Modifying
        @Query(value = "INSERT INTO Student (id, firstName, lastName, password, active, grade, contactNo1, contactNo2, email1, email2, relation1, relation2, address, state, branch, memo, gender, registerDate, endDate) VALUES (:id, :firstName, :lastName, :password, :active, :grade, :contactNo1, :contactNo2, :email1, :email2, :relation1, :relation2, :address, :state, :branch, :memo, :gender, :registerDate, :endDate)", nativeQuery = true)
        void insertStudentWithId(
            @Param("id") Long id,
            @Param("firstName") String firstName,
            @Param("lastName") String lastName,
            @Param("password") String password,
            @Param("active") Integer active,
            @Param("grade") String grade,
            @Param("contactNo1") String contactNo1,
            @Param("contactNo2") String contactNo2,
            @Param("email1") String email1,
            @Param("email2") String email2,
            @Param("relation1") String relation1,
            @Param("relation2") String relation2,
            @Param("address") String address,
            @Param("state") String state,
            @Param("branch") String branch,
            @Param("memo") String memo,
            @Param("gender") String gender,
            @Param("registerDate") LocalDate registerDate,
            @Param("endDate") LocalDate endDate
        );
}
