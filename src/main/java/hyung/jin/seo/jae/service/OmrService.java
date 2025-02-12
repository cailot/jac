package hyung.jin.seo.jae.service;

import java.io.IOException;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.OmrUploadDTO;
import hyung.jin.seo.jae.dto.StudentTestDTO;

public interface OmrService {

	// generate template
	void generateTemplate(String origin);

	// recongnise image
	void recogniseImage(String template, String image);

	// preview the OMR
	List<StudentTestDTO> previewOmr(String branch, MultipartFile file) throws IOException;

	// save the OMR
	boolean saveOmr(OmrUploadDTO meta, List<StudentTestDTO> studentTestDTOs);

}
