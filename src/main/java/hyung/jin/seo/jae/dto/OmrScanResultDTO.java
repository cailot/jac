package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OmrScanResultDTO implements Serializable{
    
    private String testId;
    
    private String testName;
    
    private String studentId;
    
    private String studentName;
    
    private List<Integer> answers = new ArrayList<>();

    public void addAnswer(int answer) {
        this.answers.add(answer);
    }
   
}
