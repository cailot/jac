<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ page import="hyung.jin.seo.jae.dto.EnrolmentDTO" %>
<%@ page import="hyung.jin.seo.jae.utils.JaeConstants" %>

<%
   String invoiceId = request.getParameter("invoiceId");
   String studentId = request.getParameter("studentId");
   String firstName = request.getParameter("firstName");
   String lastName = request.getParameter("lastName");

   Date date = new Date();
   SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
   String today = dateFormat.format(date);

%>

<script type="text/javascript">
$(document).ready(function () {
    $('#pdfExportButton').click(function () {
        fetch("${pageContext.request.contextPath}/invoice/exportReceipt?studentId=${param.studentId}&invoiceId=${param.invoiceId}&invoiceHistoryId=${param.invoiceHistoryId}&paymentId=${param.paymentId}&branchCode=${param.branchCode}")
            .then(response => response.blob())
            .then(blob => {
                var link = document.createElement('a');
                link.href = window.URL.createObjectURL(blob);
                link.download = "receipt.pdf";
                link.click();
            });
    });

    // Convert markdown in note to HTML
    var noteText = $('#invoiceNote').html();
    if (noteText) {
        $('#invoiceNote').html(convertMarkdownToHtml(noteText.trim()));
    }
});

function convertMarkdownToHtml(text) {
    if (!text) return '';
    
    // Convert markdown to HTML
    return text
        // Bold
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        // Italic
        .replace(/_(.*?)_/g, '<em>$1</em>')
        // Underline
        .replace(/__(.*?)__/g, '<u>$1</u>')
        // Links
        .replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2" target="_blank">$1</a>')
        // Unordered lists
        .replace(/^\- (.*)/gm, '<li>$1</li>').replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
        // Ordered lists
        .replace(/^\d+\. (.*)/gm, '<li>$1</li>').replace(/(<li>.*<\/li>)/s, '<ol>$1</ol>')
        // Line breaks
        .replace(/\n/g, '<br>');
}

///////////////////////////////////////////////////////////////////////////
// 		Send Email
///////////////////////////////////////////////////////////////////////////
function sendEmail() {
    // Show loading spinner with message
    $('#loading-message').text('Sending receipt email');
    $('#loading-spinner').modal('show');
    $.ajax({
        url : '${pageContext.request.contextPath}/invoice/emailReceipt?studentId=${param.studentId}&invoiceId=${param.invoiceId}&invoiceHistoryId=${param.invoiceHistoryId}&paymentId=${param.paymentId}&branchCode=${param.branchCode}',
        type : 'GET',
        dataType: 'json',
        success : function(response) {
            // Hide loading spinner
            $('#loading-spinner').modal('hide');

            if (response.status === 'success') {
                $('#success-alert .modal-body').html(response.message);
                $('#success-alert').modal('toggle');
            } else {
                $('#validation-alert .modal-body').html(response.message || 'Failed to send email.');
                $('#validation-alert').modal('toggle');
            }
        },
        error : function(xhr, status, error) {
            // Hide loading spinner
            $('#loading-spinner').modal('hide');

            console.log('Error:', error);
            console.log('Status:', status);
            console.log('Response:', xhr.responseText);
            
            let errorMessage = 'Failed to send email.';
            try {
                const response = JSON.parse(xhr.responseText);
                if (response.message) {
                    errorMessage = response.message;
                }
            } catch(e) {
                console.log('Error parsing response:', e);
            }
            
            $('#validation-alert .modal-body').html(errorMessage);
            $('#validation-alert').modal('toggle');
        }        
    });
}

</script>

<!-- Add the watermark styles -->
<style>
    .watermark-container {
        position: absolute;
        top: 150;
        left: 50;
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        pointer-events: none;
        z-index: 9999; /* Ensure it appears on top of other content */
        visibility: visible; /* Show the watermark by default */
        opacity: 1; /* Make the watermark fully opaque by default */
    }

    .watermark {
        font-size: 150px;
        font-weight: bold;
        color: rgba(250, 2, 2, 0.2);
        transform: rotate(310deg);
    }

    @media print {
        .watermark-container {
            visibility: visible; /* Show the watermark by default */
            opacity: 1; /* Make the watermark fully opaque by default */
        }
    }

    /* Rich text styling for Note section */
    #invoiceNote {
        font-family: 'arial', sans-serif;
        line-height: 1.6;
    }

    #invoiceNote strong {
        font-weight: bold;
    }

    #invoiceNote em {
        font-style: italic;
    }

    #invoiceNote u {
        text-decoration: underline;
    }

    #invoiceNote ul, #invoiceNote ol {
        margin-left: 20px;
        margin-bottom: 10px;
    }

    #invoiceNote li {
        margin-bottom: 5px;
    }

    #invoiceNote a {
        color: #007bff;
        text-decoration: underline;
    }

    #invoiceNote a:hover {
        color: #0056b3;
    }

    #invoiceNote br {
        margin-bottom: 5px;
    }
