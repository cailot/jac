package hyung.jin.seo.jae.controller;

import java.text.ParseException;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.service.StatsService;
import hyung.jin.seo.jae.utils.JaeUtils;

@Controller
@RequestMapping("stats")
public class StatisticController {

	@Autowired
	private StatsService statsService;

	// search registration
	@PostMapping("/activeSearch")
	@ResponseBody
	public List<StatsDTO> searchActiveStats(@RequestParam String fromDate, @RequestParam String toDate) {
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
		List<StatsDTO> dtos = statsService.getActiveStats(start, end);
		// 3. return dtos
		return dtos;
	}

	// search inactive
	@PostMapping("/inactiveSearch")
	@ResponseBody
	public List<StatsDTO> searchInactiveStats(@RequestParam String fromDate, @RequestParam String toDate) {
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
		List<StatsDTO> dtos = statsService.getInactiveStats(start, end);
		// 3. return dtos
		return dtos;
	}

	// search invoice
	@PostMapping("/invoiceSearch")
	@ResponseBody
	public List<StatsDTO> searchInvoiceeStats(@RequestParam String fromDate, @RequestParam String toDate) {
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
		List<StatsDTO> dtos = statsService.getInactiveStats(start, end);
		// 3. return dtos
		return dtos;
	}

	// search active student with branch, grade, start/endDate
	@GetMapping("/activeStudent")
	@ResponseBody
	List<StudentDTO> listActiveStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate) {
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
		List<StudentDTO> dtos = statsService.listActiveStudent4Stats(branch, grade, start, end);
		return dtos;
	}

	// search inactive student with branch, grade, start/endDate
	@GetMapping("/inactiveStudent")
	@ResponseBody
	List<StudentDTO> listInactiveStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate) {
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
		List<StudentDTO> dtos = statsService.listInactiveStudent4Stats(branch, grade, start, end);
		return dtos;
	}

	// search invoice student with branch, grade, start/endDate
	@GetMapping("/invoiceStudent")
	@ResponseBody
	List<StudentDTO> listInvoiceStudents(@RequestParam("branch") String branch, 
									@RequestParam("grade") String grade,
									@RequestParam("start") String fromDate,
									@RequestParam("end") String toDate) {
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
		List<StudentDTO> dtos = statsService.listInactiveStudent4Stats(branch, grade, start, end);
		return dtos;
	}

}
