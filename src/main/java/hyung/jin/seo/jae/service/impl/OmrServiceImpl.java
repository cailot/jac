package hyung.jin.seo.jae.service.impl;

import org.springframework.stereotype.Service;

import com.aspose.omr.GenerationResult;
import com.aspose.omr.OmrEngine;
import com.aspose.omr.RecognitionResult;
import com.aspose.omr.TemplateProcessor;

import hyung.jin.seo.jae.service.OmrService;

@Service
public class OmrServiceImpl implements OmrService {

	private OmrEngine engine;

	public OmrServiceImpl() {
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
	
}
