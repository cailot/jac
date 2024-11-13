package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import hyung.jin.seo.jae.model.NoticeEmail;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class NoticeEmailDTO implements Serializable{
    
	private String id;

	private String title;

	private String body;

	private String grade;

	private String state;

	private String branch;

	private String sender;

	private String registerDate;

	public NoticeEmailDTO(long id, String title, String grade, String state, String branch, String sender, LocalDate registerDate) {
		this.id = Long.toString(id);
		this.title = title;
		this.grade = grade;
		this.state = state;
		this.branch = branch;
		this.sender = sender;
		this.registerDate = (registerDate!=null) ? registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : null;
	}

	public NoticeEmailDTO(long id, String title, String body, String grade, String state, String branch, String sender, LocalDate registerDate) {
		this.id = Long.toString(id);
		this.title = title;
		this.body = body;
		this.grade = grade;
		this.state = state;
		this.branch = branch;
		this.sender = sender;
		this.registerDate = (registerDate!=null) ? registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : null;
	}

	public NoticeEmailDTO(NoticeEmail email) {
    	this.id = (email.getId()!=null) ? email.getId().toString() : "";
        this.title = (email.getTitle()!=null) ? email.getTitle() : "";
        this.body = (email.getBody()!=null) ? email.getBody() : "";
		this.grade = (email.getGrade()!=null) ? email.getGrade() : "";
        this.state = (email.getState()!=null) ? email.getState() : "";
        this.branch = (email.getBranch()!=null) ? email.getBranch() : "";
		this.sender = (email.getSender()!=null) ? email.getSender() : "";
        this.registerDate = (email.getRegisterDate()!=null) ? email.getRegisterDate().toString() : "";
    }

}
