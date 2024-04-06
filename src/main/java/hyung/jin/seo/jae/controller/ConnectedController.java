package hyung.jin.seo.jae.controller;

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

import hyung.jin.seo.jae.dto.ExtraworkDTO;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.dto.PracticeAnswerDTO;
import hyung.jin.seo.jae.dto.PracticeDTO;
import hyung.jin.seo.jae.dto.PracticeScheduleDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.TestAnswerDTO;
import hyung.jin.seo.jae.dto.TestDTO;
import hyung.jin.seo.jae.model.Extrawork;
import hyung.jin.seo.jae.model.Grade;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.model.Practice;
import hyung.jin.seo.jae.model.PracticeAnswer;
import hyung.jin.seo.jae.model.PracticeSchedule;
import hyung.jin.seo.jae.model.PracticeType;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.model.Test;
import hyung.jin.seo.jae.model.TestAnswer;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.model.TestType;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("connected")
public class ConnectedController {

	private static final Logger LOG = LoggerFactory.getLogger(ConnectedController.class);

	@Autowired
	private ConnectedService connectedService;

	@Autowired
	private CodeService codeService;
	
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
		List<PracticeDTO> practices = formData.getPractices();
		// associate practice to schedule
		for(PracticeDTO practice : practices){
			String practiceId = practice.getId();
			Practice prac = connectedService.getPractice(Long.parseLong(practiceId));
			schedule.addPractice(prac);
		}
		schedule.setActive(true);
		// save practice schedule
		schedule = connectedService.addPracticeSchedule(schedule);
		PracticeScheduleDTO dto = new PracticeScheduleDTO(schedule);
		// return dto
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

	// update existing practice schedule
	@PutMapping("/updatePracticeSchedule")
	@ResponseBody
	public ResponseEntity<String> updatePracticeSchedule(@RequestBody PracticeScheduleDTO formData) {
		try{
			// 1. create barebone PracticeSchedule
			PracticeSchedule work = formData.convertToPracticeSchedule();
			// 2. update associated Practices
			List<PracticeDTO> practices = formData.getPractices();
			for(PracticeDTO practice : practices){
				// 2.1 get Practice
				Practice prac = connectedService.getPractice(Long.parseLong(practice.getId()));
				// 2.2 update Practice
				work.addPractice(prac);
			}
			// 3. update PracticeSchedule
			work = connectedService.updatePracticeSchedule(work, Long.parseLong(formData.getId()));
			// 4.return flag
			return ResponseEntity.ok("\"Practice Schedule updated successfully\"");
		}catch(Exception e){
			String message = "Error updating Practice Schedule : " + e.getMessage();
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

	// get practice schedule
	@GetMapping("/getPracticeSchedule/{id}")
	@ResponseBody
	public PracticeScheduleDTO getPracticeSchedule(@PathVariable Long id) {
		PracticeSchedule work = connectedService.getPracticeSchedule(id);
		PracticeScheduleDTO dto = new PracticeScheduleDTO(work);
		List<Practice> practices = work.getPractices();
		for(Practice practice : practices){
			PracticeDTO prac = new PracticeDTO(practice);
			// get PracticeType name
			String name =  connectedService.getPracticeTypeName(practice.getId());
			prac.setName(name);
			dto.addPractice(prac);
		}
		return dto;
	}

	// search homework by subject, year & week
	@GetMapping("/homework/{subject}/{year}/{week}")
	@ResponseBody
	public HomeworkDTO searchHomework(@PathVariable int subject, @PathVariable int year, @PathVariable int week) {
		HomeworkDTO dto = connectedService.getHomeworkInfo(subject, year, week);
		return dto;
	}

	// bring homework in database
	@GetMapping("/filterHomework")
	public String listHomeworks(
			@RequestParam(value = "listSubject", required = false) String subject,
			@RequestParam(value = "listGrade", required = false) String grade,
			@RequestParam(value = "listYear", required = false) String year,
			@RequestParam(value = "listWeek", required = false) String week, 
			Model model) {
		List<HomeworkDTO> dtos = new ArrayList();
		String filteredSubject = StringUtils.defaultString(subject, "0");
		String filteredGrade = StringUtils.defaultString(grade, JaeConstants.ALL);
		String filteredYear = StringUtils.defaultString(year, "0");
		String filteredWeek = StringUtils.defaultString(week, "0");
		dtos = connectedService.listHomework(Integer.parseInt(filteredSubject), filteredGrade, Integer.parseInt(filteredYear), Integer.parseInt(filteredWeek));		
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
		String filteredGrade = StringUtils.defaultString(grade, JaeConstants.ALL);
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
		String filteredGrade = StringUtils.defaultString(grade, JaeConstants.ALL);
		String filteredVolume = StringUtils.defaultString(volume, "0");
		dtos = connectedService.listTest(Integer.parseInt(filteredType), filteredGrade, Integer.parseInt(filteredVolume));		
		model.addAttribute(JaeConstants.TEST_LIST, dtos);
		return "testListPage";
	}

	@GetMapping("/filterPracticeSchedule")
	public String listPracticeSchedules(
			@RequestParam(value = "listYear", required = false) String listYear,
			@RequestParam(value = "listWeek", required = false) String listWeek,
			Model model) {
		List<PracticeScheduleDTO> dtos = new ArrayList();
		String filteredYear = StringUtils.defaultString(listYear, "0");
		String filteredWeek = StringUtils.defaultString(listWeek, "0");
		dtos = connectedService.listPracticeSchedule(Integer.parseInt(filteredYear), Integer.parseInt(filteredWeek)); 		
		model.addAttribute(JaeConstants.PRACTICE_SCHEDULE_LIST, dtos);
		return "practiceSchedulePage";
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
	@GetMapping("/practice4Schedule/{type}/{grade}")
	@ResponseBody
	List<PracticeDTO> getPracticeForSchedule(@PathVariable int type, @PathVariable String grade) {
		List<PracticeDTO> dtos = connectedService.listPracticeByTypeNGrade(type, grade); 
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
