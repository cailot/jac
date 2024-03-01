package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.repository.SubjectRepository;
import hyung.jin.seo.jae.service.SubjectService;

@Service
public class SubjectServiceImpl implements SubjectService {
		
	@Autowired
	private SubjectRepository subjectRepository;

	@Override
	public List<Subject> allSubjects() {
		List<Subject> subs = new ArrayList<>();
		try{
			subs = subjectRepository.findAll();
		}catch(Exception e){
			System.out.println("No Subject found");
		}
		return subs;
	}

	@Override
	public Subject getSubject(Long id) {
		Subject subject = null;
		try{
			subject = subjectRepository.findById(id).get();
		}catch(Exception e){
			System.out.println("No Subject found");
		}
		return subject;
	}
	
}
