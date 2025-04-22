package hyung.jin.seo.jae.service;

import java.time.LocalDateTime;
import java.util.List;

import hyung.jin.seo.jae.dto.ExtraworkDTO;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.dto.HomeworkScheduleDTO;
import hyung.jin.seo.jae.dto.PracticeAnswerDTO;
import hyung.jin.seo.jae.dto.PracticeDTO;
import hyung.jin.seo.jae.dto.PracticeScheduleDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StudentPracticeDTO;
import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.dto.TestAnswerDTO;
import hyung.jin.seo.jae.dto.TestDTO;
import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.model.Extrawork;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.model.HomeworkSchedule;
import hyung.jin.seo.jae.model.Practice;
import hyung.jin.seo.jae.model.PracticeAnswer;
import hyung.jin.seo.jae.model.PracticeSchedule;
import hyung.jin.seo.jae.model.StudentPractice;
import hyung.jin.seo.jae.model.StudentTest;
import hyung.jin.seo.jae.model.Test;
import hyung.jin.seo.jae.model.TestAnswer;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.model.TestSchedule;

public interface ConnectedService {

	/////////////////////////////////////////////////////////
	//
	//	HOMEWORK
	//
	/////////////////////////////////////////////////////////
	// list all Homeworks
	List<Homework> allHomeworks();
	
	// retrieve Homework by Id
	Homework getHomework(Long id);
	
	// register Homework
	Homework addHomework(Homework crs);
    
    // update Homework info by Id
 	Homework updateHomework(Homework newWork, Long id);
	
	// delete Homework
	void deleteHomework(Long id);

	// delete HomeworkProgress
	// void deleteHomeworkProgress(Long id);

	// get Homework by subject & week
	// HomeworkDTO getHomeworkInfo(long subject, int week);

	// list Homework by subject, grade & week
	List<HomeworkDTO> listHomework(long subject, String grade, int week);

	/////////////////////////////////////////////////////////
	//
	//	EXTRAWORK
	//
	/////////////////////////////////////////////////////////
	// list all Extraworks
	List<Extrawork> allExtraworks();

	// retrieve Extrawork by Id
	Extrawork getExtrawork(Long id);
	
	// register Extrawork
	Extrawork addExtrawork(Extrawork crs);
	
	// update Extrawork info by Id
	Extrawork updateExtrawork(Extrawork newWork, Long id);
	
	// delete Extrawork
	void deleteExtrawork(Long id);

	// get Extrawork by subject, year & week
	ExtraworkDTO getExtraworkInfo(int subject, int year, int week);

	// list Extrawork by grade
	List<ExtraworkDTO> listExtrawork(String grade);
	
	// summary of Extrawork by grade
	List<SimpleBasketDTO> loadExtrawork(String grade);

	/////////////////////////////////////////////////////////
	//
	//	PRACTICE
	//
	/////////////////////////////////////////////////////////

	// list all Practices
	List<Practice> allPractices();

	// retrieve Practice by Id
	Practice getPractice(Long id);
	
	// register Practice
	Practice addPractice(Practice crs);
	
	// update Practice info by Id
	Practice updatePractice(Practice newWork, Long id);
	
	// delete Practice
	void deletePractice(Long id);

	// get Practice by type, grade & volume
	PracticeDTO getPracticeInfo(int type, String grade, int volume);

	// list Practice by type, grade & volume
	List<PracticeDTO> listPractice(int type, String grade, int volume);

	// summary of Practice by practiceType & grade
	List<SimpleBasketDTO> loadPractice(int type, int grade);

	// retrieve PracticeAnswer by Id
	PracticeAnswer getPracticeAnswer(Long id);

	// retrieve PracticeAnswer by Practice
	PracticeAnswerDTO findPracticeAnswerByPractice(Long id);

	// register PracticeAnswer
	PracticeAnswer addPracticeAnswer(PracticeAnswer crs);
	
	// update PracticeAnswer info by Id
	PracticeAnswer updatePracticeAnswer(PracticeAnswer newWork, Long id);

	// get Answer sheet by Practice
	List<Integer> getAnswersByPractice(Long practiceId);

	// get Student's answer by Student & Practice
	List<Integer> getStudentPracticeAnswer(Long studentId, Long  practionId);

	// get how many question answer sheet has
	int getPracticeAnswerCount(Long practiceId);
	
	// retrieve StudentPractice by Id
	StudentPractice getStudentPractice(Long id);

	// retrieve PracticeAnswer by Practice
	StudentPracticeDTO findStudentPracticeByStudentNPractice(Long studentId, Long practiceId);

	// register PracticeAnswer
	StudentPractice addStudentPractice(StudentPractice crs);
	
	// update PracticeAnswer info by Id
	StudentPractice updateStudentPractice(StudentPractice newWork, Long id);

	// check if student has done the practice
	boolean isStudentPracticeExist(Long studentId, Long practiceId);

	// delete existing record to take test again
	void deleteStudentPractice(Long studentId, Long practiceId); 

	// list Practice by type & grade
	List<PracticeDTO> listPracticeByTypeNGrade(int type, String grade);

