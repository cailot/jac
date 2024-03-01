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
	
	private String grade;

	private String subject;

	private String registerDate;

	// public HomeworkDTO(Homework work) {
	// 	this.id = (work.getId() != null) ? work.getId().toString() : "";
	// 	this.grade = (work.getGrade() != null) ? work.getGrade() : "";
	// 	this.name = (work.getName() != null) ? work.getName() : "";
	// 	//this.registerDate = (crs.getRegisterDate() != null) ? crs.getRegisterDate().toString() : "";
	// }

	// public Homework convertToElearning() {
	// 	Homework crs = new Homework();
	// 	if (StringUtils.isNotBlank(id))
	// 		crs.setId(Long.parseLong(this.id));
	// 	if (StringUtils.isNotBlank(grade))
	// 		crs.setGrade(this.grade);
	// 	if (StringUtils.isNotBlank(name))
	// 		crs.setName(this.name);
	// 	if (StringUtils.isNotBlank(registerDate))
	// 		crs.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
	// 	return crs;
	// }

}
