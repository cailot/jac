package hyung.jin.seo.jae.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.service.OmrService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.dto.OmrUploadDTO;
import hyung.jin.seo.jae.utils.JaeConstants;

@Controller
@RequestMapping("omr")
public class OmrController {

	@Autowired
	private StudentService studentService;

	@Autowired
	private ConnectedService connectedService;

    @Autowired
    private OmrService omrService;

	/**
     * Display the OMR upload form
     */
    @GetMapping("/upload")
    public String showUploadForm(Model model) {
        model.addAttribute("omrUploadDto", new OmrUploadDTO());
        return "omrUploadPage";
    }

	/**
     * Handle the form submission
     */
    @PostMapping("/upload")
    public String handleFileUpload(@ModelAttribute OmrUploadDTO omrUploadDto,
                                   RedirectAttributes redirectAttributes) {

        // extract form data
        String state = omrUploadDto.getState();
        String branch = omrUploadDto.getBranch();
        String testGroup = omrUploadDto.getTestGroup();
        String grade = omrUploadDto.getGrade();
        String volume = omrUploadDto.getVolume();
		System.out.println("state: " + state + ", branch: " + branch + ", testGroup: " + testGroup + ", grade: " + grade + ", volume: " + volume);
        MultipartFile file = omrUploadDto.getFile();

        // validate file is not empty
        if (file.isEmpty()) {
            redirectAttributes.addFlashAttribute(JaeConstants.ERROR, "Please select a file to upload.");
            return "redirect:/omr/upload";
        }
		String fileName = file.getOriginalFilename();
		String fileExtension =  fileName !=null ?  fileName.substring(fileName.lastIndexOf(".") + 1) : "";
		// validate file extension is pdf
		if (!JaeConstants.OMR_FILE_PDF.equalsIgnoreCase(fileExtension)) {
			redirectAttributes.addFlashAttribute("error", "Only PDF file is allowed.");
			return "redirect:/omr/upload";
		}
	
		// process omr image


        try {
            omrService.previewOmr(branch, file);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }







		// create omr results 	
		List<StudentTestDTO> results = processOmrImage();
		// add the meta to flash attributes
		redirectAttributes.addFlashAttribute(JaeConstants.METADATA, omrUploadDto);
		// add the results to flash attributes
		redirectAttributes.addFlashAttribute(JaeConstants.RESULTS, results);
		// set scuccess message
		redirectAttributes.addFlashAttribute(JaeConstants.SUCCESS, "Please click next button at the bottom to proceed scanned image result.");
        return "redirect:/omr/upload";
	}




	private List<StudentTestDTO> processOmrImage() {
		
		List<StudentTestDTO> results = new ArrayList<>();
		for(int i=1; i<=5; i++) {
			StudentTestDTO result = new StudentTestDTO();
			result.setTestId(3L);

			// String testName = connectedService.getTestTypeName(result.getTestId());

			result.setTestName("Mega Test");
			Long studentId = (long)new Random().nextInt(50000);
			result.setStudentId(studentId);
			
			// String studentName = studentService.getStudentName(studentId);
			
			result.setStudentName("David Hwang");
			for(int j=0; j<40; j++) {
				// generate radom number from 0 to 4
				int radom = new Random().nextInt(5);
				result.addAnswer(radom);
			}
            result.setFileName(new Random().nextInt(1000) + ".jpg");
			results.add(result);
		}
		return results;
	}

    // Save the OMR results
	@PostMapping("/saveResult")
    @ResponseBody
	public ResponseEntity<String> saveResults(@RequestBody SaveResultsRequest payload) {
        // 1. Extract metaDto and omrDtos from the request
        OmrUploadDTO metaDto = payload.getMetaDto();
        List<StudentTestDTO> omrDtos = payload.getOmrDtos();

        // 2. Save to the database
        boolean isSaved = omrService.saveOmr(metaDto, omrDtos);

        // 3. Return a success response
        if(isSaved) {
            return new ResponseEntity<>("OMR data successfully saved", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("OMR data failed to save", HttpStatus.EXPECTATION_FAILED);
        }		
    }

	// DTO class to handle the request
    public static class SaveResultsRequest {
        private OmrUploadDTO metaDto;
        private List<StudentTestDTO> omrDtos;

        // Getters and setters
        public OmrUploadDTO getMetaDto() {
            return metaDto;
        }

        public void setMetaDto(OmrUploadDTO metaDto) {
            this.metaDto = metaDto;
        }

        public List<StudentTestDTO> getOmrDtos() {
            return omrDtos;
        }

        public void setOmrDtos(List<StudentTestDTO> omrDtos) {
            this.omrDtos = omrDtos;
        }
    }
}
	