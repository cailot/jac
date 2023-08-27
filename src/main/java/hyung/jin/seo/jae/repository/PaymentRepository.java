package hyung.jin.seo.jae.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.Payment;

public interface PaymentRepository extends JpaRepository<Payment, Long>{  
	
	@Query(value = "SELECT p.id, p.amount, p.method, p.register_date, p.invoiceId, p.info FROM Payment p WHERE p.invoiceId = ?1", nativeQuery = true)
	Payment findByInvoiceId(Long invoiceId);


}
