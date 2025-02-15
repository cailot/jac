package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import hyung.jin.seo.jae.model.TestAnswer;
import hyung.jin.seo.jae.model.TestAnswerItem;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class TestAnswerDTO implements Serializable {

	private String id;

	private String videoPath;

	private String pdfPath;

	private long testId;

	private int answerCount;

	private List<TestAnswerItem> answers;

	public TestAnswerDTO(TestAnswer work){
		this.id = String.valueOf(work.getId());
		this.videoPath = work.getVideoPath();
		this.pdfPath = work.getPdfPath();
		this.answerCount = work.getAnswerCount();
		this.testId = work.getTest().getId();
		this.answers = work.getAnswers();
	}

	public TestAnswerDTO(Long id, Collection<TestAnswerItem> answers){
		this.id = String.valueOf(id);
		this.answers = new ArrayList<>(answers);
	}

	public TestAnswerDTO(Object[] obj){
		this.id = obj[0].toString();
		this.answers = obj[1] == null ? new ArrayList<>() : (List<TestAnswerItem>) obj[1];
	}

}
