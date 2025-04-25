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
import com.itextpdf.kernel.pdf.PdfReader;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.border.Border;
import com.itextpdf.layout.element.AreaBreak;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.property.TextAlignment;
import com.itextpdf.layout.property.VerticalAlignment;

import hyung.jin.seo.jae.dto.StudentDTO;
import hyung.jin.seo.jae.dto.TestResultHistoryDTO;
import hyung.jin.seo.jae.model.TestAnswerItem;
import hyung.jin.seo.jae.service.PdfService;
import hyung.jin.seo.jae.utils.JaeConstants;
import hyung.jin.seo.jae.utils.JaeUtils;
import com.itextpdf.layout.border.SolidBorder;
import hyung.jin.seo.jae.dto.BranchDTO;
import hyung.jin.seo.jae.dto.EnrolmentDTO;
import hyung.jin.seo.jae.dto.InvoiceDTO;
import hyung.jin.seo.jae.dto.MaterialDTO;
import hyung.jin.seo.jae.dto.MoneyDTO;
import hyung.jin.seo.jae.dto.PaymentDTO;
import java.io.ByteArrayInputStream;


@Service
public class PdfServiceImpl implements PdfService {

	private static final int ANSWER_SPLIT_SIZE = 30;

	private static final int MEGA_REVISION_HISTORY_SIZE = 5;
	
	private static final int EDU_HISTORY_SIZE = 32;
	
	private static final int ACER_HISTORY_SIZE = 40;

