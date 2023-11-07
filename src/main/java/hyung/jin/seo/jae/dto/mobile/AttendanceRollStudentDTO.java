package hyung.jin.seo.jae.dto.mobile;

import java.io.Serializable;
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
public class AttendanceRollStudentDTO implements Serializable {

	private String id;

	private String attendDate;

	private String status;

	private String studentId;

	private String studentName;

	public AttendanceRollStudentDTO(long id, LocalDate attendDate, String status, long studentId, String studentName) {
		this.id = Long.toString(id);
		this.attendDate = attendDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.status = status;
		this.studentId = Long.toString(studentId);
		this.studentName = studentName;
	}

	// just for testing purpose
	public AttendanceRollStudentDTO(long id, String attendDate, String status, long studentId, String studentName) {
		this.id = Long.toString(id);
		this.attendDate = attendDate;
		this.status = status;
		this.studentId = Long.toString(studentId);
		this.studentName = studentName;
	}

}
