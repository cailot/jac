package hyung.jin.seo.jae.config;

import org.apache.tomcat.util.scan.StandardJarScanFilter;
import org.apache.tomcat.util.scan.StandardJarScanner;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TomcatConfig {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> tomcatCustomizer() {
        return (tomcatFactory) -> tomcatFactory.addContextCustomizers((context) -> {
            if (context.getJarScanner() instanceof StandardJarScanner) {
                StandardJarScanner jarScanner = (StandardJarScanner) context.getJarScanner();
                StandardJarScanFilter jarScanFilter = new StandardJarScanFilter();
                jarScanFilter.setTldSkip("*"); // Skip scanning all TLDs
                jarScanner.setJarScanFilter(jarScanFilter);
            }
        });
    }
}