package hyung.jin.seo.jae.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.service.CodeService;

@Controller
@RequestMapping("code")
public class JaeCodeController {

	@Autowired
	private CodeService codeService;
	
	// list state
	@GetMapping("/state")
	@ResponseBody
	List<SimpleBasketDTO> listState() {
		List<SimpleBasketDTO> dtos = codeService.loadState();
		return dtos;
	}

}