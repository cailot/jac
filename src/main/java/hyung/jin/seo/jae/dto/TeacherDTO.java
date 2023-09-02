package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import org.apache.commons.lang3.StringUtils;
import hyung.jin.seo.jae.model.Teacher;
import java.time.format.DateTimeFormatter;
import java.time.LocalDate;


public class TeacherDTO implements Serializable{
    
    private String id;
    
    private String firstName;
    
    private String lastName;
    
    private String title;
    
    private String phone;
    
    private String email;
    
    private String address;
    
    private String state;
    
    private String branch;
    
    private String memo;
    
    private String bank;
    
    private String bsb;
    
    private String accountNumber;
    
    private String superannuation;
    
    private String superMember;
    
    private String tfn;
    
    private String startDate;
    
    private String endDate;
    
    public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getBranch() {
		return branch;
	}

	public void setBranch(String branch) {
		this.branch = branch;
	}

	public String getMemo() {
		return memo;
	}

	public void setMemo(String memo) {
		this.memo = memo;
	}

	public String getBank() {
		return bank;
	}

	public void setBank(String bank) {
		this.bank = bank;
	}

	public String getBsb() {
		return bsb;
	}

	public void setBsb(String bsb) {
		this.bsb = bsb;
	}

	public String getAccountNumber() {
		return accountNumber;
	}

	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public String getSuperannuation() {
		return superannuation;
	}

	public void setSuperannuation(String superannuation) {
		this.superannuation = superannuation;
	}

	public String getSuperMember() {
		return superMember;
	}

	public void setSuperMember(String superMember) {
		this.superMember = superMember;
	}

	public String getTfn() {
		return tfn;
	}

	public void setTfn(String tfn) {
		this.tfn = tfn;
	}

	public String getStartDate() {
		return startDate;
	}

	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	@Override
	public String toString() {
		return "TeacherDTO [id=" + id + ", firstName=" + firstName + ", lastName=" + lastName + ", title=" + title
				+ ", phone=" + phone + ", email=" + email + ", address=" + address + ", state=" + state + ", branch="
				+ branch + ", memo=" + memo + ", bank=" + bank + ", bsb=" + bsb + ", accountNumber=" + accountNumber
				+ ", superannuation=" + superannuation + ", superMember=" + superMember + ", taxNumber=" + tfn
				+ ", startDate=" + startDate + ", endDate=" + endDate + "]";
	}

	public TeacherDTO() {}

    public TeacherDTO(Teacher teacher) {
    	this.id = (teacher.getId()!=null) ? teacher.getId().toString() : "";
        this.firstName = (teacher.getFirstName()!=null) ? teacher.getFirstName() : "";
        this.lastName = (teacher.getLastName()!=null) ? teacher.getLastName() : "";
        this.title = (teacher.getTitle()!=null) ? teacher.getTitle() : "";
        this.phone = (teacher.getPhone()!=null) ? teacher.getPhone() : "";
        this.email = (teacher.getEmail()!=null) ? teacher.getEmail() : "";
        this.address = (teacher.getAddress()!=null) ? teacher.getAddress() : "";
        this.state = (teacher.getState()!=null) ? teacher.getState() : "";
        this.branch = (teacher.getBranch()!=null) ? teacher.getBranch() : "";
        this.memo = (teacher.getMemo()!=null) ? teacher.getMemo() : "";
        this.bank = (teacher.getBank()!=null) ? teacher.getBank() : "";
        this.bsb = (teacher.getBsb()!=null) ? teacher.getBsb() : "";
        this.accountNumber = (teacher.getAccountNumber()!=null) ? teacher.getAccountNumber().toString() : "";
        this.superannuation = (teacher.getSuperannuation()!=null) ? teacher.getSuperannuation() : "";
        this.superMember = (teacher.getSuperMember()!=null) ? teacher.getSuperMember() : "";
        this.tfn = (teacher.getTfn()!=null) ? teacher.getTfn().toString() : "";
        this.startDate = (teacher.getStartDate()!=null) ? teacher.getStartDate().toString() : "";
        this.endDate = (teacher.getEndDate()!=null) ? teacher.getEndDate().toString() : ""; 
    }
    
    public Teacher convertToTeacher() {
    	Teacher teacher = new Teacher();
    	if(StringUtils.isNotBlank(id)) teacher.setId(Long.parseLong(this.id));
    	if(StringUtils.isNotBlank(firstName)) teacher.setFirstName(this.firstName);
    	if(StringUtils.isNotBlank(lastName)) teacher.setLastName(this.lastName);
    	if(StringUtils.isNotBlank(title)) teacher.setTitle(this.title);
    	if(StringUtils.isNotBlank(phone)) teacher.setPhone(this.phone);
    	if(StringUtils.isNotBlank(email)) teacher.setEmail(this.email);
    	if(StringUtils.isNotBlank(address)) teacher.setAddress(this.address);
    	if(StringUtils.isNotBlank(state)) teacher.setState(this.state);
    	if(StringUtils.isNotBlank(branch)) teacher.setBranch(this.branch);
    	if(StringUtils.isNotBlank(memo)) teacher.setMemo(this.memo);
    	if(StringUtils.isNotBlank(bank)) teacher.setBank(this.bank);
    	if(StringUtils.isNotBlank(bsb)) teacher.setBsb(this.bsb);
    	if(StringUtils.isNotBlank(accountNumber)) teacher.setAccountNumber(Long.parseLong(this.accountNumber));
    	if(StringUtils.isNotBlank(superannuation)) teacher.setSuperannuation(this.superannuation);
    	if(StringUtils.isNotBlank(superMember)) teacher.setSuperMember(this.superMember);
    	if(StringUtils.isNotBlank(tfn)) teacher.setTfn(Long.parseLong(this.tfn));
    	if(StringUtils.isNotBlank(startDate)) teacher.setStartDate(LocalDate.parse(startDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
    	if(StringUtils.isNotBlank(endDate)) teacher.setEndDate(LocalDate.parse(endDate, DateTimeFormatter.ofPattern("dd/MM/yyyy")));
    	return teacher;
    }
}
