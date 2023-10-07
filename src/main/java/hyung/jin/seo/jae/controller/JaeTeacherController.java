package hyung.jin.seo.jae.controller;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.TeacherDTO;
import hyung.jin.seo.jae.model.Teacher;
import hyung.jin.seo.jae.service.TeacherService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("teacher")
public class JaeTeacherController {

	@Autowired
	private TeacherService teacherService;
	

	// register new teacher
	@PostMapping("/register")
	@ResponseBody
	public TeacherDTO registerTeacher(@RequestBody TeacherDTO formData) {
		Teacher teacher = formData.convertToTeacher();
		teacher = teacherService.addTeacher(teacher);
		TeacherDTO dto = new TeacherDTO(teacher);
		return dto;
	}

	// search teacher with keyword - ID, firstName & lastName
	@GetMapping("/search")
	@ResponseBody
	List<TeacherDTO> searchTeachers(@RequestParam("keyword") String keyword) {
		List<Teacher> teachers = teacherService.searchTeachers(keyword);
		List<TeacherDTO> dtos = new ArrayList<TeacherDTO>();
		for (Teacher teacher : teachers) {
			TeacherDTO dto = new TeacherDTO(teacher);
			dtos.add(dto);
		}
		return dtos;
	}

	// search teacher by ID
	@GetMapping("/get/{id}")
	@ResponseBody
	TeacherDTO getTeachers(@PathVariable Long id) {
		Teacher teacher = teacherService.getTeacher(id);
		if(teacher==null) return new TeacherDTO(); // return empty if not found
		TeacherDTO dto = new TeacherDTO(teacher);
		return dto;
	}
	
	// update existing teacher
	@PutMapping("/update")
	@ResponseBody
	public TeacherDTO updateTeacher(@RequestBody TeacherDTO formData) {
		Teacher teacher = formData.convertToTeacher();
		System.out.println(formData);
		System.out.println(teacher);
//		if((teacher.getElearnings() != null) && (teacher.getElearnings().size() > 0)) {
//			// 1. check if any related courses come
//			Set<ElearningDTO> crss = formData.getElearnings();
//			Set<Long> cidList = new HashSet<Long>(); // extract Course Id
//			for(ElearningDTO crsDto : crss) {
//				cidList.add(Long.parseLong(crsDto.getId()));
//			}
//			long[] courseId = cidList.stream().mapToLong(Long::longValue).toArray();
//			// 2. get Course in Teacher
//			Set courses = teacher.getElearnings();
//			// 3. clear existing course
//			courses.clear();
//			for(long cid : courseId) {
//				// 4. get course info
//				Elearning crs = elearningService.getElearning(cid);
//				// 6. add Teacher to Course
//				crs.getTeachers().add(teacher);
//				// 5. add Course to Teacher
//				courses.add(crs);
//			}
//		}
		// 7. update Teacher
		teacher = teacherService.updateTeacher(teacher, teacher.getId());
		// 8. convert Teacher to TeacherDTO
		TeacherDTO dto = new TeacherDTO(teacher);
		return dto;
	}

	// activate teacher by Id
	@PutMapping("/activate/{id}")
	@ResponseBody
	public void activateTeacher(@PathVariable Long id) {
		teacherService.reactivateTeacher(id);
	}

		
	// de-activate teacher by Id
	@PutMapping("/inactivate/{id}")
	@ResponseBody
	public void inactivateTeacher(@PathVariable Long id) {
		teacherService.dischargeTeacher(id);
	}
	
	
	// search student list with state, branch or active
	@GetMapping("/list")
	public String listTeachers(@RequestParam(value="listState", required=false) String state, @RequestParam(value="listBranch", required=false) String branch, @RequestParam(value="listActive", required=false) String active, Model model) {
		System.out.println(state + "\t" + branch + "\t" + active);
		List<Teacher> teachers = teacherService.listTeachers(state, branch, active);
		List<TeacherDTO> dtos = new ArrayList<TeacherDTO>();
		for (Teacher teacher : teachers) {
			TeacherDTO dto = new TeacherDTO(teacher);
			try {
				// convert date format to dd/MM/yyyy
				dto.setStartDate(JaeUtils.convertToddMMyyyyFormat(dto.getStartDate()));
				dto.setEndDate(JaeUtils.convertToddMMyyyyFormat(dto.getEndDate()));
			} catch (ParseException e) {
				e.printStackTrace();
			}
			dtos.add(dto);
		}
		model.addAttribute(JaeConstants.TEACHER_LIST, dtos);
		return "teacherListPage";
	}

	// update memo by Id
	@PostMapping("/updateMemo/{id}")
	@ResponseBody
	public ResponseEntity<String> updateMemo(@PathVariable("id") Long id, @RequestBody(required = false) String info) {
		try{
			teacherService.updateTeacherMemo(id, info);
			return ResponseEntity.ok("Memo Update Success");
		}catch(Exception e){
			System.out.println("No teacher found");
			return ResponseEntity.ok("Material Update Failed");
		}
	}
}
