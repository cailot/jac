package hyung.jin.seo.jae.model;

import java.io.Serializable;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.data.annotation.CreatedDate;
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
@Table(name="Teacher")
public class Teacher implements Serializable{
    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
    @Column(length = 100, nullable = false)
    private String firstName;
    
    @Column(length = 100, nullable = false)
    private String lastName;
    
    @Column(length = 5, nullable = true)
    private String title;
    
    @Column(length = 100, nullable = true)
    private String phone;
    
    @Column(length = 100, nullable = true)
    private String email;
    
    @Column(length = 200, nullable = true)
    private String address;
    
    @Column(length = 30, nullable = true)
    private String state;
    
    @Column(length = 50, nullable = true)
    private String branch;
    
    @Column(length = 1000, nullable = true)
    private String memo;
    
    @Column(length = 50, nullable = true)
    private String bank;
        
    @Column(length = 10, nullable = true)
    private String bsb;

    @Column(length = 15, nullable = true)
    private Long accountNumber;
    
    @Column(length = 50, nullable = true)
    private String superannuation;
    
    @Column(length = 20, nullable = true)
    private String superMember;
    
    @Column(length = 15, nullable = true)
    private Long tfn;
    
	@CreationTimestamp
    private LocalDate startDate;
    
    @CreatedDate
    private LocalDate endDate;
    
   }
