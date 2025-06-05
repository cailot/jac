package hyung.jin.seo.jae.dto;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.apache.commons.lang3.StringUtils;
import hyung.jin.seo.jae.model.Material;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@ToString
public class MaterialDTO extends MoneyDTO{
 
	private String name;

	private double price;

	private double input;

	private String paymentDate;

	private String bookId;

	private String invoiceId;

	private String invoiceHistoryId;


	public MaterialDTO(Material material){
		this.id = String.valueOf(material.getId());
		this.name = (material.getBook()!=null) ? material.getBook().getName() : "";
		this.price = (material.getBook()!=null) ? material.getBook().getPrice() : 0;
		this.registerDate = material.getRegisterDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.paymentDate = (material.getPaymentDate()!=null) ? material.getPaymentDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
		this.bookId = (material.getBook()!=null) ? String.valueOf(material.getBook().getId()) : "";
		this.invoiceId = (material.getInvoice()!=null) ? String.valueOf(material.getInvoice().getId()) : "";
		this.invoiceHistoryId = (material.getInvoiceHistory()!=null) ? String.valueOf(material.getInvoiceHistory().getId()) : "";
		this.info = (material.getInfo()!=null) ? material.getInfo() : "";
	}

	public Material convertToMaterial() {
    	Material material = new Material();
		if(StringUtils.isNotBlank(id)) material.setId(Long.parseLong(id));
    	if(StringUtils.isNotBlank(registerDate)) material.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		if(StringUtils.isNotBlank(paymentDate)) material.setRegisterDate(LocalDate.parse(paymentDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));	
		// if(input>0) material.setInput(input);
		if(StringUtils.isNotBlank(info)) material.setInfo(info);		
    	return material;
    }

	public MaterialDTO(long id, LocalDate registerDate, LocalDate paymentDate, String info, long bookId, String name, double price, long invoiceId, long invoiceHistoryId, double input){
		this.id = String.valueOf(id);
		this.registerDate = registerDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		this.paymentDate = (paymentDate!=null) ? paymentDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
		this.info = info;
		this.bookId = String.valueOf(bookId);
		this.name = name;
		this.price = price;
		this.invoiceId = String.valueOf(invoiceId);
		this.invoiceHistoryId = String.valueOf(invoiceHistoryId);
		this.input = input;
	}
	
}