</style>

<div class="toolbar no-print">
    <div class="text-right pt-3">
            <input id="InvoiceType" name="InvoiceType" type="hidden" value="D" />
            <input id="StudentNo" name="StudentNo" type="hidden" value="990088" />
            <input id="FromDate" name="FromDate" type="hidden" value="" />
            <input id="ToDate" name="ToDate" type="hidden" value="" />
            <input id="Grade" name="Grade" type="hidden" value="" />
            <input id="Head" name="Head" type="hidden" value="Victoria" />
            <input id="BranchCode" name="BranchCode" type="hidden" value="99" />
            <input data-val="true" data-val-number="The field JobIdx must be a number." data-val-required="The JobIdx field is required." id="JobIdx" name="JobIdx" type="hidden" value="0" />
            <input id="InvoiceNumber" name="InvoiceNumber" type="hidden" value="98994" />
            <input id="Desc" name="Desc" type="hidden" value="" />           
            <button class="btn btn-primary" type="button" onclick="sendEmail()"><i class="bi bi-envelope"></i> Email</button>
            <button id="printInvoice" class="btn btn-success" type="button" onclick="window.print();"><i class="bi bi-printer"></i> Print</button>
            <button class="btn btn-warning" type="button" id="pdfExportButton"><i class="bi bi-file-pdf"></i> Export as PDF</button> 
    </div>
</div>

