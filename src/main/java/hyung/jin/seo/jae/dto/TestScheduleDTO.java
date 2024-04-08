package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import hyung.jin.seo.jae.model.TestSchedule;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class TestScheduleDTO implements Serializable {

	private String id;

	private int year;

	private int week;

	private String info;

	private boolean active;

	private LocalDateTime startDate;

    private LocalDateTime endDate;

	private String registerDate;

	private List<TestDTO> tests = new ArrayList();

	public void addTest(TestDTO test){
		tests.add(test);
	}

	public TestSchedule convertToTestSchedule() {
    	TestSchedule ts = new TestSchedule();
		ts.setYear(this.year);
		ts.setWeek(this.week);
		ts.setInfo(this.info);
		ts.setActive(this.active);
		ts.setStartDate(this.startDate);
		ts.setEndDate(this.endDate);
		return ts;
	}

	public TestScheduleDTO(TestSchedule work){
		this.id = String.valueOf(work.getId());
		this.year = work.getYear();
		this.week = work.getWeek();
		this.info = work.getInfo();
		this.active = work.isActive();
		this.registerDate = work.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.startDate = work.getStartDate();
		this.endDate = work.getEndDate();
	}

	public TestScheduleDTO(long id, int year, int week, String info, boolean active, LocalDate registerDate, LocalDateTime starDateTime, LocalDateTime endDateTime){
		this.id = String.valueOf(id);
		this.year = year;
		this.week = week;
		this.info = info;
		this.active = active;
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.startDate = starDateTime;
		this.endDate = endDateTime;
	}

}
