package hyung.jin.seo.jae.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.model.OmrScanHistory;

public interface OmrScanHistoryRepository extends JpaRepository<OmrScanHistory, Long>{  
	
	List<OmrScanHistory> findAll();

	// get testGroup 1 (mega), testGroup 2 (revision), testGroup 3 (acer), testGroup 4 (edu) count of OMR scan per each branch
	//@Query(value = "SELECT o.branch, SUM(CASE WHEN o.testGroup = 1 THEN 1 ELSE 0 END) AS mega, SUM(CASE WHEN o.testGroup = 2 THEN 1 ELSE 0 END) AS revision, SUM(CASE WHEN o.testGroup = 3 THEN 1 ELSE 0 END) AS acer, SUM(CASE WHEN o.testGroup = 4 THEN 1 ELSE 0 END) AS edu FROM OmrScanHistory o WHERE o.registerDate >= :fromDate AND o.registerDate <= :toDate GROUP BY o.branch", nativeQuery = true)
	// List<Object[]> getOmrStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);
	@Query(value = "SELECT o.branch, " +
        "SUM(CASE WHEN o.testGroup = 1 THEN 1 ELSE 0 END) AS mega, " +
        "SUM(CASE WHEN o.testGroup = 2 THEN 1 ELSE 0 END) AS revision, " +
        "SUM(" +
            "CASE " + 
                "WHEN (o.testGroup IN (3, 4) AND t.gradeId = 11) " +
                "THEN 1 ELSE 0 " +
            "END" +
        ") AS tt6, " +
		"SUM(" +
            "CASE " + 
                "WHEN (o.testGroup = 4 AND t.gradeId = 12) " +
                "THEN 1 ELSE 0 " +
            "END" +
        ") AS tt8, " +
		"SUM(" +
            "CASE " + 
                "WHEN (o.testGroup = 3 AND t.gradeId = 19) " +
                "THEN 1 ELSE 0 " +
            "END" +
        ") AS jmss " +		
    "FROM OmrScanHistory o " +
    "JOIN Test t ON o.testId = t.id " +
    "WHERE o.registerDate >= :fromDate " +
    "AND o.registerDate <= :toDate " +
    "GROUP BY o.branch", nativeQuery = true)
	List<Object[]> getOmrStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);
	
}
