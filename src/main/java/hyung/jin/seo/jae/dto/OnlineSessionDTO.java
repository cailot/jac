package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.model.OnlineSession;
import hyung.jin.seo.jae.utils.JaeUtils;
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
		// this.grade = session.getGrade();
		this.day = session.getDay();
		this.startTime = session.getStartTime();
		this.endTime = session.getEndTime();
		// this.year = session.getYear();
		this.registerDate = session.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.clazzId = (session.getClazz()!=null) ? String.valueOf(session.getClazz().getId()) : "";
	}

	// public OnlineSession convertToEOnlineSession() {
    // 	OnlineSession session = new OnlineSession();
	// 	if(StringUtils.isNotBlank(id)) session.setId(Long.parseLong(id));
    // 	if(StringUtils.isNotBlank(registerDate)) session.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
	// 	session.setCancelled(cancelled);
	// 	session.setStartWeek(startWeek);
	// 	session.setEndWeek(endWeek);
	// 	session.setCredit(credit);
	// 	session.setDiscount(discount);
	// 	if(StringUtils.isNotBlank(paymentDate)) session.setRegisterDate(LocalDate.parse(paymentDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
	// 	if(StringUtils.isNotBlank(cancellationReason)) session.setCancellationReason(cancellationReason);
	// 	session.setInfo(info);		
    // 	return session;
    // }

	public OnlineSessionDTO(long id, boolean active, int week, String address, String grade, String day, String startTime, String endTime, int year, LocalDate registerDate, long clazzId){
		this.id = String.valueOf(id);
		this.active = active;
		this.address = address;
		this.grade = grade;
		this.day = day;
		this.startTime = startTime;
		this.endTime = endTime;
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.clazzId = String.valueOf(clazzId);
	}



	// public OnlineSessionDTO(Object[] obj){
	// 	this.id = (obj[0]!=null) ? String.valueOf(obj[0]) : null;
	// 	this.registerDate = (obj[1]!=null) ? String.valueOf(obj[1]) : null;
	// 	this.cancelled = (obj[2]!=null) ? (boolean)obj[2] : false;
	// 	this.cancellationReason = (obj[3]!=null) ? (String)obj[3] : null;
	// 	this.startWeek = (obj[4]!=null) ? (int)obj[4] : 0;
	// 	this.endWeek = (obj[5]!=null) ? (int)obj[5] : 0;
	// 	this.info = (obj[6]!=null) ? String.valueOf(obj[6]) : "";				
	// 	this.invoiceId = (obj[7]!=null) ? String.valueOf(obj[7]) : "0";
	// 	this.credit = (obj[8]!=null) ? Integer.parseInt(String.valueOf(obj[8])) : 0;
	// 	this.discount = (obj[9]!=null) ? String.valueOf(obj[9]) : "0";
	// 	this.amount = (obj[10]!=null) ? Double.parseDouble(String.valueOf(obj[10])) : 0;
	// 	this.paid = (obj[11]!=null) ? Double.parseDouble(String.valueOf(obj[11])) : 0;
	// 	this.paymentDate = (obj[12] != null) ? JaeUtils.dateFormat.format(obj[12]) : null;
	// 	this.studentId = (obj[13]!=null) ? String.valueOf(obj[13]) : "0";
	// 	this.clazzId = (obj[14]!=null) ? String.valueOf(obj[14]) : "0";
	// 	this.name = (obj[15]!=null) ? (String)obj[15] : null;
	// 	this.price = (obj[16]!=null) ? Double.parseDouble(String.valueOf(obj[16])) : 0;
	// 	this.online = (obj[17]!=null) ? (boolean)obj[17] : false;
	// 	this.year = (obj[18]!=null) ? String.valueOf(obj[18]) : null;
	// 	this.grade = (obj[19]!=null) ? (String)obj[19] : null;
	// 	this.day = (obj[20]!=null) ? (String)obj[20] : null;
	// }
}
