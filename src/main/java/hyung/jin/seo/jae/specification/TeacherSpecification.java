package hyung.jin.seo.jae.specification;

import java.time.LocalDate;

import org.springframework.data.jpa.domain.Specification;

import hyung.jin.seo.jae.model.Teacher;

public interface TeacherSpecification {
	
	
	// Id
	static Specification<Teacher> idEquals(String keyword){
		return (root, query, cb) -> cb.equal(root.get("id"), Integer.parseInt(keyword));
	}
		
	// first name
	static Specification<Teacher> firstNameContains(String keyword){
		return (root, query, cb) -> cb.like(root.get("firstName"), "%" + keyword + "%");
	}
	
	// last name
	static Specification<Teacher> lastNameContains(String keyword){
		return (root, query, cb) -> cb.like(root.get("lastName"), "%" + keyword + "%");
	}

	// name
	static Specification<Teacher> nameContains(String keyword) {
	    return (root, query, builder) -> {
	        String keywordLike = "%" + keyword + "%";
	        return builder.or(
	                builder.like(root.get("firstName"), keywordLike),
	                builder.like(root.get("lastName"), keywordLike)
	        );
	    };
	}

	// state
	static Specification<Teacher> stateEquals(String keyword){
		return (root, query, cb) -> cb.equal(root.get("state"), keyword);
	}
	
	// branch
	static Specification<Teacher> branchEquals(String keyword){
		return (root, query, cb) -> cb.equal(root.get("branch"), keyword);
	}
		
	
	// start date equal
	static Specification<Teacher> startDateEquals(LocalDate date) {
		  return (root, query, cb) -> cb.equal(root.get("startDate"), date);
	}

	
	// start date before
	static Specification<Teacher> startDateLessThanOrEqualTo(LocalDate date) {
	    return (root, query, cb) -> cb.lessThanOrEqualTo(root.get("startDate"), date);
	}

	
	// start date after
	static Specification<Teacher> startDateAfter(LocalDate date) {
	    return (root, query, cb) -> cb.greaterThan(root.get("staratDate"), date);
	}

	
	// is not null 
	static Specification<Teacher> hasNotNullVaule(String column){
		return (root, query, cb) -> cb.isNotNull(root.get(column));
	}
	
	// is null
	static Specification<Teacher> hasNullVaule(String column){
		return (root, query, cb) -> cb.isNull(root.get(column));
	}
	
	
}
