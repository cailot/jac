package hyung.jin.seo.jae.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.Table;

import org.hibernate.annotations.CreationTimestamp;
import org.springframework.data.annotation.CreatedDate;

import javax.persistence.Id;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Column;
import javax.persistence.ManyToOne;
import javax.persistence.JoinColumn;
import java.time.LocalDate;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="Payment")
public class Payment {

	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
     
    @Column(length = 10, nullable = false)
    private String method;
    
    @Column(length = 100)
    private String info;

    @Column(columnDefinition = "DECIMAL(10,2)")
    private double amount;

    @Column(columnDefinition = "DECIMAL(10,2)")
    private double total;
    
    @CreationTimestamp
    private LocalDate registerDate;

    @CreatedDate
    private LocalDate payDate;

    @ManyToOne
    @JoinColumn(name = "invoiceId")
    private Invoice invoice;

    @ManyToOne
    @JoinColumn(name = "invoiceHistoryId")
    private InvoiceHistory invoiceHistory;
	
}
