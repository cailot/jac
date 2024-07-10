package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.AssessmentDTO;
import hyung.jin.seo.jae.dto.ExtraworkDTO;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.dto.PracticeAnswerDTO;
import hyung.jin.seo.jae.dto.PracticeDTO;
import hyung.jin.seo.jae.dto.PracticeScheduleDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StudentPracticeDTO;
import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.dto.TestAnswerDTO;
import hyung.jin.seo.jae.dto.TestDTO;
import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.model.Assessment;
import hyung.jin.seo.jae.model.Extrawork;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.model.Practice;
import hyung.jin.seo.jae.model.PracticeAnswer;
import hyung.jin.seo.jae.model.PracticeSchedule;
import hyung.jin.seo.jae.model.StudentPractice;
import hyung.jin.seo.jae.model.StudentTest;
import hyung.jin.seo.jae.model.Test;
import hyung.jin.seo.jae.model.TestAnswer;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.model.TestSchedule;

public interface AssessmentService {

	// list all Assessment
	List<Assessment> allAssessments();

	// retrieve Assessment by Id
	Assessment getAssessment(Long id);
	
	// register Assessment
	Assessment addAssessment(Assessment crs);
	
	// update Assessment info by Id
	Assessment updateAssessment(Assessment newWork, Long id);
	
	// delete Assessment
	void deleteAssessment(Long id);

	// get Assessment by grade & subject
	AssessmentDTO getAssessmentInfo(String grade, long subjectId);

	// list Assessment by grade
	List<AssessmentDTO> listAssessment(String grade);

	// list Assessment by subject
	List<AssessmentDTO> listAssessment(long subjectId);



	/* 
	// retrieve TestAnswer by Id
	TestAnswer getTestAnswer(Long id);

	// retrieve TestAnswer by Test
	TestAnswerDTO findTestAnswerByTest(Long id);

	// register TestAnswer
	TestAnswer addTestAnswer(TestAnswer crs);
	
	// update TestAnswer info by Id
	TestAnswer updateTestAnswer(TestAnswer newWork, Long id);

	// get Answer sheet by Test
	List<TestAnswerItem> getAnswersByTest(Long testId);

	// get Student's answer by Student & Test
	List<Integer> getStudentTestAnswer(Long studentId, Long  testId);


	// retrieve StudentTest by Id
	StudentTest getStudentTest(Long id);

	// retrieve TestAnswer by Test
	StudentTestDTO findStudentTestByStudentNTest(Long studentId, Long testId);

	// register TestAnswer
	StudentTest addStudentTest(StudentTest crs);
	
	// update TestAnswer info by Id
	StudentTest updateStudentTest(StudentTest newWork, Long id);

	// check if student has done the test
	boolean isStudentTestExist(Long studentId, Long testId);

	// delete existing record to take test again
	void deleteStudentTest(Long studentId, Long testId); 	

	// list Test by type & grade
	List<TestDTO> listTestByTypeNGrade(int type, String grade);

	// get TestType name by test id
	String getTestTypeName(Long id);
	*/

}
