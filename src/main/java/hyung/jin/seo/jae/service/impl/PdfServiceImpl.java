package hyung.jin.seo.jae.service.impl;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import com.itextpdf.io.image.ImageData;
import com.itextpdf.io.image.ImageDataFactory;
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

import hyung.jin.seo.jae.service.PdfService;

@Service
public class PdfServiceImpl implements PdfService {

	@Autowired
	private ResourceLoader resourceLoader;

	@Override
	public void generatePdf(String fileName){
		try (PdfWriter pdfWriter = new PdfWriter(fileName)) {
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");

			// button section
			Image buttons = imageButtons();
			float x = pdfDocument.getDefaultPageSize().getWidth()/2 - 90;
			float y = pdfDocument.getDefaultPageSize().getHeight()/2 + 380;
			buttons.setFixedPosition(x, y);
			document.add(buttons);
			document.add(onespace);
			document.add(onespace);

			// title section
			Table title = getHeader();
			document.add(title);
			document.add(onespace);



			document.close();
		} catch (IOException | URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private Table getHeader() throws MalformedURLException, URISyntaxException, IOException {
		float twocol = 285f;
		float twocol150 = twocol+150f;
		float twocolumWith[] = {twocol150, twocol};

		Table table = new Table(twocolumWith);
		table.addCell(new Cell().add("TAX INVOICE").setBorder(Border.NO_BORDER).setBold().setFontSize(20f));


		Table nested = new Table(new float[]{twocol});
		nested.addCell(new Cell().add(imageInvoiceLogo()).setBorder(Border.NO_BORDER));
		nested.addCell(boldTitleCell("03 9361 0051"));
		nested.addCell(boldTitleCell("16c 77-79 Ashley St"));
		nested.addCell(boldTitleCell("ABN 123456789"));


		table.addCell(new Cell().add(nested).setBorder(Border.NO_BORDER));
		return table;
	}

	private Cell boldTitleCell(String contents) {
		return new Cell().add(contents).setBorder(Border.NO_BORDER).setBold().setFontSize(8f);
	}

	private Cell boldCell(String contents) {
		return new Cell().add(contents).setBorder(Border.NO_BORDER).setBold().setFontSize(9f);
	}

	private Cell tableHeaderCell(String contents) {
		return new Cell().add(contents).setBorder(Border.NO_BORDER).setFontSize(9f).setTextAlignment(TextAlignment.CENTER);
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
