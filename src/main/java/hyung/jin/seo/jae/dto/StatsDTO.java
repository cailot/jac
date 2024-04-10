package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class StatsDTO implements Serializable{
    
	private int state;
    
    private int branch;
    
    private int grade;
    
    private int count;

    public StatsDTO(Object[] obj){
        this.state = state;
        this.branch = branch;
        this.grade = grade;
        this.count = count;
    }

}
