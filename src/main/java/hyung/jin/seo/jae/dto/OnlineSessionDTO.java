package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.apache.commons.lang3.StringUtils;
import hyung.jin.seo.jae.model.OnlineSession;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class OnlineSessionDTO implements Serializable{
    
	private String id;

	private boolean active;

	private int week;
	
	private String address;

	private String grade;

	private String day;

	private String title;

	private String startTime;

	private String endTime;

	private int year;

	private String registerDate;

	private String clazzId;

	public OnlineSessionDTO(OnlineSession session){
		this.id = String.valueOf(session.getId());
		this.active = session.isActive();
		this.week = session.getWeek();
		this.address = session.getAddress();
		this.grade = session.getClazz().getCourse().getGrade();
		this.day = session.getDay();
		this.title	= session.getTitle();
		this.startTime = session.getStartTime();
		this.endTime = session.getEndTime();
		this.year = session.getClazz().getCourse().getCycle().getYear();
		this.registerDate = session.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.clazzId = (session.getClazz()!=null) ? String.valueOf(session.getClazz().getId()) : "";
	}

	public OnlineSession convertToOnlineSession() {
    	OnlineSession session = new OnlineSession();
		if(StringUtils.isNotBlank(id)) session.setId(Long.parseLong(id));
		session.setActive(active);
		session.setWeek(week);
		session.setAddress(address);
		session.setDay(day);
		session.setTitle(title);
		session.setStartTime(startTime);
		session.setEndTime(endTime);
		if(StringUtils.isNotBlank(registerDate)) session.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		return session;
    }

	public OnlineSessionDTO(long id, boolean active, int week, String address, String grade, String day, String title, String startTime, String endTime, int year, LocalDate registerDate, long clazzId){
		this.id = String.valueOf(id);
		this.active = active;
		this.week = week;
		this.address = address;
		this.grade = grade;
		this.day = day;
		this.title = title;
		this.startTime = startTime;
		this.endTime = endTime;
		this.year = year;
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.clazzId = String.valueOf(clazzId);
	}

}
