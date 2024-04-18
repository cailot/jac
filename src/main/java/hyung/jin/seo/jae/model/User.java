package hyung.jin.seo.jae.model;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Id;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Column;

import java.math.BigInteger;
import java.time.LocalDate;
import java.util.Collection;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="User")
public class User implements UserDetails {

	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto increment
    private Long id;
    
    @Column(length = 30, nullable = false)
    private String username;
    
    @Column(length = 100, nullable = false)
    private String password;

    @Column
    private int enabled;

    @Column(length = 100, nullable = false)
    private String firstName;
    
    @Column(length = 100, nullable = false)
    private String lastName;

    @Column(length = 50, nullable = false)
    private String role;
    
    @CreationTimestamp
    private LocalDate registerDate;


    @Column(length = 100, nullable = true)
    private String email;

    @Column(length = 100, nullable = true)
    private String phone;

    @Column(length = 2, nullable = true)
    private String state;
    
    @Column(length = 2, nullable = true)
    private String branch;



	public User(Object[] columns) {
        // this.id = (columns[0] != null) ? ((Long) columns[0]) : 0;
        this.id = (columns[0] != null) ? ((columns[0] instanceof BigInteger) ? ((BigInteger) columns[0]).longValue() : (Long) columns[0]) : 0L;
		this.username = StringUtils.defaultString((String) columns[1], "");
		this.password = StringUtils.defaultString((String) columns[2], "");
		this.enabled = (columns[3] != null) ? ((Integer) columns[3]) : 0;
		this.firstName = StringUtils.defaultString((String) columns[4], "");
		this.lastName = StringUtils.defaultString((String) columns[5], "");
		this.role = StringUtils.defaultString((String) columns[6], "");
        this.state = StringUtils.defaultString((String) columns[7], "0");
		this.branch = StringUtils.defaultString((String) columns[8], "0");
		this.email = StringUtils.defaultString((String) columns[9], "");
        this.phone = StringUtils.defaultString((String) columns[10], "");
	}


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
       return null;
    }


    @Override
    public boolean isAccountNonExpired() {
       return true;
    }


    @Override
    public boolean isAccountNonLocked() {
        return true;
    }


    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }


    @Override
    public boolean isEnabled() {
        return true;
    }
	
}
