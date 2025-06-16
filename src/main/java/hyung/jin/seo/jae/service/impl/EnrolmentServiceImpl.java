package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import javax.persistence.EntityNotFoundException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.model.Enrolment;
import hyung.jin.seo.jae.repository.EnrolmentRepository;
import hyung.jin.seo.jae.repository.InvoiceRepository;
import hyung.jin.seo.jae.service.EnrolmentService;

@Service
public class EnrolmentServiceImpl implements EnrolmentService {

	@Autowired
	private EnrolmentRepository enrolmentRepository;

	@Autowired
	private InvoiceRepository invoiceRepository;

	@Override
	public List<EnrolmentDTO> allEnrolments() {
		List<Enrolment> enrols = new ArrayList<>();
		try {
			enrols = enrolmentRepository.findAll();
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		List<EnrolmentDTO> dtos = new ArrayList<>();
		for (Enrolment enrol : enrols) {
			EnrolmentDTO dto = new EnrolmentDTO(enrol);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByStudent(Long studentId) {
		List<Object[]> objects = new ArrayList<>();
		try {
			objects = enrolmentRepository.findEnrolmentByStudentId(studentId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		// enrolmentRepository.findEnrolmentByStudentId(studentId);
		List<EnrolmentDTO> dtos = new ArrayList<EnrolmentDTO>();
		for (Object[] object : objects) {
			EnrolmentDTO dto = new EnrolmentDTO(object);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByClazz(Long claszzId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findEnrolmentByClazzId(claszzId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByClazzAndStudent(Long clazzId, Long studentId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findEnrolmentByClazzIdAndStudentId(clazzId, studentId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByClazzAndInvoice(Long clazzId, Long invoiceId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findEnrolmentByClazzIdAndInvoiceId(clazzId, invoiceId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
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
		List<Long> clazzIds = new ArrayList<>();
		try {
			clazzIds = enrolmentRepository.findClazzIdByStudentId(studentId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return clazzIds;
	}

	@Override
	public List<Long> findEnrolmentIdByStudentId(Long studentId) {
		List<Long> enrolmentIds = new ArrayList<>();
		try {
			enrolmentIds = enrolmentRepository.findEnrolmentIdByStudentId(studentId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return enrolmentIds;
	}

	@Override
	public Enrolment getEnrolment(Long id) {
		Enrolment enrol = null;
		try {
			enrol = enrolmentRepository.findById(id).get();
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return enrol;
	}

	@Override
	public EnrolmentDTO getActiveEnrolment(Long id) {
		EnrolmentDTO enrol = null;
		try {
			enrol = enrolmentRepository.findActiveEnrolmentById(id);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return enrol;
	}

	@Override
	public Enrolment updateEnrolment(Enrolment enrolment, Long id) {
		// search by getId
		Enrolment existing = enrolmentRepository.findById(id)
				.orElseThrow(() -> new EntityNotFoundException("Enrolment not found"));
		// Update info
		// StartWeek
		if (enrolment.getStartWeek() != existing.getStartWeek()) {
			existing.setStartWeek(enrolment.getStartWeek());
		}
		// EndWeek
		if (enrolment.getEndWeek() != existing.getEndWeek()) {
			existing.setEndWeek(enrolment.getEndWeek());
		}
		// cancelled
		if (enrolment.isCancelled() != existing.isCancelled()) {
			existing.setCancelled(enrolment.isCancelled());
		}
		// cancellationReason
		if (!StringUtils.equalsIgnoreCase(StringUtils.defaultString(enrolment.getCancellationReason()),
				StringUtils.defaultString(existing.getCancellationReason()))) {
			existing.setCancellationReason(StringUtils.defaultString(enrolment.getCancellationReason()));
		}
		// credit
		if (enrolment.getCredit() != existing.getCredit()) {
			existing.setCredit(enrolment.getCredit());
		}
		// discount
		if (enrolment.getDiscount() != existing.getDiscount()) {
			existing.setDiscount(enrolment.getDiscount());
		}
		// info
		if (!StringUtils.equalsIgnoreCase(StringUtils.defaultString(enrolment.getInfo()),
				StringUtils.defaultString(existing.getInfo()))) {
			existing.setInfo(StringUtils.defaultString(enrolment.getInfo()));
		}
		// update the existing record
		Enrolment updated = enrolmentRepository.save(existing);
		return updated;
	}

	@Override
	public void archiveEnrolment(Long id) {
		// 1. get Enrolment
		Enrolment enrol = null;
		try {
			enrol = enrolmentRepository.findById(id).get();
			// 2. set old to true
			enrol.setOld(true);
			// 3. save
			enrolmentRepository.save(enrol);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByInvoice(Long invoiceId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findEnrolmentByInvoiceId(invoiceId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

	@Override
	public List<Enrolment> getEnrolmentByInvoice(Long invoiceId) {
		List<Enrolment> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.getEnrolmentByInvoiceId(invoiceId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByInvoiceHistory(Long invoiceHistoryId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findEnrolmentByInvoiceHistroyId(invoiceHistoryId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

	@Override
	public List<Long> findEnrolmentIdByInvoiceId(Long invoiceId) {
		List<Long> enrolmentIds = new ArrayList<>();
		try {
			enrolmentIds = enrolmentRepository.findEnrolmentIdByInvoiceId(invoiceId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return enrolmentIds;
	}

	@Override
	public Long findLatestInvoiceIdByStudent(Long studentId) {
		Long invoiceId = 0L;
		try {
			// invoiceId = enrolmentRepository.findLatestInvoiceIdByStudentId(studentId);
			invoiceId = invoiceRepository.findLatestInvoiceIdByStudentIdPattern(studentId);
		} catch (Exception e) {
			System.out.println("No invoice found");
		}
		return invoiceId;
	}

	@Override
	public Long find2ndLatestInvoiceIdByStudent(Long studentId) {
		Long invoiceId = 0L;
		try {
			// invoiceId = enrolmentRepository.findSecondLatestInvoiceIdByStudentId(studentId);
			invoiceId = invoiceRepository.findSecondLatestInvoiceIdByStudentIdPattern(studentId);
		} catch (Exception e) {
			System.out.println("No invoice found");
		}
		return invoiceId;
	}

	@Override
	public Long find3rdLatestInvoiceIdByStudent(Long studentId) {
		Long invoiceId = 0L;
		try {
			// invoiceId = enrolmentRepository.findThirdLatestInvoiceIdByStudentId(studentId);
			invoiceId = invoiceRepository.findThirdLatestInvoiceIdByStudentIdPattern(studentId);
		} catch (Exception e) {
			System.out.println("No invoice found");
		}
		return invoiceId;
	}

	@Override
	public List<EnrolmentDTO> findEnrolmentByInvoiceAndStudent(Long invoiceId, Long studentId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findEnrolmentByInvoiceIdAndStudentId(invoiceId, studentId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

	@Override
	public List<Enrolment> findEnrolmentMigrationByInvoiceAndStudent(String invoiceId, Long studentId) {
		List<Enrolment> enrolments = new ArrayList<>();
		try {
			enrolments = enrolmentRepository.findMigratedEnrolmentByInvoiceIdAndStudentId(invoiceId, studentId);
		} catch (Exception e) {
			System.out.println("No enrolment found: " + e.getMessage());
		}
		return enrolments;
	}

	@Override
	public List<Long> findInvoiceIdByStudent(Long studentId) {
		List<Long> invoiceIds = new ArrayList<>();
		try {
			// invoiceIds = enrolmentRepository.findInvoiceIdByStudentId(studentId);
			invoiceIds = invoiceRepository.findInvoiceIdsByStudentIdPattern(studentId);
		} catch (Exception e) {
			System.out.println("No invoice found");
		}
		return invoiceIds;
	}

	@Override
	public List<Long> findStudentIdByClazzId(Long clazzId) {
		List<Long> studentIds = new ArrayList<>();
		try {
			studentIds = enrolmentRepository.findStudentIdByClazzId(clazzId);
		} catch (Exception e) {
			System.out.println("No student found");
		}
		return studentIds;
	}

	@Override
	public Integer getStudentNumberByClazz(Long clazzId, int week) {
		Integer number = 0;
		try {
			number = enrolmentRepository.getStudentNumberByClazzId(clazzId, week);
		} catch (Exception e) {
			System.out.println("No student found");
		}
		return number;
	}

	@Override
	public Long findClazzId4OnlineSession(long studentId, int year, int week) {
		Optional<Long> optionalId = null;
		Long clazzId = 0L;
		try{
			optionalId = enrolmentRepository.findClazzId4fOnlineSession(studentId, year, week);
			clazzId = optionalId.orElse(0L);
		}catch(Exception e){
			System.out.println("No class found");
		}
		return clazzId;
	}

	@Override
	public Integer isStudentAttendOnlineClazz(long studentId, long clazzId, int week) {
		Integer number = 0;
		try {
			number = enrolmentRepository.isExistByStudentIdAndClazzIdAndWeek(studentId, clazzId, week);
		} catch (Exception e) {
			System.out.println("No student found");
		}
		return number;
	}

	@Override
	public List<Integer> findStartEndWeekByInvoiceNClazz(long invoiceId, long clazzId) {
		List<Integer> interval = new ArrayList<>();
		int start = 0;
		int end = 0;
		List<Object[]> weeks = enrolmentRepository.findStartAndEndWeeksByLastInvoice(invoiceId, clazzId);
		for (Object[] week : weeks) {
			Integer startWeek = (Integer) week[0];
			start = startWeek;
			Integer endWeek = (Integer) week[1];
			end = endWeek;
		}
		interval.add(start);
		interval.add(end);
		return interval;
	}

	@Override
	@Transactional
	public void deleteEnrolment(Long id) {
		try {
			enrolmentRepository.deleteById(id);
		} catch (Exception e) {
			throw new RuntimeException("Failed to delete enrolment: " + e.getMessage(), e);
		}
	}

	@Override
	public List<EnrolmentDTO> findAllEnrolmentByInvoiceId(Long invoiceId) {
		List<EnrolmentDTO> dtos = new ArrayList<>();
		try {
			dtos = enrolmentRepository.findAllEnrolmentByInvoiceId(invoiceId);
		} catch (Exception e) {
			System.out.println("No enrolment found");
		}
		return dtos;
	}

}
