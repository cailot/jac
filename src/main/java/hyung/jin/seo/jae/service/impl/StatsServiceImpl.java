package hyung.jin.seo.jae.service.impl;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.StatsDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.repository.StudentRepository;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.service.StatsService;

@Service
public class StatsServiceImpl implements StatsService {
	
	@Autowired
	StudentRepository studentRepository;

	@Autowired
	CycleService cycleService;

	@Override
	public List<StatsDTO> getActiveStats(String from, String to) {
		List<Object[]> objects = studentRepository.getActiveStudentStats(from, to);
		// convert result to StatsDTO
		List<StatsDTO> dtos = new ArrayList<>();
		for(Object[] object : objects){
			StatsDTO dto = new StatsDTO(object);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<StatsDTO> getInactiveStats(String from, String to) {
		List<Object[]> objects = studentRepository.getInactiveStudentStats(from, to);
		// convert result to StatsDTO
		List<StatsDTO> dtos = new ArrayList<>();
		for(Object[] object : objects){
			StatsDTO dto = new StatsDTO(object);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<StatsDTO> getInvoiceStats(String from, String to) {
		List<Object[]> objects = studentRepository.getInvoiceStudentStats(from, to);
		// convert result to StatsDTO
		List<StatsDTO> dtos = new ArrayList<>();
		for(Object[] object : objects){
			StatsDTO dto = new StatsDTO(object);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<StudentDTO> listActiveStudent4Stats(String branch, String grade, String from, String to) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
			LocalDate fromDate = LocalDate.parse(from, formatter);
			LocalDate toDate = LocalDate.parse(to, formatter);
			dtos = studentRepository.listActiveStudent4Stats(branch, grade, fromDate, toDate);
		}catch(Exception e){
			System.out.println("No Student found");
		}
		return dtos;
	}

	@Override
	public List<StudentDTO> listInactiveStudent4Stats(String branch, String grade, String from, String to) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
			LocalDate fromDate = LocalDate.parse(from, formatter);
			LocalDate toDate = LocalDate.parse(to, formatter);
			dtos = studentRepository.listInactiveStudent4Stats(branch, grade, fromDate, toDate);
		}catch(Exception e){
			System.out.println("No Student found");
		}
		return dtos;
	}


	@Override
	public List<StudentDTO> listInvoiceStudent4Stats(String branch, String grade, String from, String to) {
		List<StudentDTO> dtos = new ArrayList<>();
		try{
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
			LocalDate fromDate = LocalDate.parse(from, formatter);
			LocalDate toDate = LocalDate.parse(to, formatter);
			dtos = studentRepository.listInvoiceStudent4Stats(branch, grade, fromDate, toDate);
		}catch(Exception e){
			System.out.println("No Student found");
		}
		return dtos;
	}

	@Override
	public List<StudentDTO> listOverdueStudent4Stats(String branch, String grade) {
		List<StudentDTO> dtos = new ArrayList<>();
		int year = cycleService.academicYear();
		int week = cycleService.academicWeeks();
		try{
			dtos = studentRepository.listOverdueStudent4Stats(branch, grade, year, week);
		}catch(Exception e){
			System.out.println("No Student found");
		}
		return dtos;
	}
}
