package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.math.BigInteger;

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
        this.state = (obj[0]!=null) ? Integer.parseInt(String.valueOf(obj[0])) : 0;
		this.branch = (obj[1]!=null) ? Integer.parseInt(String.valueOf(obj[1])) : 0;
        this.grade = (obj[2]!=null) ? Integer.parseInt(String.valueOf(obj[2])) : 0;
        this.count = (obj[3] != null) ? ((BigInteger) obj[3]).intValue() : 0;
    }

}
