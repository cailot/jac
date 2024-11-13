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

import hyung.jin.seo.jae.dto.NoticeEmailDTO;
import hyung.jin.seo.jae.model.NoticeEmail;
import hyung.jin.seo.jae.repository.NoticeEmailRepository;
import hyung.jin.seo.jae.service.EmailService;

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
			message.setContent(body, "text/html; charset=utf-8");
			mailSender.send(message);
			System.out.println("MAIL SENT SUCCESSFULLY");
	
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
