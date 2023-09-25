package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.model.Attendance;
import hyung.jin.seo.jae.repository.AttendanceRepository;
import hyung.jin.seo.jae.service.AttendanceService;

@Service
public class AttendanceServiceImpl implements AttendanceService {
	
	@Autowired
	private AttendanceRepository attendanceRepository;

	@Override
	public List<AttendanceDTO> allAttendances() {
		List<Attendance> attends = new ArrayList<>();
		try{
			attends = attendanceRepository.findAll();
		}catch(Exception e){
			System.out.println("No attendance found");
		}
		List<AttendanceDTO> dtos = new ArrayList<>();
		for(Attendance attend: attends){
			AttendanceDTO dto = new AttendanceDTO(attend);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<AttendanceDTO> findAttendanceByStudent(Long studentId) {
		List<AttendanceDTO> dtos = new ArrayList<>();
		try{
			dtos = attendanceRepository.findAttendanceByStudentId(studentId);
		}catch(Exception e){
			System.out.println("No attendance found");
		}	
		return dtos;
	}

	@Override
	public List<AttendanceDTO> findAttendanceByClazz(Long claszzId) {
		List<AttendanceDTO> dtos = new ArrayList<>();
		try{
			dtos = attendanceRepository.findAttendanceByClazzId(claszzId);
		}catch(Exception e){
			System.out.println("No attendance found");
		}	
		return dtos;
	}

	@Override
	public List<AttendanceDTO> findAttendanceByStudentAndClazz(Long studentId, Long clazzId) {
		List<AttendanceDTO> dtos = new ArrayList<>();
		try{
			dtos = attendanceRepository.findAttendanceByStudentIdAndClazzId(studentId, clazzId);
		}catch(Exception e){
			System.out.println("No attendance found");
		}	
		return dtos;
	}

	@Override
	public AttendanceDTO addAttendance(Attendance attendance) {
		Attendance attend = attendanceRepository.save(attendance);
		AttendanceDTO dto = new AttendanceDTO(attend);
		return dto;
	}

	@Override
	public Attendance updateAttendance(Attendance attend, Long id) {
		// search by getId
		Attendance existing = attendanceRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Attendance not found"));
		// Update info
		// status
		if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(attend.getStatus()), StringUtils.defaultString(existing.getStatus()))){
			existing.setStatus(StringUtils.defaultString(attend.getStatus()));
		}
		// week
		if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(attend.getWeek()), StringUtils.defaultString(existing.getWeek()))){
			existing.setWeek(StringUtils.defaultString(attend.getWeek()));
		}
		// info
		if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(attend.getInfo()), StringUtils.defaultString(existing.getInfo()))){
			existing.setInfo(StringUtils.defaultString(attend.getInfo()));
		}
		// update the existing record
		Attendance updated = attendanceRepository.save(existing);
		return updated;
	}

	@Override
	public List<Long> findAttendanceIdByStudent(Long studentId) {
		List<Long> attendIds = new ArrayList<>();
		try{
			attendIds = attendanceRepository.findAttendanceIdByStudentId(studentId);	
		}catch(Exception e){
			System.out.println("No attendance found");
		}
		return attendIds;
	}

	@Override
	public List<Long> findAttendanceIdByClazz(Long clazzId) {
		List<Long> attendIds = new ArrayList<>();
		try{
			attendIds = attendanceRepository.findAttendanceIdByClazzId(clazzId);	
		}catch(Exception e){
			System.out.println("No attendance found");
		}
		return attendIds;
	}

	@Override
	public List<Long> findAttendanceIdByStudentAndClazz(Long studentId, long clazzId) {
		List<Long> attendIds = new ArrayList<>();
		try{
			attendIds = attendanceRepository.findAttendanceIdByStudentIdAndClazzId(studentId, clazzId);	
		}catch(Exception e){
			System.out.println("No attendance found");
		}
		return attendIds;
	}

	@Override
	public Attendance getAttendance(Long id) {
		Attendance attend = null;
		try{
			attend = attendanceRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No attendance found");
		}
		return attend;
	}

	@Override
	public long checkCount() {
		long count = attendanceRepository.count();
		return count;
	}

	@Override
	public void deleteAttendance(Long id) {
		try{
			attendanceRepository.deleteById(id);
		}catch(EmptyResultDataAccessException e){
			System.out.println("No attendance to delete");
		}
	}
	
}