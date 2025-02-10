package hyung.jin.seo.jae.service.impl;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.Buffer;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.aspose.omr.GenerationResult;
import com.aspose.omr.License;
import com.aspose.omr.OmrEngine;
import com.aspose.omr.RecognitionResult;
import com.aspose.omr.TemplateProcessor;

import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.service.OmrService;

@Service
public class OmrServiceImpl implements OmrService {

	private OmrEngine engine;

	private License omrLicense;

	public OmrServiceImpl() {
		// omrLicense = new License();
		// try {
		// 	omrLicense.setLicense("src/main/resources/omr/Aspose.OMR.Java.lic");
		// } catch (Exception e) {
		// 	e.printStackTrace();
		// }
		engine = new OmrEngine();
	}

	@Override
	public void generateTemplate(String origin) {
		// 1. create an instance of OmrEngine
		if(engine==null) return;

		// 2. generate template
		GenerationResult result = engine.generateTemplate(origin);

		// 3. save the result
		result.save("target", "jac");
	}

	@Override
	public void recogniseImage(String template, String image) {
		// 1. create an instance of OmrEngine
		if(engine==null) return;

		try {
			// 2. load template
			TemplateProcessor processor = engine.getTemplateProcessor(template);

			// 3. recognize image
			RecognitionResult result = processor.recognizeImage(image);

			// 4. save the result
			String resultCsv = result.getCsv();

			// 5. print the result
			System.out.println(resultCsv);
		
		
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}

	@Override
	public List<StudentTestDTO> processOmrForm(MultipartFile file) throws IOException {
		// 1. create List
		List<StudentTestDTO> saved = new ArrayList<>();
		
		// 2. convert MultipartFile to Stream
		BufferedImage image = ImageIO.read(file.getInputStream());

		// 3. check if it's a single page or multiple pages
		if(isSinglePage(image)) {
			// 4. if it's a single page, process the single page
			StudentTestDTO student = new StudentTestDTO();
			// student.setStudentId("1234");
			// student.setStudentName("John Doe");
			// student.setScore(100);
			saved.add(student);
		} else {
			// 5. if it's multiple pages, process the multiple pages
			List<BufferedImage> pages = splitPages(image);
			for(BufferedImage page : pages) {
				StudentTestDTO student = new StudentTestDTO();
				// student.setStudentId("1234");
				// student.setStudentName("John Doe");
				// student.setScore(100);
				saved.add(student);
			}			
		}
		// 4. return the list
		return saved;
	}

	// check if it's a single page
	private boolean isSinglePage(BufferedImage image) {
		// 1. check if it's a single page

		return true;
	}

	// split pages
	private List<BufferedImage> splitPages(BufferedImage image) {
        List<BufferedImage> pages = new ArrayList<>();
        int pageHeight = image.getWidth(); // Assuming square pages
        int numPages = image.getHeight() / pageHeight;

        for (int i = 0; i < numPages; i++) {
            pages.add(image.getSubimage(0, i * pageHeight, image.getWidth(), pageHeight));
        }

        return pages;
    }

	
}
