package hyung.jin.seo.jae.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.dto.AttendanceListDTO;
import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.dto.SearchCriteriaDTO;
import hyung.jin.seo.jae.model.Attendance;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Cycle;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.AttendanceService;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("attendance")
public class AttendanceController {

	@Autowired
	private AttendanceService attendanceService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private StudentService studentService;

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

	// search attendance
	@GetMapping("/search")
	public String searchAttendance(@RequestParam("listState") String state, 
								 @RequestParam("listBranch") String branch, 
								 @RequestParam("listGrade") String grade, 
								 @RequestParam("listClass") String clazz, 
								 @RequestParam("fromDate") String fromDate, 
								 @RequestParam("toDate") String toDate,
								 @RequestParam(value = "page", defaultValue = "0") int page,
								 @RequestParam(value = "size", defaultValue = "20") int size,
								 Model model) {
		
		List<AttendanceListDTO> dtos = new ArrayList<>();
		
		// 2. set search criteria
		SearchCriteriaDTO criteria = new SearchCriteriaDTO();
		criteria.setState(state);
		criteria.setBranch(branch);
		criteria.setGrade(grade);
		String clazzId = clazz;
		String clazzName = (clazzId.equalsIgnoreCase("0")) ? "All" : clazzService.getName(Long.parseLong(clazzId));
		criteria.setClazzId(clazzId);
		criteria.setClazzName(clazzName);
		criteria.setFromDate(fromDate);
		criteria.setToDate(toDate);
		model.addAttribute(JaeConstants.CRITERIA_INFO, criteria);	

		// 3. check academic years and cycles
		long startCycleId = cycleService.findIdByDate(fromDate);
		long endCycleId = cycleService.findIdByDate(toDate);
		
		// Get all cycle IDs between start and end dates
		List<Long> cycleIds = new ArrayList<>();
		for (long id = startCycleId; id <= endCycleId; id++) {
			cycleIds.add(id);
		}

		// 3. header info - collect all weeks across cycles
		List<Integer> headerWks = new ArrayList<>();
		List<Integer> yearLabels = new ArrayList<>(); // To store year labels for each week
		
		for (Long cycleId : cycleIds) {
			Cycle cycle = cycleService.getCycle(cycleId);
			if (cycle == null) continue;
			
			// Get week range for this cycle
			int cycleStartWeek = (cycleId == startCycleId) ? cycleService.academicWeeks(fromDate) : 1;
			int cycleEndWeek;
			
			if (cycleId == endCycleId) {
				cycleEndWeek = cycleService.academicWeeks(toDate);
			} else {
				LocalDate endDateOfCycle = cycle.getEndDate();
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
				String formattedDate = endDateOfCycle.format(formatter);
				cycleEndWeek = cycleService.academicWeeks(formattedDate);
			}
			
			// Add weeks and year labels for this cycle
			for (int i = cycleStartWeek; i <= cycleEndWeek; i++) {
				headerWks.add(i);
				yearLabels.add(cycle.getYear());
			}
		}
		
		model.addAttribute(JaeConstants.WEEK_HEADER, headerWks);
		model.addAttribute("yearLabels", yearLabels);

		// 4. search AttendanceListDTO
		List<ClazzDTO> clazzs;
		if(criteria.getClazzId().equalsIgnoreCase("0")) {
			// 4-1. if clazzId is "All", then search all clazz Ids
			clazzs = clazzService.filterOnSiteClazz(criteria.getState(), criteria.getBranch(), criteria.getGrade()); // except online class	
		} else {
			// 4-2. if clazzId is not "All", then search by clazz Id
			clazzs = new ArrayList<>();
			Long clazId = Long.parseLong(criteria.getClazzId());
			Clazz claz = clazzService.getClazz(clazId);
			clazzs.add(new ClazzDTO(claz));
		}

		// Process classes in batches
		int totalClasses = clazzs.size();
		int startIdx = page * size;
		int endIdx = Math.min(startIdx + size, totalClasses);
		List<ClazzDTO> pageClazzs = clazzs.subList(startIdx, endIdx);

		for(ClazzDTO claz : pageClazzs) {
			Long clazId = Long.parseLong(claz.getId());
			String clazName = claz.getName();
			String clazDay = claz.getDay();
			String clazGrade = claz.getGrade();

			// Get student ids by clazz id
			List<Long> studentIds = enrolmentService.findStudentIdByClazzId(clazId);
			
			// Process students
			for(Long studentId : studentIds) {
				Student std = studentService.getStudent(studentId);
				if(std == null) continue;

				AttendanceListDTO dto = new AttendanceListDTO();
				dto.setClazzId(clazId+"");
				dto.setStudentId(studentId+"");
				dto.setStudentName(std.getFirstName() + " " + std.getLastName());
				dto.setClazzName(clazName);
				dto.setClazzDay(clazDay);
				dto.setClazzGrade(clazGrade);

				List<String> statuses = new ArrayList<>();
				List<String> dates = new ArrayList<>();
				List<Integer> weeks = new ArrayList<>();
				
				// Get attendance for each week across all cycles
				for (Long cycleId : cycleIds) {
					Cycle cycle = cycleService.getCycle(cycleId);
					if (cycle == null) continue;
					
					int cycleStartWeek = (cycleId == startCycleId) ? cycleService.academicWeeks(fromDate) : 1;
					int cycleEndWeek;
					
					if (cycleId == endCycleId) {
						cycleEndWeek = cycleService.academicWeeks(toDate);
					} else {
						LocalDate endDateOfCycle = cycle.getEndDate();
						DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
						String formattedDate = endDateOfCycle.format(formatter);
						cycleEndWeek = cycleService.academicWeeks(formattedDate);
					}
					
					for (int i = cycleStartWeek; i <= cycleEndWeek; i++) {
						Attendance attend = attendanceService.getAttendanceByStudentAndClazzAndWeekAndCycle(studentId, clazId, i, cycleId);
						if (attend != null) {
							statuses.add(attend.getStatus());
							dates.add(attend.getAttendDate()+"");
							weeks.add(i);
						} else {
							statuses.add("");
							dates.add("");
							weeks.add(0);
						}
					}
				}
				
				dto.setStatus(statuses);
				dto.setAttendDate(dates);
				dto.setWeek(weeks);

				// Add DTO if it has any non-empty status
				if(statuses.stream().anyMatch(StringUtils::isNotBlank)) {
					dtos.add(dto);
				}
			}
		}

		// Add pagination info to model
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages", (int) Math.ceil((double) totalClasses / size));
		model.addAttribute("pageSize", size);
		model.addAttribute(JaeConstants.ATTENDANCE_INFO, dtos);	

		return "studentAttendancePage";
	}

