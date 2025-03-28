package hyung.jin.seo.jae.service.impl;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.CycleDTO;
import hyung.jin.seo.jae.dto.TestDTO;
import hyung.jin.seo.jae.dto.TestScheduleDTO;
import hyung.jin.seo.jae.dto.TestSummaryDTO;
import hyung.jin.seo.jae.model.TestSchedule;
import hyung.jin.seo.jae.repository.AssessmentAnswerRepository;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.service.TestProcessService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Service
public class TestProcessServiceImpl implements TestProcessService {

    private final AssessmentAnswerRepository assessmentAnswerRepository;

	@Autowired
	private CycleService cycleService;

	@Autowired
	private ConnectedService connectedService;

	@Autowired
	private CodeService codeService;

	@Autowired
	private StudentService studentService;

	private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();

    TestProcessServiceImpl(AssessmentAnswerRepository assessmentAnswerRepository) {
        this.assessmentAnswerRepository = assessmentAnswerRepository;
    }

	@Override
	public void processTestScheduleAt11_30PM(Long testScheduleId) {
		long delay = calculateDelayUntil11_30PM();

        scheduler.schedule(() -> {
            // Step 1: Get current year
            int currentYear = cycleService.academicYear();
            CycleDTO cycle = cycleService.listCycles(currentYear);
			// Step 2: Get test by shedule ID
			TestScheduleDTO schedule = connectedService.getTestSchedule(testScheduleId);
			String grade = schedule.getGrade();
			String[] groups = schedule.getTestGroup();
			int groupSize = groups.length;
			String[] weeks = schedule.getWeek();
			// Step 3: Get test list by grade, group and week
			List<TestDTO> tests = new ArrayList<>();
			for (int i = 0; i < groupSize; i++) {
				List<TestDTO> temp = connectedService.getTestByGroup(Integer.parseInt(groups[i]), grade, Integer.parseInt(weeks[i]));
				for(TestDTO t : temp){
					tests.add(t);
				}
			}
			for(TestDTO test : tests){
				// Step 4: Get average score
				double average = connectedService.getAverageScoreByTest(Long.parseLong(test.getId()), cycle.getStartDate(), cycle.getEndDate());
				// Step 5: Update average score
				connectedService.updateTestAverage(Long.parseLong(test.getId()), average);
				// Step 6: Get student list
				List<Long> studentList = connectedService.getStudentListByTest(Long.parseLong(test.getId()), cycle.getStartDate(), cycle.getEndDate());
				// Step 7: Make TestSummaryDTO list
				List<TestSummaryDTO> summaries = new ArrayList<>();
				for (Long studentId : studentList) {
					TestSummaryDTO summary = new TestSummaryDTO();
					summary.setId(studentId.toString());
					String studentName = studentService.getStudentName(studentId);
					summary.setName(studentName);
					String studentBranch = studentService.getBranch(studentId);
					summary.setBranch(studentBranch);
					summaries.add(summary);
				}
				// Step 8: Send email to all students
				System.out.println("Scheduled process student count : " + studentList.size());
				for (Long studentId : studentList) {
					// Replace with actual email logic (JavaMailSender or other service)
					System.out.println("Sending email to student ID: " + studentId + " for Test ID: " + test.getId());
				}
				// Step 9: Send summary email to branch
				List<BranchDTO> branches = codeService.allBranches();
				for (BranchDTO branch : branches) {
					if(branch.getCode().equals(JaeConstants.HEAD_OFFICE_CODE) || branch.getCode().equals(JaeConstants.TEST_CODE)) {
						continue;
					}
					String branchCode = branch.getCode();
					String branchEmail = branch.getEmail();
					System.out.println("Sending summary email to branch: " + branchCode + " to email: " + branchEmail);
				}				
				System.out.println("Scheduled process completed for Test ID: " + test.getId());
			}
            
        }, delay, TimeUnit.MILLISECONDS);
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

	
}
