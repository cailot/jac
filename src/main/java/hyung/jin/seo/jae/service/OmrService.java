package hyung.jin.seo.jae.service;

import java.io.IOException;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import hyung.jin.seo.jae.dto.StudentTestDTO;

public interface OmrService {

	// generate template
	void generateTemplate(String origin);

	// recongnise image
	void recogniseImage(String template, String image);

	// process the OMR form
	List<StudentTestDTO> processOmrForm(MultipartFile file) throws IOException;

}
