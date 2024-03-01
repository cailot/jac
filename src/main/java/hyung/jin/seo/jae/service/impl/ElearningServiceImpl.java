package hyung.jin.seo.jae.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.model.Homework;
import hyung.jin.seo.jae.repository.HomeworkRepository;
import hyung.jin.seo.jae.service.ElearningService;

@Service
public class ElearningServiceImpl implements ElearningService {
	
	@Autowired
	private HomeworkRepository elearningRepository;

	@Override
	public long checkCount() {
		long count = elearningRepository.count();
		return count;
	}

	@Override
	public List<Homework> allElearnings() {
		List<Homework> courses = new ArrayList<>();
		try{
			courses = elearningRepository.findAll();
		}catch(Exception e){
			System.out.println("No elearning found");
		}
		// elearningRepository.findAll();
		return courses;
	}
	
	@Override
	public Homework getElearning(Long id) {
		Optional<Homework> crs = elearningRepository.findById(id);
		if(!crs.isPresent()) return null;
		return crs.get();
	}

	@Override
	public Homework addElearning(Homework crs) {
		Homework course = elearningRepository.save(crs);
		return course;
	}

	@Override
	public Homework updateElearning(Homework newCourse, Long id) {
		// search by getId
		Homework existing = elearningRepository.findById(id).get();
        // Update info
        String newName = StringUtils.defaultString(newCourse.getName());
        if(StringUtils.isNotBlank(newName)){
        	existing.setName(newName);
        }
        String newGrade = StringUtils.defaultString(newCourse.getGrade());
        if(StringUtils.isNotBlank(newGrade)){
        	existing.setGrade(newGrade);
        }
        LocalDate newRegisterDate = newCourse.getRegisterDate();
        if(newRegisterDate!=null){
        	existing.setRegisterDate(newRegisterDate);
        }
        // update the existing record
        Homework updated = elearningRepository.save(existing);
        return updated;
	}

	
	@Override
	public void deleteElearning(Long id) {
		try{
		    elearningRepository.deleteById(id);
        }catch(org.springframework.dao.EmptyResultDataAccessException e){
            System.out.println("Nothing to delete");
        }
	}

	@Override
	public List<Homework> gradeElearnings(String grade) {
		List<Homework> courses = new ArrayList<>();
		try{
			courses = elearningRepository.findAllByGrade(grade);
		}catch(Exception e){
			System.out.println("No elearning found");
		}
		// elearningRepository.findAllByGrade(grade);
		return courses;
	}

	@Override
	public List<Homework> studentElearnings(Long id) {
		List<Homework> courses = new ArrayList<>();
		try{
			courses = elearningRepository.findByStudentId(id);
		}catch(Exception e){
			System.out.println("No elearning found");
		}
		// elearningRepository.findByStudentId(id);
		return courses;
	}


}