<div id="invoice">
    <!-- Watermark Container -->
    <div class="watermark-container">
        <div class="watermark">RECEIVED</div>
    </div>

    <div class="invoice WordSection1" style="min-width: 1080px; padding-top: 35px; padding-bottom: 35px; font-family: 'arial',sans-serif;">
        <table style="width: 90%; margin: 0 auto; border-collapse: collapse; table-layout: fixed; border: 0; color: #444;">
            <tr>
                <td style="vertical-align: middle; padding: 35px 0; text-align: left; font-family: 'arial', sans-serif; font-size: 35px; color:#3f4254; font-weight: 700 !important;background: none; border: 0;">RECEIPT</td>
                <td style="width: 450px; padding: 35px 0; vertical-align: middle; border: 0;">
                    <img style="width:450px; vertical-align: top;" src="${pageContext.request.contextPath}/image/invoicelogo.jpg" alt="JAC" />
                    <p style="margin-top: 8px; font-size: 13px;font-weight:600;line-height:1.5">
                        <c:out value="${sessionScope.invoiceBranch.phone}" escapeXml="false" />
                        <br /><c:out value="${sessionScope.invoiceBranch.address}" escapeXml="false" />
                        <br /><span style="font-weight:900;font-size:14px;">ABN <c:out value="${sessionScope.invoiceBranch.abn}" escapeXml="false" /></span>
                    </p>
                </td>
            </tr>
        </table>

        <table style="width: 90%; margin: 0 auto 10px; border-collapse: collapse; table-layout: fixed; border: 0; color: #444;">
            <c:set var="paymentMeta" value="${sessionScope.receiptHeader}" />
            <tr>
                <td style="width: 100px; font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; font-weight: bold; background: none; border: 0;">Date : </td>
                <td style="font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; background: none; border: 0;font-weight: 600 !important;"><%= today %></td>
                <td style="width: 100px; font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; font-weight: bold; background: none; border: 0;">Due Date : </td>
                <td style="font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; background: none; border: 0;font-weight: 600 !important;"><c:out value="${paymentMeta.registerDate}" /></td>
            </tr>
            <tr>
                <td style="width: 100px; font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; font-weight: bold; background: none; border: 0;">Name : </td>
                <td style="font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; background: none; border: 0;font-weight: 600 !important;"><strong><%= firstName %> <%= lastName %></strong></td>
                <td style="width: 100px; font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; font-weight: bold; background: none; border: 0;">Grade : </td>
                <td style="font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; background: none; border: 0;font-weight: 600 !important;">
                    <script type="text/javascript">
                        document.write(gradeName('${paymentMeta.info}'));
                    </script>
                </td>
            </tr>
            <tr>
                <td style="width: 100px; font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; font-weight: bold; background: none; border: 0;">Student ID : </td>
                <td style="font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; background: none; border: 0;font-weight: 600 !important;"><%= studentId %></td>
                <td style="width: 100px; font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; font-weight: bold; background: none; border: 0;">Invoice No : </td>
                <td style="font-size: 16px; line-height: 2; vertical-align: middle; text-align: left; font-family: 'arial', sans-serif; background: none; border: 0;font-weight: 600 !important;"><%= invoiceId %></td>
            </tr>
        </table>

        <table style="width: 90%; margin: 0 auto; padding: 0; border-collapse: collapse; table-layout: fixed; border: 2px solid #444; color: #444;">
            <colgroup>
                <col style="width:25%;">
                <col style="width:auto">
                <col style="width:10%;">
                <col style="width:15%;">
                <col style="width:10%;">
                <col style="width:15%;">
            </colgroup>
            <thead>
                <tr>
                    <th rowspan="2" style="width:25%; height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444; border-bottom-style:double;border: 1px solid #444;">Title</th>
                    <th rowspan="2" style="width: auto; height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444;border-bottom-style:double;">Period / Date</th>
                    <th colspan="2" style="height: 40px; width:25%; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444;">Fee (Incl.GST)</th>
                    <th rowspan="2" style="width:10%; height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444;border-bottom-style:double;">Discount</th>
                    <th rowspan="2" style="width:15%; height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444;border-bottom-style:double;">Subtotal<br />(Incl.GST)</th>
                </tr>
                <tr>
                    <th style="width:12%; height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444;border-bottom-style:double;">Weeks<br>(Qty)</th>
                    <th style="width:12%; height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: normal; border: 1px solid #444;border-bottom-style:double;">Weekly fee<br>(Unit price)</th>
                </tr>
            </thead>
            <tbody>
                <c:set var="finalTotal" value="0" />
                <c:set var="paidTotal" value="0" />
                <!-- Check if enrolments attribute exists in session -->
                <c:if test="${not empty sessionScope.enrolments}">
                    <!-- Retrieve the payments from session -->
                    <c:set var="enrolments" value="${sessionScope.enrolments}" />
                    <c:forEach items="${enrolments}" var="enrolment">
                        <tr>
                            <td style='height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: bold; border: 1px solid #444;'>Class 
                                 
                                [<script type="text/javascript">
                                    document.write(gradeName('${enrolment.grade}'));
                                </script>]
                                
                                <c:out value="${enrolment.name}" /></td>
                            <td style='height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: bold; border: 1px solid #444;'><c:out value="${enrolment.extra}" /></td>
                            <c:set var="weeks" value="${enrolment.endWeek - enrolment.startWeek + 1}" />
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                                <c:out value="${weeks}" />
                            </td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                                <fmt:formatNumber value="${enrolment.price}" pattern="#0.00" />
                            </td>
                            <!-- discount -->
                            <c:set var="discount" value="${enrolment.discount}" />
                            <c:if test="${fn:contains(discount, '%')}">
                                <c:set var="discount" value="${(weeks-enrolment.credit)*enrolment.price*(discount.replace('%', '')/100)}" />
                            </c:if>                          
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'><c:out value="${discount}" /></td>                    
                            <c:set var="totalPrice" value="${((weeks - enrolment.credit) * (enrolment.price)) - discount}" />
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                                <fmt:formatNumber value="${totalPrice}" pattern="#0.00" />
                            </td>
                            <!-- Add the amount to the finalTotal variable -->
                            <c:set var="finalTotal" value="${finalTotal + totalPrice}" />
                            <!-- Add the paid to the paidTotal variable. if full paid made, consider paidTotal; otherwise skip now for payments -->
                            <c:if test="${empty sessionScope.payments}">
                                <c:set var="paidTotal" value="${paidTotal + enrolment.paid}" />
                            </c:if>
                        </tr>
                    </c:forEach>
                </c:if>

                <!-- Check if materials attribute exists in session -->
                <c:if test="${not empty sessionScope.materials}">
                    <!-- Retrieve the payments from session -->
                    <c:set var="materials" value="${sessionScope.materials}" />
                    <c:forEach items="${materials}" var="book">
                        <tr>
                            <td style='height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: bold; border: 1px solid #444;'>Book <c:out value="${book.name}" /></td>
                            <td style='height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: bold; border: 1px solid #444;'></td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'></td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'></td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'></td>
                            
                            
                            <c:choose>
                                <c:when test="${book.name eq 'Extra'}">
                                    <c:set var="bookPrice" value="${book.input}" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="bookPrice" value="${book.price}" />
                                </c:otherwise>
                            </c:choose>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'><fmt:formatNumber value="${bookPrice}" pattern="#0.00" /></td>
                            
                            
                            
                            
                            
                            
                            
                            <!-- Add the amount to the finalTotal variable -->
                            <c:set var="finalTotal" value="${finalTotal + bookPrice}" />
                            <!-- Add the paid to the paidTotal variable. if full paid made, consider paidTotal; otherwise skip now for payments -->
                            <c:if test="${empty sessionScope.materials}">
                                <c:set var="paidTotal" value="${paidTotal + bookPrice}" />
                            </c:if>
                        </tr>
                    </c:forEach>
                </c:if>




                <!-- Check if payments attribute exists in session -->
                <c:if test="${not empty sessionScope.payments}">
                    <!-- Retrieve the payments from session -->
                    <c:set var="payments" value="${sessionScope.payments}" />
                    <c:forEach items="${payments}" var="payment">
                        <tr>
                            <td style='height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: bold; border: 1px solid #444;'>
                                Payment
                            </td>
                            <td style='height: 40px; padding: 10px 5px; text-align: center; font-size: 14px; font-weight: bold; border: 1px solid #444;'>
                                <c:out value="${payment.registerDate}" />
                            </td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                            </td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                            </td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                            </td>
                            <td style='height: 40px; padding: 10px 5px; font-size: 14px; font-weight: bold; border: 1px solid #444; text-align: right;'>
                                <c:choose>
                                    <c:when test="${payment.amount >= 0}">
                                        <fmt:formatNumber value="${- payment.amount}" pattern="#0.00" />
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${payment.amount}" pattern="#0.00" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <!-- Add the paid to the paidTotal variable -->
                            <c:set var="paidTotal" value="${paidTotal + payment.amount}" />
                        </tr>
                    </c:forEach>
                </c:if>


                
            </tbody>
        </table>

        <table style="width: 90%; margin: 50px auto 0; text-align: right; border-collapse: collapse; table-layout: fixed; border: 0; color: #444;">
            <tr>
                <td style="height: 32px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: right; font-weight: bold; font-family: 'arial', sans-serif; border: 0;font-weight: 600 !important;">FINAL TOTAL</td>
                <td style="height: 32px; width: 100px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: center; color: #bdbdbd; font-style: normal; font-family: 'arial', sans-serif; border: 0;">$</td>
                <td style="height: 32px; width: 130px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: right; font-family: 'arial', sans-serif; border: 0;"><strong><fmt:formatNumber value="${finalTotal}" pattern="#0.00" /></strong></td>
            </tr>
            <tr>
                <td style="height: 32px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: right; font-weight: bold; font-family: 'arial', sans-serif; border: 0;font-weight: 600 !important;">FEE PAID</td>
                <td style="height: 32px; width: 100px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: center; color: #bdbdbd; font-style: normal; font-family: 'arial', sans-serif; border: 0;">$</td>
                <td style="height: 32px; width: 130px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: right; font-family: 'arial', sans-serif; border: 0;">
                    <c:choose>
                        <c:when test="${paidTotal >= finalTotal}">
                            <fmt:formatNumber value="${- finalTotal}" pattern="#0.00" />
                        </c:when>
                        <c:when test="${paidTotal < finalTotal && paidTotal > 0}">
                            <fmt:formatNumber value="${- paidTotal}" pattern="#0.00" />
                        </c:when>                                
                        <c:otherwise>
                            <fmt:formatNumber value="${paidTotal}" pattern="#0.00" />
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <td style="height: 32px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: right; font-weight: bold; font-family: 'arial', sans-serif; border: 0;font-weight: 600 !important;">BALANCE</td>
                <td style="height: 32px; width: 100px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: center; color: #bdbdbd; font-style: normal; font-family: 'arial', sans-serif; border: 0;">$</td>
                <td style="height: 32px; width: 130px; font-size: 15px; line-height: 1.5; vertical-align: top; text-align: right; font-family: 'arial', sans-serif; border: 0;">
                    <!-- Check if the balance is full paid -->
                    <c:choose>
                        <c:when test="${finalTotal - paidTotal <= 0}">
                            PAID IN FULL
                        </c:when>
                        <c:otherwise>
                            <fmt:formatNumber value="${finalTotal - paidTotal}" pattern="#0.00" />
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </table>

        <table style="width: 90%; margin: 150px auto 10px; text-align: left; border-collapse: collapse; table-layout: fixed; border: 0; color: #444;">
        </table>
        <table style="width: 90%; margin: 0 auto; text-align: left; border-collapse: collapse; table-layout: fixed; border: 1px solid #444; color: #444;">
            <tr>
                <td style=" padding: 10px 10px 0; border: 0;"><strong style="font-size: 16px;font-style: italic;">Note : </strong></td>
            </tr>
            <tr>
                <td style="font-size: 15px; line-height: 1.6; border: 0; padding: 0 10px 10px;">
                    <p id="invoiceNote" class="rich-text-content">
                        <c:out value="${sessionScope.invoiceBranch.info}" escapeXml="false" />
                    </p>
                </td>
            </tr>
        </table>
    </div>
</div>

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Validation Alert -->
<div id="validation-alert" class="modal fade">
    <div class="modal-dialog">
        <div class="alert alert-block alert-danger alert-dialog-display jae-border-danger">
            <i class="bi bi-exclamation-circle-fill h5 mt-2"></i>&nbsp;&nbsp;<div class="modal-body"></div>
            <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
        </div>
    </div>
</div>