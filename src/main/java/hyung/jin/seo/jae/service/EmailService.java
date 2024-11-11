package hyung.jin.seo.jae.service;

import java.util.List;

public interface EmailService {

	// send simple email
	void sendEmail(String from, String to, String subject, String body);

	// send simple email to multiple recipients
	void sendEmail(String from, List<String> to, String subject, String body);

	// send simple email with attachment
	void sendEmailWithAttachment(String from, String to, String subject, String body, String fileName, byte[] pdfBytes);
}
