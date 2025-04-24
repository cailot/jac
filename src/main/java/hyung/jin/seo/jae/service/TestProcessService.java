package hyung.jin.seo.jae.service;

public interface TestProcessService {

	// process test schedule
	void processTestSchedule(Long testScheduleId);
	
	// process test schedule at 11:30
	void processTestScheduleAt11_30PM(Long testId);

}
