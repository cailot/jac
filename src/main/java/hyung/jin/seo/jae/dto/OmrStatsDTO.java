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
public class OmrStatsDTO implements Serializable{

    private String branch;
    
	private int mega;
    
    private int revision;
    
    private int acer;
    
    private int edu;

    public OmrStatsDTO(Object[] obj) {
        this.branch = (obj[0]!=null) ? String.valueOf(obj[0]) : "0";
		this.mega = (obj[1]!=null) ? Integer.parseInt(String.valueOf(obj[1])) : 0;
        this.revision = (obj[2]!=null) ? Integer.parseInt(String.valueOf(obj[2])) : 0;
        this.acer = (obj[3] != null) ? Integer.parseInt(String.valueOf(obj[3])) : 0;
        this.edu = (obj[4] != null) ? Integer.parseInt(String.valueOf(obj[4])) : 0;
    }

}
