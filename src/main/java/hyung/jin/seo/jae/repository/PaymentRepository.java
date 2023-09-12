package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.Payment;

public interface PaymentRepository extends JpaRepository<Payment, Long>{  
	
	@Query(value = "SELECT p.id, p.amount, p.method, p.info, p.registerDate, p.invoiceId FROM Payment p WHERE p.invoiceId = ?1", nativeQuery = true)
	List<Object[]> findByInvoiceId(Long invoiceId);
}
