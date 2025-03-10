package hyung.jin.seo.jae.model;

import java.io.Serializable;

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
import javax.persistence.OneToMany;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.ForeignKey;
import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="TestType")
public class TestType implements Serializable{
    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
    @Column(length = 50, nullable = true)
    private String name;

	@Column
	private int testGroup;
        
	@CreationTimestamp
    private LocalDate registerDate;

    @OneToMany(fetch = FetchType.LAZY, cascade = {
		CascadeType.PERSIST,
		CascadeType.MERGE,
		CascadeType.REFRESH,
		CascadeType.DETACH
	})
	@JoinColumn(name = "testTypeId", foreignKey = @ForeignKey(name = "FK_TestType_Test"))
	private Set<Test> tests = new LinkedHashSet<>();

	public void addTest(Test test){
		tests.add(test);
	}


}
