package hyung.jin.seo.jae.service.impl;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import javax.persistence.EntityNotFoundException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.LoginActivityDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.repository.StudentRepository;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;
import lombok.extern.java.Log;

@Service
public class StudentServiceImpl implements StudentService {

	@Autowired
	private StudentRepository studentRepository;

	@Override
	public List<Student> allStudents() {
		List<Student> students = new ArrayList<>();
		try{
			students = studentRepository.findAll();
		}catch(Exception e){
			System.out.println("No student found");
		}
		// studentRepository.findAll();
		return students;
	}
	
	@Override
	public List<Student> currentStudents() {
		List<Student> students = new ArrayList<>();
		try{
			students = studentRepository.findAllByEndDateIsNull();
		}catch(Exception e){
			System.out.println("No student found");
		}
		// studentRepository.findAllByEndDateIsNull();
		return students;
	}

	@Override
	public List<Student> stoppedStudents() {
		List<Student> students = new ArrayList<>();
		try{
			students = studentRepository.findAllByEndDateIsNotNull();
		}catch(Exception e){
			System.out.println("No student found");
		}
		// studentRepository.findAllByEndDateIsNotNull();
		return students;
	}
	
	@Override
	public List<StudentDTO> searchByKeyword(String keyword, String state, String branch) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			if(StringUtils.isNumericSpace(keyword)) {
				//dtos = studentRepository.searchStudentByKeywordId(Long.parseLong(keyword), state, branch);
				dtos.add(studentRepository.searchStudentById(Long.parseLong(keyword)));
			}else{
				dtos = studentRepository.searchStudentByKeywordName(keyword, state, branch);
			}
		}catch(Exception e){
			System.out.println("No student found");
		}
		return dtos;
	}


	@Override
	public Student getStudent(Long id) {
		Student std = null;
		try{
			std = studentRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No student found");
		}
		// studentRepository.findById(id).get();	
		return std;
	}

	@Override
	@Transactional
	public Student addStudent(Student std) {
		//String pwd = std.getPassword();
		// BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		// std.setPassword(passwordEncoder.encode(pwd));
		Student add = studentRepository.save(std);
		return add;
	}

	@Override
	public long checkCount() {
		long count = studentRepository.countByEndDateIsNull();
		return count;
	}

	@Override
	@Transactional
	public Student updateStudent(StudentDTO newStudent, String user) {
		// search by getId
		Student existing = studentRepository.findById(Long.parseLong(newStudent.getId())).orElseThrow(() -> new EntityNotFoundException("Student not found"));
		// Update info
		String newFirstName = StringUtils.defaultString(newStudent.getFirstName());
		existing.setFirstName(newFirstName);
		String newLastName = StringUtils.defaultString(newStudent.getLastName());
		existing.setLastName(newLastName);
		String newGrade = StringUtils.defaultString(newStudent.getGrade());
		existing.setGrade(newGrade);
		String newGender = StringUtils.defaultString(newStudent.getGender());
		existing.setGender(newGender);
		String newContactNo1 = StringUtils.defaultString(newStudent.getContactNo1());
		existing.setContactNo1(newContactNo1);
		String newContactNo2 = StringUtils.defaultString(newStudent.getContactNo2());
		existing.setContactNo2(newContactNo2);
		String newEmail1 = StringUtils.defaultString(newStudent.getEmail1());
		existing.setEmail1(newEmail1);
		String newEmail2 = StringUtils.defaultString(newStudent.getEmail2());
		existing.setEmail2(newEmail2);
		String newRelation1 = StringUtils.defaultString(newStudent.getRelation1());
		existing.setRelation1(newRelation1);
		String newRelation2 = StringUtils.defaultString(newStudent.getRelation2());
		existing.setRelation2(newRelation2);
		String newAddress = StringUtils.defaultString(newStudent.getAddress());
		existing.setAddress(newAddress);
		String newState = StringUtils.defaultString(newStudent.getState());
		existing.setState(newState);
		String newBranch = StringUtils.defaultString(newStudent.getBranch());
		existing.setBranch(newBranch);
		// existing.setActive(newStudent.getActive());
		LocalDate newRegisterDate = LocalDate.parse(newStudent.getRegisterDate(), DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		existing.setRegisterDate(newRegisterDate);
		String newMemo = StringUtils.defaultString(newStudent.getMemo());
		String existMemo = StringUtils.defaultString(existing.getMemo());
		// in case that user wants to clear memo
		if(StringUtils.isBlank(newMemo)) {
			// simply clear memo
			existing.setMemo("");
		}else if(!newMemo.equals(existMemo)) {
			// update memo with timestamp
			existing.setMemo(newMemo + JaeUtils.getTodayForMemo(user));
		}
		// update the existing record
		Student updated = studentRepository.save(existing);
		return updated;
	}

	@Override
	@Transactional
	public Student activateStudent(Long id) {
		Student student = null;
		try {
			// studentRepository.deleteById(id);
			Optional<Student> end = studentRepository.findById(id);
			if(end.isPresent()){
				Student std = end.get();
				std.setEndDate(null);
				std.setActive(JaeConstants.ACTIVE);
				student = studentRepository.save(std);
			}
			return student;
		} catch (org.springframework.dao.EmptyResultDataAccessException e) {
			System.out.println("Nothing to activate");
		}
		return student;
	}
	
	@Override
	@Transactional
	public void deactivateStudent(Long id) {
		try {
			// studentRepository.deleteById(id);
			Optional<Student> end = studentRepository.findById(id);
			if(!end.isPresent()) return; // if not found, terminate.
			Student std = end.get();
			std.setEndDate(LocalDate.now());
			std.setActive(JaeConstants.INACTIVE);
			studentRepository.save(std);
		} catch (org.springframework.dao.EmptyResultDataAccessException e) {
			System.out.println("Nothing to discharge");
		}
	}

	@Override
	@Transactional
	public void deleteStudent(Long id) {
		try {
			studentRepository.deleteById(id);
		} catch (org.springframework.dao.EmptyResultDataAccessException e) {
			System.out.println("Nothing to delete");
		}

	}

	@Override
	@Transactional
	public void updatePassword(Long id, String password) {
		BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		String encodedPassword = passwordEncoder.encode(password);
		try{
			studentRepository.updatePassword(id, encodedPassword);
		}catch(Exception e){
			System.out.println("No student found");
		}	
	}

	@Override
	public List<StudentDTO> showGradeStudents(String state, String branch, String grade) {
		List<StudentDTO> dtos = null;
		dtos = studentRepository.listActiveStudent(state, branch, grade);		
		return dtos;
	}

	@Override
	@Transactional
	public void batchUpdateGrade(List<Long> ids, String grade) {
		if(ids!=null && ids.size()>0 && StringUtils.isNotBlank(grade)) {
			for(Long id : ids) {
				studentRepository.updateGrade(id, grade);
			}
		}
	}

	@Override
	public Long getMaxId(String state, String branch) {
		Long maxId = 0L;
		try{
			maxId = studentRepository.findMaxIdByStateAndBranch(state, branch);
		}catch(Exception e){
			System.out.println("Unable to get maxId from Student");
		}
		return maxId;
	}

	@Override
	@Transactional
	public int updateInactiveStudent(int days) {
		int affectedRow = 0;
		try{
			affectedRow = studentRepository.updateInactiveStudent(days);
		}catch(Exception e){
			System.out.println("Unable to get maxId from Student");
		}
		return affectedRow;
	}


	@Override
	public List<StudentDTO> listStudents(String state, String branch, String grade, String year, String active) {		
		int yearParam = Integer.parseInt(year);
		List<StudentDTO> dtos = null;
		switch(active){
			case JaeConstants.CURRENT:
				dtos = studentRepository.listActiveStudent(state, branch, grade, yearParam);
				break;
			case JaeConstants.STOPPED:
				dtos = studentRepository.listInactiveStudent(state, branch, grade, yearParam);
		}
		return dtos;
	}

	@Override
	public List<StudentDTO> listEnrolmentStudents(String state, String branch, String grade, String active, int year, int week) {
		List<StudentDTO> dtos = null;
		switch(active){
			case JaeConstants.ALL_STUDENT :
				dtos = studentRepository.listAllStudent(state, branch, grade);
				break;
			default :
				dtos = studentRepository.listEnroledStudent(state, branch, grade, year, week);
		}
		return dtos;
	}


	@Override
	public List<StudentDTO> listPaymentStudent(String branch, String grade, String from, String to) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
			LocalDate fromDate = LocalDate.parse(from, formatter);
			LocalDate toDate = LocalDate.parse(to, formatter);
			List<Object[]> objs = studentRepository.listPaymentStudent(branch, grade, fromDate, toDate);
			for(Object[] obj : objs){
				StudentDTO dto = new StudentDTO(obj);
				dtos.add(dto);
			}	
		}catch(Exception e){
			System.out.println("No student found");
		}
		return dtos;
	}

	@Override
	public List<StudentDTO> listOverdueStudent(String branch, String grade, int year, int week) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			dtos = studentRepository.listOverdueStudent(branch, grade, year, week);	
		}catch(Exception e){
			System.out.println("No student found");
		}
		return dtos;
	}

	@Override
	public List<StudentDTO> listRenewStudent(String branch, String grade, int fromYear, int fromWeek, int toYear, int toWeek) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			dtos = studentRepository.listRenewStudent(branch, grade, fromYear, fromWeek, toYear, toWeek);	
		}catch(Exception e){
			System.out.println("No student found");
		}
		return dtos;
	}

}
