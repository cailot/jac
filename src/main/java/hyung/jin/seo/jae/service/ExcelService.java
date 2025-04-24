package hyung.jin.seo.jae.service;

import java.util.List;
import hyung.jin.seo.jae.dto.StudentTestSummaryDTO;

public interface ExcelService {

	// generate test summary excel file
	byte[] generateTestSummaryExcel(List<StudentTestSummaryDTO> data);
}
