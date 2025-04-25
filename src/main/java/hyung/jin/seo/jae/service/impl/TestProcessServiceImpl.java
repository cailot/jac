package hyung.jin.seo.jae.service.impl;

import java.text.ParseException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.io.ByteArrayInputStream;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.azure.core.util.Context;
import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.models.BlobHttpHeaders;
import com.azure.storage.blob.options.BlobParallelUploadOptions;
import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.CycleDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.dto.StudentTestSummaryDTO;
import hyung.jin.seo.jae.dto.TestDTO;
import hyung.jin.seo.jae.dto.TestResultHistoryDTO;
import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.EmailService;
import hyung.jin.seo.jae.service.ExcelService;
import hyung.jin.seo.jae.service.PdfService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.service.TestProcessService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Service
public class TestProcessServiceImpl implements TestProcessService {

	@Autowired
	private CycleService cycleService;

	@Autowired
	private ConnectedService connectedService;

	@Autowired
	private CodeService codeService;

	@Autowired
	private StudentService studentService;

	@Autowired
	private EmailService emailService;

	@Autowired
	private PdfService pdfService;

	@Autowired
	private ExcelService excelService;

	@Value("${spring.sender.result}")
    private String emailSender;

	@Value("${azure.storage.connection}")
	private String azureConnection;

	private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();

	@Override
	public void processTestScheduleAt11_30PM(Long testScheduleId) {
		long delay = calculateDelayUntil11_30PM();
        scheduler.schedule(() -> {
			// process time consuming task
			processTestSchedule(testScheduleId);
        }, delay, TimeUnit.MILLISECONDS);
	}

