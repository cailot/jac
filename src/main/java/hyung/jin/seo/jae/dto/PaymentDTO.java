package hyung.jin.seo.jae.dto;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

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
    
	private String method;

	private String invoiceId;

	private String invoiceHistoryId;

	private List enrols;

	private double upto;

	private double total;

	private String payDate;

	public PaymentDTO(Payment payment){
		this.id = String.valueOf(payment.getId());
		this.payDate = payment.getPayDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.amount = payment.getAmount();
		this.total = payment.getTotal();
		this.method = payment.getMethod();
		this.info = payment.getInfo();
		this.invoiceId = String.valueOf(payment.getInvoice().getId());
	}

	public PaymentDTO(Object[] obj){
		this.id = (obj[0]!=null) ? String.valueOf(obj[0]) : "0"; // id
		this.amount = (obj[1]!=null) ? Double.parseDouble(String.valueOf(obj[1])) : 0; // amount
		this.total = (obj[2]!=null) ? Double.parseDouble(String.valueOf(obj[2])) : 0; // total
		this.method = (obj[3]!=null) ? String.valueOf(obj[3]) : ""; // method
		this.info = (obj[4]!=null) ? String.valueOf(obj[4]) : ""; // info
		this.registerDate = (obj[5]!=null) ? String.valueOf(obj[5]) : null; // registerDate
		// SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
		// this.registerDate = (obj[5] != null) ? dateFormat.format((Date) obj[5]) : null; // registerDate
		this.invoiceId = (obj[6]!=null) ? String.valueOf(obj[6]) : "0"; // invoiceId
		this.invoiceHistoryId = (obj[7]!=null) ? String.valueOf(obj[7]) : "0"; // invoiceHistoryId
		this.payDate = (obj[8]!=null) ? String.valueOf(obj[8]) : null; // payDate
	}

	public PaymentDTO(long id, double amount, double total, String method, String info, LocalDate payDate){
		this.id = String.valueOf(id);
		this.amount = amount;
		this.total = total;
		this.method = method;
		this.info = info;
		this.payDate = (payDate!=null) ? payDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : null;
	}

	// public PaymentDTO(long id, double amount, String info, LocalDate registerDate, long invoiceId, long invoiceHistoryId, double total){
	// 	this.id = String.valueOf(id);
	// 	this.amount = amount;
	// 	this.info = info;
	// 	this.registerDate = (registerDate!=null) ? registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : null;
	// 	this.invoiceId = String.valueOf(invoiceId);
	// 	this.invoiceHistoryId = String.valueOf(invoiceHistoryId);
	// 	this.total = total; // invoice amount
	// }


	public Payment convertToPayment() {
    	Payment payment = new Payment();
		if(StringUtils.isNotBlank(id)) payment.setId(Long.parseLong(id));
    	if(StringUtils.isNotBlank(registerDate)) payment.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(payDate)) payment.setRegisterDate(LocalDate.parse(payDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(info)) payment.setInfo(info);
		payment.setAmount(amount);
		payment.setTotal(total);
		payment.setMethod(method);
		return payment;
    }

}
