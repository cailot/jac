package hyung.jin.seo.jae.controller;

import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.BookDTO;
import hyung.jin.seo.jae.dto.SubjectDTO;
import hyung.jin.seo.jae.model.Book;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.service.BookService;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("book")
public class BookController {

	//private static final Logger LOG = LoggerFactory.getLogger(JaeBookController.class);

	@Autowired
	private BookService bookService;

	@Autowired
	private CodeService codeService;

	// search all course books
	@GetMapping("/list")
	public String listBooks(@RequestParam(value = "listGrade", required = false) String grade, Model model) {
		List<BookDTO> dtos = null;
		// if grade has some value
		if ((StringUtils.isNotBlank(grade)) && !(JaeConstants.ALL.equalsIgnoreCase(grade))) {
			dtos = bookService.booksByGrade(grade);
		} else { // if grade has no value, simply bring all
			dtos = bookService.allBooks();
		}
		model.addAttribute(JaeConstants.BOOK_LIST, dtos);
		return "bookListPage";
	}	
	
	@PostMapping("/register")
	@ResponseBody
	public ResponseEntity<String> registerBook(@RequestBody BookDTO formData) {
		try {
			// 1. create Book
			Book book = formData.convertToBook();
			// 2. associate Subjects
			List<SubjectDTO> subjects = formData.getSubjects();
			for(SubjectDTO subject : subjects){
				Subject sub =  codeService.getSubject(Long.parseLong(subject.getId()));
				book.addSubject(sub);
			}
			// 3. save Course
			bookService.addBook(book);
			// 4. return success;
			return ResponseEntity.ok("\"Book register success\"");
		} catch (Exception e) {
			String message = "Error registering Book: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}	

	// get book by Id
	@GetMapping("/get/{id}")
	@ResponseBody
	public BookDTO getBook(@PathVariable("id") Long id) {
		Book book = bookService.getBook(id);
		BookDTO dto = new BookDTO(book);
		List<Subject> subjects = book.getSubjects();
		for(Subject subject : subjects){
			SubjectDTO subDTO = new SubjectDTO(subject);
			dto.addSubject(subDTO);
		}
		return dto;
	}

		// update existing course
	@PutMapping("/update")
	@ResponseBody
	public ResponseEntity<String> updateBook(@RequestBody BookDTO formData) {
		try {
			// 1. create Book
			Book book = formData.convertToBook();
			book.setActive(formData.isActive());
			// 2. associate Subjects
			List<SubjectDTO> subjects = formData.getSubjects();
			for(SubjectDTO subject : subjects){
				Subject sub =  codeService.getSubject(Long.parseLong(subject.getId()));
				book.addSubject(sub);
			}
			// 3. update Book
			bookService.updateBook(book, Long.parseLong(formData.getId()));
			// 4. return flag
			return ResponseEntity.ok("\"Book update success\"");
		} catch (Exception e) {
			String message = "Error updating book: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// delete book by Id
	@DeleteMapping(value = "/delete/{bookId}")
	@ResponseBody
    public ResponseEntity<String> removeBook(@PathVariable String bookId) {
        Long id = Long.parseLong(StringUtils.defaultString(bookId, "0"));
		bookService.deleteBook(id);
		return ResponseEntity.ok("\"Course deleted successfully\"");
    }

	// search course books by grade
	@GetMapping("/listGrade")
	@ResponseBody
	List<BookDTO> listGradeBook(@RequestParam("grade") String grade) {
		// int year = JaeUtils.academicYear();
		List<BookDTO> dtos = bookService.booksByGrade(grade);	
		return dtos;
	}

	// count records number in database
	@GetMapping("/count")
	@ResponseBody
	long coutFees() {
		long count = bookService.checkCount();
		return count;
	}
}
