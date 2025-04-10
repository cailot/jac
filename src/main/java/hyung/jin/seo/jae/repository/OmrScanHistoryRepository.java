package hyung.jin.seo.jae.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import hyung.jin.seo.jae.model.OmrScanHistory;

public interface OmrScanHistoryRepository extends JpaRepository<OmrScanHistory, Long>{  
	
	List<OmrScanHistory> findAll();

    /*
	@Query(value = "SELECT o.branch, " +
        //"SUM(CASE WHEN o.testGroup = 1 THEN 1 ELSE 0 END) AS mega, " +
        "COUNT(DISTINCT CONCAT(o.studentId, '-', o.testGroup)) AS mega, " +
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
    */

    @Query(value = "SELECT o.branch, " +
        // Count distinct sheet (1 student per group = 1 sheet)
        "COUNT(DISTINCT CASE WHEN o.testGroup = 1 THEN CONCAT(o.studentId, '-', o.testGroup) END) AS mega, " +
        // Distinct revision sheets
        "COUNT(DISTINCT CASE WHEN o.testGroup = 2 THEN CONCAT(o.studentId, '-', o.testGroup) END) AS revision, " +
        // Distinct tt6 sheets (testGroup 3 or 4 with grade 11)
        "COUNT(DISTINCT CASE WHEN o.testGroup IN (3, 4) AND t.gradeId = 11 THEN CONCAT(o.studentId, '-', o.testGroup) END) AS tt6, " +
        // Distinct tt8 sheets (testGroup 4 and grade 12)
        "COUNT(DISTINCT CASE WHEN o.testGroup = 4 AND t.gradeId = 12 THEN CONCAT(o.studentId, '-', o.testGroup) END) AS tt8, " +
        // Distinct jmss sheets (testGroup 3 and grade 19)
        "COUNT(DISTINCT CASE WHEN o.testGroup = 3 AND t.gradeId = 19 THEN CONCAT(o.studentId, '-', o.testGroup) END) AS jmss " +
    "FROM OmrScanHistory o " +
    "JOIN Test t ON o.testId = t.id " +
    "WHERE o.registerDate >= :fromDate " +
    "AND o.registerDate <= :toDate " +
    "GROUP BY o.branch", nativeQuery = true)
    List<Object[]> getOmrStats(@Param("fromDate") String fromDate, @Param("toDate") String toDate);
	
}
