package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

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
public class StudentTestSummaryDTO implements Serializable {

	private String id;

	private String name;

	private String course;

	private String branch;

	private List<Double> scores = new ArrayList<>();

	public void addScore(double score) {
		this.scores.add(score);
	}

}
