package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.AssessmentDTO;
import hyung.jin.seo.jae.model.Assessment;
import hyung.jin.seo.jae.model.Grade;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.service.AssessmentService;
import hyung.jin.seo.jae.service.CodeService;

@Controller
@RequestMapping("assessment")
public class AssessmentController {

	@Autowired
	private CodeService codeService;

	@Autowired
	private AssessmentService assessmentService;
	


	// register test
	@PostMapping("/addAssessment")
	@ResponseBody
	public AssessmentDTO registerAssessment(@RequestBody AssessmentDTO formData) {
		// 1. create barebone
		Assessment work = formData.convertToAssessment();
		// 2. set active to true as default
		work.setActive(true);
		// 3. set Grade & Subject
		Grade grade = codeService.getGrade(Long.parseLong(formData.getGrade()));
		Subject subject = codeService.getSubject(formData.getSubject());
		// 4. associate Grade & Subject
		work.setGrade(grade);
		work.setSubject(subject);
		// 5. register Assessment
		Assessment added = assessmentService.addAssessment(work);
		// 6. return dto
		AssessmentDTO dto = new AssessmentDTO(added);
		return dto;
	}


	// get Assessment
	@GetMapping("/getAssessInfo/{grade}/{subject}")
	@ResponseBody
	public AssessmentDTO getAssessInfo(@PathVariable String grade, @PathVariable long subject) {
		AssessmentDTO dto = assessmentService.getAssessmentInfo(grade, subject);
		return dto;
		// document URL	
		// String url = "https://jacstorage.blob.core.windows.net/extra-materials/MathsTopic/P3/document/2D_Shapes.pdf";
		// return url;
	}

	@PostMapping(value = "/markAssessment")
	@ResponseBody
    public ResponseEntity<String> markTest(@RequestBody Map<String, Object> payload) {
        // Extract practiceId and answers from the payload
		String studentId = StringUtils.defaultString(payload.get("studentId").toString(), "0");
		String assessId = StringUtils.defaultString(payload.get("assessId").toString(), "0");
		List<Map<String, Object>> mapAns = (List<Map<String, Object>>) payload.get("answers");
		// convert the Map of answers to List
		List<Integer> answers = convertAssessmentAnswers(mapAns);
	
	
	/*
		// compare answers with answer sheet
		List<TestAnswerItem> corrects = connectedService.getAnswersByTest(Long.parseLong(testId));
		double score = JaeUtils.calculateTestScore(answers, corrects);
		// 1. create barebone
		StudentTest st = new StudentTest();
		st.setScore(score);
		// 2. set Student & Test
		Student student = studentService.getStudent(Long.parseLong(studentId));
		Test test = connectedService.getTest(Long.parseLong(testId));
		// 3. associate Student & Test
		st.setStudent(student);
		st.setTest(test);
		// 4. set answers
		st.setAnswers(answers);
		// 5. register StudentTest
		connectedService.addStudentTest(st);
	*/
		// 6. return flag
		return ResponseEntity.ok("\"StudentTest registered\"");
    }



	// helper method converting test answers Map to List
	private List<Integer> convertAssessmentAnswers(List<Map<String, Object>> answers) {
		// Sort the answers based on the "question" key
		answers.sort(Comparator.comparingInt(answer -> Integer.parseInt(answer.get("question").toString())));
		List<Integer> answerList = new ArrayList<>();
		for (Map<String, Object> answer : answers) {
//			int questionNum = Integer.parseInt(answer.get("question").toString());
			int selectedOption = Integer.parseInt(answer.get("answer").toString());
			answerList.add(selectedOption);
		}
		return answerList;
	}
}
