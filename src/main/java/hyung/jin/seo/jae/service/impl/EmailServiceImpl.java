package hyung.jin.seo.jae.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.util.ByteArrayDataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.core.io.ByteArrayResource;

import hyung.jin.seo.jae.dto.NoticeEmailDTO;
import hyung.jin.seo.jae.model.NoticeEmail;
import hyung.jin.seo.jae.repository.NoticeEmailRepository;
import hyung.jin.seo.jae.service.EmailService;
import hyung.jin.seo.jae.utils.JaeConstants;

@Service
public class EmailServiceImpl implements EmailService {
	
	@Autowired
	JavaMailSender mailSender;

	@Autowired
	NoticeEmailRepository noticeEmailRepository;

	@Override
	public void sendEmail(String from, String to, String subject, String body) {
		MimeMessage message = mailSender.createMimeMessage();
		try {
			message.setFrom(new InternetAddress(from));
			message.setRecipients(MimeMessage.RecipientType.TO, to);
			message.setSubject(subject);
			String contents =  "<h1>This is a test Spring Boot email</h1>" +
			"<marquee><p>It can contain <strong>HTML</strong> content.</p></marquee>";
			message.setContent(contents, "text/html; charset=utf-8");
			mailSender.send(message);
			System.out.println("MAIL SENT SUCCESSFULLY");

		} catch (MessagingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

	@Override
	public void sendEmail(String from, String to, String subject, String body, String cc) {
		MimeMessage message = mailSender.createMimeMessage();
		try {
			message.setFrom(new InternetAddress(from));
			message.setRecipients(MimeMessage.RecipientType.TO, InternetAddress.parse(to));
			message.setRecipients(MimeMessage.RecipientType.CC, InternetAddress.parse(cc));
			message.setSubject(subject);
			message.setContent(JaeConstants.EMAIL_HEADER_HTML + body, "text/html; charset=utf-8");
			mailSender.send(message);
		} catch (MessagingException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendEmail(String from, List<String> to, String subject, String body) {
		MimeMessage message = mailSender.createMimeMessage();
		try {
			message.setFrom(new InternetAddress(from));
			
			// Convert List<String> to array of InternetAddress
			InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
			for (int i = 0; i < to.size(); i++) {
				recipientAddresses[i] = new InternetAddress(to.get(i));
			}
			
			message.setRecipients(MimeMessage.RecipientType.TO, recipientAddresses);
			message.setSubject(subject);
			message.setContent(JaeConstants.EMAIL_HEADER_HTML + body, "text/html; charset=utf-8");
			mailSender.send(message);
			System.out.println("MAIL SENT SUCCESSFULLY");
	
		} catch (MessagingException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendEmail(String from, List<String> to, String subject, String body, String cc) {
		MimeMessage message = mailSender.createMimeMessage();
		try {
			message.setFrom(new InternetAddress(from));
			
			// Convert List<String> to array of InternetAddress
			InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
			for (int i = 0; i < to.size(); i++) {
				recipientAddresses[i] = new InternetAddress(to.get(i));
			}
			
			message.setRecipients(MimeMessage.RecipientType.TO, recipientAddresses);
			message.setRecipients(MimeMessage.RecipientType.CC, cc);
			message.setSubject(subject);
			message.setContent(JaeConstants.EMAIL_HEADER_HTML + body, "text/html; charset=utf-8");
			mailSender.send(message);
		} catch (MessagingException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendEmailWithAttachment(String from, String to, String subject, String body, String fileName, byte[] pdfBytes) {
		MimeMessagePreparator preparator = mimeMessage -> {
            MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true); // true indicates multipart
            messageHelper.setFrom(from);
            messageHelper.setTo(to);
            messageHelper.setSubject(subject);
            messageHelper.setText(body, true);

            if (pdfBytes != null && pdfBytes.length > 0) {
                ByteArrayDataSource dataSource = new ByteArrayDataSource(pdfBytes, "application/octet-stream");
                messageHelper.addAttachment(fileName, dataSource);
            }
        };
        mailSender.send(preparator);
	}
	
	@Override
	public void sendEmailWithAttachment(String from, List<String> to, String subject, String body, String fileName, byte[] pdfBytes) {
		try {
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true);
				messageHelper.setFrom(from);
				
				// Convert List<String> to array of InternetAddress
				InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
				for (int i = 0; i < to.size(); i++) {
					recipientAddresses[i] = new InternetAddress(to.get(i));
				}
				messageHelper.setTo(recipientAddresses);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				if (pdfBytes != null && pdfBytes.length > 0) {
					ByteArrayDataSource dataSource = new ByteArrayDataSource(pdfBytes, "application/octet-stream");
					messageHelper.addAttachment(fileName, dataSource);
				}
			};
			mailSender.send(preparator);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendEmailWithAttachment(String from, List<String> to, String subject, String body, String fileName, byte[] pdfBytes, String cc) {
		try {
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true);
				messageHelper.setFrom(from);
				
				// Convert List<String> to array of InternetAddress
				InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
				for (int i = 0; i < to.size(); i++) {
					recipientAddresses[i] = new InternetAddress(to.get(i));
				}
				messageHelper.setTo(recipientAddresses);
				messageHelper.setCc(cc);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				if (pdfBytes != null && pdfBytes.length > 0) {
					ByteArrayDataSource dataSource = new ByteArrayDataSource(pdfBytes, "application/octet-stream");
					messageHelper.addAttachment(fileName, dataSource);
				}
			};
			mailSender.send(preparator);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendResultWithAttachment(String from, String to, String subject, String body, byte[] fileData, String fileName) {
		// html email
		try{
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true); // true indicates multipart
				messageHelper.setFrom(from);
				messageHelper.setTo(to);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				if (fileData != null && fileData.length > 0) {
					ByteArrayDataSource dataSource = new ByteArrayDataSource(fileData, "application/octet-stream");
					messageHelper.addAttachment(fileName, dataSource);
				}
			};
			mailSender.send(preparator);
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	@Override
	public void sendResultWithAttachment(String from, List<String> to, String subject, String body, byte[] fileData, String fileName) {
		try {
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true); // true indicates multipart
				messageHelper.setFrom(from);
				
				// Convert List<String> to array of InternetAddress
				InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
				for (int i = 0; i < to.size(); i++) {
					recipientAddresses[i] = new InternetAddress(to.get(i));
				}
				messageHelper.setTo(recipientAddresses);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				if (fileData != null && fileData.length > 0) {
					ByteArrayDataSource dataSource = new ByteArrayDataSource(fileData, "application/octet-stream");
					messageHelper.addAttachment(fileName, dataSource);
				}
			};
			mailSender.send(preparator);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	
	@Override
	public void sendResultWithAttachments(String from, String to, String subject, String body, List<byte[]> fileData, List<String> fileNames) {
		try {
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true); // true indicates multipart
				messageHelper.setFrom(from);
				messageHelper.setTo(to);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				for (int i = 0; i < fileData.size(); i++) {
					messageHelper.addAttachment(fileNames.get(i), new ByteArrayResource(fileData.get(i)));
				}
			};
			mailSender.send(preparator);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendResultWithAttachments(String from, List<String> to, String subject, String body, List<byte[]> fileData, List<String> fileNames) {
		try {
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true);
				messageHelper.setFrom(from);
				
				// Convert List<String> to array of InternetAddress
				InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
				for (int i = 0; i < to.size(); i++) {
					recipientAddresses[i] = new InternetAddress(to.get(i));
				}
				messageHelper.setTo(recipientAddresses);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				for (int i = 0; i < fileData.size(); i++) {
					messageHelper.addAttachment(fileNames.get(i), new ByteArrayResource(fileData.get(i)));
				}
			};
			mailSender.send(preparator);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void sendResultWithAttachments(String from, List<String> to, String subject, String body, List<byte[]> fileData, List<String> fileNames, String cc) {
		try {
			MimeMessagePreparator preparator = mimeMessage -> {
				MimeMessageHelper messageHelper = new MimeMessageHelper(mimeMessage, true);
				messageHelper.setFrom(from);
				
				// Convert List<String> to array of InternetAddress
				InternetAddress[] recipientAddresses = new InternetAddress[to.size()];
				for (int i = 0; i < to.size(); i++) {
					recipientAddresses[i] = new InternetAddress(to.get(i));
				}
				messageHelper.setTo(recipientAddresses);
				messageHelper.setCc(cc);
				messageHelper.setSubject(subject);
				messageHelper.setText(body, true);

				for (int i = 0; i < fileData.size(); i++) {
					messageHelper.addAttachment(fileNames.get(i), new ByteArrayResource(fileData.get(i)));
				}
			};
			mailSender.send(preparator);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	@Override
	public List<NoticeEmailDTO> getNoticeEmails(String state, String sender, String grade) {
		List<NoticeEmailDTO> dtos = new ArrayList<>();
		try{
			dtos = noticeEmailRepository.findEmails(state, sender, grade);
		}catch(Exception e){
			System.out.println("No Email Found");
		}
		return dtos;
	}

	@Override
	public List<NoticeEmailDTO> getNoticeEmails(String state, String branch, String sender, String grade) {
		List<NoticeEmailDTO> dtos = new ArrayList<>();
		try{
			dtos = noticeEmailRepository.findEmails(state, branch, sender, grade);
		}catch(Exception e){
			System.out.println("No Email Found");
		}
		return dtos;
	}


	@Override
	@Transactional
	public void saveNoticeEmail(NoticeEmail email) {
		noticeEmailRepository.save(email);
	}


	@Override
	public NoticeEmailDTO getNoticeEmail(Long id) {
		NoticeEmailDTO dto = null;
		try{
			NoticeEmail email = noticeEmailRepository.findById(id).get();
			dto = new NoticeEmailDTO(email);
		}catch(Exception e){
			System.out.println("No Email Found");
		}
		return dto;
	}

}