	// update existing attendance list
	@PutMapping("/updateList")
	@ResponseBody
	public ResponseEntity<String> updateAttendanceList(@RequestBody AttendanceListDTO formData) {
		try{
			// 1. get student id & clazz id
			Long stdId = Long.parseLong(StringUtils.defaultString(formData.getStudentId(),"0"));
			Long clzId = Long.parseLong(StringUtils.defaultString(formData.getClazzId(),"0"));

			// 2. get size of arrays
			int size = formData.getWeek().size();
			for(int i=0; i<size; i++){
				// 3. get week
				int week = formData.getWeek().get(i);
				// 4. get status
				String status = formData.getStatus().get(i);

				if((week==0) || StringUtils.isBlank(status)) continue;
				
				System.out.println(week + " - " + StringUtils.defaultString(status));
				// 5. check if it needs to update or not
				String updateStats = StringUtils.defaultString(status);
				if(updateStats.equalsIgnoreCase(JaeConstants.ATTEND_YES) || updateStats.equalsIgnoreCase(JaeConstants.ATTEND_NO) || updateStats.equalsIgnoreCase(JaeConstants.ATTEND_PAUSE) || updateStats.equalsIgnoreCase(JaeConstants.ATTEND_OTHER)){
					// 6. update attendance
					attendanceService.updateStatus(stdId, clzId, week, status);
				}
			}
			// 7. return success;
			return ResponseEntity.ok("\"Attendance update success\"");
		}catch(Exception e){
			String message = "Error updating Attendance: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
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

	// update attendance day
	@PutMapping("/updateDay/{attendanceId}/{day}")
	@ResponseBody
	public ResponseEntity<String> updateAttendanceDay(@PathVariable("attendanceId") Long attendanceId, @PathVariable("day") String day) {
		try{
			// 1. get student id & clazz id
			attendanceService.updateDay(attendanceId, day);
			// 7. return success;
			return ResponseEntity.ok("\"Attendance day update success\"");
		}catch(Exception e){
			String message = "Error updating Attendance day : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	@PutMapping("/updateBatch")
	@ResponseBody
	public ResponseEntity<String> updateAttendanceBatch(@RequestBody List<AttendanceListDTO> formDataList) {
		try {
			for(AttendanceListDTO formData : formDataList) {
				// 1. get student id & clazz id
				Long stdId = Long.parseLong(StringUtils.defaultString(formData.getStudentId(),"0"));
				Long clzId = Long.parseLong(StringUtils.defaultString(formData.getClazzId(),"0"));

				// 2. get size of arrays
				int size = formData.getWeek().size();
				for(int i=0; i<size; i++) {
					// 3. get week
					int week = formData.getWeek().get(i);
					// 4. get status
					String status = formData.getStatus().get(i);

					if((week==0) || StringUtils.isBlank(status)) continue;
					
					// 5. check if it needs to update or not
					String updateStats = StringUtils.defaultString(status);
					if(updateStats.equalsIgnoreCase(JaeConstants.ATTEND_YES) || 
					   updateStats.equalsIgnoreCase(JaeConstants.ATTEND_NO) || 
					   updateStats.equalsIgnoreCase(JaeConstants.ATTEND_PAUSE) || 
					   updateStats.equalsIgnoreCase(JaeConstants.ATTEND_OTHER)) {
						// 6. update attendance
						attendanceService.updateStatus(stdId, clzId, week, status);
					}
				}
			}
			// 7. return success
			return ResponseEntity.ok("\"Batch attendance update success\"");
		} catch(Exception e) {
			String message = "Error updating Attendance batch: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

}
