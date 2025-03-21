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
public class OmrStatsDTO implements Serializable{

    private String branch;
    
	private int mega;
    
    private int revision;
    
    private int acer;
    
    private int edu;

}
