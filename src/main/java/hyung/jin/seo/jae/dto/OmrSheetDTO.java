package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class OmrSheetDTO implements Serializable{

	private String[] testIds;

	private double score;

	private Long studentId;

	private Long testId;

	// private List<Integer> answers = new ArrayList<>();

	private String studentName;

	private String testName;

	private String fileName;

	// additional info
	private int volume;

	// private Long testTypeId;

	// private String gradeCode;

	// private String testTypeName;
	
	private List<int[]> answer = new ArrayList<>();

	public void addAnswer(int[] row) {
		this.answer.add(row);
	}

	public List<int[]> getAnswer() {
		return answer;
	}
	// private List<AnswerDTO> answer = new ArrayList<>();

	// public void addAnswer(AnswerDTO dto) {
	// 	this.answer.add(dto);
	// }

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("OmrSheetDTO{");
		if (studentId != null) sb.append("studentId=").append(studentId).append(", ");
		if (studentName != null) sb.append("studentName=").append(studentName).append(", ");
		if (testId != null) sb.append("testId=").append(testId).append(", ");
		if (testName != null) sb.append("testName=").append(testName).append(", ");
		if (fileName != null) sb.append("fileName=").append(fileName).append(", ");
		if (testIds != null) sb.append("testIds=").append(Arrays.toString(testIds)).append(", ");
		sb.append("volume=").append(volume).append(", ");
		
		// Format answer arrays
		sb.append("answer=[");
		if (answer != null && !answer.isEmpty()) {
			for (int i = 0; i < answer.size(); i++) {
				if (i > 0) sb.append(", ");
				sb.append(Arrays.toString(answer.get(i)));
			}
		}
		sb.append("]");
		sb.append("}");
		return sb.toString();
	}
}
