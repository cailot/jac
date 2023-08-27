package hyung.jin.seo.jae.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import hyung.jin.seo.jae.model.Teacher;

public interface TeacherRepository extends JpaRepository<Teacher, Long>, JpaSpecificationExecutor<Teacher>{  
	
	List<Teacher> findAll();
	
	List<Teacher> findAllByEndDateIsNull();
	
	List<Teacher> findAllByEndDateIsNotNull();
	
	Optional<Teacher> findById(Long id);
	
	long count();
}
