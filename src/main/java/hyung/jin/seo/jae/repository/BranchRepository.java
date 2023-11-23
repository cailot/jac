package hyung.jin.seo.jae.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import hyung.jin.seo.jae.model.Branch;

public interface BranchRepository extends JpaRepository<Branch, Long>{  
	
	List<Branch> findAll();

	// @Query("SELECT new hyung.jin.seo.jae.dto.BranchDTO(b.id, b.code, b.name, b.phone, b.email, b.address, b.abn, b.bank, b.bsb, b.accountNumber, b.accountName, b.info, b.stateId) FROM Branch b")   	
	@Query(value = "SELECT b.id, b.code, b.name, b.phone, b.email, b.address, b.abn, b.bank, b.bsb, b.accountNumber, b.accountName, b.info, b.stateId FROM Branch b ORDER BY b.stateId DESC", nativeQuery = true)
	List<Object[]> getAllBranches();

	@Query(value = "SELECT b.name, b.code FROM Branch b", nativeQuery = true)   
	List<Object[]> loadBranch();
	
	@Query(value = "SELECT b.id, b.code, b.name, b.phone, b.email, b.address, b.abn, b.bank, b.bsb, b.accountNumber, b.accountName, b.info, b.stateId FROM Branch b WHERE b.stateId = ?1 ORDER BY b.id DESC", nativeQuery = true)
	List<Object[]> searchBranchByState(String state);

	// long count();

	
}
