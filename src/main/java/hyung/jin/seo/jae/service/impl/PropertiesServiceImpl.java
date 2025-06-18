package hyung.jin.seo.jae.service.impl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import hyung.jin.seo.jae.service.PropertiesService;

@Service
public class PropertiesServiceImpl implements PropertiesService {

	@Value("${connected.homework.subject.count}")
	private String subjectCard;

	@Value("${connected.homework.answer.count}")
	private String answerCard;

	@Value("${jac.study.endpoint}")
	private String elearningEndpoint;

	@Override
	public int getSubjectCardCount() {
		return subjectCard!=null ? Integer.parseInt(subjectCard) : 0;
	}

	@Override
	public int getAnswerCardCount() {
		return answerCard!=null ? Integer.parseInt(answerCard) : 0;
	}

	@Override
	public String getElearningEndpoint() {
		return elearningEndpoint != null ? elearningEndpoint : "https://jac-study.azurewebsites.net/online/";
	}

}