	@Override
	public void processTestSchedule(Long testScheduleId) {
		// Step 1: Get current year
		int currentYear = cycleService.academicYear();
		CycleDTO cycle = cycleService.listCycles(currentYear);
		String startDate = cycle.getStartDate();
		String endDate = cycle.getEndDate();
		// Step 2: Get test by shedule ID
		TestScheduleDTO schedule = connectedService.getTestSchedule(testScheduleId);
		String grade = schedule.getGrade();
		String group = schedule.getTestGroup();
		String week = schedule.getWeek();
		// Step 3: Get test list by grade, group and week
		List<TestDTO> tests = connectedService.getTestByGroup(Integer.parseInt(group), grade, Integer.parseInt(week));
		// student list
		List<Long> studentList = new ArrayList<>();
		for(TestDTO test : tests){
			// Step 5: Get average score
			double average = connectedService.getAverageScoreByTest(Long.parseLong(test.getId()), startDate, endDate);
			// Step 6: Update average score
			connectedService.updateTestAverage(Long.parseLong(test.getId()), average);
			// Step 7: Get student list by test
			List<Long> newStudents = connectedService.getStudentListByTest(Long.parseLong(test.getId()), startDate, endDate);
			for (Long studentId : newStudents) {
				if (!studentList.contains(studentId)) {
					studentList.add(studentId);
				}
			}
		}

		// student test summary list
		List<StudentTestSummaryDTO> studentTestSummaryList = new ArrayList<>();
		StringBuilder emailBodyBuilder = new StringBuilder();
		emailBodyBuilder.append("<html>")
            .append("<head>")
            .append("</head>")
            .append("<body>")
			.append("<p style='color: red; font-weight: bold;'>Please Do Not Reply to This Email. This email is intended for sending purposes only</p><br>")
            .append("<p style='font-family: Arial, sans-serif; font-size: 15px; color: #333; font-weight: bold;'>Dear %s (%s),</p>")
            .append("<br>")
			.append("<span style='color: #333; font-size: 14px; font-family: Arial, sans-serif;'>Your test results for the recent Test are now available.</span><br>")
			.append("<span style='color: #333; font-family: Arial, sans-serif; font-size: 14px;'>Please check the attached file for your test results.</span><br><br>")
			.append("<span style='color: #333; font-family: Arial, sans-serif; font-size: 14px;'>Best regards,</span><br>")
			.append("<span style='color: #333; font-family: Arial, sans-serif; font-size: 14px; font-style: italic;'>James An College Victoria Head Office</span>")
			.append("</body>")
			.append("</html>");	
		String emailTemplate = emailBodyBuilder.toString();
		// handlinge each student
		// 1. send email to student
		// 2. upload pdf to azure blob storage
		String emailSubject = "James An College Victoria Test Results are now available.";
		for(Long studentId : studentList){
			Student st = studentService.getStudent(studentId);
			if (st == null) {
				continue; // Skip if no student found
			}
			StudentTestSummaryDTO summary = new StudentTestSummaryDTO();
			summary.setId(studentId.toString());
			String studentName = st.getFirstName() + " " + st.getLastName();
			summary.setName(studentName);
			summary.setBranch(st.getBranch());

			// student test list
			List<StudentTestDTO> studentTests = new ArrayList<>();
			// get student test list
			for(TestDTO test : tests){
				// get student score by studentId and testId
				double score = connectedService.getStudentScoreByTest(studentId, Long.parseLong(test.getId()));
				summary.addScore(score);
				// get student test list
				StudentTestDTO studentTest = connectedService.findStudentTestByStudentNTest(studentId, Long.parseLong(test.getId()), startDate, endDate);
				if(studentTest != null){
					studentTests.add(studentTest);
				}
			}
			if(studentTests.size() == 0){
				continue; // Skip if no student test found
			}
			// prepare pdf data
			Map<String, Object> pdfData = preparePdfData(studentId, studentTests);
			byte[] pdfBytes = pdfService.generateTestResultPdf(pdfData);
			// String studentEmail = st.getEmail1();
			String studentEmail ="jh05052008@gmail.com";
			String emailContent = String.format(emailTemplate, studentName, studentId);
			//  Step 8: Send email to all students using template
			try {
				// Add debug logging
				System.out.println("Attempting to send email to: " + studentEmail + " Id :" + studentId);
				System.out.println("From: " + emailSender);
				System.out.println("Subject: " + emailSubject);
				emailService.sendResultWithAttachment(emailSender, studentEmail, emailSubject, emailContent, pdfBytes, summary.getId() + ".pdf");
				// emailService.sendEmail(emailSender, studentEmail, emailSubject, emailContent);				
				System.out.println("Email sent successfully");
			} catch (Exception e) {
				System.out.println("Failed to send email: " + e.getMessage());
				e.printStackTrace();
			}
			// Step 9: Upload pdf to azure blob storage
			String blobName = studentId + ".pdf";
			uploadPdfToAzureBlob(blobName, pdfBytes);
			// add to list
			studentTestSummaryList.add(summary);
		}
		
		// get branch list
		List<BranchDTO> branchList = codeService.allBranches();
		for(BranchDTO branchDTO : branchList){
			String branchCode = branchDTO.getCode();
			List<byte[]> attachments = new ArrayList<>();
			List<String> fileNames = new ArrayList<>();
			List<StudentTestSummaryDTO> branchSummaryList = new ArrayList<>();
			// Step 10: Send email to branch with summary	
			for(StudentTestSummaryDTO summary : studentTestSummaryList){
				if(StringUtils.equalsIgnoreCase(branchCode, summary.getBranch())){
					// download PDF from Azure Blob Storage
					String blobName = summary.getId() + ".pdf";
					byte[] pdfBytes = downloadPdfFromAzureBlob(blobName);
					attachments.add(pdfBytes);
					fileNames.add(summary.getId() + ".pdf");
					branchSummaryList.add(summary);
				}
			}
			// send email to branch
			if(branchSummaryList.size() > 0){
				String emailReceipient = "cailot@naver.com";//branchDTO.getEmail();
				StringBuilder branchEmailBodyBuilder = new StringBuilder();
				branchEmailBodyBuilder.append("<html>")
					.append("<head>")
					.append("</head>")
					.append("<body>")
					.append("<p style='color: red; font-weight: bold;'>Please Do Not Reply to This Email. This email is intended for sending purposes only</p><br>")
					.append("<p style='font-family: Arial, sans-serif; font-size: 15px; color: #333; font-weight: bold;'>Dear " + branchDTO.getName() + " Branch,</p>")
					.append("<br>")
					.append("<span style='color: #333; font-size: 14px; font-family: Arial, sans-serif;'>Recent test results are now available.</span><br>")
					.append("<span style='color: #333; font-family: Arial, sans-serif; font-size: 14px;'>Please check the attached file for your test results at your branch.</span><br><br>")
					.append("<span style='color: #333; font-family: Arial, sans-serif; font-size: 14px;'>Best regards,</span><br>")
					.append("<span style='color: #333; font-family: Arial, sans-serif; font-size: 14px; font-style: italic;'>James An College Victoria Head Office</span>")
					.append("</body>")
					.append("</html>");	
				String emailContent = branchEmailBodyBuilder.toString();		
				byte[] excelBytes = excelService.generateTestSummaryExcel(branchSummaryList);

				if(attachments.size() > 1){
					// merge pdf files
					byte[] mergedPdfBytes = pdfService.mergePdfFiles(attachments);
					if(mergedPdfBytes == null){
						// skip merge pdf files and handle next branch
						continue;
					}
					attachments.clear();
					attachments.add(mergedPdfBytes);
					fileNames.clear();
					fileNames.add(branchDTO.getName() + ".pdf");										
				}

				attachments.add(excelBytes);
				fileNames.add("summary.xlsx");
				emailService.sendResultWithAttachments(emailSender, emailReceipient, emailSubject, emailContent, attachments, fileNames);
			}
	
		}// end of branch list

	   
	}	   

