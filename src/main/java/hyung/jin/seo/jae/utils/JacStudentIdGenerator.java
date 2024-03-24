package hyung.jin.seo.jae.utils;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.id.IdentifierGenerator;
import hyung.jin.seo.jae.model.Student;
import java.io.Serializable;

public class JacStudentIdGenerator implements IdentifierGenerator{

  @Override
  public Serializable generate(SharedSessionContractImplementor session, Object object) throws HibernateException {
    Student student = (Student)object;
    String state = student.getState();
    String branch = student.getBranch();
    // String query = "SELECT COALESCE(MAX(id), 0) + 1 as id FROM Student WHERE state = '" + state + "' AND branch = '" + branch + "'";
    String query = "SELECT COALESCE(MAX(id), 0) + 1 as id FROM Student WHERE branch = '" + branch + "'";
    Long maxId = (Long) session.createQuery(query).getSingleResult();
    // generate the next Id
    Long nextId = (maxId != 1) ? maxId : Long.parseLong(branch + "0001");
    // generate custom Id based on state, branch and nextId
    // String customId = state + branch + String.format("%05d", nextId);
    String customId = String.format("%06d", nextId);
    return Long.parseLong(customId);
  }
 }
