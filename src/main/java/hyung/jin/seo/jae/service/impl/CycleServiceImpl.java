package hyung.jin.seo.jae.service.impl;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.CycleDTO;
import hyung.jin.seo.jae.model.Cycle;
import hyung.jin.seo.jae.repository.CycleRepository;
import hyung.jin.seo.jae.service.CycleService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Service
public class CycleServiceImpl implements CycleService {
	

	private static DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    
	private List<CycleDTO> cycles;

	@Autowired
	private CycleRepository cycleRepository;

	@Autowired
	private ConfigurableApplicationContext applicationContext;

	
	@Override
	public long checkCount() {
		long count = cycleRepository.count();
		return count;
	}

	@Override
	public List<CycleDTO> allCycles() {
		List<Cycle> cycles = cycleRepository.findAll();
		List<CycleDTO> dtos = new ArrayList<>();
		for(Cycle cycle: cycles){
			CycleDTO dto = new CycleDTO(cycle);
			dtos.add(dto);
		}
		return dtos;
	}	



	// return academic year.
	// for example, today is 17/04/2023 while academic year in 2023 is 11/06/2023 then it will return '2022'
	// however, if today is 17/09/2023, it will return '2023' as academic calendar date (11/06/2023) already passed.
	@Override
	public int academicYear() {
		if(cycles==null) {
			cycles = (List<CycleDTO>) applicationContext.getBean(JaeConstants.ACADEMIC_CYCLES);
		}
		int year = 0;
		for(CycleDTO dto: cycles) {
			String startDate = dto.getStartDate();
			String endDate = dto.getEndDate();
			try {
				if(JaeUtils.checkIfTodayBelongTo(startDate, endDate)) {
					year =  Integer.parseInt(dto.getYear());
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		return year;
	}

	@Override
	public int academicYear(String date) {
		if(cycles==null) {
			cycles = (List<CycleDTO>) applicationContext.getBean(JaeConstants.ACADEMIC_CYCLES);
		}
		int year = 0;
		for(CycleDTO dto: cycles) {
			String startDate = dto.getStartDate();
			String endDate = dto.getEndDate();
			try {
				if(JaeUtils.checkIfTodayBelongTo(date, startDate, endDate)) {
					year =  Integer.parseInt(dto.getYear());
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		return year;
	}

	// return weeks number based on academic year
	@Override
	public int academicWeeks(){
		LocalDate today = LocalDate.now();
		int currentYear = today.getYear();
		int academicYear = academicYear();
		int weeks = 0;
		String academicDate = "";
		String vacationStartDate = "";
		String vacationEndDate = "";
		if(currentYear==academicYear) { // from June to December
			// bring academic start date
			for(CycleDTO dto : cycles){
				if(dto.getYear().equals(Integer.toString(academicYear))){
					academicDate = dto.getStartDate();
					vacationStartDate = dto.getVacationStartDate();
					break;
				}
			}
			// convert to LocalDate
			LocalDate academicStart = LocalDate.parse(academicDate);
			LocalDate vacationStart = LocalDate.parse(vacationStartDate);
			// compare today's date with vacation start date
			if(today.isBefore(vacationStart)) { // simply calculate weeks
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, today);
			}else { // set weeks as xmas week
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, vacationStart);
			}
		}else { // from January to June
			// simply calculate since last year starting date - 3 weeks (xmas holidays)
			// bring academic start date
			for(CycleDTO dto : cycles){
				if(dto.getYear().equals(Integer.toString(academicYear))){
					academicDate = dto.getStartDate();
					vacationStartDate = dto.getVacationStartDate();
					vacationEndDate = dto.getVacationEndDate();
					break;
				}
			}
			LocalDate academicStart = LocalDate.parse(academicDate);
			LocalDate vacationStart = LocalDate.parse(vacationStartDate);
			LocalDate vacationEnd = LocalDate.parse(vacationEndDate);
			// compare today's date with vacation end date
			if(today.isBefore(vacationEnd)) { // until vacation start date
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, vacationStart);
			}else{
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, today) - 3; // 3 weeks for xmas holidays
			}		
		}
		return (weeks+1); // calculation must start from 1 not 0
	}


	// return weeks number based on academic year
	@Override
	public int academicWeeks(String date){
		// if not formatted date passed, return 0
		if(!JaeUtils.isValidDateFormat(date)) return 0;
		LocalDate specificDate = LocalDate.parse(date, DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		int currentYear = specificDate.getYear();
		int academicYear = academicYear(date);
		int weeks = 0;
		String academicDate = "";
		String vacationStartDate = "";
		String vacationEndDate = "";
		if(currentYear==academicYear) { // from June to December
			// bring academic start date
			for(CycleDTO dto : cycles){
				if(dto.getYear().equals(Integer.toString(academicYear))){
					academicDate = dto.getStartDate();
					vacationStartDate = dto.getVacationStartDate();
				}
			}
			// convert to LocalDate
			LocalDate academicStart = LocalDate.parse(academicDate);
			LocalDate vacationStart = LocalDate.parse(vacationStartDate);
			// compare today's date with vacation start date
			if(specificDate.isBefore(vacationStart)) { // simply calculate weeks
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, specificDate);
			}else { // set weeks as xmas week
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, vacationStart);
			}
		}else { // from January to June
			// simply calculate since last year starting date - 3 weeks (xmas holidays)
			// bring academic start date
			for(CycleDTO dto : cycles){
				if(dto.getYear().equals(Integer.toString(academicYear))){
					academicDate = dto.getStartDate();
					vacationStartDate = dto.getVacationStartDate();
					vacationEndDate = dto.getVacationEndDate();
				}
			}
			// convert to LocalDate
			LocalDate academicStart = LocalDate.parse(academicDate);
			LocalDate vacationStart = LocalDate.parse(vacationStartDate);
			LocalDate vacationEnd = LocalDate.parse(vacationEndDate);
			// compare today's date with vacation end date
			if(specificDate.isBefore(vacationEnd)) { // until vacation start date
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, vacationStart);
			}else{
				weeks = (int) ChronoUnit.WEEKS.between(academicStart, specificDate) - 3; // 3 weeks for xmas holidays
			}		
		}
		return (weeks+1); // calculation must start from 1 not 0
	}

