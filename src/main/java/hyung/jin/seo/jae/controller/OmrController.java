package hyung.jin.seo.jae.controller;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import hyung.jin.seo.jae.dto.StudentTestDTO;
import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.model.Student;
import hyung.jin.seo.jae.model.StudentTest;
import hyung.jin.seo.jae.model.Test;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.service.ConnectedService;
import hyung.jin.seo.jae.service.OmrService;
import hyung.jin.seo.jae.service.StudentService;
import hyung.jin.seo.jae.dto.HomeworkDTO;
import hyung.jin.seo.jae.dto.OmrStatsDTO;
import hyung.jin.seo.jae.dto.OmrUploadDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("omr")
public class OmrController {

    @Autowired
    private StudentService studentService;

    @Autowired
    private ConnectedService connectedService;

    @Autowired
    private OmrService omrService;

    @Autowired
    private CodeService codeService;

    @Value("${output.directory}")
    private String outputDir;


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

        // create omr results 	
        List<StudentTestDTO> results = new ArrayList<>();
        
        try {
            results = omrService.previewOmr(branch, file);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        // create omr results 	
        // List<StudentTestDTO> results = processOmrImage();
        // add the meta to flash attributes
        redirectAttributes.addFlashAttribute(JaeConstants.METADATA, omrUploadDto);
        // add the results to flash attributes
        redirectAttributes.addFlashAttribute(JaeConstants.RESULTS, results);
        // set scuccess message
        redirectAttributes.addFlashAttribute(JaeConstants.SUCCESS, "Please review answer sheets and click next button at the bottom to proceed scanned image result.");
        return "redirect:/omr/upload";
    }



    ///////////// test......
    private List<StudentTestDTO> processOmrImage() {
        
        List<StudentTestDTO> results = new ArrayList<>();
        for(int i=1; i<=2; i++) {
            StudentTestDTO result = new StudentTestDTO();
            // 3~6 random number
            int testId = new Random().nextInt(4) + 3;
            result.setTestId((long)testId);
            result.setTestName("Mega Test");
            Long studentId = 11301580L;//(long)new Random().nextInt(50000);
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
        }
        
        // 4. remove all files of which file name starts with 'branch' in the output directory
        boolean isSaved = false;
        String branch = metaDto.getBranch();
        File outputDirFile = new File(outputDir);
		File[] files = outputDirFile.listFiles();
		for(File file : files) {
			if(file.getName().startsWith(branch+"_")) {
				file.delete();
			}
		}
		isSaved = true;


        // 5. Return a success response
        if(isSaved) {
            return new ResponseEntity<>("OMR data successfully stored into database", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("OMR data failed to save", HttpStatus.EXPECTATION_FAILED);
        }		
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
		List<OmrStatsDTO> dtos = dummy();//statsService.getActiveStats(start, end, branch);

		// 3. return dtos
		return dtos;
	}


    private List<OmrStatsDTO> dummy() {
        List<OmrStatsDTO> dtos = new ArrayList<>();
        for(int i=12; i<=34; i++) {
            OmrStatsDTO dto = new OmrStatsDTO();
            dto.setBranch("" + i);
            // random number
            int ran1 = (new Random().nextInt(1) + 10);
            int ran2 = (new Random().nextInt(1) + 15);
            int ran3 = (new Random().nextInt(1) + 20);
            int ran4 = (new Random().nextInt(1) + 25);
            dto.setMega(ran1);
            dto.setRevision(ran2);
            dto.setAcer(ran3);
            dto.setEdu(ran4);
            dtos.add(dto);
        }
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
	