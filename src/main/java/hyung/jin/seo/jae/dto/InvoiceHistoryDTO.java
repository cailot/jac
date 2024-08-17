package hyung.jin.seo.jae.dto;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.apache.commons.lang3.StringUtils;

import hyung.jin.seo.jae.model.InvoiceHistory;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class InvoiceHistoryDTO extends MoneyDTO{
    
	private double paidAmount;

	public InvoiceHistoryDTO(InvoiceHistory invoice){
		this.id = String.valueOf(invoice.getId());
		this.registerDate = invoice.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.amount = invoice.getAmount();
		this.paidAmount = invoice.getPaidAmount();
	}

	public InvoiceHistory convertToOnlyInvoice() {
    	InvoiceHistory invoice = new InvoiceHistory();
		if(StringUtils.isNotBlank(id)) invoice.setId(Long.parseLong(id));
    	if(StringUtils.isNotBlank(registerDate)) invoice.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		invoice.setAmount(amount);
		invoice.setPaidAmount(paidAmount);
		return invoice;
    }

	public InvoiceHistoryDTO(long id, double paidAmount, double amount, LocalDate registerDate){
		this.id = String.valueOf(id);
		this.paidAmount = paidAmount;
		this.amount = amount;
		this.registerDate = (registerDate!=null) ? registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : null;
	}

}
