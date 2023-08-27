package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.model.Enrolment;

public interface EnrolmentRepository extends JpaRepository<Enrolment, Long>{  

	// bring latest EnrolmentDTO by student id, called from retrieveEnrolment() in courseInfo.jsp
	@Query(value = "SELECT en.id, en.registerDate, en.cancelled, en.cancellationReason, en.startWeek, en.endWeek, en.info, " +
            "COALESCE(inv.id, 0) AS invoiceId, COALESCE(inv.credit, 0.0) AS credit, COALESCE(inv.discount, 0.0) AS discount, " +
            "COALESCE(inv.amount, 0.0) AS amount, COALESCE(inv.paidAmount, 0.0) AS paidAmount, " +
            "inv.paymentDate, en.studentId, en.clazzId, co.description, co.price, cy.year, co.grade, cl.day " +
            "FROM Enrolment en " +
            "LEFT JOIN Invoice inv ON en.invoiceId = inv.id " +
            "JOIN Class cl ON en.clazzId = cl.id " +
            "JOIN Course co ON cl.courseId = co.id " +
            "JOIN Cycle cy ON cl.cycleId = cy.id " +
            "WHERE en.studentId = :studentId AND en.old = 0", nativeQuery = true)
    List<Object[]> findEnrolmentByStudentId(@Param("studentId") long studentId);

	// get start and end week by student id and year in studentList.jsp
	@Query(value = "SELECT en.startWeek, en.endWeek FROM Enrolment en LEFT JOIN Class cl ON en.clazzId = cl.id JOIN Cycle cy ON cl.cycleId = cy.id WHERE en.studentId = :studentId AND cy.year = :year", nativeQuery = true)
	List<Object[]> findStartAndEndWeekByStudentIdAndYear(@Param("studentId") long studentId, @Param("year") int year);

	// bring latest EnrolmentDTO by student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, COALESCE(e.invoice.credit, 0.0), e.invoice.discount, e.invoice.amount, e.invoice.paidAmount,  e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.description, e.clazz.course.price, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.clazz.id = ?1 and e.old = false") 
	List<EnrolmentDTO> findEnrolmentByClazzId(long clazzId);

	// bring latest EnrolmentDTO by invoice id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, COALESCE(e.invoice.credit, 0.0), e.invoice.discount, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.description, e.clazz.course.price, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false") 
	List<EnrolmentDTO> findEnrolmentByInvoiceId(long invoiceId);

	// bring latest EnrolmentDTO by clazz id & student id
	@Query("SELECT new hyung.jin.seo.jae.dto.EnrolmentDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, COALESCE(e.invoice.credit, 0.0), e.invoice.discount, e.invoice.amount, e.invoice.paidAmount, e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.description, e.clazz.course.price, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.clazz.id = ?1 and e.student.id = ?2 and e.old = false")	
	List<EnrolmentDTO> findEnrolmentByClazzIdAndStudentId(long clazzId, long studentId);	

	// return class id by student id
	@Query("SELECT e.clazz.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false")
	List<Long> findClazzIdByStudentId(long clazzId);

	// return enrolment id by student id
	@Query("SELECT e.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false")
	List<Long> findEnrolmentIdByStudentId(long studentId);

	// return enrolment id by invoice id
	@Query("SELECT e.id FROM Enrolment e WHERE e.invoice.id = ?1 and e.old = false")
	List<Long> findEnrolmentIdByInvoiceId(long invoiceId);
}
