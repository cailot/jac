package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.BookDTO;
import hyung.jin.seo.jae.dto.SubjectDTO;
import hyung.jin.seo.jae.model.Book;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.repository.BookRepository;
import hyung.jin.seo.jae.service.BookService;

@Service
public class BookServiceImpl implements BookService {
	
	@Autowired
	private BookRepository bookRepository;
	
	@Override
	public List<BookDTO> allBooks() {
		List<Book> books = new ArrayList<>();
		try{
			books = bookRepository.findAll();
		}catch(Exception e){
			System.out.println("No book found");
		}
		List<BookDTO> dtos = new ArrayList<>();
		for(Book book: books){
			BookDTO dto = new BookDTO(book);
			List<Subject> subjects = book.getSubjects();
			for(Subject subject : subjects){
				SubjectDTO sub = new SubjectDTO(subject);
				dto.addSubject(sub);
			}
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public Book getBook(Long id){
		Book book = null;
		try{
			book = bookRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No book found");
		}
		return book;
	}

	@Override
	public List<BookDTO> booksByGrade(String grade) {
		List<BookDTO> dtos = new ArrayList<BookDTO>();
		// 1. get books
		List<Book> books = bookRepository.findByGrade(grade);
		// 2. get & asscoatiate subjects
		for(Book book : books){
			BookDTO dto = new BookDTO(book);
			List<Subject> subjects = book.getSubjects();
			for(Subject subject : subjects){
				SubjectDTO sub = new SubjectDTO(subject);
				dto.addSubject(sub);
			}
			dtos.add(dto);
		}
		// 3. add postage for all years
		List<Book> postageBooks = bookRepository.findByGradeAndActiveIsTrue("0");
		for(Book postageBook : postageBooks){
			BookDTO dto = new BookDTO(postageBook);
			List<Subject> subjects = postageBook.getSubjects();
			for(Subject subject : subjects){
				SubjectDTO sub = new SubjectDTO(subject);
				dto.addSubject(sub);
			}
			dtos.add(dto);
		}
		// 4. return DTOs
		return dtos;	
	}

	@Override
	public List<BookDTO> booksActiveByGrade(String grade) {
		List<BookDTO> dtos = new ArrayList<BookDTO>();
		// 1. get books
		List<Book> books = bookRepository.findByGradeAndActiveIsTrue(grade);
		// 2. get & asscoatiate subjects
		for(Book book : books){
			BookDTO dto = new BookDTO(book);
			List<Subject> subjects = book.getSubjects();
			for(Subject subject : subjects){
				SubjectDTO sub = new SubjectDTO(subject);
				dto.addSubject(sub);
			}
			dtos.add(dto);
		}
		// 3. add postage for all years
		List<Book> postageBooks = bookRepository.findByGradeAndActiveIsTrue("0");
		for(Book postageBook : postageBooks){
			BookDTO dto = new BookDTO(postageBook);
			List<Subject> subjects = postageBook.getSubjects();
			for(Subject subject : subjects){
				SubjectDTO sub = new SubjectDTO(subject);
				dto.addSubject(sub);
			}
			dtos.add(dto);
		}
		// 4. return DTOs
		return dtos;	
	}

	@Override
	public long checkCount() {
		long count = bookRepository.count();
		return count;
	}

	@Override
	public List<BookDTO> findBookByInvoiceId(Long id) {
		List<Book> books = new ArrayList<>();
		try{
			books = bookRepository.findBookByInvoiceId(id);
		}catch(Exception e){
			System.out.println("No book found");
		}
		// bookRepository.findBookByInvoiceId(id);
		List<BookDTO> dtos = new ArrayList<>();
		for(Book book: books){
			BookDTO dto = new BookDTO(book);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public double getPriceByMaterial(Long materialId) {
		double price = 0;
		try{
			price = bookRepository.getPriceByMaterialId(materialId);
		}catch(Exception e){
			System.out.println("No book found");
		}
		return price;
		// return bookRepository.getPriceByMaterialId(materialId);
	}

	@Override
	public double getPrice(Long bookId) {
		double price = 0;
		try{
			price = bookRepository.getPrice(bookId);
		}catch(Exception e){
			System.out.println("No book found");
		}
		return price;
		// return bookRepository.getPrice(bookId);
	}

	@Override
	@Transactional
	public Book addBook(Book book) {
		Book add = bookRepository.save(book);
		return add;
	}


	@Override
	@Transactional
	public BookDTO updateBook(Book book, Long id) {
		// search by Id
		Book existing = bookRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Book Not Found"));
		// update grade
		String newGrade = book.getGrade();
		existing.setGrade(newGrade);
		// update name
		String newName = book.getName();
		existing.setName(newName);
		// update price
		double newPrice = book.getPrice();
		existing.setPrice(newPrice);
		// update acive
		boolean newActive = book.isActive();
		existing.setActive(newActive);
		// update associated subjects
		List<Subject> newSubjects = book.getSubjects();
		existing.setSubjects(newSubjects);
		// update the existing record
		Book updated = bookRepository.save(existing);
		BookDTO dto = new BookDTO(updated);
		return dto;
	}

	@Override
	@Transactional
	public void deleteBook(Long id) {
		// 1. get book
		Book existing = bookRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Book Not Found"));
		// 2. delete associated subject
		existing.setSubjects(null);
		bookRepository.save(existing);
		// 3. delete class
		bookRepository.deleteById(id);
	}

	@Override
	public long getBookIdByGradeNOrder(int grade, int rowNum) {
		long bookId = 0;
		try{
			bookId = bookRepository.getBookIdByGradeNOrder(grade, rowNum);
		}catch(Exception e){
			System.out.println("No book found");
		}
		return bookId;		
	}
	
}
