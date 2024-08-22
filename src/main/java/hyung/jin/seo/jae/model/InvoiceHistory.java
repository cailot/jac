package hyung.jin.seo.jae.model;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ForeignKey;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import org.hibernate.annotations.CreationTimestamp;
import javax.persistence.Column;
import javax.persistence.CascadeType;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="InvoiceHistory")
public class InvoiceHistory{ 
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;

	@ManyToOne
	@JoinColumn(name = "invoiceId", foreignKey = @ForeignKey(name = "FK_Invoice_InvoiceHistory"))
	private Invoice invoice;

    
	@OneToMany(mappedBy = "invoiceHistory", cascade = {
     	CascadeType.PERSIST,
		CascadeType.MERGE,
		CascadeType.REFRESH,
		CascadeType.DETACH
	})
    private Set<Enrolment> enrolments = new HashSet<>();

	public void addEnrolment(Enrolment enrolment){
		enrolments.add(enrolment);
	}

	@OneToMany(fetch = FetchType.LAZY, cascade = {
		CascadeType.PERSIST,
		CascadeType.MERGE,
		CascadeType.REFRESH,
		CascadeType.DETACH
	})
	@JoinColumn(name = "invoiceHistoryId", foreignKey = @ForeignKey(name = "FK_InvoiceHistory_Payment"))
	private Set<Payment> payments = new LinkedHashSet<>();

	public void addPayment(Payment payment){
		payments.add(payment);
	}

	@OneToMany(mappedBy = "invoiceHistory", cascade = {
     	CascadeType.PERSIST,
		CascadeType.MERGE,
		CascadeType.REFRESH,
		CascadeType.DETACH
	})
    private Set<Material> materials = new HashSet<>();

	public void addMaterial(Material material){
		materials.add(material);
	}

	// auto update to current date
	@CreationTimestamp
    private LocalDate registerDate;

	// @CreatedDate
    // private LocalDate paymentDate;

	// @Column
    // private int credit;

	// @Column
    // private double discount;

	@Column
    private double amount;

	@Column
	private double paidAmount;

}
