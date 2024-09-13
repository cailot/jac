package hyung.jin.seo.jae.controller;

import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.ObjectMapper;

import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
public class JaeController {

	@Autowired
	private StudentController studentController;

	@GetMapping("/login")
	public String showLogin() {
		return "loginPage";
	}

	@GetMapping("/logout")
	public String redirectConnectedLogin() {
		return "redirect:/login";
	}

	@GetMapping("/studentAdmin")
	public String adminJob(@RequestParam(value = "id", required = false) String id, Model model) {
		//
		if(StringUtils.isNotBlank(id)){
			 try {
                Long studentId = Long.parseLong(id);
                StudentDTO std = studentController.getStudents(studentId);
                ObjectMapper objectMapper = new ObjectMapper();
                String json = objectMapper.writeValueAsString(std);
                model.addAttribute("std", json);
            } catch (Exception e) {
                e.printStackTrace();
                // Handle the exception appropriately
            }
		}
		return "studentAdminPage";
	}

	@GetMapping("/studentEnrol")
	public String studentList(HttpSession session) {
		return "studentEnrolPage";
	}

	@GetMapping("/studentInvoice")
	public String studentInvoice(HttpSession session) {
		// clear existing session info
		JaeUtils.clearSession(session);
		return "studentInvoicePage";
	}

	@GetMapping("/studentAttendance")
	public String studentAttendance(HttpSession session) {
		return "studentAttendancePage";
	}

	@GetMapping("/studentGrade")
	public String studentGrade(HttpSession session) {
		return "studentGradePage";
	}

	@GetMapping("/courseList")
	public String courseList(HttpSession session) {
		return "courseListPage";
	}

	@GetMapping("/bookList")
	public String bookList(HttpSession session) {
		return "bookListPage";
	}
	
	@GetMapping("/classList")
	public String classList(HttpSession session) {
		return "classListPage";
	}

	@GetMapping("/paymentList")
	public String paymentList(HttpSession session) {
		return "paymentListPage";
	}

	@GetMapping("/renewList")
	public String renewList(HttpSession session) {
		return "renewListPage";
	}

	@GetMapping("/overdueList")
	public String overdueList(HttpSession session) {
		return "overdueListPage";
	}

	@GetMapping("/onlineStatus")
	public String onlineStatusList(HttpSession session) {
		return "onlineStatusListPage";
	}

	@GetMapping("/connectedAttend")
	public String connectedAttendList(HttpSession session) {
		return "connectedAttendListPage";
	}

	@GetMapping("/onlineList")
	public String onlineList(HttpSession session) {
		return "onlineListPage";
	}

	@GetMapping("/gradeList")
	public String gradeList(HttpSession session) {
		return "gradeListPage";
	}

	@GetMapping("/cycle")
	public String academicCycle(HttpSession session) {
		return "cyclePage";
	}

	@GetMapping("/branch")
	public String branchList(HttpSession session) {
		return "branchPage";
	}

	@GetMapping("/userList")
	public String user(HttpSession session) {
		return "userListPage";
	}

	@GetMapping("/teacherList")
	public String teacher(HttpSession session) {
		return "teacherListPage";
	}

	@GetMapping("/setting")
	public String setting(HttpSession session) {
		return "settingPage";
	}

	@GetMapping("/receipt")
	public String openReceipt(HttpSession session) {
		return "receiptPage";
	}

	@GetMapping("/invoice")
	public String openInvoice(HttpSession session) {
		return "invoicePage";
	}

	//////////////////////////////////////////////////
	// CONNECTED CLASS
	/////////////////////////////////////////////////

	@GetMapping("/homeworkList")
	public String homework(HttpSession session) {
		return "homeworkListPage";
	}

	@GetMapping("/extraworkList")
	public String extrawork(HttpSession session) {
		return "extraworkListPage";
	}

	@GetMapping("/practiceList")
	public String practice(HttpSession session) {
		return "practiceListPage";
	}

	@GetMapping("/testList")
	public String test(HttpSession session) {
		return "testListPage";
	}

	@GetMapping("/practiceSchedule")
	public String practiceSchedule(HttpSession session) {
		return "practiceSchedulePage";
	}

	@GetMapping("/testSchedule")
	public String testSchedule(HttpSession session) {
		return "testSchedulePage";
	}


	@GetMapping("/assessList")
	public String assess(HttpSession session) {
		return "assessListPage";
	}

	//////////////////////////////////////////////////
	// OMR
	/////////////////////////////////////////////////

	@GetMapping("/omrUpload")
	public String omrUpload(HttpSession session) {
		return "omrUploadPage";
	}


	//////////////////////////////////////////////////
	// STATS
	/////////////////////////////////////////////////

	@GetMapping("/activeStats")
	public String activeStudentStats(HttpSession session) {
		return "activeStatPage";
	}

	@GetMapping("/inactiveStats")
	public String inactiveStudentStats(HttpSession session) {
		return "inactiveStatPage";
	}

	@GetMapping("/invoiceStats")
	public String invoiceStudentStats(HttpSession session) {
		return "invoiceStatPage";
	}

	@GetMapping("/migration")
	public String studentMigration(HttpSession session) {
		return "migrationPage";
	}

	@GetMapping("/batch")
	public String batchProcess(HttpSession session) {
		return "batchPage";
	}


}
