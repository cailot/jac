package hyung.jin.seo.jae.controller;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import hyung.jin.seo.jae.dto.CycleDTO;
import hyung.jin.seo.jae.dto.ExtraworkDTO;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.dto.HomeworkScheduleDTO;
import hyung.jin.seo.jae.dto.PracticeAnswerDTO;
import hyung.jin.seo.jae.dto.PracticeDTO;
import hyung.jin.seo.jae.dto.PracticeScheduleDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.dto.TestAnswerDTO;
import hyung.jin.seo.jae.dto.TestDTO;
import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.model.Extrawork;
import hyung.jin.seo.jae.model.Grade;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.model.HomeworkSchedule;
import hyung.jin.seo.jae.model.Practice;
import hyung.jin.seo.jae.model.PracticeAnswer;
import hyung.jin.seo.jae.model.PracticeSchedule;
import hyung.jin.seo.jae.model.PracticeType;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.model.Test;
import hyung.jin.seo.jae.model.TestAnswer;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.model.TestSchedule;
import hyung.jin.seo.jae.model.TestType;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.service.TestProcessService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("connected")
public class ConnectedController {

	private static final Logger LOG = LoggerFactory.getLogger(ConnectedController.class);

	@Autowired
	private ConnectedService connectedService;

	@Autowired
	private CodeService codeService;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private TestProcessService testProcessService;

	@Autowired
	private StudentService studentService;
	
	// register homework
	@PostMapping("/addHomework")
	@ResponseBody
	public HomeworkDTO registerHomework(@RequestBody HomeworkDTO formData) {
		// 1. create barebone
		Homework work = formData.convertToHomework();
		// 2. set active to true as default
		work.setActive(true);
		// 3. set Subject
		Subject subject = codeService.getSubject(Long.parseLong(formData.getSubject()));
		// 4. set Grade
		Grade grade = codeService.getGrade(Long.parseLong(formData.getGrade()));
		// 5. associate Subject & Grade
		work.setSubject(subject);
		work.setGrade(grade);
		// 6. register Homework
		Homework added = connectedService.addHomework(work);
		// 7. return dto
		HomeworkDTO dto = new HomeworkDTO(added);
		return dto;
	}

	// register extrawork
	@PostMapping("/addExtrawork")
	@ResponseBody
	public ExtraworkDTO registerExtrawork(@RequestBody ExtraworkDTO formData) {
		// 1. create barebone
		Extrawork work = formData.convertToExtrawork();
		// 2. set active to true as default
		work.setActive(true);
		// 3. set Grade
		Grade grade = codeService.getGrade(Long.parseLong(formData.getGrade()));
		// 4. associate Grade
		work.setGrade(grade);
		// 5. register Extrawork
		Extrawork added = connectedService.addExtrawork(work);
		// 6. return dto
		ExtraworkDTO dto = new ExtraworkDTO(added);
		return dto;
	}

	// register practice
	@PostMapping("/addPractice")
	@ResponseBody
	public PracticeDTO registerPractice(@RequestBody PracticeDTO formData) {
		// 1. create barebone
		Practice work = formData.convertToPractice();
		// 2. set active to true as default
		work.setActive(true);
		// 3. set Grade & PracticeType
		Grade grade = codeService.getGrade(Long.parseLong(formData.getGrade()));
		PracticeType type = codeService.getPracticeType(formData.getPracticeType());
		// 4. associate Grade & PracticeType
		work.setGrade(grade);
		work.setPracticeType(type);
		// 5. register Practice
		Practice added = connectedService.addPractice(work);
		// 6. return dto
		PracticeDTO dto = new PracticeDTO(added);
		return dto;
	}