	private static final int[][] PERCENT_GRADE = {
		{31, 45, 67, 34, 56, 78, 42, 65, 37, 59, 32, 54, 76, 43, 66, 38, 57, 33, 55, 77, 44, 68, 39, 58, 35, 53, 75, 41, 64, 36, 52, 74, 40, 63, 37, 51, 73, 46, 62, 38, 50, 72, 47, 61, 39, 49, 71, 48, 60, 40, 48, 70, 42, 59, 41, 47, 69, 43, 58, 42},
		{32, 46, 68, 35, 57, 77, 43, 66, 38, 58, 33, 55, 75, 44, 67, 39, 56, 34, 54, 76, 45, 69, 40, 57, 36, 52, 74, 42, 65, 37, 51, 73, 41, 64, 38, 50, 72, 47, 63, 39, 49, 71, 48, 62, 40, 48, 70, 49, 61, 41, 47, 69, 43, 60, 42, 46, 68, 44, 59, 43},
		{33, 47, 69, 36, 58, 76, 44, 67, 39, 57, 34, 56, 74, 45, 68, 40, 55, 35, 53, 75, 46, 70, 41, 56, 37, 51, 73, 43, 66, 38, 50, 72, 42, 65, 39, 49, 71, 48, 64, 40, 48, 70, 49, 63, 41, 47, 69, 50, 62, 42, 46, 68, 44, 61, 43, 45, 67, 45, 60, 44},
		{34, 48, 70, 37, 59, 75, 45, 68, 40, 56, 35, 57, 73, 46, 69, 41, 54, 36, 52, 74, 47, 71, 42, 55, 38, 50, 72, 44, 67, 39, 49, 71, 43, 66, 40, 48, 70, 49, 65, 41, 47, 69, 50, 64, 42, 46, 68, 51, 63, 43, 45, 67, 45, 62, 44, 44, 66, 46, 61, 45},
		{35, 49, 71, 38, 60, 74, 46, 69, 41, 55, 36, 58, 72, 47, 70, 42, 53, 37, 51, 73, 48, 72, 43, 54, 39, 49, 71, 45, 68, 40, 48, 70, 44, 67, 41, 47, 69, 50, 66, 42, 46, 68, 51, 65, 43, 45, 67, 52, 64, 44, 44, 66, 46, 63, 45, 43, 65, 47, 62, 46},
		{36, 50, 72, 39, 61, 73, 47, 70, 42, 54, 37, 59, 71, 48, 71, 43, 52, 38, 50, 72, 49, 73, 44, 53, 40, 48, 70, 46, 69, 41, 47, 69, 45, 68, 42, 46, 68, 51, 67, 43, 45, 67, 52, 66, 44, 44, 66, 53, 65, 45, 43, 65, 47, 64, 46, 42, 64, 48, 63, 47},
		{37, 51, 73, 40, 62, 72, 48, 71, 43, 53, 38, 60, 70, 49, 72, 44, 51, 39, 49, 71, 50, 74, 45, 52, 41, 47, 69, 47, 70, 42, 46, 68, 46, 69, 43, 45, 67, 52, 68, 44, 44, 66, 53, 67, 45, 43, 65, 54, 66, 46, 42, 64, 48, 65, 47, 41, 63, 49, 64, 48},
		{38, 52, 74, 41, 63, 71, 49, 72, 44, 52, 39, 61, 69, 50, 73, 45, 50, 40, 48, 70, 51, 75, 46, 51, 42, 46, 68, 48, 71, 43, 45, 67, 47, 70, 44, 44, 66, 53, 69, 45, 43, 65, 54, 68, 46, 42, 64, 55, 67, 47, 41, 63, 49, 66, 48, 40, 62, 50, 65, 49},
		{39, 53, 75, 42, 64, 70, 50, 73, 45, 51, 40, 62, 68, 51, 74, 46, 49, 41, 47, 69, 52, 76, 47, 50, 43, 45, 67, 49, 72, 44, 44, 66, 48, 71, 45, 43, 65, 54, 70, 46, 42, 64, 55, 69, 47, 41, 63, 56, 68, 48, 40, 62, 50, 67, 49, 39, 61, 51, 66, 50},
		{40, 54, 76, 43, 65, 69, 51, 74, 46, 50, 41, 63, 67, 52, 75, 47, 48, 42, 46, 68, 53, 77, 48, 49, 44, 44, 66, 50, 73, 45, 43, 65, 49, 72, 46, 42, 64, 55, 71, 47, 41, 63, 56, 70, 48, 40, 62, 57, 69, 49, 39, 61, 51, 68, 50, 38, 60, 52, 67, 51},
		{41, 55, 77, 44, 66, 68, 52, 75, 47, 49, 42, 64, 66, 53, 76, 48, 47, 43, 45, 67, 54, 78, 49, 48, 45, 43, 65, 51, 74, 46, 42, 64, 50, 73, 47, 41, 63, 56, 72, 48, 40, 62, 57, 71, 49, 39, 61, 58, 70, 50, 38, 60, 52, 69, 51, 37, 59, 53, 68, 52},
		{42, 56, 78, 45, 67, 67, 53, 76, 48, 48, 43, 65, 65, 54, 77, 49, 46, 44, 44, 66, 55, 77, 50, 47, 46, 42, 64, 52, 75, 47, 41, 63, 51, 74, 48, 40, 62, 57, 73, 49, 39, 61, 58, 72, 50, 38, 60, 59, 71, 51, 37, 59, 53, 70, 52, 36, 58, 54, 69, 53},
		{43, 57, 77, 46, 68, 66, 54, 77, 49, 47, 44, 66, 64, 55, 78, 50, 45, 45, 43, 65, 56, 76, 51, 46, 47, 41, 63, 53, 76, 48, 40, 62, 52, 75, 49, 39, 61, 58, 74, 50, 38, 60, 59, 73, 51, 37, 59, 60, 72, 52, 36, 58, 54, 71, 53, 35, 57, 55, 70, 54},
		{44, 58, 76, 47, 69, 65, 55, 78, 50, 46, 45, 67, 63, 56, 77, 51, 44, 46, 42, 64, 57, 75, 52, 45, 48, 40, 62, 54, 77, 49, 39, 61, 53, 76, 50, 38, 60, 59, 75, 51, 37, 59, 60, 74, 52, 36, 58, 61, 73, 53, 35, 57, 55, 72, 54, 34, 56, 56, 71, 55},
		{45, 59, 75, 48, 70, 64, 56, 77, 51, 45, 46, 68, 62, 57, 76, 52, 43, 47, 41, 63, 58, 74, 53, 44, 49, 39, 61, 55, 78, 50, 38, 60, 54, 77, 51, 37, 59, 60, 76, 52, 36, 58, 61, 75, 53, 35, 57, 62, 74, 54, 34, 56, 56, 73, 55, 33, 55, 57, 72, 56},
		{46, 60, 74, 49, 71, 63, 57, 76, 52, 44, 47, 69, 61, 58, 75, 53, 42, 48, 40, 62, 59, 73, 54, 43, 50, 38, 60, 56, 77, 51, 37, 59, 55, 78, 52, 36, 58, 61, 77, 53, 35, 57, 62, 76, 54, 34, 56, 63, 75, 55, 33, 55, 57, 74, 56, 32, 54, 58, 73, 57},
		{47, 61, 73, 50, 72, 62, 58, 75, 53, 43, 48, 70, 60, 59, 74, 54, 41, 49, 39, 61, 60, 72, 55, 42, 51, 37, 59, 57, 76, 52, 36, 58, 56, 77, 53, 35, 57, 62, 78, 54, 34, 56, 63, 77, 55, 33, 55, 64, 76, 56, 32, 54, 58, 75, 57, 31, 53, 59, 74, 58},
		{48, 62, 72, 51, 73, 61, 59, 74, 54, 42, 49, 71, 59, 60, 73, 55, 40, 50, 38, 60, 61, 71, 56, 41, 52, 36, 58, 58, 75, 53, 35, 57, 57, 76, 54, 34, 56, 63, 77, 55, 33, 55, 64, 78, 56, 32, 54, 65, 77, 57, 31, 53, 59, 76, 58, 32, 52, 60, 75, 59},
		{49, 63, 71, 52, 74, 60, 60, 73, 55, 41, 50, 72, 58, 61, 72, 56, 39, 51, 37, 59, 62, 70, 57, 40, 53, 35, 57, 59, 74, 54, 34, 56, 58, 75, 55, 33, 55, 64, 76, 56, 32, 54, 65, 77, 57, 31, 53, 66, 78, 58, 32, 52, 60, 77, 59, 33, 51, 61, 76, 60},
		{50, 64, 70, 53, 75, 59, 61, 72, 56, 40, 51, 73, 57, 62, 71, 57, 38, 52, 36, 58, 63, 69, 58, 39, 54, 34, 56, 60, 73, 55, 33, 55, 59, 74, 56, 32, 54, 65, 75, 57, 31, 53, 66, 76, 58, 32, 52, 67, 77, 59, 33, 51, 61, 78, 60, 34, 50, 62, 77, 61}
	};

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
		@SuppressWarnings("unchecked")
		List<EnrolmentDTO> enrolments = data.get(JaeConstants.PAYMENT_ENROLMENTS) != null ? (List<EnrolmentDTO>) data.get(JaeConstants.PAYMENT_ENROLMENTS) : new ArrayList<>();
		@SuppressWarnings("unchecked") 
		List<MaterialDTO> materials = data.get(JaeConstants.PAYMENT_MATERIALS) != null ? (List<MaterialDTO>) data.get(JaeConstants.PAYMENT_MATERIALS) : new ArrayList<>();
		@SuppressWarnings("unchecked")
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

