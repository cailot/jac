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

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="NoticeEmail")
public class NoticeEmail {
    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
    @Column(length = 200, nullable = false)
    private String title;
    
    @Column(length = 2000)
    private String body;
    
    @Column(length = 10)
    private String grade;

    @Column(length = 50)
    private String branch;

    @Column(length = 30)
    private String state;

    @Column(length = 50)
    private String sender;

    @CreationTimestamp
    private LocalDate registerDate;
 }
