package hyung.jin.seo.jae.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.model.Enrolment;

public interface EnrolmentRepository extends JpaRepository<Enrolment, Long> {

	// bring latest EnrolmentDTO by student id, called from retrieveEnrolment() in
	// courseInfo.jsp
	@Query(value = "SELECT en.id, en.registerDate, en.cancelled, en.cancellationReason, en.startWeek, en.endWeek, en.info, COALESCE(inv.id, 0) AS invoiceId, en.credit, en.discount, COALESCE(inv.amount, 0.0) AS amount, COALESCE(inv.paidAmount, 0.0) AS paidAmount, inv.paymentDate, en.studentId, en.clazzId, co.description, cl.price, co.online, cy.year, co.grade, cl.day FROM Enrolment en LEFT JOIN Invoice inv ON en.invoiceId = inv.id JOIN Class cl ON en.clazzId = cl.id JOIN Course co ON cl.courseId = co.id JOIN jac.Cycle cy ON cl.cycleId = cy.id WHERE en.studentId = :studentId AND en.old = 0", nativeQuery = true)
	List<Object[]> findEnrolmentByStudentId(@Param("studentId") long studentId);

	// get start and end week by student id and year in studentList.jsp
	@Query(value = "SELECT en.startWeek, en.endWeek FROM Enrolment en LEFT JOIN Class cl ON en.clazzId = cl.id JOIN jac.Cycle cy ON cl.cycleId = cy.id WHERE en.studentId = :studentId AND cy.year = :year", nativeQuery = true)
	List<Object[]> findStartAndEndWeekByStudentIdAndYear(@Param("studentId") long studentId, @Param("year") int year);

	// bring latest EnrolmentDTO by student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount,  e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.clazz.id = ?1 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByClazzId(long clazzId);

	// bring latest EnrolmentDTO by invoice id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByInvoiceId(long invoiceId);

	// bring latest Enrolment by invoice id
	@Query("SELECT e FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false")
	List<Enrolment> getEnrolmentByInvoiceId(long invoiceId);

	// bring latest EnrolmentDTO by invoice history id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.invoiceHistory.id = ?1")
	List<EnrolmentDTO> findEnrolmentByInvoiceHistroyId(long invoiceHistoryId);

	// bring latest EnrolmentDTO by clazz id & student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.clazz.id = ?1 and e.student.id = ?2 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByClazzIdAndStudentId(long clazzId, long studentId);

	// bring latest EnrolmentDTO by invoice id & student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.invoice.id = ?1 and e.student.id = ?2 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByInvoiceIdAndStudentId(long invoiceId, long studentId);

	// bring latest EnrolmentDTO by invoice id & student id + old = false
	@Query(value = "SELECT * FROM Enrolment e WHERE e.invoiceId = ?1 AND e.studentId = ?2", nativeQuery = true)
	List<Enrolment> findAllEnrolmentByInvoiceIdAndStudentId(long invoiceId, long studentId);

	// bring EnrolmentDTO by id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount,  e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.id = ?1 and e.old = false")
	EnrolmentDTO findActiveEnrolmentById(long id);

	// bring latest EnrolmentDTO by clazz id & invoice id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.course.price, e.clazz.course.online, e.clazz.course.grade, e.clazz.day, e.clazz.course.cycle.year) FROM Enrolment e WHERE e.clazz.id = ?1 and e.invoice.id = ?2 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByClazzIdAndInvoiceId(long clazzId, long invoiceId);

	// return class id by student id
	@Query("SELECT e.clazz.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false")
	List<Long> findClazzIdByStudentId(long clazzId);

	// return student id by clazz id
	@Query("SELECT distinct(e.student.id) FROM Enrolment e WHERE e.clazz.id = ?1")
	List<Long> findStudentIdByClazzId(long studentId);

	// return enrolment id by student id
	@Query("SELECT e.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false")
	List<Long> findEnrolmentIdByStudentId(long studentId);

