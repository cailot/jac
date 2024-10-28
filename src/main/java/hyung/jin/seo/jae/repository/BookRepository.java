package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.dto.BookDTO;
import hyung.jin.seo.jae.model.Book;

public interface BookRepository extends JpaRepository<Book, Long>{  
	
	List<Book> findAll();

	List<Book> findByGrade(String grade);

	List<Book> findByGradeAndActiveIsTrue(String grade);

	@Query(value = "SELECT new hyung.jin.seo.jae.dto.BookDTO(b.id, b.grade, b.name, b.price, b.active) FROM Book b WHERE b.grade = :grade")
	List<BookDTO> getByGrade(@Param("grade") String grade);

	@Query(value = "SELECT * FROM Book WHERE id IN (SELECT bookId FROM Invoice_Book WHERE invoiceId = ?1)", nativeQuery = true)   	
	List<Book> findBookByInvoiceId(Long invoiceId);
	
	long count();

	// get price by material id
	@Query(value = "SELECT b.price FROM Book b where b.id = (SELECT m.bookId FROM Material m WHERE m.id = :materialId)", nativeQuery = true)
	double getPriceByMaterialId(Long materialId);

	// get price by book id
	@Query("SELECT b.price FROM Book b WHERE b.id = ?1")
	double getPrice(Long bookId);
	
	@Query(value = "SELECT id FROM (SELECT id, grade, ROW_NUMBER() OVER (PARTITION BY grade ORDER BY id) AS row_num FROM Book) AS ordered_books WHERE grade = :grade AND row_num = :rowNum", nativeQuery = true)
	long getBookIdByGradeNOrder(int grade, int rowNum);

}
