package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
// @ToString
public class EnrolmentMigrateDTO extends MigrateDTO implements Serializable{

	private int year;

	private int startWeek;

	private int endWeek;	

	private int credit;

	private double discount;

	// private double price;

	private double total;

	// private String clazzName;

    @Override
    public String toString() {
        return  "year=" + year +
                ",startWeek=" + startWeek +
                ",endWeek=" + endWeek +
                ",credit=" + credit +
                ",discount=" + discount +
                ",price=" + price +
                ",total=" + total +
                ",name=" + name;
    }

}
