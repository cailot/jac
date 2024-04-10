package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.StatsDTO;

public interface StatsService {

	// search registration stats
	List<StatsDTO> getRegistrationStats(String from, String to);	
}
