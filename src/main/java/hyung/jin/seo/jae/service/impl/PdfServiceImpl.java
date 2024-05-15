package hyung.jin.seo.jae.service.impl;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import com.itextpdf.io.image.ImageData;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.color.Color;
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

import hyung.jin.seo.jae.service.PdfService;

@Service
public class PdfServiceImpl implements PdfService {

	@Autowired
	private ResourceLoader resourceLoader;

	@Override
	public void generatePdf(String fileName){
		
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
			Table title = getTitleTable(wholeWidth);
			document.add(title);
			document.add(onespace);

			// 3. header section
			Table header = getHeaderTable(wholeWidth);
			document.add(header);

			// 4. detail section
			Table detail = getDetailTable(wholeWidth);
			document.add(detail);
			document.add(onespace);

			// 5. paid section
			Table paid = getPaidTable(wholeWidth);
			document.add(paid);
			document.add(onespace);
			document.add(onespace);

			// 6. note section
			Table note = getNoteTable(wholeWidth);
			document.add(note);

			document.close();
		} catch (IOException | URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private Table getNoteTable(float wholeWidth) {
		Table note = new Table(new float[]{wholeWidth}).setBorder(new SolidBorder(0.5f));
		note.addCell(boldCell("Note :").setItalic().setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setPaddingLeft(5));
		String content = "1. Total payment dute in 14 days<br>2. Please make payment to the following account<br>3. Please use the invoice number as the reference when making payment<br>4. If you have any questions about this invoice, please contact Jin Seo on 03 9361 0051";
		String[] contents = StringUtils.splitByWholeSeparator(content, "<br>");
		if(contents != null){
			for(String msg : contents){
				note.addCell(new Cell().add(msg).setFontSize(8f).setBorder(Border.NO_BORDER).setPaddingLeft(10));
			}
		}
		return note;
	}
	
	private Table getDetailTable(float wholeWidth) {
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

		// data
		detail.addCell(new Cell().add(boldCell("Class [11] TT6 Online")).setTextAlignment(TextAlignment.CENTER));
		detail.addCell(new Cell().add(boldCell("")).setTextAlignment(TextAlignment.CENTER));
		detail.addCell(new Cell().add(boldCell("10")).setTextAlignment(TextAlignment.RIGHT));
		detail.addCell(new Cell().add(boldCell("50.00")).setTextAlignment(TextAlignment.RIGHT));
		detail.addCell(new Cell().add(boldCell("0")).setTextAlignment(TextAlignment.RIGHT));
		detail.addCell(new Cell().add(boldCell("500.00")).setTextAlignment(TextAlignment.RIGHT));
		// note
		detail.addCell(new Cell(0, 6).add(boldCell("* Other Information : new")).setTextAlignment(TextAlignment.LEFT).setPaddingLeft(10));

		return detail;
	}

	private Table getTitleTable(float wholeWidth) throws MalformedURLException, URISyntaxException, IOException {
		float one = wholeWidth*2/3;
		float two = wholeWidth/3;
		float twocolumWith[] = {one, two};
		Table table = new Table(twocolumWith);
		table.addCell(new Cell().add("TAX INVOICE").setBorder(Border.NO_BORDER).setBold().setFontSize(20f).setVerticalAlignment(VerticalAlignment.MIDDLE));
		Table nested = new Table(new float[]{two});
		nested.addCell(new Cell().add(imageInvoiceLogo()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell("03 9361 0051").setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell("16c 77-79 Ashley St").setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell("ABN 123456789").setBorder(Border.NO_BORDER));
		table.addCell(new Cell().add(nested).setBorder(Border.NO_BORDER));
		return table;
	}

	private Table getHeaderTable(float wholeWidth) {
		Table header = new Table(new float[]{wholeWidth/2, wholeWidth/2});
		Table nested1 = new Table(new float[]{(wholeWidth/2)/4, (wholeWidth/2)*3/4});
		nested1.addCell(boldCell("Date :").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("14/05/2024").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("Name :").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("Jin Seo").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("Student ID :").setBorder(Border.NO_BORDER));
		nested1.addCell(boldCell("12400001").setBorder(Border.NO_BORDER));
		header.addCell(new Cell().add(nested1).setBorder(Border.NO_BORDER));
		Table nested2 = new Table(new float[]{(wholeWidth/2)/4, (wholeWidth/2)*3/4});
		nested2.addCell(boldCell("Due Date :").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("14/05/2024").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("Grade :").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("TT6").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("Invoice No :").setBorder(Border.NO_BORDER));
		nested2.addCell(boldCell("111200001").setBorder(Border.NO_BORDER));
		header.addCell(new Cell().add(nested2).setBorder(Border.NO_BORDER));
		return header;
	}

	private Table getPaidTable(float wholeWidth) {
		Table paid = new Table(new float[]{wholeWidth/4, wholeWidth/4, wholeWidth/4, wholeWidth/4}).setBorder(Border.NO_BORDER);
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().setBorder(Border.NO_BORDER));
		Table paidDetail = new Table(new float[]{(wholeWidth/4)*3/7, (wholeWidth/4)/7, (wholeWidth/4)*3/7}).setBorder(Border.NO_BORDER);
		paidDetail.addCell(paidCell("FINAL TOTAL").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("500.00").setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("FEE PAID").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidNoBoldCell("- 500.00").setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidCell("BALANCE").setBorder(Border.NO_BORDER));
		paidDetail.addCell(dollarCell().setBorder(Border.NO_BORDER));
		paidDetail.addCell(paidNoBoldCell("PAID IN FULL").setBorder(Border.NO_BORDER));
		paid.addCell(new Cell().add(paidDetail).setBorder(Border.NO_BORDER));
		return paid;
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
		return new Cell().add("$").setFontSize(7f).setTextAlignment(TextAlignment.LEFT).setFontColor(Color.GRAY).setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(Border.NO_BORDER);
	}

	private Cell paidCell(String contents) {
		return new Cell().add(contents).setFontSize(7f).setTextAlignment(TextAlignment.RIGHT).setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(Border.NO_BORDER).setBold();
	}

	private Cell paidNoBoldCell(String contents) {
		return new Cell().add(contents).setFontSize(7f).setTextAlignment(TextAlignment.RIGHT).setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(Border.NO_BORDER);
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

}