	// prepare pdf data
	private Map<String, Object> preparePdfData(Long studentId, List<StudentTestDTO> studentTests) {
		// Set Map to store ingredients
		Map<String, Object> data = new HashMap<>();
		// add student info
		Student std = studentService.getStudent(studentId);
		data.put(JaeConstants.STUDENT_INFO, new StudentDTO(std));
		// add test result info
		data.put(JaeConstants.TEST_RESULT_INFO, studentTests);
		// add test group info
		long tempTestId = ((StudentTestDTO)(studentTests.get(0))).getTestId();
		int testGroup = connectedService.getTestGroup(tempTestId);
		String testGrade = connectedService.getTestGrade(tempTestId);
		String testGroupName = JaeUtils.getTestGroup(testGroup);
		data.put(JaeConstants.TEST_GROUP_INFO, testGroupName);
		// add branch info
		BranchDTO branch = codeService.getBranch(std.getBranch());
		data.put(JaeConstants.BRANCH_INFO, branch);
		// add test volume info
		int volume = connectedService.getTestVolume(tempTestId);
		String volumeName = "";
		if(testGroup == 1 || testGroup == 2) { // if test group is 1 or 2, then add volume info
			if(volume == 1) {
				volumeName = "Volume 1";
			}else if(volume == 2) {
				volumeName = "Volume 2";
			}else if(volume == 3) {
				volumeName = "Volume 3";
			}else if(volume == 4) {
				volumeName = "Volume 4";
			}else if(volume == 5) {
				volumeName = "Volume 5";
			}
		}else{
			if(volume == 36) {
				volumeName = "SIM 1";
			}else if(volume == 37) {
				volumeName = "SIM 2";
			}else if(volume == 38) {
				volumeName = "SIM 3";
			}else if(volume == 39) {
				volumeName = "SIM 4";
			}else if(volume == 40) {
				volumeName = "SIM 5";
			}else {
				volumeName = volume + " week";
			}
		}
		data.put(JaeConstants.VOLUME_INFO, volumeName);

		int currentYear = cycleService.academicYear();
		CycleDTO cycle = cycleService.listCycles(currentYear);
		String startCycle = cycle.getStartDate();
		String endCycle = cycle.getEndDate();

		// set test title info
		List<String> testTitles = new ArrayList<>();
		// set test answer total count info
		List<Integer> testAnswerTotalCount = new ArrayList<>();
		// set student answer correct count info
		List<Integer> studentAnswerCorrectCount = new ArrayList<>();
		// set student score
		List<Double> studentScores = new ArrayList<>();
		// set average score
		List<Double> averageScores = new ArrayList<>();
		// set highest score
		List<Double> highestScores = new ArrayList<>();
		// set lowest score
		List<Double> lowestScores = new ArrayList<>();
		// set student answer
		List<List<Integer>> studentAnswers = new ArrayList<>();
		// set test answer
		List<List<TestAnswerItem>> testAnswers = new ArrayList<>();
		// set result history
		List<List<TestResultHistoryDTO>> histories = new ArrayList<>();
		for(StudentTestDTO studentTest : studentTests) {		
			// add test title info
			long testId = studentTest.getTestId();
			String testTypeName = connectedService.getTestTypeName(testId);
			testTitles.add(testTypeName);
			// get test answer total count info
			int testAnswerCount = connectedService.getTestAnswerCount(testId);
			testAnswerTotalCount.add(testAnswerCount);
			// get student answer correct count info
			List<Integer> answers = connectedService.getStudentTestAnswer(studentId, testId, cycle.getStartDate(), cycle.getEndDate());	
			List<TestAnswerItem> testAnswerItems = connectedService.getAnswersByTest(testId);
			int correctCount = JaeUtils.countTestScore(answers, testAnswerItems);
			studentAnswerCorrectCount.add(correctCount);
			studentAnswers.add(answers);
			testAnswers.add(testAnswerItems);
			// get average, hightest, lowest score
			double studentScore = studentTest.getScore();
			double averageScore = connectedService.getAverageScoreByTest(studentTest.getTestId(), startCycle, endCycle);
			double highestScore = connectedService.getHighestScoreByTest(studentTest.getTestId(), startCycle, endCycle);
			double lowestScore = connectedService.getLowestScoreByTest(studentTest.getTestId(), startCycle, endCycle);
			studentScores.add(studentScore);
			averageScores.add(averageScore);
			highestScores.add(highestScore);
			lowestScores.add(lowestScore);

			// get test result history
			List<TestResultHistoryDTO> history = null;// new ArrayList<>();
			int weekCount = 0;	
			if(testGroup == 1 || testGroup == 2) { // Mega, Revision
				weekCount = 5;
			}else if(testGroup == 3){ // Edu - max 32
				weekCount = 32;
			}else{ // Acer - max 40
				weekCount = 40;
			}
			history = new ArrayList<>(weekCount);
			// get test result history
			for(int i=1; i<=weekCount; i++){
				TestScheduleDTO testSchedule = connectedService.getMostRecentTestSchedule(testGroup+"", testGrade, i+"");
				TestResultHistoryDTO testHistory = new TestResultHistoryDTO();
				if(testSchedule == null) {
					history.add(testHistory);
					continue;
				}
				String from = testSchedule.getFrom(); // ex> 01/04/2025, 17:38
				String dateOnlyFrom = from.substring(0, 10); // Extracts the first 10 characters ex> 01/04/2025
				try {
					from = JaeUtils.convertToyyyyMMddFormat(dateOnlyFrom);
				} catch (ParseException e) {
					from = "2100-01-01";
					e.printStackTrace();
				} // ex> 2025-04-01
				String to = testSchedule.getTo();
				String dateOnlyTo = to.substring(0, 10);
				try {
					to = JaeUtils.convertToyyyyMMddFormat(dateOnlyTo);
				} catch (ParseException e) {
					to = "2100-01-01";
					e.printStackTrace();
				}
				// Subtract 3 days from the 'from' date as buffer for Onsite date while no need for to (same as the last day of Online)
				LocalDate fromDate = LocalDate.parse(from);
				fromDate = fromDate.minusDays(3);
				from = fromDate.toString(); // Convert back to String

				double average = connectedService.getAverageScoreByTest(studentTest.getTestId(), from, to);
				testHistory.setTestNo(i);
				testHistory.setAverage((int)(average));
				// student score
				StudentTestDTO studentTestHistory = connectedService.findStudentTestByStudentNTest(studentId, testId, from, to);
				testHistory.setStudentScore(studentTestHistory==null ? 0 : (int)(studentTestHistory.getScore()));
				history.add(testHistory);			
			}
			histories.add(history);
		}
		// add test title info
		data.put(JaeConstants.TEST_TITLE_INFO, testTitles);
		// add test answer total count info
		data.put(JaeConstants.TEST_ANSWER_TOTAL_COUNT, testAnswerTotalCount);
		// add student answer correct count info
		data.put(JaeConstants.STUDENT_ANSWER_CORRECT_COUNT, studentAnswerCorrectCount);
		// add student score
		data.put(JaeConstants.STUDENT_SCORE, studentScores);
		// add average score
		data.put(JaeConstants.TEST_AVERAGE_SCORE, averageScores);
		// add highest score
		data.put(JaeConstants.TEST_HIGHEST_SCORE, highestScores);
		// add lowest score
		data.put(JaeConstants.TEST_LOWEST_SCORE, lowestScores);
		// add student answer
		data.put(JaeConstants.STUDENT_ANSWERS, studentAnswers);
		// add test answers
		data.put(JaeConstants.TEST_ANSWERS, testAnswers);
		// add test result history
		data.put(JaeConstants.TEST_RESULT_HISTORY, histories);
		return data;
	}

