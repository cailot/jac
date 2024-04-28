package hyung.jin.seo.jae.utils;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.id.IdentifierGenerator;
import org.hibernate.query.Query;

import hyung.jin.seo.jae.model.Invoice;
import java.io.Serializable;

public class InvoiceIdGenerator implements IdentifierGenerator{

  @Override
  public Serializable generate(SharedSessionContractImplementor session, Object object) throws HibernateException {
    Invoice invoice = (Invoice) object;
    // Check student ID
    Long stdId = invoice.getStudentId();
    // Check for existing maximum number
    String sqlQuery = "SELECT COALESCE(MAX(id), " + (stdId * 1000) + ") FROM Invoice WHERE id DIV 1000 = " + stdId;
    // Executing the native query due to 'DIV' MariaDB function
    Query query = session.createNativeQuery(sqlQuery);
    // Assuming the query returns a single result, and you expect it to be a number
    Number result = (Number) query.getSingleResult();
    // Optionally, convert the result to a specific type, e.g., Long
    Long maxId = result.longValue();
    return maxId+1;
  }
}
