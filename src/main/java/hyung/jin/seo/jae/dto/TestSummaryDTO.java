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
public class TestSummaryDTO implements Serializable {

	private String id;

	private String name;

	private String course;

	private String branch;

	private double score1;

	private double score2;

	private double score3;
	
}
