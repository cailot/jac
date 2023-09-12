package hyung.jin.seo.jae.dto;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.apache.commons.lang3.StringUtils;
import hyung.jin.seo.jae.model.Payment;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class PaymentDTO extends MoneyDTO{
    
	// private String id;

	// private String registerDate;

	// private double amount;

	private String method;

	// private String info;

	private String invoiceId;

	public PaymentDTO(Payment payment){
		this.id = String.valueOf(payment.getId());
		this.registerDate = payment.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.amount = payment.getAmount();
		this.method = payment.getMethod();
		this.info = payment.getInfo();
	}

	public PaymentDTO(Object[] obj){
		this.id = (obj[0]!=null) ? String.valueOf(obj[0]) : "0"; // id
		this.amount = (obj[1]!=null) ? Double.parseDouble(String.valueOf(obj[1])) : 0; // amount
		this.method = (obj[2]!=null) ? String.valueOf(obj[2]) : ""; // method
		this.info = (obj[3]!=null) ? String.valueOf(obj[3]) : ""; // info
		this.registerDate = (obj[4]!=null) ? String.valueOf(obj[4]) : null; // registerDate
		this.invoiceId = (obj[5]!=null) ? String.valueOf(obj[5]) : ""; // invoiceId
	}

	public PaymentDTO(long id, double amount, String method, String info, LocalDate registerDate){
		this.id = String.valueOf(id);
		this.amount = amount;
		this.method = method;
		this.info = info;
		this.registerDate = (registerDate!=null) ? registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : null;
	}

	public Payment convertToPayment() {
    	Payment payment = new Payment();
		if(StringUtils.isNotBlank(id)) payment.setId(Long.parseLong(id));
    	if(StringUtils.isNotBlank(registerDate)) payment.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(info)) payment.setInfo(info);
		payment.setAmount(amount);
		payment.setMethod(method);
		return payment;
    }

}
