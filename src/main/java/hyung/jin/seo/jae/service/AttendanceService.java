package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.model.Attendance;

public interface AttendanceService {
	
	// list all attendances
	List<AttendanceDTO> allAttendances();

	// return total count
	long checkCount();

	// find attendance by id
	Attendance getAttendance(Long id);

	// add attendance
	AttendanceDTO addAttendance(Attendance attendance);

	// update attendance
	Attendance updateAttendance(Attendance attendance, Long id);

	// list attendances by student Id
	List<AttendanceDTO> findAttendanceByStudent(Long studentId);

	// list attendances by clazz Id
	List<AttendanceDTO> findAttendanceByClazz(Long claszzId);

	// list attendances by student Id and clazz Id
	List<AttendanceDTO> findAttendanceByStudentAndClazz(Long studentId, Long clazzId);

	// find attendance Id by student Id
	List<Long> findAttendanceIdByStudent(Long studentId);

	// find attendance Id by clazz Id
	List<Long> findAttendanceIdByClazz(Long clazzId);

	// find attendance Id by student Id & clazz Id
	List<Long> findAttendanceIdByStudentAndClazz(Long studentId, long clazzId);

	
}