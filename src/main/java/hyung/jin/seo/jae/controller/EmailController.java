package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.EmailService;
import hyung.jin.seo.jae.service.StudentService;

@Controller
@RequestMapping("email")
public class EmailController {

	@Autowired
	private EmailService emailService;

	@Autowired
	private CodeService codeService;

	@Autowired
	private StudentService studentService;

	@GetMapping("/sendAnnouncement")
	@ResponseBody
    public ResponseEntity<String> emailAnnouncement(@RequestParam String state, @RequestParam String branch, @RequestParam String grade, @RequestParam String subject, @RequestParam String body){
		try{
			// 1. get sender email address
			String fromEmail = codeService.getBranchEmail(branch);
			fromEmail = "cailot@naver.com";
			// 2. get receipients
			List<String> receipients = studentService.getBranchReceipents(state, branch, grade);
			
			receipients = new ArrayList<String>();
			receipients.add("cailot@naver.com");
			receipients.add("jh05052008@gmail.com");

			// 3. send email
			emailService.sendEmail(fromEmail, receipients, subject, body);
			// 4. return response

			return ResponseEntity.ok(receipients.size()+"");
		}catch(Exception e){
			String message = "\"Error sending email : " + e.getMessage() + "\"";
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(message);
		}
    }

}