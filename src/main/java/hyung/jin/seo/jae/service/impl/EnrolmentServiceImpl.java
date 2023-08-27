package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.repository.EnrolmentRepository;
import hyung.jin.seo.jae.service.EnrolmentService;

@Service
public class EnrolmentServiceImpl implements EnrolmentService {
	
	@Autowired
	private EnrolmentRepository enrolmentRepository;

	@Override
	public List<EnrolmentDTO> allEnrolments() {
		List<Enrolment> enrols = enrolmentRepository.findAll();
		List<EnrolmentDTO> dtos = new ArrayList<>();
		for(Enrolment enrol: enrols){
			EnrolmentDTO dto = new EnrolmentDTO(enrol);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByStudent(Long studentId) {
		List<Object[]> objects = enrolmentRepository.findEnrolmentByStudentId(studentId);
		List<EnrolmentDTO> dtos = new ArrayList<EnrolmentDTO>();
		for(Object[] object : objects){
			EnrolmentDTO dto = new EnrolmentDTO(object);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByClazz(Long claszzId) {
		List<EnrolmentDTO> dtos = enrolmentRepository.findEnrolmentByClazzId(claszzId);
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByClazzAndStudent(Long clazzId, Long studentId) {
		List<EnrolmentDTO> dtos = enrolmentRepository.findEnrolmentByClazzIdAndStudentId(clazzId, studentId);
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByClazzAndInvoice(Long clazzId, Long invoiceId) {
		List<EnrolmentDTO> dtos = enrolmentRepository.findEnrolmentByClazzIdAndInvoiceId(clazzId, invoiceId);
		return dtos;
	}

	@Override
	public EnrolmentDTO addEnrolment(Enrolment enrolment) {
		Enrolment enrol = enrolmentRepository.save(enrolment);
		EnrolmentDTO dto = new EnrolmentDTO(enrol);
		return dto;
	}

	@Override
	public long checkCount() {
		long count = enrolmentRepository.count();
		return count;
	}

	@Override
	public List<Long> findClazzIdByStudentId(Long studentId) {
		List<Long> clazzIds = enrolmentRepository.findClazzIdByStudentId(studentId);
		return clazzIds;
	}

	@Override
	public List<Long> findEnrolmentIdByStudentId(Long studentId) {
		List<Long> enrolmentIds = enrolmentRepository.findEnrolmentIdByStudentId(studentId);
		return enrolmentIds;
	}

	@Override
	public Enrolment getEnrolment(Long id) {
		Enrolment enrol = enrolmentRepository.findById(id).get();
		return enrol;
	}

	@Override
	public Enrolment updateEnrolment(Enrolment enrolment, Long id) {
		// search by getId
		Enrolment existing = enrolmentRepository.findById(id).orElseThrow(() -> new EntityNotFoundException("Enrolment not found"));
		// Update info
		// StartWeek
		if(enrolment.getStartWeek()!=existing.getStartWeek()){
			existing.setStartWeek(enrolment.getStartWeek());
		}
		// EndWeek
		if(enrolment.getEndWeek()!=existing.getEndWeek()){
			existing.setEndWeek(enrolment.getEndWeek());
		}
		// cancelled
		if(enrolment.isCancelled()!=existing.isCancelled()){
			existing.setCancelled(enrolment.isCancelled());
		}
		// cancellationReason
		if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(enrolment.getCancellationReason()), StringUtils.defaultString(existing.getCancellationReason()))){
			existing.setCancellationReason(StringUtils.defaultString(enrolment.getCancellationReason()));
		}
		// info
		if(!StringUtils.equalsIgnoreCase(StringUtils.defaultString(enrolment.getInfo()), StringUtils.defaultString(existing.getInfo()))){
			existing.setInfo(StringUtils.defaultString(enrolment.getInfo()));
		}
		// update the existing record
		Enrolment updated = enrolmentRepository.save(existing);
		return updated;
	}

	@Override
	public void archiveEnrolment(Long id) {
		// 1. get Enrolment
		Enrolment enrol = enrolmentRepository.findById(id).get();
		// 2. set old to true
		enrol.setOld(true);
		// 3. save
		enrolmentRepository.save(enrol);		
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByInvoice(Long invoiceId) {
		List<EnrolmentDTO> dtos = enrolmentRepository.findEnrolmentByInvoiceId(invoiceId);
		return dtos;
	}

	@Override
	public List<Long> findEnrolmentIdByInvoiceId(Long invoiceId) {
		List<Long> enrolmentIds = enrolmentRepository.findEnrolmentIdByInvoiceId(invoiceId);
		return enrolmentIds;
	}
}
