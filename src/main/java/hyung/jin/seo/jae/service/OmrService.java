package hyung.jin.seo.jae.service;

public interface OmrService {

	// generate template
	void generateTemplate(String origin);

	// recongnise image
	void recogniseImage(String template, String image);

}