	// register test
	@PostMapping("/addTest")
	@ResponseBody
	public TestDTO registerTest(@RequestBody TestDTO formData) {
		// 1. create barebone
		Test work = formData.convertToTest();
		// 2. set active to true as default
		work.setActive(true);
		// 3. set Grade & PracticeType
		Grade grade = codeService.getGrade(Long.parseLong(formData.getGrade()));
		TestType type = codeService.getTestType(formData.getTestType());
		// 4. associate Grade & PracticeType
		work.setGrade(grade);
		work.setTestType(type);
		// 5. register Practice
		Test added = connectedService.addTest(work);
		// 6. return dto
		TestDTO dto = new TestDTO(added);
		return dto;
	}

	// register practice schedule
	@PostMapping("/addPracticeSchedule")
	@ResponseBody
	public PracticeScheduleDTO registerPracticeSchedule(@RequestBody PracticeScheduleDTO formData) {
		PracticeSchedule schedule = formData.convertToPracticeSchedule();
		schedule.setActive(true);
		schedule = connectedService.addPracticeSchedule(schedule);
		PracticeScheduleDTO dto = new PracticeScheduleDTO(schedule);
		return dto;
	}
	
	// register test schedule
	@PostMapping("/addTestSchedule")
	@ResponseBody
	public TestScheduleDTO registerTestSchedule(@RequestBody TestScheduleDTO formData) {
		TestSchedule schedule = formData.convertToTestSchedule();
		schedule.setActive(true);
		schedule = connectedService.addTestSchedule(schedule);
		TestScheduleDTO dto = new TestScheduleDTO(schedule);
		return dto;
	}

	// register homework schedule
	@PostMapping("/addHomeworkSchedule")
	@ResponseBody
	public HomeworkScheduleDTO registerHomeworkSchedule(@RequestBody HomeworkScheduleDTO formData) {
		// System.out.println("formData : " + formData);
		HomeworkSchedule schedule = formData.convertToHomeworkSchedule();
		schedule = connectedService.addHomeworkSchedule(schedule);
		HomeworkScheduleDTO dto = new HomeworkScheduleDTO(schedule);
		return dto;
	}

