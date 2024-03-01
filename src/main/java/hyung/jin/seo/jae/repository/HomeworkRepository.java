package hyung.jin.seo.jae.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.model.Homework;

public interface HomeworkRepository extends JpaRepository<Homework, Long>{  
	
	List<Homework> findAll();
	
	Optional<Homework> findById(Long id);
	
	long count();

	// bring HomeworkDTO by id
	@Query("SELECT new hyung.jin.seo.jae.dto.HomeworkDTO(e.id, e.registerDate, e.cancelled, e.cancellationReason, e.startWeek, e.endWeek, e.info, e.credit, e.discount, e.invoice.id, e.invoice.amount, e.invoice.paidAmount,  e.invoice.paymentDate, e.student.id, e.clazz.id, e.clazz.course.name, e.clazz.price, e.clazz.course.online, e.clazz.cycle.year, e.clazz.course.grade, e.clazz.day) FROM Enrolment e WHERE e.id = ?1 and e.old = false")
	HomeworkDTO findActiveEnrolmentById(long id);
}
