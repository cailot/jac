package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StateDTO;

public interface CodeService {

	// list all state
	List<StateDTO> allStates();

	// list for initial state value
	List<SimpleBasketDTO> loadState();
	
}