	// Calculate delay until 11:30 PM, if current time is after 11:30 PM, schedule for next day
	private long calculateDelayUntil11_30PM() {
		LocalDateTime now = LocalDateTime.now();
		LocalDateTime targetTime = now.withHour(6).withMinute(30).withSecond(0).withNano(0);
		if (now.isAfter(targetTime)) {
			targetTime = targetTime.plusDays(1); // schedule for next day if missed
		}
		Duration duration = Duration.between(now, targetTime);
		return duration.toMillis();
	}

	// Create file in Azure Blob Storage for PDF files
	private void uploadPdfToAzureBlob(String fileName, byte[] fileData) {
		// Create a BlobServiceClient
		BlobServiceClient blobServiceClient = new BlobServiceClientBuilder()
		.connectionString(azureConnection)
		.buildClient();
		// Access the container: work
		BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(JaeConstants.WORK_FOLDER);
		// Define the full path inside the container (folder structure emulated using slashes)
		String blobPath = JaeConstants.TEST_FOLDER + "/" + fileName;
		// Get a blob client
		BlobClient blobClient = containerClient.getBlobClient(blobPath);
		// Set content-type for PDF
		BlobHttpHeaders headers = new BlobHttpHeaders().setContentType("application/pdf");
		// Upload the file
		BlobParallelUploadOptions options = new BlobParallelUploadOptions(new ByteArrayInputStream(fileData))
			.setHeaders(headers);
		blobClient.uploadWithResponse(options, null, Context.NONE);

		System.out.println("PDF file uploaded to Azure >>> " + fileName);
	}

	// Download PDF from Azure Blob Storage
	private byte[] downloadPdfFromAzureBlob(String fileName) {
		// Create a BlobServiceClient
		BlobServiceClient blobServiceClient = new BlobServiceClientBuilder()
			.connectionString(azureConnection)
			.buildClient();
		// Access the container: work
		BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(JaeConstants.WORK_FOLDER);
		// Define the full path inside the container (folder structure emulated using slashes)
		String blobPath = JaeConstants.TEST_FOLDER + "/" + fileName;
		// Get a blob client
		BlobClient blobClient = containerClient.getBlobClient(blobPath);
		// Download the file
		return blobClient.downloadContent().toBytes();
	}


}
