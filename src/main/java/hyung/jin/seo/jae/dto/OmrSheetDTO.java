package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class OmrSheetDTO implements Serializable{
    
	private List<StudentTestDTO> studentTest = new ArrayList<>();

	public void addStudentTest(StudentTestDTO dto) {
		this.studentTest.add(dto);
	}
}
