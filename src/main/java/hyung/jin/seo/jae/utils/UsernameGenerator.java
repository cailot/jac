package hyung.jin.seo.jae.utils;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.id.IdentifierGenerator;
import hyung.jin.seo.jae.model.User;

import java.io.Serializable;

public class UsernameGenerator implements IdentifierGenerator{

  @Override
  public Serializable generate(SharedSessionContractImplementor session, Object object) throws HibernateException {
    User user = (User)object;
    String state = user.getState();
    String branch = user.getBranch();
    String role = user.getRole();
    String query = "SELECT COALESCE(MAX(username), 0) + 1 as id FROM User WHERE state = '" + state + "' AND branch = '" + branch + "' AND role = '" + role + "'";
    int maxId = (int) session.createQuery(query).getSingleResult();
    Long nextId = (long) 0;
    if(JaeConstants.ROLE_ADMIN.equalsIgnoreCase(StringUtils.defaultString(role))){
      nextId = (maxId != 1) ? maxId : Long.parseLong("1" + state + branch + "001"); // admin starts with '1'
    }else{
      nextId = (maxId != 1) ? maxId : Long.parseLong("2" + state + branch + "001"); // staff starts with '2'
    }
    // generate custom Id based on state, branch and nextId
    String customId = String.format("%07d", nextId);
    return customId;
  }
 }
