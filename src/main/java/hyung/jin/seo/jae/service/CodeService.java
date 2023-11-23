package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StateDTO;
import hyung.jin.seo.jae.model.Branch;

public interface CodeService {

	// list all state
	List<StateDTO> allStates();

	// list for initial state value
	List<SimpleBasketDTO> loadState();
	
	// list all branch
	List<BranchDTO> allBranches();

	// list branch by state
	List<BranchDTO> searchBranchByState(String state);

	// list for initial branch value
	List<SimpleBasketDTO> loadBranch();

	// add branch
	Branch addBranch(Branch branch);

	// update branch
	Branch updateBranch(Branch newBranch, Long id);

	// delete branch
	void deleteBranch(Long id);

}
