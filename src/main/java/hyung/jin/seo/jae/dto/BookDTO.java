package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import hyung.jin.seo.jae.model.Book;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_DEFAULT) // eliminate any unnecessary variable such as registerDate is null
public class BookDTO implements Serializable{
    
	private String id;
    
    private String grade;
    
    private String name;
         
    private double price;
    
    private String registerDate;

	private boolean active;

	private List<SubjectDTO> subjects = new ArrayList<>();

    public void addSubject(SubjectDTO subject){
        subjects.add(subject);
    }

	public BookDTO(Book cb) {
    	this.id = (cb.getId()!=null) ? cb.getId().toString() : "";
    	this.grade = (cb.getGrade()!=null) ? cb.getGrade() : "";
    	this.name = (cb.getName()!=null) ? cb.getName() : "";
    	this.price = cb.getPrice();
		this.active = cb.isActive();
    }

    public BookDTO(long id,  String grade, String name, double price, boolean active) {
        this.id = Long.toString(id);
		this.grade = grade;
        this.name = name;
		this.price = price;		
		this.active = active;
	}

    public Book convertToBook() {
    	Book book = new Book();
    	if(StringUtils.isNotBlank(id)) book.setId(Long.parseLong(this.id));
    	if(StringUtils.isNotBlank(name)) book.setName(this.name);
    	if(StringUtils.isNotBlank(registerDate)) book.setRegisterDate(LocalDate.parse(registerDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
    	if(StringUtils.isNotBlank(grade)) book.setGrade(this.grade);
		book.setPrice(price);
		book.setActive(true);
    	return book;
    }

  }
