package hyung.jin.seo.jae.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class JaeApiConfig{

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
