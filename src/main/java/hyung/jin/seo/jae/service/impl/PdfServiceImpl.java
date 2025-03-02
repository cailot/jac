package hyung.jin.seo.jae.service.impl;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.text.FieldPosition;
import java.text.NumberFormat;
import java.text.ParsePosition;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.Paint;
import java.awt.RenderingHints;

import org.apache.commons.lang3.StringUtils;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtils;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.axis.NumberTickUnit;
import org.jfree.chart.labels.ItemLabelAnchor;
import org.jfree.chart.labels.ItemLabelPosition;
import org.jfree.chart.labels.StandardCategoryItemLabelGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.renderer.category.LineAndShapeRenderer;
import org.jfree.chart.renderer.category.StandardBarPainter;
import org.jfree.chart.ui.TextAnchor;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import com.itextpdf.io.image.ImageData;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.io.source.ByteArrayOutputStream;
import com.itextpdf.kernel.color.DeviceRgb;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.border.Border;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.property.TextAlignment;
import com.itextpdf.layout.property.VerticalAlignment;

import hyung.jin.seo.jae.dto.AssessmentAnswerDTO;
import hyung.jin.seo.jae.dto.GuestStudentAssessmentDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.TestResultHistoryDTO;
import hyung.jin.seo.jae.model.GuestStudent;
import hyung.jin.seo.jae.service.PdfService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;
import com.itextpdf.io.image.ImageData;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.io.source.ByteArrayOutputStream;
// import com.itextpdf.kernel.color.Color;
import com.itextpdf.kernel.color.DeviceRgb;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.border.Border;
import com.itextpdf.layout.border.SolidBorder;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.property.TextAlignment;
import com.itextpdf.layout.property.VerticalAlignment;

import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.dto.MoneyDTO;
import hyung.jin.seo.jae.dto.PaymentDTO;
import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.TestResultHistoryDTO;
import hyung.jin.seo.jae.service.PdfService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;

@Service
public class PdfServiceImpl implements PdfService {

	@Autowired
	private ResourceLoader resourceLoader;

