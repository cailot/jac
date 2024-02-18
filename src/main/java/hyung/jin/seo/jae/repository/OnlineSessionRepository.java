package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.model.OnlineSession;

public interface OnlineSessionRepository extends JpaRepository<OnlineSession, Long> {

	// get start and end week by student id and year in studentList.jsp
	// @Query(value = "SELECT en.startWeek, en.endWeek FROM Enrolment en LEFT JOIN Class cl ON en.clazzId = cl.id JOIN Cycle cy ON cl.cycleId = cy.id WHERE en.studentId = :studentId AND cy.year = :year", nativeQuery = true)
	// List<Object[]> findStartAndEndWeekByStudentIdAndYear(@Param("studentId") long studentId, @Param("year") int year);

	// bring OnlineSessionDTO by clazz id
	@Query("SELECT new hyung.jin.seo.jae.dto.OnlineSessionDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount,  e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.clazz.id = ?1 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByClazzId(long clazzId);

	// bring latest EnrolmentDTO by invoice id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByInvoiceId(long invoiceId);

	// bring latest EnrolmentDTO by clazz id & student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.clazz.id = ?1 and e.student.id = ?2 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByClazzIdAndStudentId(long clazzId, long studentId);

	// bring latest EnrolmentDTO by invoice id & student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.invoice.id = ?1 and e.student.id = ?2 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByInvoiceIdAndStudentId(long invoiceId, long studentId);

	// bring latest EnrolmentDTO by invoice id & student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.invoice.id = ?1 and e.student.id = ?2")
	List<EnrolmentDTO> findAllEnrolmentByInvoiceIdAndStudentId(long invoiceId, long studentId);

	// bring EnrolmentDTO by id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount,  e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.id = ?1 and e.old = false")
	EnrolmentDTO findActiveEnrolmentById(long id);

	// bring latest EnrolmentDTO by clazz id & invoice id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.clazz.id = ?1 and e.invoice.id = ?2 and e.old = false")
	List<EnrolmentDTO> findEnrolmentByClazzIdAndInvoiceId(long clazzId, long invoiceId);

	// return class id by student id
	@Query("SELECT e.clazz.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false")
	List<Long> findClazzIdByStudentId(long clazzId);

	// return student id by clazz id
	@Query("SELECT e.student.id FROM Enrolment e WHERE e.clazz.id = ?1")
	List<Long> findStudentIdByClazzId(long studentId);

	// return enrolment id by student id
	@Query("SELECT e.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false")
	List<Long> findEnrolmentIdByStudentId(long studentId);

	// return enrolment id by invoice id
	@Query("SELECT e.id FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false")
	List<Long> findEnrolmentIdByInvoiceId(long invoiceId);

	// return latest invoice id by student id
	@Query(value = "SELECT MAX(e.invoiceId) FROM Enrolment e WHERE e.studentId = :studentId", nativeQuery = true)
	Long findLatestInvoiceIdByStudentId(@Param("studentId") long studentId);

	// return all invoice id by student id
	@Query(value = "SELECT DISTINCT(e.invoiceId) FROM Enrolment e WHERE e.studentId = :studentId ORDER BY e.invoiceId DESC", nativeQuery = true)
	List<Long> findInvoiceIdByStudentId(@Param("studentId") long studentId);

	// return number of students by clazz id
	@Query(value = "SELECT COUNT(DISTINCT e.studentId) FROM Enrolment e WHERE e.clazzId = :clazzId AND :week BETWEEN e.startWeek AND e.endWeek", nativeQuery = true)
	Integer getStudentNumberByClazzId(@Param("clazzId") long clazzId, @Param("week") int week);

}
