package hyung.jin.seo.jae.dto;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class OmrScanHistoryDTO{
    
	private Long id;

	private String registerDate;

	private Long studentId;

	private Long testId;

	private String branch;

	private int testGroup;

	public OmrScanHistoryDTO(Long id, Long studentId, Long testId, String branch, int testGroup, LocalDate registerDate) {
		this.id = id;
		this.studentId = studentId;
		this.testId = testId;
		this.branch = branch;
		this.testGroup = testGroup;
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
	}

}
