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

	public PaymentDTO(Payment payment){
		this.id = String.valueOf(payment.getId());
		this.registerDate = payment.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.amount = payment.getAmount();
		this.method = payment.getMethod();
		this.info = payment.getInfo();
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
