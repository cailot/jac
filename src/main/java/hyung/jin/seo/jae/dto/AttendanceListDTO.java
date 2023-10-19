package hyung.jin.seo.jae.dto;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class AttendanceListDTO {
    
	private List<String> attendDate = new ArrayList<>();

	private List<String> status = new ArrayList<>();

	private List<Integer> week = new ArrayList<>();

	private String studentId;

	private String studentName;

	private String clazzId;

	private String clazzDay;

	private String clazzGrade;

	private String clazzName;

	public AttendanceListDTO convertToAttendanceListDTO(){
		AttendanceListDTO dto = new AttendanceListDTO();
		dto.setStudentId(this.studentId);
		dto.setStudentName(this.studentName);
		dto.setClazzId(this.clazzId);
		dto.setClazzDay(this.clazzDay);
		dto.setClazzGrade(this.clazzGrade);
		dto.setClazzName(this.clazzName);
		return dto;
	}
	
	public AttendanceListDTO(String json) {
    ObjectMapper objectMapper = new ObjectMapper();
    try {
        AttendanceListDTO dto = objectMapper.readValue(json, AttendanceListDTO.class);
        this.attendDate = dto.getAttendDate();
        this.status = dto.getStatus();
        this.week = dto.getWeek();
        // Set other fields as needed
    } catch (JsonProcessingException e) {
        e.printStackTrace();
    }
}

}



