package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.DayScheduleDTO;
import hyung.jin.seo.jae.dto.GradeDTO;
import hyung.jin.seo.jae.dto.SimpleBasketDTO;
import hyung.jin.seo.jae.dto.StateDTO;
import hyung.jin.seo.jae.dto.SubjectDTO;
import hyung.jin.seo.jae.model.Branch;
import hyung.jin.seo.jae.model.DaySchedule;
import hyung.jin.seo.jae.model.Grade;
import hyung.jin.seo.jae.model.PracticeType;
import hyung.jin.seo.jae.model.State;
import hyung.jin.seo.jae.model.Subject;
import hyung.jin.seo.jae.model.TestType;

public interface CodeService {

	// list all state
	List<StateDTO> allStates();

	// list for initial state value
	List<SimpleBasketDTO> loadState();

	// get State
	State getState(Long id);
	
	// update State
	State updateState(State newState, Long id);

	// list all branch
	List<BranchDTO> allBranches();

	// list branch by state
	List<BranchDTO> searchBranchByState(String state);

	// list for initial branch value
	List<SimpleBasketDTO> loadBranch();

	// get branch
	BranchDTO getBranch(Long id);

	// get branch by code
	BranchDTO getBranch(String code);

	// get branch by state & code
	BranchDTO getBranch(String state, String code);

	// add branch
	Branch addBranch(Branch branch);

	// update branch
	Branch updateBranch(Branch newBranch, Long id);

	// delete branch
	void deleteBranch(Long id);

	// get branch info - email, info
	SimpleBasketDTO getBranchInfo(String code);

	// get branch email
	String getBranchEmail(String code);

	// list all grade
	List<GradeDTO> allGrades();

	// list for initial grade value
	List<SimpleBasketDTO> loadGrade();

	// get grade
	Grade getGrade(Long id);

	// add grade
	Grade addGrade(Grade grade);

	// update grade
	Grade updateGrade(Grade newGrade, Long id);

	// get previous grade
	String getPreviousGrade(String code);

	// delete grade
	void deleteGrade(Long id);

	// list all day
	List<DayScheduleDTO> allDays();

	// list for initial day value
	List<SimpleBasketDTO> loadDay();

	// get day
	DaySchedule getDay(Long id);

	// list all subjcet
	List<SubjectDTO> allSubjects();

	// get Subject
	Subject getSubject(Long id);

	// list for initial subject value
	List<SimpleBasketDTO> loadSubject();

	// get practice type
	PracticeType getPracticeType(Long id);

	// list for initial practice type value
	List<SimpleBasketDTO> loadPracticeType();

	// list for practice type by group
	List<PracticeType> getPracticeTypes(int group);

	// get practice type name by id
	String getPracticeTypeName(Long id);

	// get test type
	TestType getTestType(Long id);

	// get test type name by id
	String getTestTypeName(Long id);
	
	// list for test type value
	List<TestType> getTestTypes(int group);

	// list for initial test type value
	List<SimpleBasketDTO> loadTestType();

}
