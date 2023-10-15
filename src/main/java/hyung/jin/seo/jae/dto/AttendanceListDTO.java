package hyung.jin.seo.jae.dto;

import java.util.ArrayList;
import java.util.List;

import hyung.jin.seo.jae.utils.JaeConstants;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class AttendanceListDTO extends RollBook {
    
	private List<Long> id = new ArrayList<>();

	private List<String> attendDate = new ArrayList<>();

	private List<String> status = new ArrayList<>();

	private List<Integer> week = new ArrayList<>();

	private String studentId = JaeConstants.ATTEND_LIST_STUDENT_ID;

	private String studentName = JaeConstants.ATTEND_LIST_STUDENT_NAME;

	private String clazzId = JaeConstants.ATTEND_LIST_CLASS_ID;

	private String clazzDay = JaeConstants.ATTEND_LIST_CLASS_DAY;

	private String clazzGrade = JaeConstants.ATTEND_LIST_CLASS_GRADE;

	private String clazzName = JaeConstants.ATTEND_LIST_CLASS_NAME;

}