	@Override
	public Cycle findById(String cycleId) {
		Optional<Cycle> cycle = cycleRepository.findById(Long.parseLong(cycleId));
		if(cycle.isPresent()) {
			return cycle.get();
		}else{
			return null;
		}
	}

	@Override
	public Long findIdByDate(String date) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        // Parse the string to LocalDate
        LocalDate localDate = LocalDate.parse(date, formatter);
		Long id = cycleRepository.findIdByDate(localDate);
		return id;
	}

	@Override
	public Cycle findCycleByDate(String date) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
		// Parse the string to LocalDate
		LocalDate localDate = LocalDate.parse(date, formatter);
		Cycle cycle = cycleRepository.findCycleByDate(localDate);
		return cycle;
	}

	@Override
	public String academicStartSunday(int year, int week) {
		String startDate = getStartDate(year);
		LocalDate academicYearStartDate = LocalDate.parse(startDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		LocalDate weekStartDay = academicYearStartDate.plusWeeks(week - 1);
        // LocalDate weekEndDay = weekStartDay.plusDays(6);

        String formattedWeekStartDay = weekStartDay.format(dateFormatter);
        // String formattedWeekEndDay = weekEndDay.format(dateFormatter);

        // System.out.println("Week " + week + " Start Day: " + formattedWeekStartDay);
        // System.out.println("Week " + week + " End Day: " + formattedWeekEndDay);
		return formattedWeekStartDay;
	}

	@Override
	public String academicEndSaturday(int year, int week) {
		String startDate = getStartDate(year);
		LocalDate academicYearStartDate = LocalDate.parse(startDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		LocalDate weekStartDay = academicYearStartDate.plusWeeks(week - 1);
        LocalDate weekEndDay = weekStartDay.plusDays(6);

        // String formattedWeekStartDay = weekStartDay.format(dateFormatter);
        String formattedWeekEndDay = weekEndDay.format(dateFormatter);

        // System.out.println("Week " + week + " Start Day: " + formattedWeekStartDay);
        // System.out.println("Week " + week + " End Day: " + formattedWeekEndDay);
		return formattedWeekEndDay;
	}

	// get start date of academic year
	private String getStartDate(int year){
		String startDate = "";
		if(cycles==null) {
			cycles = (List<CycleDTO>) applicationContext.getBean(JaeConstants.ACADEMIC_CYCLES);
		}
		for(CycleDTO dto : cycles){
			if(dto.getYear().equals(Integer.toString(year))){
				startDate = dto.getStartDate();
				break;
			}
		}
		return startDate;
	}











}
