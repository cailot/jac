package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.model.InvoiceHistory;

public interface InvoiceHistoryRepository extends JpaRepository<InvoiceHistory, Long>{  

	List<InvoiceHistory> findAll();
	
	// bring latest InvoiceDTO by student id
    @Query("SELECT new hyung.jin.seo.jae.dto.InvoiceDTO(i.id, i.credit, i.discount, i.paidAmount, i.amount, i.registerDate, i.paymentDate, i.info) FROM Invoice i WHERE i.id = (SELECT MAX(en.invoice.id) FROM Enrolment en WHERE en.student.id = ?1)")
	InvoiceDTO findInvoiceHistoryDTOByStudentId(long studentId);

	// Fetch the top InvoiceHistory with the highest id for a given invoiceId
	@Query("SELECT i FROM InvoiceHistory i WHERE i.invoice.id = ?1 ORDER BY i.id DESC")
	InvoiceHistory findTopByInvoiceIdOrderByIdDesc(long invoiceId);

	// return invoice amount by id
	@Query("SELECT (i.amount - i.paidAmount) FROM InvoiceHistory i WHERE i.id = ?1")
	double getInvoiceHistoryOwingAmount(long id);

	// return invoice total amount by id
	@Query("SELECT i.amount FROM InvoiceHistory i WHERE i.id = ?1")
	double getInvoiceHistoryTotalAmount(long id);

}
