package hyung.jin.seo.jae.controller;

import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.model.OmrScanHistory;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.model.StudentTest;
import hyung.jin.seo.jae.model.Test;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.service.OmrManagementService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.dto.OmrSheetDTO;
import hyung.jin.seo.jae.dto.OmrStatsDTO;
import hyung.jin.seo.jae.dto.OmrUploadDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("omr")
public class OmrManagementController {

    @Autowired
    private StudentService studentService;

    @Autowired
    private ConnectedService connectedService;

    @Autowired
    private OmrManagementService omrManagementService;

    @Autowired
    private CodeService codeService;

    @Value("${jac.omr.endpoint}")
    private String omrEndpoint;

    @Autowired
    private RestTemplate restTemplate;

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
        List<MultipartFile> files = omrUploadDto.getFiles();

        // validate files are not empty
        if (files == null || files.isEmpty()) {
            redirectAttributes.addFlashAttribute(JaeConstants.ERROR, "Please select files to upload.");
            return "redirect:/omr/upload";
        }

        // validate all files are PDFs
        for (MultipartFile file : files) {
            String fileName = file.getOriginalFilename();
            String fileExtension = fileName != null ? fileName.substring(fileName.lastIndexOf(".") + 1) : "";
            if (!JaeConstants.OMR_FILE_PDF.equalsIgnoreCase(fileExtension)) {
                redirectAttributes.addFlashAttribute("error", "Only PDF files are allowed. Found invalid file: " + fileName);
                return "redirect:/omr/upload";
            }
        }

        // process omr images
        List<OmrSheetDTO> allResults = new ArrayList<>();
        
        try {
            for (MultipartFile file : files) {
                List<OmrSheetDTO> fileResults = previewOmr(branch, file);
                allResults.addAll(fileResults);
            }
        } catch (IOException e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute(JaeConstants.ERROR, "Failed to process OMR files.");
            return "redirect:/omr/upload";
        }

        // add the meta to flash attributes
        redirectAttributes.addFlashAttribute(JaeConstants.METADATA, omrUploadDto);
        // add the results to flash attributes
        redirectAttributes.addFlashAttribute(JaeConstants.RESULTS, allResults);
        // set success message
        redirectAttributes.addFlashAttribute(JaeConstants.SUCCESS, "Please review answer sheets and click next button at the bottom to proceed scanned image results.");
        return "redirect:/omr/upload";
    }

    // invoke omr preview api call to JAC-HUB server
    private List<OmrSheetDTO> previewOmr(String branch, MultipartFile file) throws IOException {
         // 1. complete endpoint url
         String url = omrEndpoint + "/preview";
         // 2. create headers
         HttpHeaders headers = new HttpHeaders();
         headers.setContentType(MediaType.MULTIPART_FORM_DATA);
         // 3. crearte the file part
         Resource fileResource = new ByteArrayResource(file.getBytes()){
             @Override
             public String getFilename() {
                 return file.getOriginalFilename();
             }
         };
         // 4. create the request entity
         MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
         body.add("branch", branch);
         body.add("file", fileResource);
         HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);
         // 5. send the request
         List<OmrSheetDTO> dtos = new ArrayList<>();
         ResponseEntity<List<OmrSheetDTO>> response = restTemplate.exchange(
             url,
             HttpMethod.POST,
             requestEntity,
             new ParameterizedTypeReference<List<OmrSheetDTO>>() {}
         );
         // 6. parse and return the response
         if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
             dtos = response.getBody();
         } else {
             System.out.println("Failed to fetch OMR preview: " + response.getStatusCode());
             return new ArrayList<>();
         }    
         // System.out.println(">>>>>>>>>>> " + dtos);
         // 7. return response;
         return dtos;  
    }

    // Save the OMR results
    @PostMapping("/saveResult")
    @ResponseBody
    public ResponseEntity<String> saveResults(@RequestBody SaveResultsRequest payload) {
        // 1. Extract metaDto and omrDtos from the request
        OmrUploadDTO metaDto = payload.getMetaDto();
        List<StudentTestDTO> omrDtos = payload.getOmrDtos();

        // 2. Calculate scores per each answer sheet
        for(StudentTestDTO dto : omrDtos) {
            double score = 0;
            Long testId = dto.getTestId();
            // get the correct answers
            int rightCnt = 0;
            int answerCnt = connectedService.getTestAnswerCount(testId);
            List<TestAnswerItem> correctAnswers = connectedService.getTestAnswerOnlyByTest(testId);
            List<Integer> studentAnswers = dto.getAnswers();
            for(int i=0; i<answerCnt; i++) {
                // find TestAnswerItem from List<TestAnswerItem> correctAnswers of which question number is (i+1)
                int questionNumber = i+1;
                Optional<TestAnswerItem> answerItem = correctAnswers.stream()
                                                        .filter(item -> item.getQuestion() == questionNumber)
                                                        .findFirst();
                if(answerItem.isPresent()) {
                    int correctAnswer = answerItem.get().getAnswer();
                    int studentAnswer = studentAnswers.get(i);
                    if(correctAnswer == studentAnswer) {
                        rightCnt++;
                    }
                }
            }
            // calculate the score
            score = (double)rightCnt / answerCnt * 100;
            
            // 3. Save the score to database
            // StudentTest save
            StudentTest studentTest = new StudentTest();
            Student student = studentService.getStudent(dto.getStudentId());
            studentTest.setStudent(student);
            Test test = connectedService.getTest(testId);
            studentTest.setTest(test);
            studentTest.setScore(score);
            // StudentTestAnswer save
            studentTest.setAnswers(studentAnswers);    
            connectedService.addStudentTest(studentTest);
            // Save scanned sheet
            OmrScanHistory history = new OmrScanHistory();
            history.setStudentId(dto.getStudentId());
            history.setTestId(testId);
            history.setBranch(student.getBranch());
            int testGroup = connectedService.getTestGroup(testId);
            history.setTestGroup(testGroup);
            omrManagementService.recordOmr(history);

        }
        
        // 5. Return a success response
        // if(isSaved) {
            return new ResponseEntity<>("OMR data successfully stored into database", HttpStatus.OK);
        // } else {
        //     return new ResponseEntity<>("OMR data failed to save", HttpStatus.EXPECTATION_FAILED);
        // }	
    }

    // get all branch list
    @GetMapping("/listBranch")
	@ResponseBody
	public List<SimpleBasketDTO> getBranchList() {
		List<SimpleBasketDTO> dtos = new ArrayList<>();
        try{
            dtos = codeService.loadBranch();
        }catch(Exception e) {
            e.printStackTrace();
        }
		return dtos;
	}

    // search omr stats per branch
	@PostMapping("/branchStats")
	@ResponseBody
	public List<OmrStatsDTO> searchActiveStats(@RequestParam String fromDate, @RequestParam String toDate) {
		// 1. get convert date format
		String start = null;
		try {
			start = JaeUtils.convertToyyyyMMddFormat(fromDate);
		} catch (ParseException e) {			
			start = "2000-01-01";
		}
		String end = null;
		try {
			end = JaeUtils.convertToyyyyMMddFormat(toDate);
		} catch (ParseException e){
			end = "2099-12-31";
		}
		// 2. get Stats
		List<OmrStatsDTO> dtos = omrManagementService.getOmrStats(start, end);
		// 3. return dtos
		return dtos;
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
	