	// return enrolment id by invoice id
	// @Query("SELECT e.id FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false")
	@Query("SELECT e.id FROM Enrolment e WHERE e.invoice.id = ?1")
	List<Long> findEnrolmentIdByInvoiceId(long invoiceId);

	// return latest invoice id by student id
	@Query(value = "SELECT MAX(e.invoiceId) FROM Enrolment e WHERE e.studentId = :studentId", nativeQuery = true)
	Long findLatestInvoiceIdByStudentId(@Param("studentId") long studentId);

	// return second latest invoice id by student id
	@Query(value = "SELECT MAX(e.invoiceId) FROM Enrolment e WHERE e.studentId = :studentId AND e.invoiceId < (SELECT MAX(e2.invoiceId) FROM Enrolment e2 WHERE e2.studentId = :studentId)", nativeQuery = true)
	Long findSecondLatestInvoiceIdByStudentId(@Param("studentId") long studentId);


	// return third latest invoice id by student id
	@Query(value = "SELECT MAX(e.invoiceId) FROM Enrolment e WHERE e.studentId = :studentId AND e.invoiceId < (SELECT MAX(e2.invoiceId) FROM Enrolment e2 WHERE e2.studentId = :studentId AND e2.invoiceId < (SELECT MAX(e3.invoiceId) FROM Enrolment e3 WHERE e3.studentId = :studentId))", nativeQuery = true)
	Long findThirdLatestInvoiceIdByStudentId(@Param("studentId") long studentId);

	// return all invoice id by student id
	@Query(value = "SELECT DISTINCT(e.invoiceId) FROM Enrolment e WHERE e.studentId = :studentId ORDER BY e.invoiceId DESC", nativeQuery = true)
	List<Long> findInvoiceIdByStudentId(@Param("studentId") long studentId);

	// return number of students by clazz id
	@Query(value = "SELECT COUNT(DISTINCT e.studentId) FROM Enrolment e WHERE e.clazzId = :clazzId AND :week BETWEEN e.startWeek AND e.endWeek", nativeQuery = true)
	Integer getStudentNumberByClazzId(@Param("clazzId") long clazzId, @Param("week") int week);

	// return clazz id by student id, year, week and online
	@Query("SELECT e.clazz.id FROM Enrolment e WHERE e.student.id = ?1 AND e.clazz.course.price =?2 AND e.startWeek >= ?3 AND e.endWeek <= ?3 AND e.clazz.course.online = true")
	Optional<Long> findClazzId4fOnlineSession(long studentId, int year, int week);

	// return enrolment id by student id, year and week
	@Query(value = "SELECT en.id "
	+ "FROM Enrolment en " 
	+ "LEFT JOIN Class cl ON en.clazzId = cl.id " 
	+ "LEFT JOIN jac.Cycle cy ON cl.cycleId = cy.id " 
	+ "WHERE (en.studentId = :studentId) AND (cy.year = :year) AND (:week BETWEEN en.startWeek AND en.endWeek) AND en.old = 0", nativeQuery = true)
	List<Long> checkEnrolmentTime(@Param("studentId") long studentId, @Param("year") int year, @Param("week") int week);

	// check if student is enrolled in the class at the week
	@Query(value = "SELECT COUNT(en.id) "
	+ "FROM Enrolment en "
	+ "WHERE (en.student.id = ?1) AND (en.clazz.id = ?2) AND (?3 BETWEEN en.startWeek AND en.endWeek)")
	Integer isExistByStudentIdAndClazzIdAndWeek(long studentId, long clazzId, int week);

	// bring start week and end week by latest invoice (invoice id and highest invoice history id)
	@Query("SELECT e.startWeek, e.endWeek FROM Enrolment e WHERE e.invoice.id = :invoiceId AND e.clazz.id = :clazzId AND e.discount <> '100%' "
	+ "AND e.invoiceHistory.id = (SELECT MAX(subE.invoiceHistory.id) FROM Enrolment subE WHERE subE.invoice.id = :invoiceId)")
	List<Object[]> findStartAndEndWeeksByLastInvoice(@Param("invoiceId") long invoiceId, @Param("clazzId") long clazzId);
}
