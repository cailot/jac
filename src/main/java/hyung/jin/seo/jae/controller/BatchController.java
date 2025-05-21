package hyung.jin.seo.jae.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.model.Course;
import hyung.jin.seo.jae.model.Cycle;
import hyung.jin.seo.jae.model.OnlineSession;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.CourseService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.OnlineSessionService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("batch")
public class BatchController {

	@Autowired
	private CycleService cycleService;

	@Autowired
	private CodeService codeService;

	@Autowired
	private CourseService courseService;

	@Autowired
	private OnlineSessionService onlineSessionService;

	@Autowired
	private ClazzService clazzService;

	@Autowired
	private StudentService studentService;

	@Value("${inactive.student.enrolment.days}")
	private int days;

	// count records number in database
	@GetMapping("/updateInactiveStudent")
	@ResponseBody
	int coutUpdateInactiveStudent() {
		int count = 10;
		studentService.updateInactiveStudent(days);
		return count;
	}

	// create course template
	@GetMapping("/createCourse/{year}")
	@ResponseBody
	public ResponseEntity<String> createCourseTemplate(@PathVariable("year") int year) {
		try {
			// 1. get Cycle
			Cycle cycle = cycleService.findCycleByYear(year);
			// 2. create Course
			List<Course> courses = getCourses(year);
			// 3. add Course
			for (Course course : courses) {
				courseService.addCourse(course);
			}
			// 4. create Online Class under Head Office
			for(Course course : courses){
				if(course.isOnline()){
					Clazz clazz = new Clazz();
					clazz.setActive(true);
					clazz.setDay("0");
					clazz.setName("E-Learning");
					clazz.setState(JaeConstants.VICTORIA_CODE);
					clazz.setBranch(JaeConstants.HEAD_OFFICE_CODE);
					clazz.setStartDate(cycle.getStartDate());
					clazz.setCourse(course);
					clazzService.addClazz(clazz);
				}
			}
			// 5. create class template for branch
			// get branch code
			List<BranchDTO> branches = codeService.allBranches();
			// get start date for new year
			Cycle newCycle = cycleService.findCycleByYear(year);
			LocalDate startDate = newCycle.getStartDate();

			// bring last year class from branch

			for(BranchDTO branch : branches){
				String branchCode = branch.getCode();
				if(branchCode.equals(JaeConstants.HEAD_OFFICE_CODE) || branchCode.equals(JaeConstants.TEST_CODE)) continue;
				// get last year class from branch
				List<ClazzDTO> clazzes = clazzService.listOnsiteClazz(JaeConstants.VICTORIA_CODE, branchCode, "0", String.valueOf(year - 1));
				for(ClazzDTO clazz : clazzes){
					if(!clazz.isOnline()){
						Clazz newClazz = new Clazz();
						newClazz.setActive(true);
						newClazz.setName(clazz.getName());
						newClazz.setState(JaeConstants.VICTORIA_CODE);
						newClazz.setBranch(branchCode);
						newClazz.setDay(clazz.getDay());
						newClazz.setStartDate(startDate);
						Course newCourse = courseService.getNewCourse(Long.parseLong(clazz.getCourseId()), year);
						newClazz.setCourse(newCourse);
						clazzService.addClazz(newClazz);		
					}
				}
			}


			// 5. return success message// // 3. return success;
			return ResponseEntity.ok("Course template generated success");
		} catch (Exception e) {
			String message = "Error registering Class: " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}


	// get courses for new year
	private List<Course> getCourses(int year) {
		List<Course> courses = new ArrayList<>();
		Cycle cycle = cycleService.findCycleByYear(year);
		// get old courses
		List<Course> olds = courseService.allCourses(year-1);
		for(Course old : olds){
			Course newCourse = new Course();
			newCourse.setName(old.getName());
			newCourse.setGrade(old.getGrade());
			newCourse.setPrice(old.getPrice());
			newCourse.setDescription(old.getDescription());
			newCourse.setOnline(old.isOnline());
			newCourse.setActive(old.isActive());
			newCourse.setSubjects(new ArrayList<>(old.getSubjects()));
			newCourse.setCycle(cycle);
			courses.add(newCourse);
		}
		return courses;
	}

	@PostMapping("/createOnline")
	@ResponseBody
    public ResponseEntity<String> processOnlineBatch(@RequestParam("file") MultipartFile file, @RequestParam("year") int year) {

		// 1. validate uploaded file	
		if (file != null && !file.isEmpty()) {
			String originalFilename = file.getOriginalFilename();
			if (originalFilename != null) {
				String fileExtension = originalFilename.substring(originalFilename.lastIndexOf(".") + 1);
				if ("csv".equalsIgnoreCase(fileExtension)) {
					// File extension is CSV, proceed with further processing
				} else {
					// Invalid file extension
					return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Invalid file format. Please upload a CSV file.");
				}
			} else {
				// File name not found
				return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("File name not found. Please try again.");
			}
		} else {
			// No file uploaded
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("No file uploaded. Please select a file to upload.");
		}
		
		// 2. proccess online session
		int lineCount = 0;
		if (file != null && !file.isEmpty()) {
			try {
				// Create a BufferedReader to read the lines from the uploaded CSV file
				BufferedReader reader = new BufferedReader(new InputStreamReader(file.getInputStream()));
				String line;
				while ((line = reader.readLine()) != null) {
					lineCount++;
					String[] columns = line.split(",");	
					if(lineCount ==1) continue; // skip header in csv
					String grade = JaeUtils.getGradeCode(StringUtils.trimToEmpty(columns[0]));
					int week = Integer.parseInt(StringUtils.trimToEmpty(columns[1]));
					String title = JaeUtils.getGradeCode(StringUtils.trimToEmpty(columns[2]));
					String url = StringUtils.trimToEmpty(columns[3]);
					// create OnlineSession
					OnlineSession session = getOnlineSession(grade, year, week, title, url);
					// register OnlineSession	
					session = onlineSessionService.addOnlineSession(session);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		// return success message
		return ResponseEntity.ok("\"Online Session template generated success\"");							
    }

	// return OnlineSession
	private OnlineSession getOnlineSession(String grade, int year, int set, String title, String url){
		// get Clazz
		Clazz clazz = clazzService.getOnlineByGradeNYear(grade, year);
		// create OnlineSession
		OnlineSession online = new OnlineSession();
		// fixed
		online.setActive(true);		
		online.setDay(getDay4Online(grade));
		online.setStartTime("16:00");
		online.setEndTime("19:30");
		online.setClazz(clazz);
		// variable
		online.setWeek(set);
		online.setTitle(title);
		online.setAddress(url);
		// return OnlineSession
		return online;		
	}

	private String getDay4Online(String grade){
		String day = "0";
		switch (grade) {
			case "1":
				day = "1"; // Monday
			case "2":
				day = "1";
			case "3":
				day = "1";
				break;
			case "4":
				day = "2"; // Tuesday
			case "5":
				day = "2";
			case "6":
				day = "2";
				break;
			case "7":
				day = "3"; // Wednessday
			case "8":
				day = "3";
			case "9":
				day = "3";
				break;
			case "11":
				day = "2";
				break;
			case "12":
				day = "3";
				break;
			default:
				break;
		}
		return day;
	}

}