package hyung.jin.seo.jae.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.model.Attendance;
import hyung.jin.seo.jae.service.AttendanceService;

@Controller
@RequestMapping("attendance")
public class JaeAttendanceController {

	@Autowired
	private AttendanceService attendanceService;

	// count records number in database
	@GetMapping("/count")
	@ResponseBody
	public long count() {
		long count = attendanceService.checkCount();
		return count;
	}

	// bring all attendances in database
	@GetMapping("/list")
	@ResponseBody
	public List<AttendanceDTO> listAttendances() {
 		List<AttendanceDTO> dtos = attendanceService.allAttendances();
		return dtos;
	}

	// register new attendance
	@PostMapping("/register")
	@ResponseBody
	public AttendanceDTO registerAttendance(@RequestBody AttendanceDTO formData) {
		Attendance attend = formData.convertToAttendance();
		AttendanceDTO dto = attendanceService.addAttendance(attend);
		return dto;
	}

	// update existing attendance
	@PutMapping("/update")
	@ResponseBody
	public AttendanceDTO updateAttendance(@RequestBody AttendanceDTO formData) {
		Attendance attend = formData.convertToAttendance();
		// 1. update Attendance
		attend = attendanceService.updateAttendance(attend, attend.getId());
		// 2. convert Attendance to AttendanceDTO
		AttendanceDTO dto = new AttendanceDTO(attend);
		return dto;
	}

	// search attendance by ID
	@GetMapping("/get/{id}")
	@ResponseBody
	AttendanceDTO getAttendance(@PathVariable Long id) {
		Attendance attend = attendanceService.getAttendance(id);
		if(attend==null) return new AttendanceDTO(); // return empty if not found
		AttendanceDTO dto = new AttendanceDTO(attend);
		return dto;
	}

	// list attendance by student Id
	@GetMapping("/list/student/{id}")
	@ResponseBody
	public List<AttendanceDTO> listAttendancesByStudent(@PathVariable Long id) {
		List<AttendanceDTO> dtos = attendanceService.findAttendanceByStudent(id);
		return dtos;
	}

	// list attendance by clazz Id
	@GetMapping("/list/clazz/{id}")
	@ResponseBody
	public List<AttendanceDTO> listAttendancesByClazz(@PathVariable Long id) {
		List<AttendanceDTO> dtos = attendanceService.findAttendanceByClazz(id);
		return dtos;
	}
	
	// list attendance by student Id & clazz Id
	@GetMapping("/list/student/{studentId}/clazz/{clazzId}")
	@ResponseBody
	public List<AttendanceDTO> listAttendancesByStudentAndClazz(@PathVariable("studentId") Long studentId, @PathVariable("clazzId") Long clazzId) {
		List<AttendanceDTO> dtos = attendanceService.findAttendanceByStudentAndClazz(studentId, clazzId);
		return dtos;
	}

	// list attendance Id by student Id
	@GetMapping("/listId/student/{id}")
	@ResponseBody
	public List<Long> listAttendanceIdByStudent(@PathVariable Long id) {
		List<Long> dtos = attendanceService.findAttendanceIdByStudent(id);
		return dtos;
	}

	// list attendance Id by clazz Id
	@GetMapping("/listId/clazz/{id}")
	@ResponseBody
	public List<Long> listAttendanceIdByClazz(@PathVariable Long id) {
		List<Long> dtos = attendanceService.findAttendanceIdByClazz(id);
		return dtos;
	}
	
	// list attendance Id by student Id & clazz Id
	@GetMapping("/listId/student/{studentId}/clazz/{clazzId}")
	@ResponseBody
	public List<Long> listAttendanceIdByStudentAndClazz(@PathVariable("studentId") Long studentId, @PathVariable("clazzId") Long clazzId) {
		List<Long> dtos = attendanceService.findAttendanceIdByStudentAndClazz(studentId, clazzId);
		return dtos;
	}

}
