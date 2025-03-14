package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.BookDTO;
import hyung.jin.seo.jae.model.Book;

public interface BookService {
	// list all Course Books
	List<BookDTO> allBooks();
	
	// list available books based on grade
	List<BookDTO> booksActiveByGrade(String grade);

	// list available books based on grade
	List<BookDTO> booksByGrade(String grade);

	// list books based on invoice Id
	List<BookDTO> findBookByInvoiceId(Long id);

	// get Book by Id
	Book getBook(Long id);

	// return total count
	long checkCount();

	// get price by material id
	double getPriceByMaterial(Long materialId);

	// get price by book id
	double getPrice(Long bookId);

	// register Book
	Book addBook(Book book);

	// update Book
	BookDTO updateBook(Book book, Long id);

	// delete Book
	void deleteBook(Long id);

	// get Book Id by grade and order
	long getBookIdByGradeNOrder(int grade, int rowNum);
}
