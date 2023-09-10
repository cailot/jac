package hyung.jin.seo.jae.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityNotFoundException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.ClazzDTO;
import hyung.jin.seo.jae.model.Clazz;
import hyung.jin.seo.jae.repository.ClazzRepository;
import hyung.jin.seo.jae.service.ClazzService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Service
public class ClazzServiceImpl implements ClazzService {
	
	@Autowired
	private ClazzRepository clazzRepository;

	@Override
	public long checkCount() {
		long count = clazzRepository.count();
		return count;
	}

	@Override
	public List<ClazzDTO> allClasses() {
		List<Clazz> crs = new ArrayList<>();
		try{
			crs = clazzRepository.findAll();
		}catch(Exception e){
			System.out.println("No class found");
		}
		// clazzRepository.findAll();
		List<ClazzDTO> dtos = new ArrayList<>();
		for(Clazz claz : crs){
			ClazzDTO dto = new ClazzDTO(claz);
			dtos.add(dto);
		}
		return dtos;
	}

	@Override
	public List<ClazzDTO> findClassesForGradeNCycle(String grade, int year) {
		// 1. get classes
		List<ClazzDTO> dtos = new ArrayList<>();
		try{
			dtos = clazzRepository.findClassForGradeNCycle(grade, year);
		}catch(Exception e){
			System.out.println("No class found");
		}
		// clazzRepository.findClassForGradeNCycle(grade, year);
		return dtos;	
	}

	@Override
	public List<ClazzDTO> findClassesForCourseIdNCycle(Long id, int year) {
		List<ClazzDTO> dtos = new ArrayList<>();
		try{
			dtos = clazzRepository.findClassForCourseIdNCycle(id, year);
		}catch(Exception e){
			System.out.println("No class found");
		}	
		// clazzRepository.findClassForCourseIdNCycle(id, year);
		return dtos;	
	}

	@Override
	public ClazzDTO addClass(Clazz clazz) {
		Clazz cla = clazzRepository.save(clazz);
		ClazzDTO dto = new ClazzDTO(cla);
		return dto;
	}

	@Override
	public Clazz getClazz(Long id) {
		Clazz clazz = null;
		try{
			clazz = clazzRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No class found");
		}
		// clazzRepository.findById(id).get();
		return clazz;	
	}

	@Override
	public ClazzDTO updateClazz(Clazz clazz) {
		// search by getId
		Clazz existing =  clazzRepository.findById(clazz.getId()).orElseThrow(() -> new EntityNotFoundException("Clazz Not Found"));
		// Update info
		// state
		String newState = clazz.getState();
		existing.setState(newState);
		// branch
		String newBranch = clazz.getBranch();
		existing.setBranch(newBranch);
		// start date
		LocalDate newStartDate = clazz.getStartDate();
		existing.setStartDate(newStartDate);
		// name
		String newName = clazz.getName();
		existing.setName(newName);
		// day
		String newDay = clazz.getDay();
		existing.setDay(newDay);
		// active
		boolean newActive = clazz.isActive();
		existing.setActive(newActive);
		// update Course & Cycle
		existing.setCourse(clazz.getCourse());
		existing.setCycle(clazz.getCycle());		
		// update the existing record
		Clazz updated = clazzRepository.save(existing);
		ClazzDTO dto = new ClazzDTO(updated);
		return dto;
	}

	@Override
	public List<ClazzDTO> listClasses(String state, String branch, String grade, String year, String active) {
		List<ClazzDTO> dtos = null;
		if(StringUtils.isNotBlank(year) && (!StringUtils.equals(year, JaeConstants.ALL))){
			dtos = clazzRepository.findClassForStateNBranchNGradeNYear(state, branch, grade, Integer.parseInt(year));
		}else{
			dtos = clazzRepository.findClassForStateNBranchNGrade(state, branch, grade);
		}
		return dtos;
	}

	@Override
	public double getPrice(Long id) {
		double price = 0;
		try{
			price = clazzRepository.getPrice(id);
		}catch(Exception e){
			System.out.println("No class found");
		}
		return price;
	}

}