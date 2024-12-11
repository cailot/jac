package hyung.jin.seo.jae.model;

import org.hibernate.annotations.CreationTimestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Id;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Column;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="PracticeSchedule")
public class PracticeSchedule {
    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
    @Column(nullable = false)
    private LocalDateTime fromDatetime;

    @Column(nullable = false)
    private LocalDateTime toDatetime;

    @Column(length = 30, nullable = true)
    private String grade;

    @Column(length = 30, nullable = true)
    private String practiceGroup;
   
    @Column(length = 30, nullable = true)
    private String week;

    @Column(length = 50, nullable = false)
    private String info;

    @Column
    private boolean active;
    
    @CreationTimestamp
    private LocalDate registerDate;

    // @ManyToMany(cascade = CascadeType.ALL)
	// @JoinTable(
	// 	name = "PracticeScheculeLink",
	// 	joinColumns = { @JoinColumn(name = "practiceScheduleId", foreignKey = @javax.persistence.ForeignKey(name = "FK_PracticeScheduleLink_PracticeSchedule")) },
	// 	inverseJoinColumns = { @JoinColumn(name = "practiceId", foreignKey = @javax.persistence.ForeignKey(name = "FK_PracticeScheduleLink_Practice")) }
	// )
	// private Set<Practice> practices = new LinkedHashSet();

    // public void addPractice(Practice practice){
    //     practices.add(practice);
    // }

 }
