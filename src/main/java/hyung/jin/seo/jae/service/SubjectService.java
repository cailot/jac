package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.model.Subject;

public interface SubjectService {

	// bring all students
	List<Subject> allSubjects();

	Subject getSubject(Long id);
}
