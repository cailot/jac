package hyung.jin.seo.jae.model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.ForeignKey;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.CollectionTable;
import javax.persistence.Column;
import javax.persistence.ElementCollection;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="StudentTest")
public class StudentTest{ // bridge table between Student & Test
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
	@ManyToOne
	@JoinColumn(name = "studentId", foreignKey = @ForeignKey(name = "FK_StudentTest_Student"))
	private Student student;
	
	@ManyToOne
	@JoinColumn(name = "testId", foreignKey = @ForeignKey(name = "FK_StudentTest_Test"))
	private Test test;

	@CreationTimestamp
    private LocalDate registerDate;

	@Column
	private double score;

	@ElementCollection
    @CollectionTable(name = "StudentTestAnswerCollection",
	joinColumns = @JoinColumn(name="StudentTest_id", foreignKey = @ForeignKey(name="FK_StudentTestAnswerCollection_StudentTest"))) // Set the custom table name
    private List<Integer> answers = new ArrayList<>();
}
