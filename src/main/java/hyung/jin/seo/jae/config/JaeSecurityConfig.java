package hyung.jin.seo.jae.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;


@Configuration
@EnableWebSecurity
public class JaeSecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userDetailsService).passwordEncoder(getPasswordEncoder());
    }
	
	@Override
	public void configure(WebSecurity web) {
		web.ignoring().antMatchers(
                        "/assets/css/**",
                        "/assets/js/**",
                        "/assets/fonts/**",
                        "/assets/images/**",
                        "/js/**",
                        "/fonts/**",
                        "/css/**",
                        "/image/**"
                        ); // excluding folders list
	}

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.headers(headers -> headers.frameOptions().sameOrigin()); // Allow iframe to embed PDF in body
        http.csrf().disable();
        http
            .antMatcher("/**")
            .authorizeRequests(requests -> requests
                .antMatchers("/**").authenticated() // Secure /**
                .antMatchers("/login").permitAll())
            .formLogin(login -> login
                .loginPage("/login") // Login page link
                .loginProcessingUrl("/processLogin")
                .defaultSuccessUrl("/studentAdmin") // Redirect link after login
                .permitAll())
            .logout(logout -> logout
                .logoutUrl("/logout") // Specify logout URL
                .logoutSuccessUrl("/login") // Redirect URL after logout
                .invalidateHttpSession(true) // Make session unavailable
                .permitAll());
            // .successHandler(customAuthenticationSuccessHandler()); // Add custom success handler
    }

    @Bean
    public PasswordEncoder getPasswordEncoder(){
        return new BCryptPasswordEncoder();
    }

}
