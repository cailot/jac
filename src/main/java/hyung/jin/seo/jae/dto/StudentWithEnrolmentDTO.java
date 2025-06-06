package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
// @AllArgsConstructor
@ToString
public class StudentWithEnrolmentDTO implements Serializable{
    
    private Long id;
    private String firstName;
    private String lastName;
    private String grade;
    private String gender;
    private String state;
    private String branch;
    private LocalDate registerDate;
    private String email1;
    private String contactNo1;
    private String address;
    private Integer active;
    private Integer startWeek;
    private Integer endWeek;
    private String className;

    public StudentWithEnrolmentDTO(Long id, String firstName, String lastName, String grade, String gender, String state, String branch, LocalDate registerDate, String email1, String contactNo1, String address, Integer active, Integer startWeek, Integer endWeek, String className) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.grade = grade;
        this.gender = gender;
        this.state = state;
        this.branch = branch;
        this.registerDate = registerDate;
        this.email1 = email1;
        this.contactNo1 = contactNo1;
        this.address = address;
        this.active = active;
        this.startWeek = startWeek;
        this.endWeek = endWeek;
        this.className = className;
    }
}
