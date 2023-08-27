package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.model.Material;

public interface MaterialRepository extends JpaRepository<Material, Long>{  
	
	List<Material> findAll();
	
	@Query("SELECT new hyung.jin.seo.jae.dto.MaterialDTO(m.id, m.registerDate, m.paymentDate, m.info, m.book.id, m.book.name, m.book.price, m.invoice.id) FROM Material m WHERE m.invoice.id = ?1") 
	List<MaterialDTO> findMaterialByInvoiceId(Long invoiceId);

	// delete material by invoice id and book id
	@Query("DELETE FROM Material m WHERE m.invoice.id = ?1 AND m.book.id = ?2")
	void deleteMaterial(Long invoiceId, Long bookId);

	// @Query(value="DELETE FROM Material m WHERE m.invoiceId = :invoiceId AND m.bookId = :bookId", nativeQuery = true)
	// void deleteMaterialByInvoiceIdAndBookId(@Param("invoiceId") Long invoiceId, @Param("bookId") Long bookId);
	//@Transactional
    @Modifying
    @Query("DELETE FROM Material m WHERE m.invoice.id = :invoiceId AND m.book.id = :bookId")
    void deleteMaterialByInvoiceIdAndBookId(@Param("invoiceId") Long invoiceId, @Param("bookId") Long bookId);



	long count();
}
