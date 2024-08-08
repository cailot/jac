package hyung.jin.seo.jae.service.impl;

import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.util.ByteArrayDataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.stereotype.Service;

import hyung.jin.seo.jae.service.EmailService;
import hyung.jin.seo.jae.utils.JaeUtils;

@Service
public class EmailServiceImpl implements EmailService {
	
	@Autowired
	JavaMailSender mailSender;
	
	// @Autowired
	// private ResourceLoader resourceLoader;

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
	public void sendEmailWithAttachment(String from, String to, String subject, String body, String fileName, byte[] pdfBytes) {
		// MimeMessage message = mailSender.createMimeMessage();
		// try {
		// 	MimeMessageHelper helper = new MimeMessageHelper(message, true);
		// 	helper.setTo(to);
		// 	helper.setSubject(subject);
		// 	String contents =  "<h1>This is a test Spring Boot email</h1>" +
		// 	"<marquee><p>It can contain <strong>HTML</strong> content.</p></marquee>";
		// 	helper.setText(contents);

		// 	// Resource resource = resourceLoader.getResource("classpath:pdf/a.pdf");
		// 	// FileSystemResource file = new FileSystemResource(resource.getFile());
		// 	helper.addAttachment(fileName, new ByteArrayDataSource(pdfBytes, "application/pdf"));
		// 	mailSender.send(message);
		// 	System.out.println("HTML WITH ATTACHMENT MAIL SENT SUCCESSFULLY");
	

		// } catch (MessagingException e) {
		// 	// TODO Auto-generated catch block
		// 	e.printStackTrace();
		// }
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

}