	@Override
	public byte[] generateInvoicePdf(Map<String, Object> data) {
		try {
			// // Set the content type and attachment header.
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter pdfWriter = new PdfWriter(baos);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");
			float wholeWidth = pdfDocument.getDefaultPageSize().getWidth(); // whole width
			float wholeHeight = pdfDocument.getDefaultPageSize().getHeight(); // whole height

			// 1. button section
			Image buttons = imageButtons();
			float x = wholeWidth/2 - 90;
			float y = wholeHeight/2 + 380;
			buttons.setFixedPosition(x, y);
			document.add(buttons);
			document.add(onespace);
			document.add(onespace);

			// 2. title section
			Table title = getInvoiceTitleTable(wholeWidth, data);
			document.add(title);
			document.add(onespace);

			// 3. header section
			Table header = getHeaderTable(wholeWidth, data);
			document.add(header);

			// 4. detail section
			Object[] details = getInvoiceDetailTable(wholeWidth, data);
			Table detail = (Table) details[0];
			double finalTotal = (double) details[1];
			document.add(detail);
			document.add(onespace);

			// 5. paid section
			Table paid = getInvoicePaidTable(wholeWidth, data, finalTotal);
			document.add(paid);
			document.add(onespace);
			document.add(onespace);

			// 6. note section
			Table note = getBranchNoteTable(wholeWidth, data);
			document.add(note);
			document.close();

			byte[] pdfData = baos.toByteArray();
			return pdfData;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public byte[] generateReceiptPdf(Map<String, Object> data) {
		try {
			// // Set the content type and attachment header.
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter pdfWriter = new PdfWriter(baos);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");
			float wholeWidth = pdfDocument.getDefaultPageSize().getWidth(); // whole width
			float wholeHeight = pdfDocument.getDefaultPageSize().getHeight(); // whole height

			// 1. watermark
			Image watermark = imageWatermark();
			float x_watermark = wholeWidth/2 - 200;
			float y_watermark = wholeHeight/2 - 200;
			watermark.setFixedPosition(x_watermark, y_watermark);
			document.add(watermark);

			// 2. button section
			Image buttons = imageButtons();
			float x = wholeWidth/2 - 90;
			float y = wholeHeight/2 + 380;
			buttons.setFixedPosition(x, y);
			document.add(buttons);
			document.add(onespace);
			document.add(onespace);

			// 3. title section
			Table title = getReceiptTitleTable(wholeWidth, data);
			document.add(title);
			document.add(onespace);

			// 4. header section
			Table header = getHeaderTable(wholeWidth, data);
			document.add(header);

			// 5. detail section
			Object[] details = getReceiptDetailTable(wholeWidth, data);
			Table detail = (Table) details[0];
			double finalTotal = (double) details[1];
			double paidTotal = (double) details[2];
			document.add(detail);
			document.add(onespace);

			// 6. paid section
			Table paid = getReceiptPaidTable(wholeWidth, finalTotal, paidTotal);
			document.add(paid);
			document.add(onespace);
			document.add(onespace);

			// 7. note section
			Table note = getBranchNoteTable(wholeWidth, data);
			document.add(note);
			document.close();

			byte[] pdfData = baos.toByteArray();
			return pdfData;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}


	// @Override
	public void generateInvoicePdf(String fileName, Map<String, Object> data){		
		try {
			// pdf directory - resources/pdf
			String projectRootPath = new File("").getAbsolutePath();
			String pdfDirectoryPath = projectRootPath + "/src/main/resources/pdf/";
			File pdfDirectory = new File(pdfDirectoryPath);
			if (!pdfDirectory.exists()) {
				pdfDirectory.mkdirs();
			}
			String fullPath = pdfDirectoryPath + fileName;

			PdfWriter pdfWriter = new PdfWriter(fullPath);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");
			float wholeWidth = pdfDocument.getDefaultPageSize().getWidth(); // whole width
			float wholeHeight = pdfDocument.getDefaultPageSize().getHeight(); // whole height

			// 1. button section
			Image buttons = imageButtons();
			float x = wholeWidth/2 - 90;
			float y = wholeHeight/2 + 380;
			buttons.setFixedPosition(x, y);
			document.add(buttons);
			document.add(onespace);
			document.add(onespace);

			// 2. title section
			Table title = getInvoiceTitleTable(wholeWidth, data);
			document.add(title);
			document.add(onespace);

			// 3. header section
			Table header = getHeaderTable(wholeWidth, data);
			document.add(header);

			// 4. detail section
			Object[] details = getInvoiceDetailTable(wholeWidth, data);
			Table detail = (Table) details[0];
			double finalTotal = (double) details[1];
			document.add(detail);
			document.add(onespace);

			// 5. paid section
			Table paid = getInvoicePaidTable(wholeWidth, data, finalTotal);
			document.add(paid);
			document.add(onespace);
			document.add(onespace);

			// 6. note section
			Table note = getBranchNoteTable(wholeWidth, data);
			document.add(note);
			document.close();
		} catch (IOException | URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	// @Override
	public void generateReceiptPdf(String fileName, Map<String, Object> data) {
		try {
			// pdf directory - resources/pdf
			String projectRootPath = new File("").getAbsolutePath();
			String pdfDirectoryPath = projectRootPath + "/src/main/resources/pdf/";
			File pdfDirectory = new File(pdfDirectoryPath);
			if (!pdfDirectory.exists()) {
				pdfDirectory.mkdirs();
			}
			String fullPath = pdfDirectoryPath + fileName;

			PdfWriter pdfWriter = new PdfWriter(fullPath);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");
			float wholeWidth = pdfDocument.getDefaultPageSize().getWidth(); // whole width
			float wholeHeight = pdfDocument.getDefaultPageSize().getHeight(); // whole height
			
			// 1. watermark
			Image watermark = imageWatermark();
			float x_watermark = wholeWidth/2 - 200;
			float y_watermark = wholeHeight/2 - 200;
			watermark.setFixedPosition(x_watermark, y_watermark);
			document.add(watermark);

			// 2. button section
			Image buttons = imageButtons();
			float x = wholeWidth/2 - 90;
			float y = wholeHeight/2 + 380;
			buttons.setFixedPosition(x, y);
			document.add(buttons);
			document.add(onespace);
			document.add(onespace);

			// 3. title section
			Table title = getReceiptTitleTable(wholeWidth, data);
			document.add(title);
			document.add(onespace);

			// 4. header section
			Table header = getHeaderTable(wholeWidth, data);
			document.add(header);

			// 5. detail section
			Object[] details = getReceiptDetailTable(wholeWidth, data);
			Table detail = (Table) details[0];
			double finalTotal = (double) details[1];
			double paidTotal = (double) details[2];
			document.add(detail);
			document.add(onespace);

			// 6. paid section
			Table paid = getReceiptPaidTable(wholeWidth, finalTotal, paidTotal);
			document.add(paid);
			document.add(onespace);
			document.add(onespace);

			// 7. note section
			Table note = getBranchNoteTable(wholeWidth, data);
			document.add(note);
			document.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}


	private Table getInvoiceTitleTable(float wholeWidth, Map<String, Object> data) throws MalformedURLException, URISyntaxException, IOException {
		float one = wholeWidth*2/3;
		float two = wholeWidth/3;
		float twocolumWith[] = {one, two};
		BranchDTO branch = data.get(JaeConstants.INVOICE_BRANCH) != null ? (BranchDTO) data.get(JaeConstants.INVOICE_BRANCH) : new BranchDTO();
		Table table = new Table(twocolumWith);
		table.addCell(new Cell().add("TAX INVOICE").setBorder(Border.NO_BORDER).setBold().setFontSize(20f).setVerticalAlignment(VerticalAlignment.MIDDLE));
		Table nested = new Table(new float[]{two});
		nested.addCell(new Cell().add(imageInvoiceLogo()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell(branch.getPhone()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell(branch.getAddress()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell("ABN " + branch.getAbn()).setBorder(Border.NO_BORDER));
		table.addCell(new Cell().add(nested).setBorder(Border.NO_BORDER));
		return table;
	}

	private Table getReceiptTitleTable(float wholeWidth, Map<String, Object> data) throws MalformedURLException, URISyntaxException, IOException {
		float one = wholeWidth*2/3;
		float two = wholeWidth/3;
		float twocolumWith[] = {one, two};
		BranchDTO branch = data.get(JaeConstants.INVOICE_BRANCH) != null ? (BranchDTO) data.get(JaeConstants.INVOICE_BRANCH) : new BranchDTO();
		Table table = new Table(twocolumWith);
		table.addCell(new Cell().add("RECEIPT").setBorder(Border.NO_BORDER).setBold().setFontSize(20f).setVerticalAlignment(VerticalAlignment.MIDDLE));
		Table nested = new Table(new float[]{two});
		nested.addCell(new Cell().add(imageInvoiceLogo()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell(branch.getPhone()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell(branch.getAddress()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell("ABN " + branch.getAbn()).setBorder(Border.NO_BORDER));
		table.addCell(new Cell().add(nested).setBorder(Border.NO_BORDER));
		return table;
	}

	private Table getHeaderTable(float wholeWidth, Map<String, Object> data) {
		Table header = new Table(new float[]{wholeWidth/2, wholeWidth/2});
		Table nested1 = new Table(new float[]{(wholeWidth/2)/4, (wholeWidth/2)*3/4});
		MoneyDTO money = data.get(JaeConstants.PAYMENT_HEADER) != null ? (MoneyDTO) data.get(JaeConstants.PAYMENT_HEADER) : new MoneyDTO();
		InvoiceDTO invoice = data.get(JaeConstants.INVOICE_INFO) != null ? (InvoiceDTO) data.get(JaeConstants.INVOICE_INFO) : new InvoiceDTO();
		StudentDTO student = data.get(JaeConstants.STUDENT_INFO) != null ? (StudentDTO) data.get(JaeConstants.STUDENT_INFO) : new StudentDTO();
		nested1.addCell(boldCell("Date :").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell(JaeUtils.getToday()).setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("Name :").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell(student.getFirstName() + " " + student.getLastName()).setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("Student ID :").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell(student.getId()).setBorder(Border.NO_BORDER));
		header.addCell(new Cell().add(nested1).setBorder(Border.NO_BORDER));
		Table nested2 = new Table(new float[]{(wholeWidth/2)/4, (wholeWidth/2)*3/4});
		nested2.addCell(boldCell("Due Date :").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell(money.getRegisterDate()).setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("Grade :").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell(JaeUtils.getGradeName(money.getInfo())).setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("Invoice No :").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell(invoice.getId()).setBorder(Border.NO_BORDER));
		header.addCell(new Cell().add(nested2).setBorder(Border.NO_BORDER));
		return header;
	}
	
	private Object[] getInvoiceDetailTable(float wholeWidth, Map<String, Object> data) {
		List<EnrolmentDTO> enrolments = data.get(JaeConstants.PAYMENT_ENROLMENTS) != null ? (List<EnrolmentDTO>) data.get(JaeConstants.PAYMENT_ENROLMENTS) : new ArrayList<>();
		List<MaterialDTO> materials = data.get(JaeConstants.PAYMENT_MATERIALS) != null ? (List<MaterialDTO>) data.get(JaeConstants.PAYMENT_MATERIALS) : new ArrayList<>();
		List<PaymentDTO> payments = data.get(JaeConstants.PAYMENT_PAYMENTS) != null ? (List<PaymentDTO>) data.get(JaeConstants.PAYMENT_PAYMENTS) : new ArrayList<>();
		InvoiceDTO invoice = data.get(JaeConstants.INVOICE_INFO) != null ? (InvoiceDTO) data.get(JaeConstants.INVOICE_INFO) : new InvoiceDTO();
		Table detail = new Table(new float[]{(wholeWidth)*3/12, (wholeWidth)*3/12, (wholeWidth)/12, (wholeWidth)*2/12, (wholeWidth)/12, (wholeWidth)*2/12});
		detail.setBorder(new SolidBorder(1)); // Set the border to a solid line with a width of 2
		detail.setMarginTop(5);

		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Title")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Period/Date")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(0, 2).add(tableHeaderCell("Fee (Incl.GST)")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Discount")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Subtotal\n(Incl.GST)")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(0, 0).add(tableHeaderCell("Weeks\n(Qty)")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(0, 0).add(tableHeaderCell("Weekly Fee\n(Unit price)")).setVerticalAlignment(VerticalAlignment.MIDDLE));

		// data display
		double finalTotal = 0;
		// enrolements
		for(EnrolmentDTO enrolment : enrolments){
			detail.addCell(new Cell().add(boldCell("Class [" + JaeUtils.getGradeName(enrolment.getGrade()) + "] " + enrolment.getName())).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add(boldCell(StringUtils.defaultString(enrolment.getExtra()))).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add(boldCell(enrolment.getEndWeek()-enrolment.getStartWeek()+1+"")).setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add(boldCell(String.format("%.2f", enrolment.getPrice()))).setTextAlignment(TextAlignment.RIGHT));
			String disStr = StringUtils.defaultString(enrolment.getDiscount(), "0");
			double discount = 0;
			if(StringUtils.contains(disStr, '%')){
				discount = Double.parseDouble(StringUtils.substringBefore(disStr, "%"));
				discount = ((enrolment.getEndWeek()-enrolment.getStartWeek()+1)-enrolment.getCredit())*enrolment.getPrice()*discount/100;
			}else{
				discount = Double.parseDouble(disStr);
			}
			detail.addCell(new Cell().add(boldCell(enrolment.getDiscount())).setTextAlignment(TextAlignment.RIGHT));
			double total = (enrolment.getEndWeek()-enrolment.getStartWeek()+1-enrolment.getCredit())*enrolment.getPrice() - discount;
			detail.addCell(new Cell().add(boldCell(String.format("%.2f", total))).setTextAlignment(TextAlignment.RIGHT));
			finalTotal += total;
		}
		// materials
		for(MaterialDTO material : materials){
			detail.addCell(new Cell().add(boldCell("Book " + material.getName())).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add(boldCell(String.format("%.2f", material.getPrice()))).setTextAlignment(TextAlignment.RIGHT));	
			finalTotal += material.getPrice();
		}
		// payments
		for(PaymentDTO payment : payments){
			detail.addCell(new Cell().add(boldCell("Payment")).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add(boldCell(payment.getRegisterDate()+"")).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			double paid = payment.getAmount();
			String paidAmount = (paid > 0.00) ? " - " + String.format("%.2f", paid) : "0.00";
			detail.addCell(new Cell().add(boldCell(paidAmount)).setTextAlignment(TextAlignment.RIGHT));
		}
		// note if invoice
		detail.addCell(new Cell(0, 6).add(boldCell("* Other Information : " + StringUtils.defaultString(invoice.getInfo()))).setTextAlignment(TextAlignment.LEFT).setPaddingLeft(10));
		// return table & finalTotal
		return new Object[]{detail, finalTotal};
	}

	private Object[] getReceiptDetailTable(float wholeWidth, Map<String, Object> data) {
		List<EnrolmentDTO> enrolments = data.get(JaeConstants.PAYMENT_ENROLMENTS) != null ? (List<EnrolmentDTO>) data.get(JaeConstants.PAYMENT_ENROLMENTS) : new ArrayList<>();
		List<MaterialDTO> materials = data.get(JaeConstants.PAYMENT_MATERIALS) != null ? (List<MaterialDTO>) data.get(JaeConstants.PAYMENT_MATERIALS) : new ArrayList<>();
		List<PaymentDTO> payments = data.get(JaeConstants.PAYMENT_PAYMENTS) != null ? (List<PaymentDTO>) data.get(JaeConstants.PAYMENT_PAYMENTS) : new ArrayList<>();
		InvoiceDTO invoice = data.get(JaeConstants.INVOICE_INFO) != null ? (InvoiceDTO) data.get(JaeConstants.INVOICE_INFO) : new InvoiceDTO();
		Table detail = new Table(new float[]{(wholeWidth)*3/12, (wholeWidth)*3/12, (wholeWidth)/12, (wholeWidth)*2/12, (wholeWidth)/12, (wholeWidth)*2/12});
		detail.setBorder(new SolidBorder(1)); // Set the border to a solid line with a width of 2
		detail.setMarginTop(5);

		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Title")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Period/Date")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(0, 2).add(tableHeaderCell("Fee (Incl.GST)")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Discount")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(2, 0).add(tableHeaderCell("Subtotal\n(Incl.GST)")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(0, 0).add(tableHeaderCell("Weeks\n(Qty)")).setVerticalAlignment(VerticalAlignment.MIDDLE));
		detail.addCell(new Cell(0, 0).add(tableHeaderCell("Weekly Fee\n(Unit price)")).setVerticalAlignment(VerticalAlignment.MIDDLE));

		// data finalTotal display
		double finalTotal = 0;
		// data paidTotal display
		double paidTotal = 0;
		// enrolements
		for(EnrolmentDTO enrolment : enrolments){
			detail.addCell(new Cell().add(boldCell("Class [" + JaeUtils.getGradeName(enrolment.getGrade()) + "] " + enrolment.getName())).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add(boldCell(StringUtils.defaultString(enrolment.getExtra()))).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add(boldCell(enrolment.getEndWeek()-enrolment.getStartWeek()+1+"")).setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add(boldCell(String.format("%.2f", enrolment.getPrice()))).setTextAlignment(TextAlignment.RIGHT));
			String disStr = StringUtils.defaultString(enrolment.getDiscount(), "0");
			double discount = 0;
			if(StringUtils.contains(disStr, '%')){
				discount = Double.parseDouble(StringUtils.substringBefore(disStr, "%"));
				discount = ((enrolment.getEndWeek()-enrolment.getStartWeek()+1)-enrolment.getCredit())*enrolment.getPrice()*discount/100;
			}else{
				discount = Double.parseDouble(disStr);
			}
			detail.addCell(new Cell().add(boldCell(enrolment.getDiscount())).setTextAlignment(TextAlignment.RIGHT));
			double total = (enrolment.getEndWeek()-enrolment.getStartWeek()+1-enrolment.getCredit())*enrolment.getPrice() - discount;
			detail.addCell(new Cell().add(boldCell(String.format("%.2f", total))).setTextAlignment(TextAlignment.RIGHT));
			finalTotal += total;
		}
		// materials
		for(MaterialDTO material : materials){
			detail.addCell(new Cell().add(boldCell("Book " + material.getName())).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add(boldCell(String.format("%.2f", material.getPrice()))).setTextAlignment(TextAlignment.RIGHT));	
			finalTotal += material.getPrice();
		}
		// payments
		for(PaymentDTO payment : payments){
			detail.addCell(new Cell().add(boldCell("Payment")).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add(boldCell(payment.getRegisterDate()+"")).setTextAlignment(TextAlignment.CENTER));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			detail.addCell(new Cell().add("").setTextAlignment(TextAlignment.RIGHT));
			double paid = payment.getAmount();
			paidTotal += paid;
			String paidAmount = (paid > 0.00) ? " - " + String.format("%.2f", paid) : "0.00";
			detail.addCell(new Cell().add(boldCell(paidAmount)).setTextAlignment(TextAlignment.RIGHT));
		}
		// return table & finalTotal
		return new Object[]{detail, finalTotal, paidTotal};
	}

	private Table getInvoicePaidTable(float wholeWidth, Map<String, Object> data, double finalTotal) {
		InvoiceDTO invoice = data.get(JaeConstants.INVOICE_INFO) != null ? (InvoiceDTO) data.get(JaeConstants.INVOICE_INFO) : new InvoiceDTO();
		Table paid = new Table(new float[]{wholeWidth/4, wholeWidth/4, wholeWidth/4, wholeWidth/4}).setBorder(Border.NO_BORDER);
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		Table paidDetail = new Table(new float[]{(wholeWidth/4)*3/7, (wholeWidth/4)/7, (wholeWidth/4)*3/7}).setBorder(Border.NO_BORDER);
		paidDetail.addCell(paidCell("FINAL TOTAL").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell(String.format("%.2f", finalTotal)).setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("FEE PAID").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		double paidAmount = invoice.getPaidAmount();
		String paidAmtStr = (paidAmount > 0.00) ? String.format(" - %.2f", paidAmount) : "0.00";
		paidDetail.addCell(paidNoBoldCell(paidAmtStr).setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("BALANCE").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		String remaining = "";
		if(finalTotal - paidAmount <= 0){
			remaining = "PAID IN FULL";
		}else{
			remaining = String.format("%.2f", (finalTotal - paidAmount));
		}
		paidDetail.addCell(paidNoBoldCell(remaining).setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().add(paidDetail).setBorder(Border.NO_BORDER));
		return paid;
	}

	private Table getReceiptPaidTable(float wholeWidth, double finalTotal, double paidTotal) {
		Table paid = new Table(new float[]{wholeWidth/4, wholeWidth/4, wholeWidth/4, wholeWidth/4}).setBorder(Border.NO_BORDER);
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		Table paidDetail = new Table(new float[]{(wholeWidth/4)*3/7, (wholeWidth/4)/7, (wholeWidth/4)*3/7}).setBorder(Border.NO_BORDER);
		paidDetail.addCell(paidCell("FINAL TOTAL").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell(String.format("%.2f", finalTotal)).setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("FEE PAID").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		String paidAmtStr = (paidTotal > 0.00) ? String.format(" - %.2f", paidTotal) : "0.00";
		paidDetail.addCell(paidNoBoldCell(paidAmtStr).setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("BALANCE").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		String remaining = "";
		if(finalTotal - paidTotal <= 0){
			remaining = "PAID IN FULL";
		}else{
			remaining = String.format("%.2f", (finalTotal - paidTotal));
		}
		paidDetail.addCell(paidNoBoldCell(remaining).setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().add(paidDetail).setBorder(Border.NO_BORDER));
		return paid;
	}

	private Table getBranchNoteTable(float wholeWidth, Map<String, Object> data) {
		BranchDTO branch = data.get(JaeConstants.INVOICE_BRANCH) != null ? (BranchDTO) data.get(JaeConstants.INVOICE_BRANCH) : new BranchDTO();
		Table note = new Table(new float[]{wholeWidth}).setBorder(new SolidBorder(0.5f));
		note.addCell(boldCell("Note :").setItalic().setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setPaddingLeft(5));
		//String content = "1. Total payment dute in 14 days<br>2. Please make payment to the following account<br>3. Please use the invoice number as the reference when making payment<br>4. If you have any questions about this invoice, please contact Jin Seo on 03 9361 0051";
		String content = branch.getInfo();
		String[] contents = StringUtils.splitByWholeSeparator(content, "<br/>");
		if(contents != null){
			for(String msg : contents){
				note.addCell(new Cell().add(msg).setFontSize(8f).setBorder(Border.NO_BORDER).setPaddingLeft(10));
			}
		}
		return note;
	}

	private Cell boldTitleCell(String contents) {
		return new Cell().add(contents).setBold().setFontSize(7f);
	}

	private Cell boldCell(String contents) {
		return new Cell().add(contents).setBold().setFontSize(7.5f);
	}

	private Cell tableHeaderCell(String contents) {
		return new Cell().add(contents).setFontSize(7.5f).setTextAlignment(TextAlignment.CENTER);
	}

	private Cell dollarCell() {
		return new Cell().add("$").setFontSize(7f).setTextAlignment(TextAlignment.LEFT).setFontColor(com.itextpdf.kernel.color.Color.GRAY).setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(Border.NO_BORDER);
	}

	private Cell paidCell(String contents) {
		return new Cell().add(contents).setFontSize(7f).setTextAlignment(TextAlignment.RIGHT).setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(Border.NO_BORDER).setBold();
	}

	private Cell paidNoBoldCell(String contents) {
		return new Cell().add(contents).setFontSize(7f).setTextAlignment(TextAlignment.RIGHT).setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(Border.NO_BORDER);
	}

	private Image imageWatermark() throws URISyntaxException, MalformedURLException, IOException {
		Resource resource = resourceLoader.getResource("classpath:static/assets/image/received.png");
		ImageData imageData = ImageDataFactory.create(resource.getFile().getAbsolutePath());
		Image img = new Image(imageData);
		img.setOpacity(0.2f);
		img.scale(0.8f, 0.8f);
		img.setRotationAngle(340);
		return img;
	}

	private Image imageButtons() throws URISyntaxException, MalformedURLException, IOException {
		Resource resource = resourceLoader.getResource("classpath:static/assets/image/invoicebutton.png");
		ImageData imageData = ImageDataFactory.create(resource.getFile().getAbsolutePath());
		Image img = new Image(imageData);
		img.scale(0.5f, 0.5f);
		return img;
	}

	private Image imageInvoiceLogo() throws URISyntaxException, MalformedURLException, IOException {
		Resource resource = resourceLoader.getResource("classpath:static/assets/image/invoicelogo.jpg");
		ImageData imageData = ImageDataFactory.create(resource.getFile().getAbsolutePath());
		Image img = new Image(imageData);
		img.setAutoScale(true);
		return img;
	}



		private Cell detailCell(String contents) {
		return new Cell().add(contents).setFontSize(6.0f);
	}





















public byte[] dummyPdf(StudentDTO student) {
		try {
			// // Set the content type and attachment header.
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter pdfWriter = new PdfWriter(baos);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");
			float wholeWidth = pdfDocument.getDefaultPageSize().getWidth(); // whole width

			// 1. student section
			Table header = getStudentTable(wholeWidth, "Scholarship Trial Test", student);
			document.add(header);
			document.add(onespace);

			// 2. title section
			Table totalScore = new Table(new float[]{wholeWidth});
			totalScore.addCell(detailCell("You have scored 19 out of 40 (48%)").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
			document.add(totalScore);

			// 3. answer section
			Table detailScore = getDetailAnswer(wholeWidth);
			document.add(detailScore);
			document.add(onespace);

			// 4. statistics title section
			Table statsTitle = new Table(new float[]{wholeWidth});
			statsTitle.addCell(detailCell("Scholarship Trial Test - Y6 Humanities Test 19 (Acer) Result").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
			document.add(statsTitle);

			// 5. statistics section
			Table statsSection = getStatisticsTable(wholeWidth);
			document.add(statsSection);

			// 6. branch section
			Table branchNote = new Table(new float[]{wholeWidth});
			branchNote.addCell(detailCell("Glen Waverley (8521 3786)").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
			document.add(branchNote);
			
			// 7. history title section
			Table historyTitle = new Table(new float[]{wholeWidth});
			historyTitle.addCell(detailCell("ENGLISH Past Average & Your Scores").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
			document.add(historyTitle);
			
			// 8. history section
			List<TestResultHistoryDTO> dummy = getDummyHistory();
			Table historySection1 = getHistoryTopTable(wholeWidth, dummy);
			document.add(historySection1);
			Table historySection2 = getHistoryBottomTable(wholeWidth, dummy);
			historySection2.setMarginTop(1);
			document.add(historySection2);
			document.add(onespace);
			
			// 9. history graph section
			Table historyGraph = getHistoryGraphTable(wholeWidth, dummy);
			document.add(historyGraph);
			
			document.close();

			byte[] pdfData = baos.toByteArray();
			return pdfData;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	// 1. student section
	private Table getStudentTable(float width, String title, StudentDTO student){ 
		Table note = new Table(new float[]{width});
		note.addCell(detailCell(title).setItalic().setFontSize(10f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.RIGHT));
		note.addCell(detailCell("Dear " + student.getFirstName() + " " + student.getLastName() + " (" + student.getId()+ ")").setFontSize(8f).setBold().setBorder(Border.NO_BORDER));
		note.addCell(detailCell("Thank you for participating in the JAC " + title).setFontSize(8f).setBold().setBorder(Border.NO_BORDER));
		note.addCell(detailCell(student.getGrade() + " Humanities Test 19 (Acer)").setFontSize(8f).setBold().setBorder(Border.NO_BORDER));
		return note;
	}

	// 3. answer section
	private Table getDetailAnswer(float width){
		Table body = new Table(new float[]{(width/2), (width/2)});
		Table left = getLeftDetailScore(width);
		Table right = getRightDetailScore(width);
		body.addCell(new Cell().add(left).setBorder(Border.NO_BORDER));
		body.addCell(new Cell().add(right).setBorder(Border.NO_BORDER));
		return body;
	}

	// 5. stats section
	private Table getStatisticsTable(float width){
		Table body = new Table(new float[]{(width/2), (width/2)});
		Image left = getLeftBarChart(width);
		Image right = getRightBarChart(width, "Above");
		body.addCell(new Cell().add(left).setBorder(Border.NO_BORDER));
		body.addCell(new Cell().add(right).setBorder(Border.NO_BORDER));
		return body;
	}

	// 8. history section
	private Table getHistoryTopTable(float width, List<TestResultHistoryDTO> histories){
		Table details = new Table(new float[]{((width)/15*2), (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15,});
		// Define header background color
    	DeviceRgb headerBgColor = new DeviceRgb(200, 200, 200); // Light gray
		details.addCell(detailCell("Test No").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("1").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("2").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("3").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("4").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("5").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("6").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("7").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("8").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("9").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("10").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("11").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("12").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("13").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("14").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		// first row
		Cell cell1_1 = detailCell("Your Score").setBold().setTextAlignment(TextAlignment.CENTER);
		details.addCell(cell1_1);
		// loop through the history if testID from 1 to 14
		for (int i = 1; i < 15; i++) {
			String studentScore = "";
			for (TestResultHistoryDTO history : histories) {
				if (history.getTestNo() == i) {
					studentScore = history.getStudentScore() > 0 ? String.valueOf(history.getStudentScore()) : "";
					break;
				}
			}
			Cell cell = detailCell(studentScore).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell);
		}
		
		// second row
		Cell cell2_1 = detailCell("Average").setBold().setTextAlignment(TextAlignment.CENTER);
		details.addCell(cell2_1);
		
		// loop through the history if testID from 1 to 14
		for (int i = 1; i < 15; i++) {
			String average = "";
			for (TestResultHistoryDTO history : histories) {
				if (history.getTestNo() == i) {
					average = history.getAverage() > 0 ? String.valueOf(history.getAverage()) : "";
					break;
				}
			}
			Cell cell = detailCell(average).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell);
		}	
		return details;		
	}

	// 8. history section
	private Table getHistoryBottomTable(float width, List<TestResultHistoryDTO> histories){
		Table details = new Table(new float[]{((width)/15*2), (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15, (width)/15,});
		// Define header background color
    	DeviceRgb headerBgColor = new DeviceRgb(200, 200, 200); // Light gray
		details.addCell(detailCell("Test No").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("15").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("16").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("17").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("18").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("19").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("20").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("21").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("22").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("23").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("24").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("25").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("26").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("27").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("28").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		// first row
		Cell cell1_1 = detailCell("Your Score").setBold().setTextAlignment(TextAlignment.CENTER);
		details.addCell(cell1_1);
		// loop through the history if testID from 1 to 14
		for(int i=15; i<29; i++){
			// int testNo = i;
			String studentScore = "";
			for(TestResultHistoryDTO history : histories){
				if(history.getTestNo() == i){
					studentScore = history.getStudentScore() > 0 ? String.valueOf(history.getStudentScore()) : "";
					break;
				}
			}
			Cell cell = detailCell(studentScore).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell);
			// System.out.println(testNo + " " + studentScore);
		}
		// second row
		Cell cell2_1 = detailCell("Average").setBold().setTextAlignment(TextAlignment.CENTER);
		details.addCell(cell2_1);
		// loop through the history if testID from 1 to 14
		for(int i=15; i<29; i++){
			// int testNo = i;
			String average = "";
			for(TestResultHistoryDTO history : histories){
				if(history.getTestNo() == i){
					// average = String.valueOf(history.getAverage());
					average = history.getAverage() > 0 ? String.valueOf(history.getAverage()) : "";
					break;
				}
			}
			Cell cell = detailCell(average).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell);
			// System.out.println(testNo + " " + average);
		}
		return details;
		
	}

	// 9. history graph section
	private Table getHistoryGraphTable(float width, List<TestResultHistoryDTO> histories){
		Table body = new Table(new float[]{(width)});
		Image line = getLineChart(width, histories);
		body.addCell(new Cell().add(line).setBorder(Border.NO_BORDER));
		return body;
	}

	// get left bar chart
	private Image getLeftBarChart(float width) {
		// Create a chart and add it to the PDF
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		String seriesName = "Scores"; 

		dataset.addValue(15, seriesName, "Your Mark");
		dataset.addValue(52, seriesName, "Average");
		dataset.addValue(83, seriesName, "Highest");
		dataset.addValue(30, seriesName, "Lowest");
		
		JFreeChart barChart = ChartFactory.createBarChart(
				"",
				null,
				null,
				dataset,
				PlotOrientation.VERTICAL,
				true, true, false);

		barChart.setBackgroundPaint(Color.WHITE);
		barChart.getTitle().setPaint(Color.BLACK);

		// Enable anti-aliasing
		barChart.setAntiAlias(true);
		barChart.setTextAntiAlias(true);
		barChart.setRenderingHints(new RenderingHints(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON));
	 
		// Customize the plot
		CategoryPlot plot = (CategoryPlot) barChart.getPlot();
		plot.setBackgroundPaint(Color.WHITE); // Set plot background color
		plot.setDomainGridlinePaint(Color.BLACK);
		plot.setRangeGridlinePaint(Color.BLACK);

		// Set the range axis (Y axis) to display up to 100%
		NumberAxis rangeAxis = (NumberAxis) plot.getRangeAxis();
		rangeAxis.setRange(0.0, 100.0);
		rangeAxis.setTickUnit(new NumberTickUnit(25));

		// Set the font size for the range axis (Y axis)
		rangeAxis.setTickLabelFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 8));
		rangeAxis.setLabelFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 8));
		
		// Set the font size for the domain axis (X axis)
		plot.getDomainAxis().setTickLabelFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 8));
		plot.getDomainAxis().setLabelFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 8));

		// Create and set custom renderer
		BarRenderer renderer = new BarRenderer() {
			@Override
			public Paint getItemPaint(int row, int column) {
				switch (column) {
					case 0: return Color.decode("#033781"); // "Your Mark" - Navy
					case 1: return Color.decode("#ADD8E6"); // "Average" - Light Blue
					case 2: return Color.decode("#ADD8E6"); // "Highest" - Light Blue
					case 3: return Color.decode("#ADD8E6"); // "Lowest" - Light Blue
					default: return super.getItemPaint(row, column);
				}
			}
		};

		// Apply to plot
		plot.setRenderer(renderer);
		// Remove decorations
		renderer.setShadowVisible(false); // Disable shadows
		renderer.setBarPainter(new StandardBarPainter()); // Remove gradient effects
		renderer.setDrawBarOutline(true); // Keep bar outlines for clarity
		renderer.setSeriesOutlinePaint(0, Color.BLACK); // Black outline for bars
		renderer.setSeriesOutlineStroke(0, new BasicStroke(1.0f)); // Define outline thickness

		// Format labels as percentages
		NumberFormat percentFormat = NumberFormat.getNumberInstance();
		percentFormat.setMaximumFractionDigits(0);
		StandardCategoryItemLabelGenerator labelGenerator = new StandardCategoryItemLabelGenerator("{2}%", percentFormat);

		// Apply label generator
		renderer.setDefaultItemLabelGenerator(labelGenerator);
		renderer.setDefaultItemLabelsVisible(true);

		// Adjust bar width
		renderer.setMaximumBarWidth(0.15);

		// Set the outline paint and stroke for the border of series 1
		renderer.setSeriesOutlinePaint(1, Color.BLACK); // Set the border color
		renderer.setSeriesOutlineStroke(1, new BasicStroke(1.0f)); // Set the border thickness
		renderer.setDrawBarOutline(true); // Enable drawing the outline

		// Set the outline paint and stroke for the border of series 0 (if needed)
		renderer.setSeriesOutlinePaint(0, Color.BLACK); // Set the border color for series 0
		renderer.setSeriesOutlineStroke(0, new BasicStroke(1.0f)); // Set the border thickness for series 0
		renderer.setDrawBarOutline(true); // Enable drawing the outline

		// Set the font size for the legend
		barChart.removeLegend();
		ByteArrayOutputStream chartOutputStream = new ByteArrayOutputStream();
		try {
			// Adjust the width and height proportionally
			int chartWidth = (int) (width / 2.25);
			int chartHeight = (int) (chartWidth * 0.7); // Adjust height to maintain aspect ratio
			ChartUtils.writeChartAsPNG(chartOutputStream, barChart, chartWidth, chartHeight);
		} catch (IOException e) {
			e.printStackTrace();
		}
		ImageData imageData = ImageDataFactory.create(chartOutputStream.toByteArray());
		Image chartImage = new Image(imageData);
		// Center horizontally
		chartImage.setHorizontalAlignment(com.itextpdf.layout.property.HorizontalAlignment.CENTER);
		return chartImage;
	}

	// get right bar chart
	private Image getRightBarChart(float width, String match) {
		// Create dataset
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		dataset.addValue(23, "Scores", "Lowest");
		dataset.addValue(17, "Scores", "Lower");
		dataset.addValue(20, "Scores", "Middle");
		dataset.addValue(17, "Scores", "Higher");
		dataset.addValue(12, "Scores", "Above");
		dataset.addValue(11, "Scores", "Top");
	
		// Create the chart
		JFreeChart barChart = ChartFactory.createBarChart(
				"",
				null,
				null,
				dataset,
				PlotOrientation.VERTICAL,
				true, true, false
		);
	
		// Customize chart background
		barChart.setBackgroundPaint(Color.WHITE);
		barChart.setAntiAlias(true);
		barChart.setTextAntiAlias(true);
	
		// Customize plot
		CategoryPlot plot = (CategoryPlot) barChart.getPlot();
		plot.setBackgroundPaint(Color.WHITE);
		plot.setDomainGridlinePaint(Color.BLACK);
		plot.setRangeGridlinePaint(Color.BLACK);
	
		// Configure range axis (Y-axis)
		NumberAxis rangeAxis = (NumberAxis) plot.getRangeAxis();
		rangeAxis.setRange(0.0, 100.0);
		rangeAxis.setTickUnit(new NumberTickUnit(25));
		rangeAxis.setTickLabelFont(new Font("SansSerif", Font.PLAIN, 8));
		rangeAxis.setLabelFont(new Font("SansSerif", Font.BOLD, 8));
	
		// Configure category axis (X-axis)
		plot.getDomainAxis().setTickLabelFont(new Font("SansSerif", Font.PLAIN, 8));
		plot.getDomainAxis().setLabelFont(new Font("SansSerif", Font.BOLD, 8));
	
		// Custom renderer to apply different colors and display percentages
		BarRenderer renderer = new BarRenderer() {
			@Override
			public Paint getItemPaint(int row, int column) {
				// Get the category name for the current column
				String category = (String) dataset.getColumnKey(column);
				if (category.equals(match)) {
					return Color.decode("#033781"); // Highlight matching category
				} else {
					return Color.decode("#ADD8E6"); // Default Light Blue
				}
			}
		};
	
		// Remove gradient effects
		renderer.setBarPainter(new StandardBarPainter());
		renderer.setShadowVisible(false);
	
		// Set border color and thickness
		renderer.setDrawBarOutline(true);
		renderer.setSeriesOutlinePaint(0, Color.BLACK);
		renderer.setSeriesOutlineStroke(0, new BasicStroke(1.0f));
	
		// Format labels to display as percentages
		NumberFormat percentFormat = NumberFormat.getNumberInstance();
		percentFormat.setMaximumFractionDigits(0);
		StandardCategoryItemLabelGenerator labelGenerator = new StandardCategoryItemLabelGenerator("{2}%", percentFormat);
	
		// Apply label generator
		renderer.setDefaultItemLabelGenerator(labelGenerator);
		renderer.setDefaultItemLabelsVisible(true);
	
		// Adjust bar width
		renderer.setMaximumBarWidth(0.15);
	
		// Apply renderer to plot
		plot.setRenderer(renderer);
	
		// Remove legend
		barChart.removeLegend();
	
		// Convert chart to an image
		ByteArrayOutputStream chartOutputStream = new ByteArrayOutputStream();
		try {
			int chartWidth = (int) (width / 2.25);
			int chartHeight = (int) (chartWidth * 0.7);
			ChartUtils.writeChartAsPNG(chartOutputStream, barChart, chartWidth, chartHeight);
		} catch (IOException e) {
			e.printStackTrace();
		}
	
		// Create and return image
		ImageData imageData = ImageDataFactory.create(chartOutputStream.toByteArray());
		Image chartImage = new Image(imageData);
		chartImage.setHorizontalAlignment(com.itextpdf.layout.property.HorizontalAlignment.CENTER);
		return chartImage;
	}

	// draw line chart
	private Image getLineChart(float width, List<TestResultHistoryDTO> histories) {
		// Create dataset
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		for (int i = 1; i < 29; i++) {
			String testNo = String.valueOf(i);
			int studentScore = 0;
			int average = 0;
			for (TestResultHistoryDTO history : histories) {
				if (history.getTestNo() == i) {
					studentScore = history.getStudentScore();
					average = history.getAverage();
					break;
				}
			}
			if (studentScore > 0) {
				dataset.addValue(studentScore, "Your Score", testNo);
			}
			if (average > 0) {
				dataset.addValue(average, "Average", testNo);
			}
		}
		// Create Line Chart
		JFreeChart lineChart = ChartFactory.createLineChart(
				"", // Chart title
				"", // X-Axis Label
				"Score", // Y-Axis Label
				dataset,
				PlotOrientation.VERTICAL,
				true, true, false);
	
		// Set chart background
		lineChart.setBackgroundPaint(Color.WHITE);
		// Customize the plot
		CategoryPlot plot = (CategoryPlot) lineChart.getPlot();
		plot.setBackgroundPaint(Color.WHITE);
		plot.setDomainGridlinePaint(Color.LIGHT_GRAY);
		plot.setRangeGridlinePaint(Color.LIGHT_GRAY);
		// Customize axis
		NumberAxis rangeAxis = (NumberAxis) plot.getRangeAxis();
		rangeAxis.setRange(0.0, 100.0); // Keep the range between 0 to 100
		rangeAxis.setTickUnit(new NumberTickUnit(10)); // Show every 10%
		rangeAxis.setNumberFormatOverride(new NumberFormat() {
			@Override
			public StringBuffer format(double number, StringBuffer toAppendTo, FieldPosition pos) {
				return toAppendTo.append((int) number).append("%"); // Append '%' correctly
			}

			@Override
			public Number parse(String source, ParsePosition parsePosition) {
				return null;
			}

			@Override
			public StringBuffer format(long number, StringBuffer toAppendTo, FieldPosition pos) {
				// TODO Auto-generated method stub
				throw new UnsupportedOperationException("Unimplemented method 'format'");
			}
		});
		rangeAxis.setTickLabelFont(new Font("SansSerif", Font.PLAIN, 10));
		rangeAxis.setLabelFont(new Font("SansSerif", Font.BOLD, 12));
		rangeAxis.setLabel("");
		CategoryAxis domainAxis = plot.getDomainAxis();
		domainAxis.setTickLabelFont(new Font("SansSerif", Font.PLAIN, 10));
		domainAxis.setLabelFont(new Font("SansSerif", Font.BOLD, 12));
		// Customize renderer
		LineAndShapeRenderer renderer = new LineAndShapeRenderer();
		renderer.setSeriesPaint(0, Color.decode("#ADD8E6")); // Average
		renderer.setSeriesStroke(0, new BasicStroke(2.0f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 0, new float[]{5, 5}, 0)); // Dashed line
		renderer.setSeriesShapesVisible(0, true);
		renderer.setSeriesPaint(1, Color.decode("#033781")); // Your Score 
		renderer.setSeriesStroke(1, new BasicStroke(2.0f));
		renderer.setSeriesShapesVisible(1, true);
		renderer.setSeriesItemLabelFont(1, new Font("SansSerif", Font.BOLD, 10));

		// Add item labels to show scores only for "Your Score"
		// Custom Label Generator to Append '%' to "Your Score"
		renderer.setSeriesItemLabelGenerator(1, new StandardCategoryItemLabelGenerator() {
			@Override
			public String generateLabel(CategoryDataset dataset, int row, int column) {
				Number value = dataset.getValue(row, column);
				if (value != null) {
					return value.intValue() + "%"; // Append '%' to each value
				}
				return "";
			}
		});
		renderer.setSeriesItemLabelsVisible(1, true);
		renderer.setSeriesItemLabelFont(1, new Font("SansSerif", Font.PLAIN, 10));
		renderer.setSeriesPositiveItemLabelPosition(1, new ItemLabelPosition(ItemLabelAnchor.OUTSIDE12, TextAnchor.BOTTOM_CENTER));
	
		plot.setRenderer(renderer);
		// Convert chart to image
		ByteArrayOutputStream chartOutputStream = new ByteArrayOutputStream();
		try {
			int chartWidth = (int) (width / 1.15);
			int chartHeight = (int) (chartWidth * 0.5);
			ChartUtils.writeChartAsPNG(chartOutputStream, lineChart, chartWidth, chartHeight);
		} catch (IOException e) {
			e.printStackTrace();
		}
		ImageData imageData = ImageDataFactory.create(chartOutputStream.toByteArray());
		Image chartImage = new Image(imageData);
		chartImage.setHorizontalAlignment(com.itextpdf.layout.property.HorizontalAlignment.CENTER);
		return chartImage;
	}


	// left answer score section
	private Table getLeftDetailScore(float width){ 
		Table subject = new Table(new float[]{(width/2)});
		Table details = new Table(new float[]{(width/2)/10, ((width/2)/10)*2, (width/2)/10, ((width/2)/10)*2, ((width/2)/10)*4});
		details.addCell(detailCell("Q.No").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Resp").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Ans").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Percent").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Topic").setBold().setBorder(Border.NO_BORDER));
		int count1 = 30;
		for(int i=0; i< count1; i++){
			// background color
			com.itextpdf.kernel.color.Color backgroundColor = (i % 2 == 0) ? com.itextpdf.kernel.color.Color.LIGHT_GRAY : com.itextpdf.kernel.color.Color.WHITE;
			Cell cell1 = detailCell((i + 1) + "").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setBold().setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell1);			
			Cell cell2 = detailCell("C - O").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell2);			
			Cell cell3 = detailCell("C").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell3);			
			Cell cell4 = detailCell("57").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER); // percent
			details.addCell(cell4);			
			Cell cell5 = detailCell("Comprehension").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.LEFT); // topics
			details.addCell(cell5);
		}
		subject.addCell(details.setMarginTop(1));
		return subject;
	}

	private Table getRightDetailScore(float width){ 
		Table subject = new Table(new float[]{(width/2)});
		Table details = new Table(new float[]{(width/2)/10, ((width/2)/10)*2, (width/2)/10, ((width/2)/10)*2, ((width/2)/10)*4});
		
		details.addCell(detailCell("Q.No").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Resp").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Ans").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Percent").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Topic").setBold().setBorder(Border.NO_BORDER));
		
		int count2 = 50;
		for(int i=30; i< count2; i++){
			// background color
			com.itextpdf.kernel.color.Color backgroundColor = (i % 2 == 0) ? com.itextpdf.kernel.color.Color.LIGHT_GRAY : com.itextpdf.kernel.color.Color.WHITE;
			Cell cell1 = detailCell((i + 1) + "").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setBold().setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell1);            
			Cell cell2 = detailCell("B - X").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell2);            
			Cell cell3 = detailCell("A").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell3);            
			Cell cell4 = detailCell("31").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER); // percent
			details.addCell(cell4);            
			Cell cell5 = detailCell("Spelling").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.LEFT); // topics
			details.addCell(cell5);
		}
		
		subject.addCell(details.setMarginTop(1).setBorder(Border.NO_BORDER));
		subject.setBorder(Border.NO_BORDER);
		return subject;
	}



	private List<TestResultHistoryDTO> getDummyHistory(){
		List<TestResultHistoryDTO> list = new ArrayList<>();
		for(int i=5; i<10; i++){
			TestResultHistoryDTO dto = new TestResultHistoryDTO();
			dto.setTestNo(i);
			// random number from 20~99
			dto.setAverage(new Random().nextInt(80) + 20);
			list.add(dto);
		}
		for(int i=10; i<=20; i++){
			TestResultHistoryDTO dto = new TestResultHistoryDTO();
			dto.setTestNo(i);
			// random number from 20~99
			dto.setAverage(new Random().nextInt(80) + 20);
			dto.setStudentScore(new Random().nextInt(80) + 20);
			list.add(dto);
		}
		return list;
	}

	

















}
