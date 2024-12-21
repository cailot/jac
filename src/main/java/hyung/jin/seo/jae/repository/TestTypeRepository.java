package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.TestType;

public interface TestTypeRepository extends JpaRepository<TestType, Long>{  
	
	@Query(value = "SELECT t.name, t.id FROM TestType t", nativeQuery = true)   
	List<Object[]> loadTestType();

	List<TestType> findByTestGroup(int group);

	// get name by id
	@Query(value = "SELECT t.name FROM TestType t WHERE p.id = ?1", nativeQuery = true)
	String getNameById(Long id);

	// get groupId by id
	@Query(value = "SELECT t.testGroup FROM TestType t WHERE p.id = ?1", nativeQuery = true)
	int getTestGroupById(Long id);
}
