package hyung.jin.seo.jae.service.impl;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.aspectj.lang.annotation.SuppressAjWarnings;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
import hyung.jin.seo.jae.model.AssessmentAnswer;
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
import hyung.jin.seo.jae.repository.AssessmentAnswerRepository;
import hyung.jin.seo.jae.repository.AssessmentRepository;
import hyung.jin.seo.jae.repository.ExtraworkRepository;
import hyung.jin.seo.jae.repository.HomeworkRepository;
import hyung.jin.seo.jae.repository.PracticeAnswerRepository;
import hyung.jin.seo.jae.repository.PracticeRepository;
import hyung.jin.seo.jae.repository.PracticeScheduleRepository;
import hyung.jin.seo.jae.repository.StudentPracticeRepository;
import hyung.jin.seo.jae.repository.StudentTestRepository;
import hyung.jin.seo.jae.repository.TestAnswerRepository;
import hyung.jin.seo.jae.repository.TestRepository;
import hyung.jin.seo.jae.repository.TestScheduleRepository;
import hyung.jin.seo.jae.service.AssessmentService;
import hyung.jin.seo.jae.service.ConnectedService;

@Service
public class AssessmentServiceImpl implements AssessmentService {
	
	@Autowired
	private AssessmentRepository assessmentRepository;

	@Autowired
	private AssessmentAnswerRepository assessmentAnswerRepository;

	@Override
	public List<Assessment> allAssessments() {
		List<Assessment> dtos = new ArrayList<>();
		try{
			dtos = assessmentRepository.findAll();
		}catch(Exception e){
			System.out.println("No Assessment found");
		}
		return dtos;
	}

	@Override
	public Assessment getAssessment(Long id) {
		Optional<Assessment> work = assessmentRepository.findById(id);
		if(!work.isPresent()) return null;
		return work.get();
	}

	@Transactional
	@Override
	public Assessment addAssessment(Assessment work) {
		Assessment assessment = assessmentRepository.save(work);
		return assessment;
	}

	@Transactional
	@Override
	public Assessment updateAssessment(Assessment newWork, Long id) {
		Assessment existing = assessmentRepository.findById(id).get();
        // Update info
        String newPdfPath = StringUtils.defaultString(newWork.getPdfPath());
        existing.setPdfPath(newPdfPath);
        boolean newActive = newWork.isActive();
		existing.setActive(newActive);
        Assessment updated = assessmentRepository.save(existing);
		return updated;
	}

	@Transactional
	@Override
	public void deleteAssessment(Long id) {
		try{
			// 1. get associated TestAnswer
			AssessmentAnswer aa = assessmentAnswerRepository.findAssessmentAnswerByAssessment(id);
			// 2. empty TestAnswerCollection
			aa.setAnswers(new ArrayList<>());
			assessmentAnswerRepository.save(aa);
			// 3. delete associated assessmentAnswer
			assessmentAnswerRepository.deleteAssessmentAnswerByAssessment(id);
			// 4. delete assessment
			assessmentRepository.deleteById(id);
		}catch(Exception e){
			System.out.println("Nothing to delete");
		}
	}

	@Override
	public AssessmentDTO getAssessmentInfo(String grade, long subjectId) {
		AssessmentDTO dto = null;
		try{
			dto = assessmentRepository.findAssessment(grade, subjectId);
		}catch(Exception e){
			System.out.println("No Assessment found");
		}
		return dto;
	}

	@Override
	public List<AssessmentDTO> listAssessment(String grade) {
		List<AssessmentDTO> dtos = new ArrayList<>();
		try{
			dtos = assessmentRepository.findAssessmentByGrade(grade);
		}catch(Exception e){
			System.out.println("No Assessment found");
		}
		return dtos;
	}

	@Override
	public List<AssessmentDTO> listAssessment(long subjectId) {
		List<AssessmentDTO> dtos = new ArrayList<>();
		try{
			dtos = assessmentRepository.findAssessmentBySubject(subjectId);
		}catch(Exception e){
			System.out.println("No Assessment found");
		}
		return dtos;
	}


