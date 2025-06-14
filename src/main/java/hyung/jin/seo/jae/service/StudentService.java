package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.StudentWithEnrolmentDTO;
import hyung.jin.seo.jae.model.Student;

public interface StudentService {

	// bring all students
	List<Student> allStudents();
	
	// bring active students
	List<Student> currentStudents();
	
	// bring inactive students
	List<Student> stoppedStudents();
	
	// bring student list base on the condition
	List<StudentDTO> listStudents(String state, String branch, String grade, String active);
	
	// bring student list base on the condition
	List<StudentDTO> listStudents(String state, String branch, String grade, String year, String active);
	
	// bring student list base on the condition
	List<StudentDTO> listAllStudents(String state, String branch, String grade, String day, String active);

	// count student per grade base on the condition
	List<SimpleBasketDTO> countAllStudents(String state, String branch, String day, String active);

	// bring student list base on the condition
	List<StudentWithEnrolmentDTO> listEnrolmentStudents(String state, String branch, String grade, int year, int week);
	
	// search student list base on keyword where id, firstName or lastName
	List<StudentDTO> searchByKeyword(String keyword, String state, String branch);

	// bring student list base on grade
	List<StudentDTO> showGradeStudents(String state, String branch, String grade);	
		
	// bring student by id
	Student getStudent(Long id);
	
    Student addStudent(Student std);
    
 	long checkCount();
    
	// Student updateStudent(Student newStudent, Long id);
	Student updateStudent(StudentDTO newStudent, String user);

	void deactivateStudent(Long id);
	
	Student activateStudent(Long id);
	
	void deleteStudent(Long id);

	void updatePassword(Long id, String password);

	// update student grade as batch for next year
	void batchUpdateGrade(List<Long> ids, String grade);

	// get maxId based on state & branch
	Long getMaxId(String state, String branch);

	int updateInactiveStudent(int days);

	// list payment students in paymentList.jsp
	List<StudentDTO> listPaymentStudent(String branch, String grade, String from, String to);

	// list payment students in paymentList.jsp
	List<StudentDTO> listPaymentStudent(String branch, String grade, String payment, String from, String to);

	// list payment students in paymentList.jsp with date type
	List<StudentDTO> listPaymentStudent(String branch, String grade, String payment, String dateType, String from, String to);

	// list overdue students in overdueList.jsp
	List<StudentDTO> listOverdueStudent(String branch, String grade, String type, int year, int week);

	// list renew students in renewList.jsp
	List<StudentDTO> listRenewStudent(String branch, String grade, int fromYear, int fromWeek, int toYear, int toWeek);

	// get branch receipents
	List<String> getBranchReceipents(String state, String branch, String grade);

	//get student name by id
	String getStudentName(Long id);

	// get student email by id
	String getStudentEmail(Long id);

	// get student email recipients
	List<String> getStudentEmailRecipient(Long id);

	// get student password by id
	String getStudentPassword(Long id);

	// get student list with enrolment if exists in studentList.jsp
	List<StudentWithEnrolmentDTO> overallStudentWithEnrolment(String state, String branch, String grade, String active, int year, int week, String day);		

	// get branch where student is registered
	String getBranch(Long id);

	// Add student for migration (bypasses ID generator)
	Student addStudentMigration(Student student);
}
