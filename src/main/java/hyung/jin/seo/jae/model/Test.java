package hyung.jin.seo.jae.model;

import org.hibernate.annotations.CreationTimestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.Table;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="Test")
public class Test{
    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
    @Column(length = 50, nullable = true)
    private String name;
    
    @Column(length = 10, nullable = false)
    private String grade;
    
    @CreationTimestamp
    private LocalDate registerDate;

	@ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "testTypeId")
    private TestType testType;

     @ManyToMany(fetch = FetchType.LAZY, cascade = {
		CascadeType.PERSIST,
		CascadeType.MERGE,
		CascadeType.REFRESH,
		CascadeType.DETACH
	})
    @JoinTable(name="Test_Subject",
    joinColumns = @JoinColumn(name="testId"),
    inverseJoinColumns = @JoinColumn(name="subjectId")
    )
    private Set<Subject> subjects = new HashSet<>();

    @OneToMany(mappedBy = "test", cascade = {
		CascadeType.PERSIST,
	   CascadeType.MERGE,
	   CascadeType.REFRESH,
	   CascadeType.DETACH
   	})
    private Set<StudentTest> studentTests = new HashSet<>();

}
