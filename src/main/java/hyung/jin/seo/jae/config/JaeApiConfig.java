package hyung.jin.seo.jae.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.http.converter.xml.MappingJackson2XmlHttpMessageConverter;
import org.springframework.http.MediaType;
import java.util.Arrays;

@Configuration
public class JaeApiConfig {

    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();
        
        // Add JSON converter
        MappingJackson2HttpMessageConverter jsonConverter = new MappingJackson2HttpMessageConverter();
        jsonConverter.setSupportedMediaTypes(Arrays.asList(
            MediaType.APPLICATION_JSON,
            MediaType.APPLICATION_OCTET_STREAM
        ));
        
        // Add XML converter
        MappingJackson2XmlHttpMessageConverter xmlConverter = new MappingJackson2XmlHttpMessageConverter();
        xmlConverter.setSupportedMediaTypes(Arrays.asList(
            MediaType.APPLICATION_XML,
            MediaType.TEXT_XML
        ));
        
        restTemplate.getMessageConverters().add(jsonConverter);
        restTemplate.getMessageConverters().add(xmlConverter);
        
        return restTemplate;
    }
}
