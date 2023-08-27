package hyung.jin.seo.jae.dto;

import java.io.Serializable;
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
}
