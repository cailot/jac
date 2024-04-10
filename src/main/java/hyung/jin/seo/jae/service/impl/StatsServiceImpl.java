package hyung.jin.seo.jae.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.repository.StudentRepository;
import hyung.jin.seo.jae.service.StatsService;

@Service
public class StatsServiceImpl implements StatsService {
	
	@Autowired
	StudentRepository studentRepository;

	@Override
	public List<StatsDTO> getRegistrationStats(String from, String to) {
		List<Object[]> stats = studentRepository.getRegistrationStats(from, to);
		// convert result to StatsDTO
		return null;
	}

}
