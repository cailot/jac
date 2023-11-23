package hyung.jin.seo.jae.dto;

import java.io.Serializable;
import java.time.LocalDate;

import hyung.jin.seo.jae.model.Branch;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class BranchDTO implements Serializable{
    
	private String id;

	private String code;

	private String name;

	private String phone;

	private String email;

	private String address;

	private String abn;

	private String bank;

	private String bsb;

	private String accountNumber;

	private String accountName;

	private String info;

	private String stateId;

	public BranchDTO(Branch branch){
		this.id = (branch.getId()!=null) ? branch.getId().toString() : "";
		this.code = (branch.getCode()!=null) ? branch.getCode() : "";
		this.name = (branch.getName()!=null) ? branch.getName() : "";
		this.phone = (branch.getPhone()!=null) ? branch.getPhone() : "";
		this.email = (branch.getEmail()!=null) ? branch.getEmail() : "";
		this.address = (branch.getAddress()!=null) ? branch.getAddress() : "";
		this.abn = (branch.getAbn()!=null) ? branch.getAbn() : "";
		this.bank = (branch.getBank()!=null) ? branch.getBank() : "";
		this.bsb = (branch.getBsb()!=null) ? branch.getBsb() : "";
		this.accountNumber = (branch.getAccountNumber()!=null) ? branch.getAccountNumber() : "";
		this.accountName = (branch.getAccountName()!=null) ? branch.getAccountName() : "";
		this.info = (branch.getInfo()!=null) ? branch.getInfo() : "";
	}

	// public BranchDTO(long id, String code, String name, String phone, String email, String address, String abn, String bank, String bsb, String accountNumber, String accountName, String info, long stateId){
	// 	this.id = (id!=0) ? String.valueOf(id) : "";
	// 	this.code = (code!=null) ? code : "";
	// 	this.name = (name!=null) ? name : "";
	// 	this.phone = (phone!=null) ? phone : "";
	// 	this.email = (email!=null) ? email : "";
	// 	this.address = (address!=null) ? address : "";
	// 	this.abn = (abn!=null) ? abn : "";
	// 	this.bank = (bank!=null) ? bank : "";
	// 	this.bsb = (bsb!=null) ? bsb : "";
	// 	this.accountNumber = (accountNumber!=null) ? accountNumber : "";
	// 	this.accountName = (accountName!=null) ? accountName : "";
	// 	this.info = (info!=null) ? info : "";
	// 	this.stateId = (stateId!=0) ? String.valueOf(stateId) : "";
	// }
	public BranchDTO(Object[] object){
		this.id = (object[0]!=null) ? String.valueOf(object[0]) : "0";
		this.code = (object[1]!=null) ? String.valueOf(object[1]) : "";
		this.name = (object[2]!=null) ? String.valueOf(object[2]) : "";
		this.phone = (object[3]!=null) ? String.valueOf(object[3]) : "";
		this.email = (object[4]!=null) ? String.valueOf(object[4]) : "";
		this.address = (object[5]!=null) ? String.valueOf(object[5]) : "";
		this.abn = (object[6]!=null) ? String.valueOf(object[6]) : "";
		this.bank = (object[7]!=null) ? String.valueOf(object[7]) : "";
		this.bsb = (object[8]!=null) ? String.valueOf(object[8]) : "";
		this.accountNumber = (object[9]!=null) ? String.valueOf(object[9]) : "";
		this.accountName = (object[10]!=null) ? String.valueOf(object[10]) : "";
		this.info = (object[11]!=null) ? String.valueOf(object[11]) : "";
		this.stateId = (object[12]!=null) ? String.valueOf(object[12]) : "0";
	}
}
