package hyung.jin.seo.jae.dto;

import java.io.Serializable;

import hyung.jin.seo.jae.model.DaySchedule;
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
public class DayScheduleDTO implements Serializable{
    
	private String id;

	private String code;

	private String name;

	public DayScheduleDTO(DaySchedule day){
		this.id = (day.getId()!=null) ? day.getId().toString() : "";
		this.code = (day.getCode()!=null) ? day.getCode() : "";
		this.name = (day.getName()!=null) ? day.getName() : "";
	}

}
