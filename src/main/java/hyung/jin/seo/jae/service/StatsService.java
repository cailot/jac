package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.dto.StudentDTO;

public interface StatsService {

	// search active student stats
	List<StatsDTO> getActiveStats(String from, String to);

	// search active branch student stats
	List<StatsDTO> getActiveStats(String from, String to, String branch);

	// search inactive student stats
	List<StatsDTO> getInactiveStats(String from, String to);

	// search invoice student stats
	List<StatsDTO> getInvoiceStats(String from, String to);

	// list active students by branch, grade, date & active
	List<StudentDTO> listActiveStudent4Stats(String branch, String grade, String from, String to);

	// list inactive students by branch, grade, date & active
	List<StudentDTO> listInactiveStudent4Stats(String branch, String grade, String from, String to);

	// list invoice students by branch, grade, date & active
	List<StudentDTO> listInvoiceStudent4Stats(String branch, String grade, String from, String to);

	// list overdue students by branch & grade
	List<StudentDTO> listOverdueStudent4Stats(String branch, String grade);

}