	// get PracticeType name by practice id
	String getPracticeTypeName(Long id);


	/////////////////////////////////////////////////////////
	//
	//	TEST
	//
	/////////////////////////////////////////////////////////

	// list all Test
	List<Test> allTests();

	// retrieve Test by Id
	Test getTest(Long id);
	
	// register Test
	Test addTest(Test crs);
	
	// update Test info by Id
	Test updateTest(Test newWork, Long id);
	
	// delete Test
	void deleteTest(Long id);

	// get Test by type, grade & volume
	TestDTO getTestByType(int type, String grade, int volume);

	// get Test by testGroup, grade & volume
	List<TestDTO> getTestByGroup(int group, String grade, int volume);
	
	// list Test by type, grade & volume
	List<TestDTO> listTest(int type, String grade, int volume);

	// summary of Test by practiceType & grade
	List<SimpleBasketDTO> loadTest(int type, int grade);

	// retrieve TestAnswer by Id
	TestAnswer getTestAnswer(Long id);

	// get TestAnswer only by Test
	List<TestAnswerItem> getTestAnswerOnlyByTest(Long testId);

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

	// get how many question answer sheet has
	int getTestAnswerCount(Long testId);
	
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

	// get test group by id
	int getTestGroup(Long id);

	// get test grade by id
	String getTestGrade(Long id);

	// get test volume by id
	int getTestVolume(Long id);
	
	// get Student's answer by Student & Test
	List<Integer> getStudentTestAnswer(Long studentId, Long  testId, String from, String to);	

	// retrieve TestAnswer by Test
	StudentTestDTO findStudentTestByStudentNTest(Long studentId, Long testId, String from, String to);

	// get average score of Test
	// double getAverageScoreByTest(Long testId, String from, String to);

	// get registerDate by studentId and testId
	String getRegDateforStudentTest(Long studentId, Long test, String from, String to);
	
	// get student score by studentId and testId
	double getStudentScoreByTest(Long studentId, Long testId);

	double getAverageScoreByTest(Long testId, String from, String to);

	double getHighestScoreByTest(Long testId, String from, String to);

	double getLowestScoreByTest(Long testId, String from, String to);

	String getScoreCategory(double studentScore, Long testId, String from, String to);

	// upgdate average score of Test
	void updateTestAverage(Long id, double score);

	// get student list who took the test
	List<Long> getStudentListByTest(Long testId, String from, String to);

	/////////////////////////////////////////////////////////
	//
	//	HOMEWORK SCHEDULE
	//
	/////////////////////////////////////////////////////////

	// list all Homework Schedules
	List<HomeworkSchedule> allHomeworkSchedules();

	// list Homework Schedule
	List<HomeworkScheduleDTO> listHomeworkSchedule(LocalDateTime from, LocalDateTime to);

	// retrieve Homework Schedule by Id
	HomeworkSchedule getHomeworkSchedule(Long id);
	
	// register Homework Schedule
	HomeworkSchedule addHomeworkSchedule(HomeworkSchedule schedule);
	
	// update Homework Schedule info by Id
	HomeworkSchedule updateHomeworkSchedule(HomeworkSchedule schedule, Long id);
	
	// delete Homeowork Schedule
	void deleteHomeworkSchedule(Long id);


	/////////////////////////////////////////////////////////
	//
	//	PRACTICE SCHEDULE
	//
	/////////////////////////////////////////////////////////

	// list all Practice Schedules
	List<PracticeSchedule> allPracticeSchedules();

	// list Practice Schedule by time
	List<PracticeScheduleDTO> listPracticeSchedule(LocalDateTime from, LocalDateTime to, int group);

	// retrieve Practice Schedule by Id
	PracticeSchedule getPracticeSchedule(Long id);
	
	// register Practice Schedule
	PracticeSchedule addPracticeSchedule(PracticeSchedule ps);
	
	// update Practice Schedule info by Id
	PracticeSchedule updatePracticeSchedule(PracticeSchedule newWork, Long id);
	
	// delete Practice Schedule
	void deletePracticeSchedule(Long id);

	/////////////////////////////////////////////////////////
	//
	//	TEST SCHEDULE
	//
	/////////////////////////////////////////////////////////

	// list all Test Schedules
	List<TestSchedule> allTestSchedules();

	// list Practice Schedule by year & week
	// List<TestScheduleDTO> listTestSchedule(int year, int week);
	List<TestScheduleDTO> listTestSchedule(LocalDateTime from, LocalDateTime to, int group);

	// retrieve Test Schedule by Id
	TestScheduleDTO getTestSchedule(Long id);
	
	// register Practice Schedule
	TestSchedule addTestSchedule(TestSchedule ps);
	
	// update Practice Schedule info by Id
	TestSchedule updateTestSchedule(TestSchedule newWork, Long id);
	
	// delete Practice Schedule
	void deleteTestSchedule(Long id);

	// get most recent Test Schedule by testGroup & grade & week
	TestScheduleDTO getMostRecentTestSchedule(String testGroup, String grade, String week);


}
