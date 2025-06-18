package hyung.jin.seo.jae.service;

import java.io.IOException;
import java.util.List;

import javax.imageio.IIOException;

import hyung.jin.seo.jae.dto.NoticeEmailDTO;
import hyung.jin.seo.jae.model.NoticeEmail;

public interface EmailService {

	void sendEmail() throws IOException;

	// send simple email
	void sendEmail(String from, String to, String subject, String body);

	// send simple email with cc
	void sendEmail(String from, String to, String subject, String body, String cc);
	
	// send simple email to multiple recipients
	void sendEmail(String from, List<String> to, String subject, String body);

	// send simple email to multiple recipients with cc
	void sendEmail(String from, List<String> to, String subject, String body, String cc);

	// send simple email with attachment
	void sendEmailWithAttachment(String from, String to, String subject, String body, String fileName, byte[] pdfBytes);

	// send simple email with attachment to multiple recipients
	void sendEmailWithAttachment(String from, List<String> to, String subject, String body, String fileName, byte[] pdfBytes);

	// send simple email with attachment to multiple recipients with cc
	void sendEmailWithAttachment(String from, List<String> to, String subject, String body, String fileName, byte[] pdfBytes, String cc);

	// send simple email with attachment to multiple recipients with bcc
	void sendEmailWithAttachment(String from, List<String> to, String bcc, String subject, String body, String fileName, byte[] pdfBytes);

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

	// send email with attachment to multiple recipients
	void sendResultWithAttachment(String from, List<String> to, String subject, String body, byte[] fileData, String fileName);

	// send email with attachments
	void sendResultWithAttachments(String from, String to, String subject, String body, List<byte[]> fileData, List<String> fileNames);

	// send email with attachments to multiple recipients
	void sendResultWithAttachments(String from, List<String> to, String subject, String body, List<byte[]> fileData, List<String> fileNames);

	// send email with attachments to multiple recipients with cc
	void sendResultWithAttachments(String from, List<String> to, String subject, String body, List<byte[]> fileData, List<String> fileNames, String cc);

	// delete email by id
	void deleteNoticeEmail(Long id);

}
