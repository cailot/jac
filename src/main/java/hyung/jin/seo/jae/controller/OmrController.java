package hyung.jin.seo.jae.controller;

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
		// validate file extension is jpg or jpeg
		if (!JaeConstants.OMR_FILE_JPG.equalsIgnoreCase(fileExtension) && !JaeConstants.OMR_FILE_JPEG.equalsIgnoreCase(fileExtension)) {
			redirectAttributes.addFlashAttribute("error", "Only JPG and JPEG files are allowed.");
			return "redirect:/omr/upload";
		}
	
		// process omr image

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
			results.add(result);
		}
		return results;
	}

	@PostMapping("/saveResult")
    @ResponseBody
	public ResponseEntity<String> saveResults(@RequestBody SaveResultsRequest payload) {
    // public ResponseEntity<String> saveResults(@RequestBody Map<String, Object> payload) {
        // Extract metaDto and omrDtos from the request
        OmrUploadDTO metaDto = payload.getMetaDto();
        List<StudentTestDTO> omrDtos = payload.getOmrDtos();

        // Save to the database

        // Log the received data for debugging
        System.out.println("Received metaDto: " + metaDto);
        System.out.println("Received omrDtos: " + omrDtos);



		// Return a failed response
		// return new ResponseEntity<>("OMR data successfully saved", HttpStatus.EXPECTATION_FAILED);


        // Return a success response
        return new ResponseEntity<>("OMR data successfully saved", HttpStatus.OK);
		
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
	