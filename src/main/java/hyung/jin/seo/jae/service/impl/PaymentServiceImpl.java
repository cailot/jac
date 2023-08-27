package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.PaymentDTO;
import hyung.jin.seo.jae.model.Payment;
import hyung.jin.seo.jae.repository.PaymentRepository;
import hyung.jin.seo.jae.service.PaymentService;

@Service
public class PaymentServiceImpl implements PaymentService {
	
	@Autowired
	private PaymentRepository paymentRepository;
   
	@Override
	public long checkCount() {
		long count = paymentRepository.count();
		return count;
	}

	@Override
	public List<PaymentDTO> allPayments() {
		List<Payment> payments = paymentRepository.findAll();
		List<PaymentDTO> dtos = new ArrayList<>();
		for(Payment payment: payments){
			PaymentDTO dto = new PaymentDTO(payment);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public PaymentDTO getPayment(Long id) {
		Payment payment = paymentRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Payment not found"));
		PaymentDTO dto = new PaymentDTO(payment);
		return dto;
	}

	@Override
	public Payment getPaymentByInvoiceId(Long invoiceId) {
		return paymentRepository.findByInvoiceId(invoiceId);

	}

	@Override
	@Transactional
	public Payment addPayment(Payment payment) {
		return paymentRepository.save(payment);
	}

	@Override
	@Transactional
	public PaymentDTO updatePayment(Payment payment, Long id) {
		// search by getId
		Payment existing = paymentRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Payment not found"));
		// Update info
		// amount
		if(payment.getAmount()!=existing.getAmount()){
			existing.setAmount(payment.getAmount());
		}
		// method
		if(payment.getMethod()!=existing.getMethod()){
			existing.setMethod(payment.getMethod());
		}
		// info
		if(payment.getInfo()!=existing.getInfo()){
			existing.setInfo(payment.getInfo());
		}
		// update the existing record
		Payment updated = paymentRepository.save(existing);
		PaymentDTO dto = new PaymentDTO(updated);
		return dto;
	}

	@Override
	public Payment findPaymentById(Long id) {
		return paymentRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Payment not found"));

	}

}
