package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import javax.persistence.EntityNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.InvoiceHistoryDTO;
import hyung.jin.seo.jae.model.InvoiceHistory;
import hyung.jin.seo.jae.repository.InvoiceHistoryRepository;
import hyung.jin.seo.jae.service.InvoiceHistoryService;

@Service
public class InvoiceHistoryServiceImpl implements InvoiceHistoryService {
	
	@Autowired
	private InvoiceHistoryRepository invoiceHistoryRepository;
	

	@Override
	public List<InvoiceHistoryDTO> allInvoiceHistory() {
		List<InvoiceHistory> histories = new ArrayList<>();
		try{
			histories = invoiceHistoryRepository.findAll();
		}catch(Exception e){
			System.out.println("No InvoiceHistory found");
		}
		List<InvoiceHistoryDTO> dtos = new ArrayList<>();
		for(InvoiceHistory history: histories){
			InvoiceHistoryDTO dto = new InvoiceHistoryDTO(history);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<InvoiceHistoryDTO> findInvoiceHistoryDTOByInvoice(Long id) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'findInvoiceHistoryDTOByInvoice'");
	}

	@Override
	public InvoiceHistory getInvoiceHistory(Long id) {
		InvoiceHistory history = null;
		try{
			history = invoiceHistoryRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No InvoiceHistory found");
		}
		return history;
	}

	@Override
	@Transactional
	public InvoiceHistory addInvoiceHistory(InvoiceHistory history) {
		InvoiceHistory add = invoiceHistoryRepository.save(history);
		return add;
	}

	@Override
	public InvoiceHistory updateInvoiceHistory(InvoiceHistory history, Long id) {
		// search by id
		InvoiceHistory existing = invoiceHistoryRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("InvoiceHistory not found"));
		// Update the existing record
		// // paymentDate
		// LocalDate newPaymentDate = history.getPaymentDate();
		// existing.setPaymentDate(newPaymentDate);
		// // credit
		// if(history.getCredit() != existing.getCredit()){
		// 	existing.setCredit(history.getCredit());
		// }
		// // discount
		// if(history.getDiscount() != existing.getDiscount()){
		// 	existing.setDiscount(history.getDiscount());
		// }
		// amount
		if(history.getAmount() != existing.getAmount()){
			existing.setAmount(history.getAmount());
		}
		// paidAmount
		if(history.getPaidAmount() != existing.getPaidAmount()){
			existing.setPaidAmount(history.getPaidAmount());
		}
		// // enrolmentId
		// if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(history.getEnrolmentId()), StringUtils.defaultString(existing.getEnrolmentId()))){
		// 	existing.setEnrolmentId(StringUtils.defaultString(history.getEnrolmentId()));
		// }
		// // info
		// if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(history.getInfo()), StringUtils.defaultString(existing.getInfo()))){
		// 	existing.setInfo(StringUtils.defaultString(history.getInfo()));
		// }
		// update the existing record
		InvoiceHistory updated = invoiceHistoryRepository.save(existing);
		return updated;
	}

	@Override
	@Transactional
	public void deleteInvoiceHistory(Long id) {
		invoiceHistoryRepository.deleteById(id);
	}

	@Override
	public InvoiceHistory getLastInvoiceHistory(Long invoiceId) {
		InvoiceHistory history = null;
		try{
			history = invoiceHistoryRepository.findTopByInvoiceIdOrderByIdDesc(invoiceId).orElse(null);
		}catch(Exception e){
			System.out.println("No InvoiceHistory found");
		}
		return history;
	}

	@Override
	public List<InvoiceHistory> getAllInvoiceHistoriesByInvoice(Long invoiceId) {
		List<InvoiceHistory> histories = new ArrayList<>();
		try{
			histories = invoiceHistoryRepository.findAllByInvoiceId(invoiceId);
		}catch(Exception e){
			System.out.println("No InvoiceHistory found");
		}
		return histories;
	}

}
