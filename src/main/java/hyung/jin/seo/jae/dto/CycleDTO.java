package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.apache.commons.lang3.StringUtils;

import hyung.jin.seo.jae.model.Cycle;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
@AllArgsConstructor
public class CycleDTO implements Serializable{
    
    private String year;
    
    private String startDate;

    private String endDate;
    
    private String vacationStartDate;

    private String vacationEndDate;
    
	public CycleDTO(Cycle cycle) {
    	this.year = (cycle.getYear()!=null) ? cycle.getYear().toString() : "";
    	this.startDate = (cycle.getStartDate()!=null) ? cycle.getStartDate().toString() : "";
    	this.endDate = (cycle.getEndDate()!=null) ? cycle.getEndDate().toString() : "";
    	this.vacationStartDate = (cycle.getVacationStartDate()!=null) ? cycle.getVacationStartDate().toString() : "";
    	this.vacationEndDate = (cycle.getVacationEndDate()!=null) ? cycle.getVacationEndDate().toString() : "";
    }
    public Cycle convertToCycle() {
    	Cycle cycle = new Cycle();
		if(StringUtils.isNotBlank(year)) cycle.setYear(Integer.parseInt(this.year));
        if(StringUtils.isNotBlank(startDate)) cycle.setStartDate(LocalDate.parse(startDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(endDate)) cycle.setStartDate(LocalDate.parse(endDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(vacationStartDate)) cycle.setStartDate(LocalDate.parse(vacationStartDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(vacationEndDate)) cycle.setStartDate(LocalDate.parse(vacationEndDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		return cycle;
    }
}
