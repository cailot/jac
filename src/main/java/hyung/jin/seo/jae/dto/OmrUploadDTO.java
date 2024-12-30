package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OmrUploadDTO implements Serializable{
    
    private String state;
    
    private String branch;
    
    private String testGroup;
    
    private String grade;
    
    private String volume;
     
	private MultipartFile file;
   
}
