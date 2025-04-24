package hyung.jin.seo.jae.service;

import java.util.List;

import hyung.jin.seo.jae.dto.NoticeEmailDTO;
import hyung.jin.seo.jae.model.NoticeEmail;

public interface EmailService {

	// send simple email
	void sendEmail(String from, String to, String subject, String body);

	// send simple email to multiple recipients
	void sendEmail(String from, List<String> to, String subject, String body);

	// send simple email with attachment
	void sendEmailWithAttachment(String from, String to, String subject, String body, String fileName, byte[] pdfBytes);

	// bring email from database
	List<NoticeEmailDTO> getNoticeEmails(String state, String sender, String grade);

	// bring email from database
	List<NoticeEmailDTO> getNoticeEmails(String state, String branch, String sender, String grade);

	// save email to database
	void saveNoticeEmail(NoticeEmail email);

	// bring email by id
	NoticeEmailDTO getNoticeEmail(Long id);

	// send email with attachment
	void sendResultWithAttachment(String from, String to, String subject, String body, byte[] fileData, String fileName);

	// send email with attachments
	void sendResultWithAttachments(String from, String to, String subject, String body, List<byte[]> fileData, List<String> fileNames);

}
