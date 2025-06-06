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
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.ForeignKey;

import org.hibernate.annotations.CreationTimestamp;
import org.springframework.data.annotation.CreatedDate;

import javax.persistence.Column;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="Material")
public class Material{ // bridge table between Invoice & Book
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
	@ManyToOne
	@JoinColumn(name = "invoiceId", foreignKey = @ForeignKey(name = "FK_Material_Invoice"))
	private Invoice invoice;

	@ManyToOne
	@JoinColumn(name = "invoiceHistoryId", foreignKey = @ForeignKey(name = "FK_Material_InvoiceHistory"))
	private InvoiceHistory invoiceHistory;
	
	@ManyToOne
	@JoinColumn(name = "bookId", foreignKey = @ForeignKey(name = "FK_Material_Book"))
	private Book book;
	
	@CreationTimestamp
    private LocalDate registerDate;

	@CreatedDate
    private LocalDate paymentDate;

	@Column(length = 100)
    private String info;

	@Column
	private boolean old;

	@Column
	private double input;

}
