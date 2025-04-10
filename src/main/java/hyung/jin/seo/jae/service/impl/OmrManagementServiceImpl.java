package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import hyung.jin.seo.jae.dto.OmrStatsDTO;
import hyung.jin.seo.jae.model.OmrScanHistory;
import hyung.jin.seo.jae.repository.OmrScanHistoryRepository;
import hyung.jin.seo.jae.service.OmrManagementService;

@Service
public class OmrManagementServiceImpl implements OmrManagementService {

	@Autowired
	private OmrScanHistoryRepository omrScanHistoryRepository;

	@Override
	@Transactional
	public OmrScanHistory recordOmr(OmrScanHistory omr) {
		OmrScanHistory saved = omrScanHistoryRepository.save(omr);
		return saved;
	}

	@Override
	public List<OmrStatsDTO> getOmrStats(String from, String to) {
		List<OmrStatsDTO> stats = new ArrayList<>();
		// convert result to StatsDTO
		List<Object[]> objects = omrScanHistoryRepository.getOmrStats(from, to);
		for(Object[] object : objects){
			OmrStatsDTO dto = new OmrStatsDTO(object);
			stats.add(dto);
		}
		return stats;
	}
	
}
