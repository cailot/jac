package hyung.jin.seo.jae.repository;

import java.util.List;
import java.time.LocalDate;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.model.Invoice;

public interface InvoiceRepository extends JpaRepository<Invoice, Long>{  
	
	// bring latest InvoiceDTO by student id
    @Query("SELECT new hyung.jin.seo.jae.dto.InvoiceDTO(i.id, i.credit, i.discount, i.paidAmount, i.amount, i.registerDate, i.paymentDate, i.info) FROM Invoice i WHERE i.id = (SELECT MAX(en.invoice.id) FROM Enrolment en WHERE en.student.id = ?1)")
	InvoiceDTO findInvoiceDTOByStudentId(long studentId);

	// bring latest Invoice by student id
	@Query("SELECT i FROM Invoice i WHERE i.id = (SELECT MAX(en.invoice.id) FROM Enrolment en WHERE en.student.id = ?1)")
	Invoice findLastInvoiceByStudentId(long studentId);

	// return invoice id by student id
	@Query("SELECT e.invoice.id FROM Enrolment e WHERE e.student.id = ?1 and e.old = false order by e.registerDate desc")
	List<Long> findInvoiceIdByStudentId(long studentId);

	// return latest invoice id by student id
	@Query("SELECT MAX(e.invoice.id) FROM Enrolment e WHERE e.student.id = ?1 and e.old = false order by e.registerDate desc")
	Long findLatestInvoiceIdByStudentId(long studentId);

	// return invoice amount by id
	@Query("SELECT (i.amount - i.paidAmount) FROM Invoice i WHERE i.id = ?1")
	double getInvoiceOwingAmount(long id);

	// return invoice total amount by id
	@Query("SELECT i.amount FROM Invoice i WHERE i.id = ?1")
	double getInvoiceTotalAmount(long id);

	// return invoice balance by id
	@Query("SELECT (i.amount - i.paidAmount) FROM Invoice i WHERE i.id = ?1")
	double isPaidInvoice(long id);

	// return invoice paid amount by id
	@Query("SELECT i.paidAmount FROM Invoice i WHERE i.id = ?1")
	double getInvoicePaidAmount(long id);

	@Modifying
	@Query(value = "INSERT INTO Invoice (id, credit, discount, amount, paidAmount, registerDate, paymentDate, info) VALUES (:id, :credit, :discount, :amount, :paidAmount, :registerDate, :paymentDate, :info)", nativeQuery = true)
	void insertInvoiceWithId(
		@Param("id") Long id,
		@Param("credit") Integer credit,
		@Param("discount") Double discount,
		@Param("amount") Double amount,
		@Param("paidAmount") Double paidAmount,
		@Param("registerDate") LocalDate registerDate,
		@Param("paymentDate") LocalDate paymentDate,
		@Param("info") String info
	);

	// get top (latest) invoice by student ID based on invoice ID pattern
	@Query(value = "SELECT * FROM Invoice WHERE id >= (:studentId * 1000) AND id < ((:studentId + 1) * 1000) ORDER BY id DESC LIMIT 1", nativeQuery = true)
	Invoice findLatestInvoiceByStudentIdPattern(@Param("studentId") Long studentId);

	// get List<Invoice Id> by student ID based on invoice ID pattern
	@Query(value = "SELECT id FROM Invoice WHERE id >= (:studentId * 1000) AND id < ((:studentId + 1) * 1000) ORDER BY id DESC", nativeQuery = true)
	List<Long> findInvoiceIdsByStudentIdPattern(@Param("studentId") Long studentId);

	// get top (latest) invoice ID by student ID based on invoice ID pattern
	@Query(value = "SELECT id FROM Invoice WHERE id >= (:studentId * 1000) AND id < ((:studentId + 1) * 1000) ORDER BY id DESC LIMIT 1", nativeQuery = true)
	Long findLatestInvoiceIdByStudentIdPattern(@Param("studentId") Long studentId);

	// get second top (latest) invoice ID by student ID based on invoice ID pattern
	@Query(value = "SELECT id FROM Invoice WHERE id >= (:studentId * 1000) AND id < ((:studentId + 1) * 1000) ORDER BY id DESC LIMIT 1 OFFSET 1", nativeQuery = true)
	Long findSecondLatestInvoiceIdByStudentIdPattern(@Param("studentId") Long studentId);

	// get third top (latest) invoice ID by student ID based on invoice ID pattern
	@Query(value = "SELECT id FROM Invoice WHERE id >= (:studentId * 1000) AND id < ((:studentId + 1) * 1000) ORDER BY id DESC LIMIT 1 OFFSET 2", nativeQuery = true)
	Long findThirdLatestInvoiceIdByStudentIdPattern(@Param("studentId") Long studentId);

}
