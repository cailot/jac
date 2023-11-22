package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StateDTO;
import hyung.jin.seo.jae.model.State;
import hyung.jin.seo.jae.repository.StateRepository;
import hyung.jin.seo.jae.service.CodeService;

@Service
public class CodeServiceImpl implements CodeService {

	@Autowired
	private StateRepository stateRepository;

	@Override
	public List<StateDTO> allStates() {
		List<StateDTO> dtos = new ArrayList<>();
		try{
			List<State> states = stateRepository.findAll();
			for(State state : states){
				StateDTO dto = new StateDTO(state);
				dtos.add(dto);
			}
		}catch(Exception e){
			System.out.println("No state found");
		}
		return dtos;
	}

	@Override
	public List<SimpleBasketDTO> loadState() {
		List<Object[]> objects = new ArrayList<>();
		try{
			objects = stateRepository.loadState();
		}catch(Exception e){
			System.out.println("No state found");
		}
		List<SimpleBasketDTO> dtos = new ArrayList<>();
		for(Object[] object : objects){
			SimpleBasketDTO dto = new SimpleBasketDTO(object);
			dtos.add(dto);
		}
		return dtos;
	}
	


}
