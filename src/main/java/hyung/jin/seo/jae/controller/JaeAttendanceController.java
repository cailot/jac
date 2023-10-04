package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.checkerframework.checker.units.qual.g;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.dto.SearchCriteriaDTO;
import hyung.jin.seo.jae.model.Attendance;
import hyung.jin.seo.jae.service.AttendanceService;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("attendance")
public class JaeAttendanceController {

	@Autowired
	private AttendanceService attendanceService;

	@Autowired
	private ClazzService clazzService;

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

	// // search attendance
	// @GetMapping("/search")
	// public String searchAttendance(@RequestParam("listState") String state, @RequestParam("listBranch") String branch, @RequestParam("listGrade") String grade, @RequestParam("listClass") String clazzId, @RequestParam("fromDate") String fromDate, @RequestParam("toDate") String toDate, HttpSession session) {
	// 	// 1. clear session
	// 	JaeUtils.clearSession(session);
	// 	// 2. set search criteria
	// 	SearchCriteriaDTO criteria = new SearchCriteriaDTO();
	// 	criteria.setState(state);
	// 	criteria.setBranch(branch);
	// 	criteria.setGrade(grade);
	// 	criteria.setFromDate(fromDate);
	// 	criteria.setToDate(toDate);
	// 	session.setAttribute(JaeConstants.CRITERIA_INFO, criteria);		
	// 	// 6. return redirect page
	// 	return "studentAttendancePage";
	// }

	// search attendance
	@GetMapping("/search")
	public String searchAttendance(HttpServletRequest request, HttpSession session) {
		// 1. clear session
		JaeUtils.clearSession(session);
		// 2. set search criteria
		String state = request.getParameter("listState");
		String branch = request.getParameter("listBranch");
		String grade = request.getParameter("listGrade");
		SearchCriteriaDTO criteria = new SearchCriteriaDTO();
		criteria.setState(state);
		criteria.setBranch(branch);
		criteria.setGrade(grade);
		String clazzId = request.getParameter("listClass");
		String clazzName = (clazzId.equalsIgnoreCase(JaeConstants.ALL)) ? "All" : clazzService.getName(Long.parseLong(clazzId));
		criteria.setClazzId(clazzId);
		criteria.setClazzName(clazzName);
		criteria.setFromDate(request.getParameter("fromDate"));
		criteria.setToDate(request.getParameter("toDate"));
		session.setAttribute(JaeConstants.CRITERIA_INFO, criteria);	
		// 3. search AttendanceDTO by class Id
		List<AttendanceDTO> dtos = new ArrayList<>();
		// 3-1. if clazzId is "All", then search all clazz Ids
		if(clazzId.equalsIgnoreCase(JaeConstants.ALL)) {
			List<Long> clazzIds = clazzService.filterClassIds(state, branch, grade);	
			for(Long id : clazzIds) {
				List<AttendanceDTO> attends = attendanceService.findAttendanceByClazz(id);	
				dtos.addAll(attends);
			}
		}else{
			// 3-2. if clazzId is not "All", then search only the clazz
			List<AttendanceDTO> attends = attendanceService.findAttendanceByClazz(Long.parseLong(clazzId));	
			dtos.addAll(attends);
		}
		// 4. save AttendanceDTOs in session
		session.setAttribute(JaeConstants.ATTENDANCE_INFO, dtos);
		// 6. return redirect page
		return "studentAttendancePage";
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
