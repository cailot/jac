package hyung.jin.seo.jae.service.impl;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.nio.Buffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.aspose.omr.GenerationResult;
import com.aspose.omr.License;
import com.aspose.omr.OmrEngine;
import com.aspose.omr.RecognitionResult;
import com.aspose.omr.TemplateProcessor;

import hyung.jin.seo.jae.dto.OmrUploadDTO;
import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.service.OmrService;
import javassist.bytecode.ByteArray;

@Service
public class OmrServiceImpl implements OmrService {

	private OmrEngine engine;

	private License omrLicense;

	@Value("${output.directory}")
    private String outputDir;

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
	public List<StudentTestDTO> previewOmr(String branch, MultipartFile file) throws IOException {
		// 1. create List
		List<StudentTestDTO> processed = new ArrayList<>();
		
		// 2. split pages
		PDDocument document = PDDocument.load(file.getInputStream());
		PDFRenderer renderer = new PDFRenderer(document);
		int numPages = document.getNumberOfPages();

		// Path tempDir = Files.createTempDirectory("omr_jpg_");
		Path tempDirPath = Path.of(outputDir);


		for(int i=0; i<numPages; i++) {
			// render the PDF page to an image with 100 DPI JPG format
			BufferedImage image = renderer.renderImageWithDPI(i, 100, ImageType.RGB);
			// process the image







			// save the result into temp folder
			File tempFile = Files.createTempFile(tempDirPath, branch + "_" + (i + 1) + "_", ".jpg").toFile();

			ImageIO.write(image, "jpg", tempFile);
			StudentTestDTO dto = new StudentTestDTO();
			dto.setFileName(tempFile.getName());
			System.out.println("Saved: " + tempFile.getName() + " , size : " + tempFile.length());

		}
		document.close();



		// 3. return the list
		return processed;
	}

	@Override
	public void saveOmr(OmrUploadDTO meta, List<StudentTestDTO> studentTestDTOs) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("Unimplemented method 'saveOmr'");
	}

	
}
