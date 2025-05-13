package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.apache.commons.lang3.StringUtils;

import hyung.jin.seo.jae.model.Clazz;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
public class MaterialMigrateDTO extends MigrateDTO implements Serializable{

	// private double price;

	private int quantity;

	// private String name;

    @Override
    public String toString() {
        return  "price=" + price +
                ",quantity=" + quantity +
                ",name=" + name;
    }

}