	@SuppressWarnings("unchecked")
	private Object[] getReceiptDetailTable(float wholeWidth, Map<String, Object> data) {
		List<EnrolmentDTO> enrolments = data.get(JaeConstants.PAYMENT_ENROLMENTS) != null ? (List<EnrolmentDTO>) data.get(JaeConstants.PAYMENT_ENROLMENTS) : new ArrayList<>();
		List<MaterialDTO> materials = data.get(JaeConstants.PAYMENT_MATERIALS) != null ? (List<MaterialDTO>) data.get(JaeConstants.PAYMENT_MATERIALS) : new ArrayList<>();
		List<PaymentDTO> payments = data.get(JaeConstants.PAYMENT_PAYMENTS) != null ? (List<PaymentDTO>) data.get(JaeConstants.PAYMENT_PAYMENTS) : new ArrayList<>();
		// InvoiceDTO invoice = data.get(JaeConstants.INVOICE_INFO) != null ? (InvoiceDTO) data.get(JaeConstants.INVOICE_INFO) : new InvoiceDTO();
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

	// generate empty test result pdf
	@Override
	public byte[] generateEmptyTestResult(Long studentId) {
		try {
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter pdfWriter = new PdfWriter(baos);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			document.add(new Paragraph("No test result found for student with ID: " + studentId)
					.setFontSize(12f)
					.setBold()
					.setTextAlignment(TextAlignment.CENTER)
					.setMarginTop(200));
			document.close();
			byte[] pdfData = baos.toByteArray();
			return pdfData;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	// generate test result pdf
	@SuppressWarnings("unchecked")
	@Override
	public byte[] generateTestResultPdf(Map<String, Object> data) {
		// prepare ingredients
		StudentDTO student = (StudentDTO) data.get(JaeConstants.STUDENT_INFO);
		String testGroupName = (String) data.get(JaeConstants.TEST_GROUP_INFO);
		BranchDTO branch = (BranchDTO) data.get(JaeConstants.BRANCH_INFO);
		String volume = (String) data.get(JaeConstants.VOLUME_INFO);
		List<String> testTitles = (List<String>) data.get(JaeConstants.TEST_TITLE_INFO); // check how many test titles for loop
		List<Integer> testAnswerTotals = (List<Integer>) data.get(JaeConstants.TEST_ANSWER_TOTAL_COUNT);
		List<Integer> studentAnswerCorrects = (List<Integer>) data.get(JaeConstants.STUDENT_ANSWER_CORRECT_COUNT);
		List<Double> scores = (List<Double>) data.get(JaeConstants.STUDENT_SCORE);
		List<Double> averages = (List<Double>) data.get(JaeConstants.TEST_AVERAGE_SCORE);
		List<Double> highests = (List<Double>) data.get(JaeConstants.TEST_HIGHEST_SCORE);
		List<Double> lowests = (List<Double>) data.get(JaeConstants.TEST_LOWEST_SCORE);

		List<List<Integer>> studentAnswers = (List<List<Integer>>) data.get(JaeConstants.STUDENT_ANSWERS);
		List<List<TestAnswerItem>> testAnswers = (List<List<TestAnswerItem>>) data.get(JaeConstants.TEST_ANSWERS);
		List<List<TestResultHistoryDTO>> histories = (List<List<TestResultHistoryDTO>>) data.get(JaeConstants.TEST_RESULT_HISTORY);
		// get test group
		int testGroup = 0;
		if(StringUtils.startsWithIgnoreCase(testGroupName, "Mega")){
			testGroup = 1;
		}else if(StringUtils.startsWithIgnoreCase(testGroupName, "Revision")) {
			testGroup = 2;
		}else if(StringUtils.startsWithIgnoreCase(testGroupName, "Edu")){
			testGroup = 3;
		}else if(StringUtils.startsWithIgnoreCase(testGroupName, "Acer")){
			testGroup = 4;
		}else{
			testGroup = 5;
		}
		try {
			// // Set the content type and attachment header.
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter pdfWriter = new PdfWriter(baos);
			PdfDocument pdfDocument = new PdfDocument(pdfWriter);
			pdfDocument.setDefaultPageSize(PageSize.A4);
			Document document = new Document(pdfDocument);
			Paragraph onespace = new Paragraph("\n");
			float wholeWidth = pdfDocument.getDefaultPageSize().getWidth(); // whole width

			// loop for each subject
			for(int i=0; i< testTitles.size(); i++){
				// 1. student section
				Table header = getStudentTable(wholeWidth, testGroupName, testTitles.get(i) + " " + volume, student);
				document.add(header);
				document.add(onespace);
				// 2. title section
				Table totalScore = new Table(new float[]{wholeWidth});
				totalScore.addCell(detailCell("You have scored " + studentAnswerCorrects.get(i)+ " out of " + testAnswerTotals.get(i)+ " (" + scores.get(i) + "%)").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
				document.add(totalScore);
				// 3. answer section
				Table detailScore = getDetailAnswer(wholeWidth, studentAnswers.get(i), testAnswers.get(i), student.getGrade());
				document.add(detailScore);
				document.add(onespace);
				// 4. statistics title section
				Table statsTitle = new Table(new float[]{wholeWidth});
				statsTitle.addCell(detailCell(testGroupName + " - " + JaeUtils.getGradeYearName(student.getGrade())+ " " + testTitles.get(i) + " " + volume + " Result").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
				document.add(statsTitle);
				// 5. statistics section
				Table statsSection = getStatisticsTable(wholeWidth, scores.get(i), averages.get(i), highests.get(i), lowests.get(i));
				document.add(statsSection);
				// 6. branch section
				Table branchNote = new Table(new float[]{wholeWidth});
				branchNote.addCell(detailCell(branch.getName() + " (" + branch.getPhone()+ ")").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
				document.add(branchNote);			
				// Add a page break
				document.add(new AreaBreak());
				// 7. history title section
				Table historyTitle = new Table(new float[]{wholeWidth});
				historyTitle.addCell(detailCell(testTitles.get(i) + " Past Average & Your Scores").setFontSize(8f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
				document.add(historyTitle);
				
				// 8. history section
				List<TestResultHistoryDTO> historyDTOs = histories.get(i);

				if ((testGroup==JaeConstants.MEGA_TEST) || (testGroup==JaeConstants.REVISION_TEST)) {
					Table historySection1 = getHistoryTopTable(wholeWidth, historyDTOs, MEGA_REVISION_HISTORY_SIZE);
					document.add(historySection1);
					document.add(onespace);
				}else if(testGroup==JaeConstants.EDU_TEST){ 
					// Edu : Maximum 32 (30 + 2 title columns)
					// Call getHistoryTopTable for the first 16 items
					List<TestResultHistoryDTO> topHistory = historyDTOs.subList(0, EDU_HISTORY_SIZE/2); // First 20 items (index 0 to 15)
					Table historySection1 = getHistoryTopTable(wholeWidth, topHistory, topHistory.size());
					document.add(historySection1);				
					// Call getHistoryBottomTable for the remaining items
					List<TestResultHistoryDTO> bottomHistory = historyDTOs.subList(EDU_HISTORY_SIZE/2, historyDTOs.size()); // Remaining items (index 16 to 32)
					Table historySection2 = getHistoryBottomTable(wholeWidth, bottomHistory, bottomHistory.size(), topHistory.size(), testGroup);
					document.add(historySection2);					
					document.add(onespace);
				}else if(testGroup==JaeConstants.ACER_TEST){
					// Acer : Maximum 42 (40 + 2 title columns)
					// Call getHistoryTopTable for the first 20 items
					List<TestResultHistoryDTO> topHistory = historyDTOs.subList(0, ACER_HISTORY_SIZE/2); // First 20 items (index 0 to 19)
					Table historySection1 = getHistoryTopTable(wholeWidth, topHistory, topHistory.size());
					document.add(historySection1);
					// Call getHistoryBottomTable for the remaining items
					List<TestResultHistoryDTO> bottomHistory = historyDTOs.subList(ACER_HISTORY_SIZE/2, historyDTOs.size()); // Remaining items (index 20 to 40)
					Table historySection2 = getHistoryBottomTable(wholeWidth, bottomHistory, bottomHistory.size(), topHistory.size(), testGroup);
					document.add(historySection2);					
					document.add(onespace);					
				}// what about Mock?.....

				// 9. history graph section
				Table historyGraph = getHistoryGraphTable(wholeWidth, historyDTOs);
				document.add(historyGraph);
				// Add a page break for next subject
				if(i < testTitles.size() - 1) {
					document.add(new AreaBreak());
				}
			}
			document.close();
			byte[] pdfData = baos.toByteArray();
			return pdfData;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}


	// 1. student section
	private Table getStudentTable(float width, String title, String testInfo, StudentDTO student){ 
		Table note = new Table(new float[]{width});
		note.addCell(detailCell(title).setItalic().setFontSize(10f).setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.RIGHT));
		note.addCell(detailCell("Dear " + student.getFirstName() + " " + student.getLastName() + " (" + student.getId()+ ")").setFontSize(8f).setBold().setBorder(Border.NO_BORDER));
		note.addCell(detailCell("Thank you for participating in the JAC " + title).setFontSize(8f).setBold().setBorder(Border.NO_BORDER));
		note.addCell(detailCell(JaeUtils.getGradeName(student.getGrade()) + " " + testInfo).setFontSize(8f).setBold().setBorder(Border.NO_BORDER));
		return note;
	}

	// 3. answer section
	private Table getDetailAnswer(float width, List<Integer> studentAnswers, List<TestAnswerItem> testAnswers, String grade) {
		Table body = new Table(new float[]{(width / 2), (width / 2)});
		if (testAnswers == null || testAnswers.isEmpty()) {
			return body;
		}
	
		int size = testAnswers.size();
		// int splitSize = 30;	
		if (size <= ANSWER_SPLIT_SIZE) {
			// If size is less than or equal to 30, use only the left table
			Table left = getLeftDetailScore(width, studentAnswers, testAnswers, grade);
			body.addCell(new Cell().add(left).setBorder(Border.NO_BORDER));
			body.addCell(new Cell().setBorder(Border.NO_BORDER)); // Empty right cell
		} else {
			// Split testAnswers into left and right parts
			List<Integer> leftStudentAnswers = studentAnswers.subList(0, ANSWER_SPLIT_SIZE);
			List<Integer> rightStudentAnswers = studentAnswers.subList(ANSWER_SPLIT_SIZE, size);
			List<TestAnswerItem> leftAnswers = testAnswers.subList(0, ANSWER_SPLIT_SIZE);
			List<TestAnswerItem> rightAnswers = testAnswers.subList(ANSWER_SPLIT_SIZE, size);
	
			// Generate left and right tables
			Table left = getLeftDetailScore(width, leftStudentAnswers, leftAnswers, grade);
			Table right = getRightDetailScore(width, rightStudentAnswers, rightAnswers, grade);
	
			// Add left and right tables to the body
			body.addCell(new Cell().add(left).setBorder(Border.NO_BORDER));
			body.addCell(new Cell().add(right).setBorder(Border.NO_BORDER));
		}
	
		return body;
	}

	// left answer from 1 ~ 30
	private Table getLeftDetailScore(float width, List<Integer> studentAnswers, List<TestAnswerItem> testAnswers, String grade){ 
		Table subject = new Table(new float[]{(width/2)});
		Table details = new Table(new float[]{(width/2)/10, ((width/2)/10)*2, (width/2)/10, ((width/2)/10)*2, ((width/2)/10)*4});
		details.addCell(detailCell("Q.No").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Resp").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Ans").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Percent").setBold().setBorder(Border.NO_BORDER)).setTextAlignment(TextAlignment.CENTER);
		details.addCell(detailCell("Topic").setBold().setBorder(Border.NO_BORDER));
		int count1 = testAnswers.size();
		for(int i=0; i< count1; i++){
			// background color
			com.itextpdf.kernel.color.Color backgroundColor = (i % 2 == 0) ? com.itextpdf.kernel.color.Color.LIGHT_GRAY : com.itextpdf.kernel.color.Color.WHITE;
			Cell cell1 = detailCell(testAnswers.get(i).getQuestion() + "").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setBold().setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell1);
			char mark = testAnswers.get(i).getAnswer() == studentAnswers.get(i) ? 'O' : 'X';			
			Cell cell2 = detailCell(JaeUtils.formatAnswer(testAnswers.get(i).getAnswer()) + " - " + mark).setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell2);			
			Cell cell3 = detailCell(JaeUtils.formatAnswer(studentAnswers.get(i))+"").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell3);			
			
			//Cell cell4 = detailCell("57").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER); // percent
			Cell cell4 = detailCell(PERCENT_GRADE[Integer.parseInt(grade)-1][i]+"").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER); // percent
			details.addCell(cell4);			
			Cell cell5 = detailCell(testAnswers.get(i).getTopic()).setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.LEFT); // topics
			details.addCell(cell5);
		}
		subject.addCell(details.setMarginTop(1));
		return subject;
	}

	// right answer from question 31 ~
	private Table getRightDetailScore(float width, List<Integer> studentAnswers, List<TestAnswerItem> testAnswers, String grade){ 
		Table subject = new Table(new float[]{(width/2)});
		Table details = new Table(new float[]{(width/2)/10, ((width/2)/10)*2, (width/2)/10, ((width/2)/10)*2, ((width/2)/10)*4});
		details.addCell(detailCell("Q.No").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Resp").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Ans").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Percent").setBold().setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.CENTER));
		details.addCell(detailCell("Topic").setBold().setBorder(Border.NO_BORDER));	
		int count2 = testAnswers.size();
		for(int i=0; i< count2; i++){
			// background color
			com.itextpdf.kernel.color.Color backgroundColor = (i % 2 == 0) ? com.itextpdf.kernel.color.Color.LIGHT_GRAY : com.itextpdf.kernel.color.Color.WHITE;
			Cell cell1 = detailCell(testAnswers.get(i).getQuestion() + "").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setBold().setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell1);
			char mark = testAnswers.get(i).getAnswer() == studentAnswers.get(i) ? 'O' : 'X';			
			Cell cell2 = detailCell(JaeUtils.formatAnswer(testAnswers.get(i).getAnswer()) + " - " + mark).setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);	            
			details.addCell(cell2);            
			Cell cell3 = detailCell(JaeUtils.formatAnswer(studentAnswers.get(i))+"").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER);
			details.addCell(cell3);            
			//	Cell cell4 = detailCell("31").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER); // percent
			Cell cell4 = detailCell(PERCENT_GRADE[Integer.parseInt(grade)-1][i+ANSWER_SPLIT_SIZE]+"").setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.CENTER); // percent
			details.addCell(cell4);            
			Cell cell5 = detailCell(testAnswers.get(i).getTopic()).setBorder(Border.NO_BORDER).setBackgroundColor(backgroundColor).setTextAlignment(TextAlignment.LEFT); // topics
			details.addCell(cell5);
		}
		subject.addCell(details.setMarginTop(1).setBorder(Border.NO_BORDER));
		subject.setBorder(Border.NO_BORDER);
		return subject;
	}

	// 5. stats section
	private Table getStatisticsTable(float width, double score, double average, double highest, double lowest) {
		Table body = new Table(new float[]{(width/2), (width/2)});
		Image left = getLeftBarChart(width, (int) score, (int) average, (int) highest, (int) lowest);
		Image right = getRightBarChart(width, (int) score, (int) average, (int) highest, (int) lowest);
		body.addCell(new Cell().add(left).setBorder(Border.NO_BORDER));
		body.addCell(new Cell().add(right).setBorder(Border.NO_BORDER));
		return body;
	}

	// get left bar chart
	private Image getLeftBarChart(float width, int score, int average, int highest, int lowest) {
		// Create a chart and add it to the PDF
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		String seriesName = "Scores"; 

		dataset.addValue(score, seriesName, "Your Mark");
		dataset.addValue(average, seriesName, "Average");
		dataset.addValue(highest, seriesName, "Highest");
		dataset.addValue(lowest, seriesName, "Lowest");
		
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
		renderer.setSeriesOutlinePaint(1, Color.black); // Set the border color
		renderer.setSeriesOutlineStroke(1, new BasicStroke(1.0f)); // Set the border thickness
		renderer.setDrawBarOutline(true); // Enable drawing the outline

		// Set the outline paint and stroke for the border of series 0 (if needed)
		renderer.setSeriesOutlinePaint(0, Color.black); // Set the border color for series 0
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
	private Image getRightBarChart(float width, int score, int average, int highest, int lowest) {
		// Create dataset
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		dataset.addValue(23, "Scores", "Lowest");
		dataset.addValue(17, "Scores", "Lower");
		dataset.addValue(20, "Scores", "Middle");
		dataset.addValue(12, "Scores", "Above");
		dataset.addValue(17, "Scores", "Higher");
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

		// calculate the band for the score
		String studentCategory = getBandForScore(score, lowest, highest);
		//System.out.println("Student score " + score + "% falls into category: " + studentCategory);
	
		// Custom renderer to apply different colors and display percentages
		BarRenderer renderer = new BarRenderer() {
			@Override
			public Paint getItemPaint(int row, int column) {
				// Get the category name for the current column
				String category = (String) dataset.getColumnKey(column);
				if (category.equalsIgnoreCase(studentCategory)) {
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
	
	// 8. history section
	private Table getHistoryTopTable(float width, List<TestResultHistoryDTO> histories, int num){
		// dynamic width based on num
		float[] columnWidths = new float[num + 1];
		for (int i = 0; i <= num; i++) {
			if (i == 0) {
				columnWidths[i] = (width / num) * 2; // First column is wider
			} else {
				columnWidths[i] = width / num; // Other columns have equal width
			}
		}
		Table details = new Table(columnWidths);		
		// Define header background color
    	DeviceRgb headerBgColor = new DeviceRgb(200, 200, 200); // Light gray
		details.addCell(detailCell("Test No").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		for (int i = 1; i <= num; i++) {
			details.addCell(detailCell(String.valueOf(i)).setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		}
		// first row
		Cell cell1_1 = detailCell("Your Score").setBold().setTextAlignment(TextAlignment.CENTER);
		details.addCell(cell1_1);
		// loop through the history if testID from 1 to 14
		for (int i = 1; i <= num; i++) {
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
		for (int i = 1; i <= num; i++) {
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
	private Table getHistoryBottomTable(float width, List<TestResultHistoryDTO> histories, int num, int topNum, int testGroup){
		// dynamic width based on num
		float[] columnWidths = new float[num + 1];
		for (int i = 0; i <= num; i++) {
			if (i == 0) {
				columnWidths[i] = (width / num) * 2; // First column is wider
			} else {
				columnWidths[i] = width / num; // Other columns have equal width
			}
		}
		Table details = new Table(columnWidths);
		// Define header background color
    	DeviceRgb headerBgColor = new DeviceRgb(200, 200, 200); // Light gray
		details.addCell(detailCell("Test No").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
		// only last 5 should be named as SIM1, SIM2, SIM3, SIM4, SIM5
		for (int i = topNum + 1; i <= topNum + num; i++) {
			if (testGroup == 4) {// Acer test
				// For Acer test, show S1-S5 for last 5 tests
				if (i == topNum + num) {
					details.addCell(detailCell("S5").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else if (i == topNum + num - 1) {
					details.addCell(detailCell("S4").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else if (i == topNum + num - 2) {
					details.addCell(detailCell("S3").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else if (i == topNum + num - 3) {
					details.addCell(detailCell("S2").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else if (i == topNum + num - 4) {
					details.addCell(detailCell("S1").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else {
					details.addCell(detailCell(String.valueOf(i)).setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				}
			} else if (testGroup == 3) {// Edu test
				// For Edu test, show S1-S2 for last 2 tests only
				if (i == topNum + num) {
					details.addCell(detailCell("S2").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else if (i == topNum + num - 1) {
					details.addCell(detailCell("S1").setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				} else {
					details.addCell(detailCell(String.valueOf(i)).setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
				}
			}else{// Mega/Revision/Mock test
				details.addCell(detailCell(String.valueOf(i)).setBold().setBackgroundColor(headerBgColor)).setTextAlignment(TextAlignment.CENTER);
			}
		}
		// first row
		Cell cell1_1 = detailCell("Your Score").setBold().setTextAlignment(TextAlignment.CENTER);
		details.addCell(cell1_1);
		// loop through the history if testID from 1 to 14
		for (int i = topNum + 1; i <= topNum + num; i++) {
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
		for (int i = topNum + 1; i <= topNum + num; i++) {
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
			
		details.setBorderTop(Border.NO_BORDER);
		return details;		
	}

	// 9. history graph section
	private Table getHistoryGraphTable(float width, List<TestResultHistoryDTO> histories){
		Table body = new Table(new float[]{(width)});
		Image line = getLineChart(width, histories);
		body.addCell(new Cell().add(line).setBorder(Border.NO_BORDER));
		return body;
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
		renderer.setSeriesItemLabelGenerator(0, new StandardCategoryItemLabelGenerator() {
			@Override
			public String generateLabel(CategoryDataset dataset, int row, int column) {
				Number value = dataset.getValue(row, column);
				if (value != null) {
					return value.intValue() + "%"; // Append '%' to each value
				}
				return "";
			}
		});
		renderer.setSeriesItemLabelsVisible(0, true);
		renderer.setSeriesItemLabelFont(0, new Font("SansSerif", Font.PLAIN, 10));
		renderer.setSeriesPositiveItemLabelPosition(0, new ItemLabelPosition(ItemLabelAnchor.OUTSIDE12, TextAnchor.BOTTOM_CENTER));
	
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

	// Merge multiple PDF files into a single PDF file
	@Override
	public byte[] mergePdfFiles(List<byte[]> pdfList) {
		try {
			ByteArrayOutputStream mergedOutputStream = new ByteArrayOutputStream();
			PdfWriter pdfWriter = new PdfWriter(mergedOutputStream);
			PdfDocument mergedPdfDocument = new PdfDocument(pdfWriter);
			
			for (byte[] pdfBytes : pdfList) {
				PdfDocument sourcePdf = new PdfDocument(new PdfReader(new ByteArrayInputStream(pdfBytes)));
				sourcePdf.copyPagesTo(1, sourcePdf.getNumberOfPages(), mergedPdfDocument);
				sourcePdf.close();
			}
			
			mergedPdfDocument.close();
			return mergedOutputStream.toByteArray();
		} catch (Exception e) {
			System.out.println("Error merging PDF files: " + e.getMessage());
			e.printStackTrace();
			return null;
		}
	}
	

/////////////////// Calculate band category ///////////////////////
public static class Band {
	String name;
	double percentileCoverage;
	double scoreMin;
	double scoreMax;

	public Band(String name, double coverage) {
		this.name = name;
		this.percentileCoverage = coverage;
	}

	public boolean contains(double score) {
		return score >= scoreMin && score < scoreMax;
	}
}

// Step 1: Calculate the score range for each band
private List<Band> calculateBands(double lowest, double highest) {
	List<Band> bands = List.of(
			new Band("Lowest", 23),
			new Band("Lower", 17),
			new Band("Middle", 20),
			new Band("Higher", 17),
			new Band("Above", 12),
			new Band("Top", 11)
	);

	double scoreSpan = highest - lowest;
	double cursor = lowest;

	for (Band band : bands) {
		double range = (band.percentileCoverage / 100.0) * scoreSpan;
		band.scoreMin = cursor;
		band.scoreMax = cursor + range;
		cursor = band.scoreMax;
	}

	return bands;
}

// Step 2: Find which band the student's score falls into
private String getBandForScore(double studentScore, double lowest, double highest) {
	List<Band> bands = calculateBands(lowest, highest);
	for (Band band : bands) {
		if (band.contains(studentScore)) {
			return band.name;
		}
	}
	return "Top"; // If it's >= highest
}



}