	// update existing homework
	@PutMapping("/updateHomework")
	@ResponseBody
	public ResponseEntity<String> updateHomework(@RequestBody HomeworkDTO formData) {
		try{
			// 1. create barebone Homework
			Homework work = formData.convertToHomework();
			// 2. update Homework
			work = connectedService.updateHomework(work, Long.parseLong(formData.getId()));
			// 3.return flag
			return ResponseEntity.ok("\"Homework updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Homework : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// update existing extrawork
	@PutMapping("/updateExtrawork")
	@ResponseBody
	public ResponseEntity<String> updateExtrawork(@RequestBody ExtraworkDTO formData) {
		try{
			// 1. create barebone Homework
			Extrawork work = formData.convertToExtrawork();
			// 2. update Homework
			work = connectedService.updateExtrawork(work, Long.parseLong(formData.getId()));
			// 3.return flag
			return ResponseEntity.ok("\"Extrawork updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Extrawork : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// update existing practice
	@PutMapping("/updatePractice")
	@ResponseBody
	public ResponseEntity<String> updatePractice(@RequestBody PracticeDTO formData) {
		try{
			// 1. create barebone Homework
			Practice work = formData.convertToPractice();
			// 2. update Homework
			work = connectedService.updatePractice(work, Long.parseLong(formData.getId()));
			// 3.return flag
			return ResponseEntity.ok("\"Practice updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Practice : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}
	
	// update existing test
	@PutMapping("/updateTest")
	@ResponseBody
	public ResponseEntity<String> updateTest(@RequestBody TestDTO formData) {
		try{
			// 1. create barebone Homework
			Test work = formData.convertToTest();
			// 2. update Homework
			work = connectedService.updateTest(work, Long.parseLong(formData.getId()));
			// 3.return flag
			return ResponseEntity.ok("\"Test updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Test : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// update existing homework schedule
	@PutMapping("/updateHomeworkSchedule")
	@ResponseBody
	public ResponseEntity<String> updateHomeworkSchedule(@RequestBody HomeworkScheduleDTO formData) {
		try{
			// 1. create barebone HomeworkSchedule
			HomeworkSchedule schedule = formData.convertToHomeworkSchedule();
			// 2. update HomeworkSchedule
			schedule = connectedService.updateHomeworkSchedule(schedule, Long.parseLong(formData.getId()));
			// 4.return flag
			return ResponseEntity.ok("\"Homework Schedule updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Homework Schedule : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// update existing practice schedule
	@PutMapping("/updatePracticeSchedule")
	@ResponseBody
	public ResponseEntity<String> updatePracticeSchedule(@RequestBody PracticeScheduleDTO formData) {
		try{
			// 1. create barebone PracticeSchedule
			PracticeSchedule work = formData.convertToPracticeSchedule();
			// 2. update PracticeSchedule
			work = connectedService.updatePracticeSchedule(work, Long.parseLong(formData.getId()));
			// 3.return flag
			return ResponseEntity.ok("\"Practice Schedule updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Practice Schedule : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}

	// update existing test schedule
	@PutMapping("/updateTestSchedule")
	@ResponseBody
	public ResponseEntity<String> updateTestSchedule(@RequestBody TestScheduleDTO formData) {
		try{
			// 1. create barebone TestSchedule
			TestSchedule work = formData.convertToTestSchedule();
			// 2. update TestSchedule
			work = connectedService.updateTestSchedule(work, Long.parseLong(formData.getId()));
			// 4.return flag
			return ResponseEntity.ok("\"Test Schedule updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Test Schedule : " + e.getMessage();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
	}
	
	// get homework
	@GetMapping("/getHomework/{id}")
	@ResponseBody
	public HomeworkDTO getHomework(@PathVariable Long id) {
		Homework work = connectedService.getHomework(id);
		HomeworkDTO dto = new HomeworkDTO(work);
		return dto;
	}

	// get extrawork
	@GetMapping("/getExtrawork/{id}")
	@ResponseBody
	public ExtraworkDTO getExtrawork(@PathVariable Long id) {
		Extrawork work = connectedService.getExtrawork(id);
		ExtraworkDTO dto = new ExtraworkDTO(work);
		return dto;
	}

	// get practice
	@GetMapping("/getPractice/{id}")
	@ResponseBody
	public PracticeDTO getPractice(@PathVariable Long id) {
		Practice work = connectedService.getPractice(id);
		PracticeDTO dto = new PracticeDTO(work);
		return dto;
	}

	// get test
	@GetMapping("/getTest/{id}")
	@ResponseBody
	public TestDTO getTest(@PathVariable Long id) {
		Test work = connectedService.getTest(id);
		TestDTO dto = new TestDTO(work);
		return dto;
	}

	// get homework schedule
	@GetMapping("/getHomeworkSchedule/{id}")
	@ResponseBody
	public HomeworkScheduleDTO getHomeworkSchedule(@PathVariable Long id) {
		HomeworkSchedule work = connectedService.getHomeworkSchedule(id);
		HomeworkScheduleDTO dto = new HomeworkScheduleDTO(work);
		return dto;
	}

	// get practice schedule
	@GetMapping("/getPracticeSchedule/{id}")
	@ResponseBody
	public PracticeScheduleDTO getPracticeSchedule(@PathVariable Long id) {
		PracticeSchedule work = connectedService.getPracticeSchedule(id);
		PracticeScheduleDTO dto = new PracticeScheduleDTO(work);
		return dto;
	}

	// get test schedule
	@GetMapping("/getTestSchedule/{id}")
	@ResponseBody
	public TestScheduleDTO getTestSchedule(@PathVariable Long id) {
		// TestSchedule work = connectedService.getTestSchedule(id);
		// TestScheduleDTO dto = new TestScheduleDTO(work);
		TestScheduleDTO dto = connectedService.getTestSchedule(id);
		return dto;
	}

	// search homework by subject, year & week
	// @GetMapping("/homework/{subject}/{year}/{week}")
	// @ResponseBody
	// public HomeworkDTO searchHomework(@PathVariable int subject, @PathVariable int week) {
	// 	HomeworkDTO dto = connectedService.getHomeworkInfo(subject, week);
	// 	return dto;
	// }

	// bring homework in database
	@GetMapping("/filterHomework")
	public String listHomeworks(
			@RequestParam(value = "listSubject", required = false) String subject,
			@RequestParam(value = "listGrade", required = false) String grade,
			@RequestParam(value = "listWeek", required = false) String week, 
			Model model) {
		List<HomeworkDTO> dtos = new ArrayList();
		String filteredSubject = StringUtils.defaultString(subject, "0");
		String filteredGrade = StringUtils.defaultString(grade, "0");
		String filteredWeek = StringUtils.defaultString(week, "0");
		dtos = connectedService.listHomework(Integer.parseInt(filteredSubject), filteredGrade, Integer.parseInt(filteredWeek));		
		model.addAttribute(JaeConstants.HOMEWORK_LIST, dtos);
		return "homeworkListPage";
	}

	// bring extrawork in database
	@GetMapping("/filterExtrawork")
	public String listExtraworks(
			@RequestParam(value = "listGrade", required = false) String grade,
			Model model) {
		List<ExtraworkDTO> dtos = new ArrayList();
		String filteredGrade = StringUtils.defaultString(grade, JaeConstants.ALL);
		dtos = connectedService.listExtrawork(filteredGrade);		
		model.addAttribute(JaeConstants.EXTRAWORK_LIST, dtos);
		return "extraworkListPage";
	}

	@GetMapping("/filterPractice")
	public String listPractices(
			@RequestParam(value = "listPracticeType", required = false) String practiceType,
			@RequestParam(value = "listGrade", required = false) String grade,
			@RequestParam(value = "listVolume", required = false) String volume,
			Model model) {
		List<PracticeDTO> dtos = new ArrayList();
		String filteredType = StringUtils.defaultString(practiceType, "0");
		String filteredGrade = StringUtils.defaultString(grade, "0");
		String filteredVolume = StringUtils.defaultString(volume, "0");
		dtos = connectedService.listPractice(Integer.parseInt(filteredType), filteredGrade, Integer.parseInt(filteredVolume));		
		model.addAttribute(JaeConstants.PRACTICE_LIST, dtos);
		return "practiceListPage";
	}

	@GetMapping("/filterTest")
	public String listTests(
			@RequestParam(value = "listTestType", required = false) String testType,
			@RequestParam(value = "listGrade", required = false) String grade,
			@RequestParam(value = "listVolume", required = false) String volume,
			Model model) {
		List<TestDTO> dtos = new ArrayList();
		String filteredType = StringUtils.defaultString(testType, "0");
		String filteredGrade = StringUtils.defaultString(grade, "0");
		String filteredVolume = StringUtils.defaultString(volume, "0");
		dtos = connectedService.listTest(Integer.parseInt(filteredType), filteredGrade, Integer.parseInt(filteredVolume));		
		model.addAttribute(JaeConstants.TEST_LIST, dtos);
		return "testListPage";
	}



	@GetMapping("/filterHomeworkSchedule")
	public String listHomeworkchedules(
			@RequestParam(value = "listYear", required = false) int listYear,
			Model model) {
		LocalDateTime startTime = JaeConstants.START_TIME;
		LocalDateTime endTime = JaeConstants.END_TIME;
		// if listYear != 0, check Cycle's first day and last day
		if(listYear != 0){
			CycleDTO cycle = cycleService.listCycles(listYear);
			String start = cycle.getStartDate();
			String end = cycle.getEndDate();
			LocalDate startDate = LocalDate.parse(start, DateTimeFormatter.ISO_LOCAL_DATE);
        	startTime = startDate.atStartOfDay(); // Combine with start of the day (00:00:00)
			LocalDate endDate = LocalDate.parse(end, DateTimeFormatter.ISO_LOCAL_DATE);
        	endTime = endDate.atStartOfDay(); // Combine with start of the day (00:00:00)
		}
		List<HomeworkScheduleDTO> dtos = new ArrayList<>();
		dtos = connectedService.listHomeworkSchedule(startTime, endTime); 		
		model.addAttribute(JaeConstants.HOMEWORK_SCHEDULE_LIST, dtos);
		return "homeworkSchedulePage";
	}


	@GetMapping("/filterPracticeSchedule")
	public String listPracticeSchedules(
			@RequestParam(value = "listYear", required = false) int listYear,
			@RequestParam(value = "listPracticeType", required = false) int listPracticeType,
			Model model) {
		LocalDateTime startTime = JaeConstants.START_TIME;
		LocalDateTime endTime = JaeConstants.END_TIME;
		// if listYear != 0, check Cycle's first day and last day
		if(listYear != 0){
			CycleDTO cycle = cycleService.listCycles(listYear);
			String start = cycle.getStartDate();
			String end = cycle.getEndDate();
			LocalDate startDate = LocalDate.parse(start, DateTimeFormatter.ISO_LOCAL_DATE);
			startTime = startDate.atStartOfDay(); // Combine with start of the day (00:00:00)
			LocalDate endDate = LocalDate.parse(end, DateTimeFormatter.ISO_LOCAL_DATE);
			endTime = endDate.atStartOfDay(); // Combine with start of the day (00:00:00)
		}
		List<PracticeScheduleDTO> dtos = new ArrayList();
		dtos = connectedService.listPracticeSchedule(startTime, endTime, listPracticeType); 		
		model.addAttribute(JaeConstants.PRACTICE_SCHEDULE_LIST, dtos);
		return "practiceSchedulePage";
	}

	@GetMapping("/filterTestSchedule")
	public String listTestSchedules(
			@RequestParam(value = "listYear", required = false) int listYear,
			@RequestParam(value = "listTestType", required = false) int listTestType,
			Model model) {
		LocalDateTime startTime = JaeConstants.START_TIME;
		LocalDateTime endTime = JaeConstants.END_TIME;
		// if listYear != 0, check Cycle's first day and last day
		if(listYear != 0){
			CycleDTO cycle = cycleService.listCycles(listYear);
			String start = cycle.getStartDate();
			String end = cycle.getEndDate();
			LocalDate startDate = LocalDate.parse(start, DateTimeFormatter.ISO_LOCAL_DATE);
			startTime = startDate.atStartOfDay(); // Combine with start of the day (00:00:00)
			LocalDate endDate = LocalDate.parse(end, DateTimeFormatter.ISO_LOCAL_DATE);
			endTime = endDate.atStartOfDay(); // Combine with start of the day (00:00:00)
		}
		List<TestScheduleDTO> dtos = new ArrayList();
		dtos = connectedService.listTestSchedule(startTime, endTime, listTestType); 		
		model.addAttribute(JaeConstants.TEST_SCHEDULE_LIST, dtos);
		return "testSchedulePage";
	}

	// bring summary of extrawork
	@GetMapping("/summaryExtrawork/{grade}")
	@ResponseBody
	public List<SimpleBasketDTO> summaryExtraworks(@PathVariable String grade) {
		List<SimpleBasketDTO> dtos = new ArrayList();
		String filteredGrade = StringUtils.defaultString(grade, JaeConstants.ALL);
		dtos = connectedService.loadExtrawork(filteredGrade);	
		return dtos;
	}
	
	@PostMapping(value = "/savePracticeAnswerSheet")
	@ResponseBody
    public ResponseEntity<String> savePracticeAnswerSheet(@RequestBody Map<String, Object> payload) {
        // Extract practiceId and answers from the payload
		String answerId = payload.get("answerId").toString();
		String practiceId = payload.get("practiceId").toString();
		String video = payload.get("videoPath").toString();
		String pdf = payload.get("pdfPath").toString();
		String answerCount = payload.get("answerCount").toString();
		List<Map<String, Object>> mapAns = (List<Map<String, Object>>) payload.get("answers");
		// convert the Map of answers to List
		List<Integer>  answer = convertAnswers(mapAns);
		// if answerId has some value, update PracticeAnswer; otherwise register.
		if(StringUtils.isBlank(answerId)){
			// ADD
			// 1. create bare bone
			PracticeAnswer pa = new PracticeAnswer();
			// 2. populate PracticeAnswer
			pa.setVideoPath(video);
			pa.setPdfPath(pdf);
			pa.setAnswerCount(Integer.parseInt(answerCount));
			pa.setAnswers(answer);
			// 3. get Practice
			Practice practice = connectedService.getPractice(Long.parseLong(practiceId));
			// 4. associate Practice
			pa.setPractice(practice);
			// 5. register PracticeAnswer
			connectedService.addPracticeAnswer(pa);
		}else{
			// UPDATE
			// 1. get PracticeAnswer
			PracticeAnswer pa = connectedService.getPracticeAnswer(Long.parseLong(answerId));
			// 2. populate PracticeAnswer
			pa.setVideoPath(video);
			pa.setPdfPath(pdf);
			pa.setAnswerCount(Integer.parseInt(answerCount));
			pa.setAnswers(answer);
			// 3. update PracticeAnswer
			connectedService.updatePracticeAnswer(pa, Long.parseLong(answerId));
		}
		return ResponseEntity.ok("\"Success\"");
    }

	@PostMapping(value = "/saveTestAnswerSheet")
	@ResponseBody
    public ResponseEntity<String> saveTestAnswerSheet(@RequestBody Map<String, Object> payload) {
        // Extract practiceId and answers from the payload
		String answerId = payload.get("answerId").toString();
		String testId = payload.get("testId").toString();
		String video = payload.get("videoPath").toString();
		String pdf = payload.get("pdfPath").toString();
		String answerCount = payload.get("answerCount").toString();	
		List<TestAnswerItem> items = new ArrayList<>();
		// convert the answers list from the payload to a List<Map<String, Object>>
		ObjectMapper mapper = new ObjectMapper();
		List<Map<String, Object>> answerList = mapper.convertValue(payload.get("answers"), new TypeReference<List<Map<String, Object>>>() {});

		// Now iterate over answerList to access question, answer, and topic for each entry
		for (Map<String, Object> answer : answerList) {
			String question = StringUtils.defaultString(answer.get("question").toString(), "0");
			String selectedAnswer = StringUtils.defaultString(answer.get("answer").toString(), "0");
			String topic = StringUtils.defaultString(answer.get("topic").toString());
			// create TestAnswerItem and put it into items
			TestAnswerItem item = new TestAnswerItem(Integer.parseInt(question), Integer.parseInt(selectedAnswer), topic);
			items.add(item);
		}

		// if answerId has some value, update TestAnswer; otherwise register.
		if(StringUtils.isBlank(answerId)){
			// ADD
			// 1. create bare bone
			TestAnswer ta = new TestAnswer();
			// 2. populate PracticeAnswer
			ta.setPdfPath(pdf);
			ta.setVideoPath(video);
			ta.setAnswerCount(Integer.parseInt(answerCount));
			ta.setAnswers(items);
			// 3. get Test
			Test test = connectedService.getTest(Long.parseLong(testId));
			// 4. associate Test
			ta.setTest(test);
			// 5. register TestAnswer
			connectedService.addTestAnswer(ta);
		}else{
			// UPDATE
			// 1. get TestAnswer
			TestAnswer ta = connectedService.getTestAnswer(Long.parseLong(answerId));
			// 2. populate PracticeAnswer
			ta.setVideoPath(video);
			ta.setPdfPath(pdf);
			ta.setAnswerCount(Integer.parseInt(answerCount));
			ta.setAnswers(items);
			// 3. update PracticeAnswer
			connectedService.updateTestAnswer(ta, Long.parseLong(answerId));
		}
		return ResponseEntity.ok("\"Success\"");
    }

	// check if PracticeAnswer exists or not
	@GetMapping("/checkPracticeAnswer/{practiceId}")
	@ResponseBody
	public PracticeAnswerDTO findPracticeAnswer(@PathVariable Long practiceId) {
		PracticeAnswerDTO answer = connectedService.findPracticeAnswerByPractice(practiceId);
		return answer;
	}

	// check if TestAnswer exists or not
	@GetMapping("/checkTestAnswer/{testId}")
	@ResponseBody
	public TestAnswerDTO findTestAnswer(@PathVariable Long testId) {
		TestAnswerDTO answer = connectedService.findTestAnswerByTest(testId);
		return answer;
	}

	// list practice type for schedule
	// @GetMapping("/practiceGroup4Schedule/{group}")
	// @ResponseBody
	// List<PracticeType> getPracticeGroupForSchedule(@PathVariable int group) {
	// 	List<PracticeType> dtos = codeService.getPracticeTypes(group);
	// 	return dtos;
	// }

	// list test type for schedule
	// @GetMapping("/test4Schedule/{type}/{grade}")
	// @ResponseBody
	// List<TestDTO> getTestForSchedule(@PathVariable int type, @PathVariable String grade) {
	// 	List<TestDTO> dtos = connectedService.listTestByTypeNGrade(type, grade); 
	// 	return dtos;
	// }
	
	@DeleteMapping(value = "/deleteHomework/{homeId}")
	@ResponseBody
    public ResponseEntity<String> removeHomework(@PathVariable String homeId) {
        Long id = Long.parseLong(StringUtils.defaultString(homeId, "0"));
		connectedService.deleteHomework(id);
		return ResponseEntity.ok("\"Homework deleted successfully\"");
    }

	@DeleteMapping(value = "/deleteExtrawork/{extraId}")
	@ResponseBody
    public ResponseEntity<String> removeExtrawork(@PathVariable String extraId) {
        Long id = Long.parseLong(StringUtils.defaultString(extraId, "0"));
		connectedService.deleteExtrawork(id);
		return ResponseEntity.ok("\"Extra Work deleted successfully\"");
    }

	@DeleteMapping(value = "/deleteHomeworkSchedule/{scheduleId}")
	@ResponseBody
    public ResponseEntity<String> removeHomeworkSchedule(@PathVariable String scheduleId) {
        Long id = Long.parseLong(StringUtils.defaultString(scheduleId, "0"));
		connectedService.deleteHomeworkSchedule(id);
		return ResponseEntity.ok("\"Homework Schedule deleted successfully\"");
    }

	@DeleteMapping(value = "/deletePracticeSchedule/{practiceScheduleId}")
	@ResponseBody
    public ResponseEntity<String> removePracticeSchedule(@PathVariable long practiceScheduleId) {
        // Long id = Long.parseLong(StringUtils.defaultString(practiceScheduleId, "0"));
		connectedService.deletePracticeSchedule(practiceScheduleId);
		return ResponseEntity.ok("\"Practice Schedule deleted successfully\"");
    }

	@DeleteMapping(value = "/deleteTestSchedule/{testScheduleId}")
	@ResponseBody
    public ResponseEntity<String> removeTestSchedule(@PathVariable long testScheduleId) {
        // Long id = Long.parseLong(StringUtils.defaultString(testScheduleId, "0"));
		connectedService.deleteTestSchedule(testScheduleId);
		return ResponseEntity.ok("\"Test Schedule deleted successfully\"");
    }

	@DeleteMapping(value = "/deletePractice/{practiceId}")
	@ResponseBody
    public ResponseEntity<String> removePractice(@PathVariable String practiceId) {
        Long id = Long.parseLong(StringUtils.defaultString(practiceId, "0"));
		connectedService.deletePractice(id);
		return ResponseEntity.ok("\"Practice deleted successfully\"");
    }

	@DeleteMapping(value = "/deleteTest/{testId}")
	@ResponseBody
    public ResponseEntity<String> removeTest(@PathVariable String testId) {
        Long id = Long.parseLong(StringUtils.defaultString(testId, "0"));
		connectedService.deleteTest(id);
		return ResponseEntity.ok("\"Test deleted successfully\"");
    }

	@PutMapping(value = "/processTestResult/{testId}")
	@ResponseBody
    public ResponseEntity<String> processTestResult(@PathVariable String testScheudleId) {
        		
		Long id = Long.parseLong(StringUtils.defaultString(testScheudleId, "0"));

		// schedule the process to 11:30 p.m. 
		testProcessService.processTestScheduleAt11_30PM(id);

		// 6. return flag
		return ResponseEntity.ok("Processing Test scheduled successfully and Results will be emailed at 11:30 p.m. tonight");
    }

	@GetMapping(value = "/getTestBranchStat/{testId}")
	@ResponseBody
    public List<StatsDTO> getTestBranchStat(@PathVariable String testId) {        		
		Long id = Long.parseLong(StringUtils.defaultString(testId, "0"));
		
		// 1. Get TestSchedule
		TestScheduleDTO test = connectedService.getTestSchedule(id);
		String grade = test.getGrade();
		String[] groups = test.getTestGroup();
		int groupSize = groups.length;
		String[] weeks = test.getWeek();
		// int weekSize = weeks.length;
		
		// 2. Get Test
		List<TestDTO> tests = new ArrayList<>();
		for(int i = 0; i < groupSize; i++){
			List<TestDTO> temp = connectedService.getTestByGroup(Integer.parseInt(groups[i]), grade, Integer.parseInt(weeks[i]));
			for(TestDTO t : temp){
				tests.add(t);
			}
		}

		// 3. Get current year
		int currentYear = cycleService.academicYear();
		CycleDTO cycle = cycleService.listCycles(currentYear);
		
		// 4. List of StatsDTO
		List<StatsDTO> dtos = new ArrayList<>();
		List<SimpleBasketDTO> branches = codeService.loadBranch();
		for(SimpleBasketDTO branch : branches){
			StatsDTO dto = new StatsDTO();
			// exclude 90, 99 - test /head office
			if(branch.getValue().equals(JaeConstants.HEAD_OFFICE_CODE) || branch.getValue().equals(JaeConstants.TEST_CODE)){
				continue;
			}
			dto.setBranch(Integer.parseInt(branch.getValue()));
			dtos.add(dto);
		}
		
		for(TestDTO t : tests){
			// 5. Get student list
			List<Long> studentList = connectedService.getStudentListByTest(Long.parseLong(t.getId()), cycle.getStartDate(), cycle.getEndDate());
			// 6. Iterate over studentList and count the students for each branch
			for(Long studentId : studentList){
				// 7. Get branch of the student
				String branch = studentService.getBranch(studentId);
				// 8. Iterate over dtos and increment the count for the branch
				for(StatsDTO dto : dtos){
					if(dto.getBranch() == Integer.parseInt(branch)){
						dto.setCount(dto.getCount() + 1);
					}
				}
			}
		}

		// 9. Return dtos
		return dtos;
    }


	// helper method converting answers Map to List
	private List<Integer> convertAnswers(List<Map<String, Object>> answers) {
		// Sort the answers based on the "question" key
		answers.sort(Comparator.comparingInt(answer -> Integer.parseInt(answer.get("question").toString())));

		List<Integer> answerList = new ArrayList<>();
		// 1st element represents total answer count
		answerList.add(0, answers.size());
		for (Map<String, Object> answer : answers) {
			int questionNum = Integer.parseInt(answer.get("question").toString());
			int selectedOption = Integer.parseInt(answer.get("answer").toString());
			answerList.add(questionNum, selectedOption);
		}
		return answerList;
	}

}
