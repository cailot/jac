package hyung.jin.seo.jae.model;

import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.Column;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="OmrScanHistory")
public class OmrScanHistory{ // simply store the history of OMR scan
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
	@Column
	private Long studentId;

	@Column
	private Long testId;

	@Column
	private String branch;

	@Column
	private int testGroup;

	@CreationTimestamp
	private LocalDate registerDate;

}