	/*
	
	
	@Override
	public List<Integer> getStudentPracticeAnswer(Long studentId, Long practionId) {
		Optional<StudentPractice> sp = studentPracticeRepository.findByStudentIdAndPracticeId(studentId, practionId);
		if(sp.isPresent()){
			return sp.get().getAnswers();
		}else{
			return null;
		}
	}

	@Override
	public List<TestAnswerItem> getAnswersByTest(Long testId) {
		Optional<TestAnswer> answer = testAnswerRepository.findByTestId(testId);
		if(answer.isPresent()){
			return answer.get().getAnswers();
		}else{
			return null;
		}
	}

	@Override
	public List<Integer> getStudentTestAnswer(Long studentId, Long testId) {
		Optional<StudentTest> answer = studentTestRepository.findByStudentIdAndTestId(studentId, testId);
		if(answer.isPresent()){
			return answer.get().getAnswers();
		}else{
			return null;
		}
	}

	@Override
	public int getPracticeAnswerCount(Long practiceId) {
		Optional<PracticeAnswer> answer = practiceAnswerRepository.findByPracticeId(practiceId);
		if(answer.isPresent()){
			List<Integer> answers =  answer.get().getAnswers();
			if((answers != null) && (answers.size()>0)) return answers.get(0);
		}
		return 0;
	}

	@Override
	public int getTestAnswerCount(Long testId) {
		Optional<TestAnswer> answer = testAnswerRepository.findByTestId(testId);
		if(answer.isPresent()){
			List<TestAnswerItem> answers =  answer.get().getAnswers();
			if((answers != null) && (answers.size()>0)) return answers.size();
		}
		return 0;
	}

	@Override
	public boolean isStudentPracticeExist(Long studentId, Long practiceId) {
		Optional<StudentPractice> sp = studentPracticeRepository.findByStudentIdAndPracticeId(studentId, practiceId);
		if(sp.isPresent()){
			return true;
		}else{
			return false;
		}
	}

	@Override
	public boolean isStudentTestExist(Long studentId, Long testId) {
		Optional<StudentTest> st = studentTestRepository.findByStudentIdAndTestId(studentId, testId);
		if(st.isPresent()){
			return true;
		}else{
			return false;
		}
	}

	@Override
	public PracticeAnswerDTO findPracticeAnswerByPractice(Long id) {
		PracticeAnswerDTO dto = null;
		try{
			PracticeAnswer answer = practiceAnswerRepository.findPracticeAnswerByPractice(id);
			if(answer!=null){
				dto = new PracticeAnswerDTO(answer);
			}
		}catch(Exception e){
			System.out.println("No PracticeAnswer found");
		}
		return dto;
	}

	@Override
	public StudentPracticeDTO findStudentPracticeByStudentNPractice(Long studentId, Long practiceId) {
		StudentPracticeDTO dto = null;
		try{
			dto = studentPracticeRepository.findStudentPractice(studentId, practiceId);
		}catch(Exception e){
			System.out.println("No StudentPractice found");
		}
		return dto;	
	}

	@Override
	public TestAnswerDTO findTestAnswerByTest(Long id) {
		TestAnswerDTO dto = null;
		try{
			TestAnswer answer = testAnswerRepository.findTestAnswerByTest(id);
			if(answer!=null){
				dto = new TestAnswerDTO(answer);
			}
		}catch(Exception e){
			System.out.println("No TestAnswer found");
		}
		return dto;
	}

	@Override
	public StudentTestDTO findStudentTestByStudentNTest(Long studentId, Long testId) {
		StudentTestDTO dto = null;
		try{
			dto =  studentTestRepository.findStudentTest(studentId, testId);
		}catch(Exception e){
			System.out.println("No StudentTest found");
		}
		return dto;
	}

	@Override
	public List<PracticeDTO> listPracticeByTypeNGrade(int type, String grade) {
		List<PracticeDTO> dtos = new ArrayList<>();
		try{
			dtos = practiceRepository.filterActivePracticeByTypeNGradeNVolume(type, grade, 0);
		}catch(Exception e){
			System.out.println("No Practice found");
		}
		return dtos;
	}

	@Override
	public List<TestDTO> listTestByTypeNGrade(int type, String grade) {
		List<TestDTO> dtos = new ArrayList<>();
		try{
			dtos = testRepository.filterActiveTestByTypeNGradeNVolume(type, grade, 0);
		}catch(Exception e){
			System.out.println("No Practice found");
		}
		return dtos;
	}


	@Override
	public String getPracticeTypeName(Long id) {
		String name = "";
		try{
			name = practiceRepository.getPracticeTypeName(id);
		}catch(Exception e){
			System.out.println("No Practice found");
		}
		return name;
	}

	@Override
	public String getTestTypeName(Long id) {
		String name = "";
		try{
			name = testRepository.getTestTypeName(id);
		}catch(Exception e){
			System.out.println("No Test found");
		}
		return name;	
	}
*/
}
