package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.annotation.JsonIgnore;

import hyung.jin.seo.jae.model.Homework;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.format.DateTimeFormatter;
import java.time.LocalDate;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class HomeworkDTO implements Serializable {

	private String id;

	private String path;

	private String info;

	private int type;

	private long duration;

	private int week;

	private int year;

	private boolean active;

	private String grade;

	private String subject;

	private String registerDate;

	
	public HomeworkDTO(long id, String path, long duration, int week, int year, String info, boolean active, String grade, String subject, LocalDate registerDate){
		this.id = String.valueOf(id);
		this.path = path;
		this.duration = duration;
		this.week = week;
		this.year = year;
		this.info = info;
		this.active = active;
		this.grade = grade;
		this.subject = subject;
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
	}

	public HomeworkDTO(long id, int type, String path, long duration, int week, int year, String info, boolean active, String grade, String subject, LocalDate registerDate){
		this.id = String.valueOf(id);
		this.type = type;
		this.path = path;
		this.duration = duration;
		this.week = week;
		this.year = year;
		this.info = info;
		this.active = active;
		this.grade = grade;
		this.subject = subject;
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
	}


}
