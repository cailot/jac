package hyung.jin.seo.jae.service;

import java.io.IOException;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.OmrStatsDTO;
import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.model.OmrScanHistory;

public interface OmrService {

	// generate template
	void generateTemplate(String origin);

	// recongnise image
	void recogniseImage(String template, String image);

	// preview the OMR
	List<StudentTestDTO> previewOmr(String branch, MultipartFile file) throws IOException;

	// record OMR scan
	OmrScanHistory recordOmr(OmrScanHistory omrScan);	

	// get OMR scan stats
	List<OmrStatsDTO> getOmrStats(String from, String to);
	// boolean saveOmr(OmrUploadDTO meta, List<StudentTestDTO> studentTestDTOs);

}
