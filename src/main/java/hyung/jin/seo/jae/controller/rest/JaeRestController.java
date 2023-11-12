package hyung.jin.seo.jae.controller.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

import hyung.jin.seo.jae.dto.AttendanceDTO;
import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.dto.mobile.AttendanceRollClazzDTO;
import hyung.jin.seo.jae.dto.mobile.AttendanceRollStudentDTO;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Cycle;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.service.AttendanceService;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.EnrolmentService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.service.TeacherService;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("api")
public class JaeRestController {

	@Autowired
	private TeacherService teacherService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private EnrolmentService enrolmentService;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private AttendanceService attendanceService;

	@GetMapping("/clazzList/{id}")
	List<AttendanceRollClazzDTO> getClazzList(@PathVariable Long id) {
		List<AttendanceRollClazzDTO> dtos = new ArrayList<>();
		// 1. clazz ids
		List<Long> clazzIds = teacherService.getClazzIdByTeacher(id);
		int currentWeek = cycleService.academicWeeks();
		// 2. get clazz info & number of students
		for (Long clazzId : clazzIds) {
			AttendanceRollClazzDTO dto = new AttendanceRollClazzDTO();
			Clazz clazz = clazzService.getClazz(clazzId);
			ClazzDTO clazzDto = new ClazzDTO(clazz);
			Integer number = enrolmentService.getStudentNumberByClazz(clazzId, currentWeek);
			dto.setId(Long.toString(clazzId));
			dto.setName(clazzDto.getName());
			dto.setDescription(clazzDto.getDescription());
			dto.setDay(clazzDto.getDay());
			dto.setGrade(clazzDto.getGrade());
			dto.setNumber(number.toString());
			dtos.add(dto);
		}
		// 3. return dtos
		return dtos;
	}

	@GetMapping("/attendList/{id}")
	List<AttendanceRollStudentDTO> getAttendList(@PathVariable Long id) {
		List<AttendanceRollStudentDTO> dtos = new ArrayList<>();
		// 1. check currentWeek
		int currentWeek = cycleService.academicWeeks();
		// 2. get attend list
		List<AttendanceDTO> attendList = attendanceService.findAttendanceByClazzAndWeek(id, currentWeek);
		// 3. populate AttendanceRollStudentDTO
		for (AttendanceDTO attend : attendList) {
			AttendanceRollStudentDTO dto = new AttendanceRollStudentDTO();
			dto.setId(attend.getId());
			dto.setStatus(attend.getStatus());
			dto.setStudentId(attend.getStudentId());
			dto.setStudentName(attend.getStudentName());
			dtos.add(dto);
		}
		// 4. return dtos
		return dtos;
	}

	@PostMapping("/updateAttend")
	@ResponseBody
	public ResponseEntity<String> updateAttendance(@RequestBody(required = false) List<Map<Integer, String>> infos) {
		// 1. check passed info
		if (infos == null || infos.isEmpty()) {
			return ResponseEntity.badRequest().body("Attendance Info Update Failed");
		}
		for (Map<Integer, String> info : infos) {
			// how to get key and value from map?
			info.entrySet().forEach(entry -> {
				int attendId = entry.getKey();
				String attendStatus = entry.getValue();
				System.out.println(attendId + " - " + attendStatus);
			});
		}
		// 4-1. return flag
		return ResponseEntity.ok("Attendance Info Update Success");
		// }
	}

}
