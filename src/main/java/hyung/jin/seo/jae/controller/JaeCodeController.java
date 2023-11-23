package hyung.jin.seo.jae.controller;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.service.CodeService;
import hyung.jin.seo.jae.utils.JaeConstants;

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

	// list branch
	@GetMapping("/branch")
	@ResponseBody
	List<SimpleBasketDTO> listBranch() {
		List<SimpleBasketDTO> dtos = codeService.loadBranch();
		return dtos;
	}

	// list branch by state
	@GetMapping("/listBranch")
	String filterBranch(@RequestParam(value = "listState", required = true) String state, Model model) {
		List<BranchDTO> dtos = new ArrayList<>();
		// search by state
		if (StringUtils.isNotBlank(state) && (!StringUtils.equals(state, JaeConstants.ALL))) {
			dtos = codeService.searchBranchByState(state);
		} else { // search all
			dtos = codeService.allBranches();
		}
		model.addAttribute(JaeConstants.BRANCH_LIST, dtos);
		return "branchPage";
	}

}