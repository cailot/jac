package hyung.jin.seo.jae.model;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

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
import javax.persistence.ManyToOne;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Column;
import javax.persistence.ForeignKey;
import java.time.LocalDate;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="Homework")
public class Homework {
    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;

    // @Column(length = 1, nullable = false)
    // private Integer type;

    @Column(length = 300, nullable = true)
    private String videoPath;

    @Column(length = 300, nullable = true)
    private String pdfPath;
    
    // @Column(length = 10, nullable = true)
    // private Long duration;

    @Column(length = 2, nullable = true)
    private Integer week;

    // @Column(length = 4, nullable = true)
    // private Integer year;

    @Column(length = 50, nullable = true)
    private String info;

    @Column
    private boolean active;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "gradeId", foreignKey = @ForeignKey(name = "FK_Homework_Grade"))
    private Grade grade;
	
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subjectId", foreignKey = @ForeignKey(name = "FK_Homework_Subject"))
    private Subject subject;
    
    @CreationTimestamp
    private LocalDate registerDate;
    
}
