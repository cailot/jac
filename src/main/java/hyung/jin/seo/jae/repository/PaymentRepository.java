package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.dto.PaymentDTO;
import hyung.jin.seo.jae.model.Payment;

public interface PaymentRepository extends JpaRepository<Payment, Long>{  
	
	@Query(value = "SELECT p.id, p.amount, p.total, p.method, p.info, p.registerDate, p.invoiceId, p.invoiceHistoryId FROM Payment p WHERE p.invoiceId = ?1 ORDER BY p.id ASC", nativeQuery = true)
	List<Object[]> findByInvoiceId(Long invoiceId);

	@Query(value = "SELECT p.invoiceId FROM Payment p WHERE p.id = ?1", nativeQuery = true)
	Long findInvoiceIdById(Long id);

	@Query(value = "SELECT SUM(amount) FROM Payment p WHERE p.id <= ?1 AND p.invoiceId = ?2", nativeQuery = true)
	double getTotalPaidById(Long id, Long invoiceId);

	// @Query(value = "SELECT new hyung.jin.seo.dto.PaymentDTO(p.id, p.amount, p.info, p.registerDate, p.invoice.id, p.invoiceHistory.id, p.invoice.amount) FROM Payment p WHERE p.invoice.id = ?1")
	// List<PaymentDTO> listPaymentByInvoiceIdId(Long id);

}
