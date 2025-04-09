package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.OmrStatsDTO;
import hyung.jin.seo.jae.model.OmrScanHistory;

public interface OmrManagementService {

	// record OMR scan
	OmrScanHistory recordOmr(OmrScanHistory omrScan);	

	// get OMR scan stats
	List<OmrStatsDTO> getOmrStats(String from, String to);

}
