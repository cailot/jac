<%@ page import="hyung.jin.seo.jae.dto.EnrolmentDTO" %>
<script>

const PAYMENT = 'Payment';
// const FULL_PAID = 'Full';
// const OUTSTANDING = 'Outstanding';


$(document).ready(
	function() {
		// remove records from basket when click on delete icon
		$('#invoiceListTable').on('click', 'a', function(e) {
			e.preventDefault();
			$(this).closest('tr').remove();
		});
		$( "#payDate" ).datepicker({
			dateFormat: 'dd/mm/yy'
  		});
	}
);

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addEnrolmentToInvoiceList(data, cnt) {
	if((data.online)&&(data.discount === DISCOUNT_FREE)){
		return;
	}
	
	// Add null/undefined checks to prevent NaN values
	if (!data || !data.name || data.startWeek == null || data.endWeek == null || data.price == null) {
		// console.error('Invalid enrollment data:', data);
		return;
	}
	
	// check cnt is odd number or even number
	var isOdd = (cnt % 2)==1;
	// if cnt is odd number, then apply tr class to row_odd, otherwise set to row_even
	var rowClass = isOdd ? 'row_odd' : 'row_even';
	var row = $('<tr class="'+ rowClass +'">');
	// display the row in red if the amount is not fully paid 
	var needPay = (data.amount - (data.paid || 0) > 0) ? true : false;
	// (needPay) ? row.addClass('text-danger') : row.addClass('');

    row.append($('<td class="text-center"><i class="bi bi-mortarboard" data-toggle="tooltip" title="class"></i></td>'));
    // row.append($('<td class="smaller-table-font">').text('[' + data.grade.toUpperCase() +'] ' + data.name));
	row.append($('<td class="smaller-table-font">').text(data.name || ''));
    row.append($('<td class="smaller-table-font text-center">').text(data.year || ''));
	row.append($('<td class="smaller-table-font text-center">').text(dayName(data.day) || ''));
    
	// Ensure numeric values with defaults
	var startWeek = parseInt(data.startWeek) || 0;
	var endWeek = parseInt(data.endWeek) || 0;
	var credit = parseInt(data.credit) || 0;
	var price = parseFloat(data.price) || 0;
	var weeksTotal = Math.max(0, endWeek - startWeek + 1);
	
	// set editable attribute to true if the amount is not fully paid	
	(needPay) ? row.append($('<td class="smaller-table-font text-center">').addClass('start-week').text(startWeek)) : row.append($('<td class="smaller-table-font text-center">').addClass('start-week').text(startWeek));
	(needPay) ? row.append($('<td class="smaller-table-font text-center">').addClass('end-week').text(endWeek)) : row.append($('<td class="smaller-table-font text-center">').addClass('end-week').text(endWeek));
	(needPay) ? row.append($('<td class="smaller-table-font text-center">').addClass('weeks').text(weeksTotal)) : row.append($('<td class="smaller-table-font text-center" >').addClass('weeks').text(weeksTotal));
    (needPay) ? row.append($('<td class="smaller-table-font text-center">').addClass('credit').text(credit)) : row.append($('<td class="smaller-table-font text-center">').addClass('credit').text(credit));
	(needPay) ? row.append($('<td class="smaller-table-font text-center">').addClass('discount').text(data.discount || '0')) : row.append($('<td class="smaller-table-font text-center">').addClass('discount').text(data.discount || '0'));
	
	row.append($('<td class="smaller-table-font text-right">').addClass('price').text(price.toFixed(2)));
	
	// Calculate total price with proper error handling
	var totalEnrolPrice = Math.max(0, (weeksTotal - credit) * price);
	var discount = defaultIfEmpty(data.discount, '0');	
	if(discount.toString().includes('%')){
		discount = discount.replace('%', '');
		var discountPercent = parseFloat(discount) || 0;
		totalEnrolPrice = totalEnrolPrice - (totalEnrolPrice * (discountPercent / 100));
	}else{
		var discountAmount = parseFloat(discount) || 0;
		totalEnrolPrice = Math.max(0, totalEnrolPrice - discountAmount);
	}
	(needPay) ? row.append($('<td class="smaller-table-font text-right">').addClass('amount').text(totalEnrolPrice.toFixed(2)).attr("id", "amountCell")) : row.append($('<td class="smaller-table-font text-right">').addClass('amount').text(totalEnrolPrice.toFixed(2)).attr("id", "amountCell"));

	row.append($('<td class="smaller-table-font paid-date text-center">').text(data.paymentDate || ''));
	// if data.info is not empty, then display filled icon, otherwise display empty icon
	isNotBlank(data.info) ? row.append($("<td class='col-1 memo text-center hand-cursor'>").html('<i class="bi bi-chat-square-text-fill text-primary" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(' + 'ENROLMENT' + ', ' +  data.id + ', \'' + data.info + '\')"></i>')) : row.append($("<td class='col-1 memo text-center hand-cursor'>").html('<i class="bi bi-chat-square-text text-primary" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(' + 'ENROLMENT' + ', ' +  data.id + ', \'\')"></i>'));
		
		
	row.append($('<td>').addClass('hidden-column').addClass('enrolment-match').text(ENROLMENT + '|' + (data.id || '')));
	row.append($('<td>').addClass('hidden-column paid').text(data.paid || '0'));
	row.append($('<td>').addClass('hidden-column invoiceId').text(data.invoiceId || ''));
	// row.append($('<td>').addClass('hidden-column invoiceAmount').text(data.amount));
	

	// if any existing row's invoice-match value is same as the new row's invoice-match value, then remove the existing row
	$('#invoiceListTable > tbody > tr').each(function() {
		if ($(this).find('.enrolment-match').text() === row.find('.enrolment-match').text()) {
			$(this).remove();
		}
	});
	
	// add new row at first row
	$('#invoiceListTable > tbody').prepend(row);
    // $('#invoiceListTable > tbody').append(row);
    
	// update latest invoice id and balance
	updateLatestInvoiceId(data.invoiceId);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Payment to invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addPaymentToInvoiceList(data, cnt) {
	console.log('addPaymentToInvoiceList called with data:', data);
	
	// Add validation to prevent issues with invalid payment data
	if (!data || !data.method || data.amount == null || isNaN(data.amount)) {
		console.log('Invalid payment data:', data);
		return;
	}

	// Ensure required properties exist with defaults
	var amount = parseFloat(data.amount) || 0;
	var total = parseFloat(data.total) || amount;
	var upto = parseFloat(data.upto) || 0;
	var remaining = total - upto;
	
	var isOdd = (cnt % 2)==1;
	// if cnt is odd number, then apply tr class to row_odd, otherwise set to row_even
	var rowClass = isOdd ? 'row_odd' : 'row_even';
	var newPayment = $('<tr class="'+ rowClass +'">');
	
	// var newPayment = $('<tr>');
	newPayment.append($('<td class="text-center"><i class="bi bi-currency-dollar" data-toggle="tooltip" title="payment"></i></td>'));
	newPayment.append($('<td class="smaller-table-font">').text('Paid'));
	newPayment.append($('<td>')); // year
	newPayment.append($('<td>')); // day
	newPayment.append($('<td>')); // start
	newPayment.append($('<td>')); // end
	newPayment.append($('<td>')); // weeks
	newPayment.append($('<td>')); // credit
	newPayment.append($('<td>')); // discount
	newPayment.append($('<td class="smaller-table-font text-right">').text(amount.toFixed(2))); // price	
	// set editable attribute to true if the amount is not fully paid	
	newPayment.append($('<td class="smaller-table-font text-right text-primary">').addClass('amount').text(remaining.toFixed(2))); // remaining
	
	// Handle date formatting with better error handling
	var formattedDate = '';
	try {
		if (data.payDate) {
			// Try parsing as string first (dd/MM/yyyy format)
			if (typeof data.payDate === 'string' && data.payDate.includes('/')) {
				formattedDate = data.payDate;
			} else {
				// Try parsing as Date object
				var payDate = new Date(data.payDate);
				if (!isNaN(payDate.getTime())) {
					var options = { day: '2-digit', month: '2-digit', year: 'numeric' };
					formattedDate = payDate.toLocaleDateString('en-GB', options);
				}
			}
		}
	} catch (e) {
		console.log('Error formatting date:', e);
		formattedDate = data.payDate || '';
	}
	
	newPayment.append($('<td class="smaller-table-font text-center paid-date">').text(formattedDate));

	newPayment.append($('<td class="hidden-column paid">').text(amount));
	newPayment.append($('<td class="hidden-column payment-match">').text(PAYMENT + '|' + (data.id || '')));

	// if data.info is not empty, then display filled icon, otherwise display empty icon
	isNotBlank(data.info) ? newPayment.append($("<td class='col-1 memo text-center hand-cursor'>").html('<i class="bi bi-chat-square-text-fill text-primary" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(' + 'PAYMENT' + ', ' +  (data.id || '') + ', \'' + (data.info || '') + '\')"></i>')) : newPayment.append($("<td class='col-1 memo text-center hand-cursor'>").html('<i class="bi bi-chat-square-text text-primary" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(' + 'PAYMENT' + ', ' +  (data.id || '') + ', \'\')"></i>'));		
	// if any existing row's invoice-match value is same as the new row's invoice-match value, then remove the existing row
	$('#invoiceListTable > tbody > tr').each(function() {
		if ($(this).find('.payment-match').text() === newPayment.find('.payment-match').text()) {
			$(this).remove();
		}
	});
	$('#invoiceListTable > tbody').prepend(newPayment);
	// $('#invoiceListTable > tbody').append(newPayment);
	
	// update latest invoice id and balance
	updateLatestInvoiceId(data.invoiceId);
	
	console.log('Payment entry added successfully');
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Book to invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addBookToInvoiceList(data, cnt) {
	// Debug log for Extra material
	if (data.name === 'Extra') {
		console.log('Extra Material in Invoice:', {
			name: data.name,
			price: data.price,
			extra: data.extra,
			input: data.input
		});
	}
	
	// Add validation to prevent issues with invalid data
	if (!data || !data.name || data.price == null) {
		return;
	}

	var isOdd = (cnt % 2)==1;
	// if cnt is odd number, then apply tr class to row_odd, otherwise set to row_even
	var rowClass = isOdd ? 'row_odd' : 'row_even';
	var row = $('<tr class="'+ rowClass +'">');
	
	// var row = $('<tr>');
	row.append($('<td class="text-center"><i class="bi bi-book" data-toggle="tooltip" title="book"></i></td>')); // item
	row.append($('<td class="smaller-table-font">').text(data.name || '')); // description
	row.append($('<td>')); // year
	row.append($('<td>')); // day
	row.append($('<td>')); // start
	row.append($('<td>')); // end
	row.append($('<td>')); // weeks 
	row.append($('<td>')); // credit
	row.append($('<td>')); // discount
	row.append($('<td>')); // price	
	
	// For Extra material, use the saved extra amount, otherwise use the book's price
	var displayPrice = data.name === 'Extra' ? parseFloat(data.input) || data.price : data.price;
	row.append($('<td class="smaller-table-font text-right">').addClass('amount').text(Number(displayPrice || 0).toFixed(2)));// Amount	
	
	row.append($('<td class="smaller-table-font text-center">').text(data.paymentDate || ''));// payment date
	row.append($('<td>').addClass('hidden-column').addClass('book-match').text(BOOK + '|' + (data.bookId || ''))); // 0
	row.append($('<td>').addClass('hidden-column').addClass('material-match').text(BOOK + '|' + (data.id || '')));
	row.append($('<td class="hidden-column materialId">').text(data.id || '')); 
	row.append($('<td class="hidden-column invoiceId">').text(data.invoiceId || '')); 
	
	// if data.info is not empty, then display filled icon, otherwise display empty icon	
	isNotBlank(data.info) ? row.append($("<td class='col-1 memo text-center hand-cursor'>").html('<i class="bi bi-chat-square-text-fill text-primary" title="Internal Memo" onclick="displayAddInfo(' + 'BOOK' + ', ' +  data.id + ', \'' + data.info + '\')"></i>')) : row.append($("<td class='col-1 memo text-center hand-cursor'>").html('<i class="bi bi-chat-square-text text-primary" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(' + 'BOOK' + ', ' +  data.id + ', \'\')"></i>'));	
	// if any existing row's invoice-match value is same as the new row's invoice-match value, then remove the existing row
	$('#invoiceListTable > tbody > tr').each(function() {
		if ($(this).find('.book-match').text() === row.find('.book-match').text()) {
			$(this).remove();
		}
	});

	// $('#invoiceListTable > tbody').append(row);
	$('#invoiceListTable > tbody').prepend(row);	
	// update latest invoice id and balance
	updateLatestInvoiceId(data.invoiceId);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Remove Enrolemnts from invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function removeEnrolmentFromInvoiceList() {
	$('#invoiceListTable > tbody > tr').each(function() {
		var hiddens = $(this).find('.enrolment-match').text();
		if(hiddens.indexOf('|') !== -1){
			var hiddenValues = hiddens.split('|');
			//console.log(hiddenValues[1]);
			if(hiddenValues[0] === ENROLMENT){
				$(this).remove();
			}
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Remove Books from invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function removeBookFromInvoiceList() {
	$('#invoiceListTable > tbody > tr').each(function() {
		var hiddens = $(this).find('.book-match').text();
		if(hiddens.indexOf('|') !== -1){
			var hiddenValues = hiddens.split('|');
			//console.log(hiddenValues[1]);
			if(hiddenValues[0] === BOOK){
				$(this).remove();
			}
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Remove Payment from invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function removePaymentFromInvoiceList() {
	$('#invoiceListTable > tbody > tr').each(function() {
		var hiddens = $(this).find('.payment-match').text();
		if(hiddens.indexOf('|') !== -1){
			var hiddenValues = hiddens.split('|');
			//console.log(hiddenValues[1]);
			if(hiddenValues[0] === PAYMENT){
				$(this).remove();
			}
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Lastest Invoice Id
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateLatestInvoiceId(invoiceId){
	// get the value of hidden invoiceId
	var hiddenInvoiceId = parseInt($('#hiddenInvoiceId').val());
	// console.log('updateLatestInvoiceId hiddenInvoiceId : ' + hiddenInvoiceId + ' - invoiceId : ' + invoiceId);
    // invoiceId is defined then compare invoiceId with hiddenInvoiceId
	if(invoiceId >= hiddenInvoiceId){
		// update invoiceId to hiddenInvoiceId
		$("#hiddenInvoiceId").val(invoiceId);
	}	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Balance in invoiceListTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInvoiceTableBalance() {
	var hiddenInvoiceId = parseInt($('#hiddenInvoiceId').val());
	$.ajax({
		url: '${pageContext.request.contextPath}/invoice/amount/' + hiddenInvoiceId,
		method: 'GET',
		success: function(response) {
			$("#rxAmount").text(response.toFixed(2));
			if(parseFloat(response) > 0){
				$('#paymentBtn').prop('disabled', false);
			}else{
				$('#paymentBtn').prop('disabled', true);
			}
		},
		error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
				$("#rxAmount").text(0);
		}
	});		
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clean invoiceTable
//////////////////////////////////////////////////////////////////////////////////////////////////////
function clearInvoiceTable(){
	$('#invoiceListTable > tbody').empty();
	// clear rxAmount in invoice section
	$('#rxAmount').text('0.00');
	// clear stored invoice id
	$('#hiddenInvoiceId').val(0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Payment Modal
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayPayment(){
    // display Receivable amount
    var rxAmount = $("#rxAmount").text();
	$("#payRxAmount").val(parseFloat(rxAmount).toFixed(2));
	$("#payAmount").val($("#payRxAmount").val());

	// payAmount
    $("#payAmount").on('input', function(){
        var payAmount = parseFloat($("#payAmount").val()).toFixed(2);
        var difference = parseFloat($("#payRxAmount").val()) - parseFloat($("#payAmount").val());
		// console.log($("#payRxAmount").val() + '-' + $("#payAmount").val());
		$("#payOutstanding").val(difference.toFixed(2));
    });

	// set payDate to today
	var today = new Date();
	var day = today.getDate();
	var month = today.getMonth() + 1; // Note: January is 0
	var year = today.getFullYear();
	var formattedDate = (day < 10 ? '0' : '') + day + '/' + (month < 10 ? '0' : '') + month + '/' + year;
	document.getElementById('payDate').value = formattedDate;
			 
    $('#paymentModal').modal('toggle');
}


//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Invoice in another tab
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayInvoiceInNewTab(){
  var invoiceId = $('#hiddenInvoiceId').val();
  var studentId = $('#formId').val();
  var firstName = $('#formFirstName').val();
  var lastName = $('#formLastName').val();
  var branch = window.branch;
  if(branch === '0'){
	branch = '90'; // head office
  }	
  var url = '/invoice?invoiceId=' + invoiceId + '&studentId=' + studentId + '&firstName=' + firstName + '&lastName=' + lastName + '&branchCode=' + branch;  
  var win = window.open(url, '_blank');
  win.focus();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Receipt in another tab
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayReceiptInNewTab(paymentId){
	// debugger
  var invoiceId = $('#hiddenInvoiceId').val();
  var studentId = $('#formId').val();
  var firstName = $('#formFirstName').val();
  var lastName = $('#formLastName').val();
  var branch = window.branch;
  if(branch === '0'){
	branch = '90'; // head office
  }	
  var url = '/receipt?invoiceId=' + invoiceId + '&studentId=' + studentId + '&firstName=' + firstName + '&lastName=' + lastName + '&branchCode=' + branch + '&paymentId=' + paymentId;  
  var win = window.open(url, '_blank');
  win.focus();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Payment History in another tab
//////////////////////////////////////////////////////////////////////////////////////////////////////
function openPaymentHistory(){
  var studentId = $('#formId').val();
  var url = '/invoice/history?studentKeyword=' + studentId;  
  var win = window.open(url, '_blank');
  win.focus();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Make Payment
//////////////////////////////////////////////////////////////////////////////////////////////////////
function makePayment(){
	var studentId = $('#formId').val();
	var payAmount = $('#payAmount').val();
	var payDate = $('#payDate').val();
	
	// Validation checks
	if (!studentId) {
		alert('Student ID is required');
		return;
	}
	
	// if (!payAmount || parseFloat(payAmount) <= 0) {
	// 	alert('Payment amount must be greater than 0');
	// 	return;
	// }
	
	if (!payDate) {
		alert('Payment date is required');
		return;
	}
	
	// branch code
	var branch = window.branch;
	if(branch === '0'){
		branch = '90'; // head office
	}
	var payment = {
		amount: payAmount,
		method: $('#payItem').val(),
		payDate: payDate,
		info: $('#payInfo').val()
	};
	
	// Show loading or disable button to prevent double submission
	$('#paymentModal .btn-primary').prop('disabled', true).text('Processing...');
	
	$.ajax({
		url : '${pageContext.request.contextPath}/invoice/payment/' + studentId + '/' + branch,
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(payment),
		contentType : 'application/json',
		success : function(response) {
			console.log('Payment response:', response);
			
			// Validate response
			if (!response || !Array.isArray(response)) {
				console.error('Invalid response format:', response);
				alert('Invalid response from server');
				return;
			}
			
			var lastPaymentId = 0;
			$.each(response, function(index, value){
				// Validate each item in response
				if (!value || typeof value !== 'object') {
					console.error('Invalid item in response:', value);
					return; // skip this item
				}
				
				if (value.hasOwnProperty('extra')) {
					// It is an EnrolmentDTO object
					let isFreeOnline = value.online && value.discount === DISCOUNT_FREE;
					if(!isFreeOnline){
						addEnrolmentToInvoiceList(value, 0);
					}
				}else if (value.hasOwnProperty('method')) { // payment
					// It is an PaymentDTO object, extract paymentId
					var temp = parseInt(value.id);
					if(temp && temp > lastPaymentId){
						lastPaymentId = temp;
					}
					addPaymentToInvoiceList(value);
				}else if (value.hasOwnProperty('bookId')) {
					// It is a BookDTO object
					addBookToInvoiceList(value, 0);
				}
			});
			
			// reset payment dialogue info
			document.getElementById('makePayment').reset();
			$('#paymentModal').modal('toggle');
			
			// display receipt if payment was successful
			if(lastPaymentId > 0) {
				displayReceiptInNewTab(lastPaymentId);
			}
			
			// update invoice & basket tables
			clearInvoiceTable();
			clearEnrolmentBasket();
			retrieveEnrolment(studentId);

		},
		error : function(xhr, status, error) {
			console.log('Payment Error:', error);
			console.log('Status:', status);
			console.log('Response:', xhr.responseText);
			
			var errorMessage = 'Payment failed. Please try again.';
			try {
				var errorResponse = JSON.parse(xhr.responseText);
				if (errorResponse.message) {
					errorMessage = errorResponse.message;
				}
			} catch(e) {
				console.log('Error parsing error response:', e);
			}
			
			alert(errorMessage);
		},
		complete: function() {
			// Re-enable the payment button
			$('#paymentModal .btn-primary').prop('disabled', false).text('Save');
		}
	});						
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Create Invoice
//////////////////////////////////////////////////////////////////////////////////////////////////////
function createInvoice(){

	var hidden = $('#hiddenInvoiceId').val();
	// console.log('create invoice hidden : ' + hidden);

	var enrols = [];
	var studentId = $('#formId').val();
	
	$('#invoiceListTable tbody tr').each(function() {
		var hiddens = $(this).find('.hidden-column').text();
		if(hiddens.indexOf('|') !== -1){
			var hiddenValues = hiddens.split('|');
			enrolId = hiddenValues[1];	
		}
		// find value of next td whose class is 'start-year'
		startWeek = $(this).find('.start-week').text();
		endWeek = $(this).find('.end-week').text();
		amount = $(this).find('.amount').text();
		credit = $(this).find('.credit').text();
		discount = $(this).find('.discount').text();
		var enrol = {
			"id" : enrolId,
			"startWeek" : startWeek,
			"endWeek" : endWeek,
			"amount" : amount,
			"credit" : credit,
			"discount" : discount
		};
		enrols.push(enrol);	
	});

	// console.log(enrols);

	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/invoice/create/' + studentId,
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(enrols),
		contentType : 'application/json',
		success : function(invoice) {

			// update invoiceId to hiddenInvoiceId
			$("#hiddenInvoiceId").val(invoice.id);
			
			// Display the success alert
			$("#invoiceId").val(invoice.id);
			$("#invoiceCredit").val(invoice.credit);
			$("#invoiceDiscount").val(invoice.discount);
			$("#invoicePaid").val(invoice.paidAmount);
			$("#invoiceTotal").val(invoice.amount);
			$("#invoiceRegisterDate").val(invoice.registerDate);
            $('#invoiceModal').modal('toggle');		
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});	
					
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Invoice Dialogue With Information
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayInvoiceInformation(){
	var studentId = $('#formId').val();
	$.ajax({
		url : '${pageContext.request.contextPath}/invoice/getInfo/' + studentId,
		type : 'GET',
		success : function(response) {
			// assign info into invoiceInfo
			document.getElementById('invoiceInfo').value = response;
			// show invoice dialogue
			$('#invoiceModal').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});	
				
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Issue Latest Invoice
//////////////////////////////////////////////////////////////////////////////////////////////////////
function issueInvoice(){
	var studentId = $('#formId').val();
	var info = $('#invoiceInfo').val();
	let encodeInfo = encodeDecodeString(info).encoded;
	var branch = window.branch;
	// branch code number...
	if(branch === '0'){
		branch = '90'; // head office
	}

	$.ajax({
		url : '${pageContext.request.contextPath}/invoice/issue/' + studentId + '/' + branch,
		type : 'POST',
		data : info, //encodeInfo,
		contentType : 'application/json',
		success : function(response) {
			// flush old data in the dialogue
			document.getElementById('showInvoice').reset();
			// disappear invoice dialogue
			$('#invoiceModal').modal('toggle');
			// show invoice in another tab
			displayInvoiceInNewTab();
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});					
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Add Modal
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayAddInfo(dataType, dataId, dataInfo){
    // console.log('displayAddInfo dataType : ' + dataType + ', dataId : ' + dataId);
	document.getElementById("infoDataType").value = dataType;
	document.getElementById("infoDataId").value = dataId;
	document.getElementById("information").value = dataInfo;
	// display Receivable amount
    $('#infoModal').modal('toggle');
}


//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Information
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addInformation(){
	var dataType = $('#infoDataType').val();
	var dataId = $('#infoDataId').val();
	var info = $('#information').val();
	
	let encodeInfo = encodeDecodeString(info).encoded;

	$.ajax({
		url : '${pageContext.request.contextPath}/invoice/updateInfo/' + dataType + '/' + dataId,
		type : 'POST',
		data : encodeInfo,
		contentType : 'application/json',
		success : function(response) {
			// flush old data in the dialogue
			document.getElementById('showInformation').reset();
			// disappear information dialogue
			$('#infoModal').modal('toggle');
			// update memo <td> in invoiceListTable 
			$('#invoiceListTable > tbody > tr').each(function() {
					if(dataType === ENROLMENT){
						if ($(this).find('.enrolment-match').text() === (dataType + '|' + dataId)) {
							(isNotBlank(info)) ? $(this).find('.memo').html('<i class="bi bi-chat-square-text-fill text-primary hand-cursor" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(ENROLMENT, ' + dataId + ', \'' + encodeInfo + '\')"></i>') : $(this).find('.memo').html('<i class="bi bi-chat-square-text text-primary hand-cursor" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(ENROLMENT, ' + dataId + ', \'\')"></i>');		
						}
					}else if(dataType === BOOK){
						if ($(this).find('.material-match').text() === (dataType + '|' + dataId)) {
							(isNotBlank(info)) ? $(this).find('.memo').html('<i class="bi bi-chat-square-text-fill text-primary hand-cursor" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(BOOK, ' + dataId + ', \'' + encodeInfo + '\')"></i>') : $(this).find('.memo').html('<i class="bi bi-chat-square-text text-primary hand-cursor" data-toggle="tooltip" title="Internal Memo" onclick="displayAddInfo(BOOK, ' + dataId + ', \'\')"></i>');
						}
					}
			});
		},
		error : function(xhr, status, error) {
			console.error('Error:', error);
		}
	});
}
 
///////////////////////////////////////////////////////////////////////////
// 		Send Invoice Email
///////////////////////////////////////////////////////////////////////////
function sendInvoiceEmail() {
	var studentId = $('#formId').val();
	var branch = window.branch;
	if(branch === '0'){
		branch = '90'; // head office
	}	
    // Show loading spinner with message
    $('#loading-message').text('Sending invoice email');
    $('#loading-spinner').modal('show');
	
	$.ajax({
        url : '${pageContext.request.contextPath}/invoice/emailInvoice?studentId='+ studentId +'&branchCode=' + branch,
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

//////////////////////////////////////////////////////////////////////////////////////////////////////
//      Delete Invoice
//////////////////////////////////////////////////////////////////////////////////////////////////////
function deleteInvoice() {
	var invoiceId = $('#hiddenInvoiceId').val();
	
	if (!invoiceId || invoiceId === '0') {
		$('#warning-alert .modal-body').text('No invoice selected to delete');
		$('#warning-alert').modal('toggle');
		return;
	}

	// Show confirmation modal
	$('#deleteInvoiceModal').modal('toggle');
}

function confirmDeleteInvoice() {
	var invoiceId = $('#hiddenInvoiceId').val();
	
	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/invoice/delete/' + invoiceId,
		type: 'DELETE',
		success: function(response) {
			// Close the confirmation modal
			$('#deleteInvoiceModal').modal('toggle');
			
			// Clear the invoice table and basket
			clearInvoiceTable();
			clearEnrolmentBasket();
			
			// Get current student ID to reload their data
			var studentId = $('#formId').val();
			if (studentId) {
				// Reload student's remaining invoice data and attendance
				retrieveEnrolment(studentId);
				retrieveAttendance(studentId);
				
				// Show success message
				$('#success-alert .modal-body').text('Invoice deleted successfully');
				$('#success-alert').modal('toggle');
			} else {
				// If no student ID, just show success and refresh
				$('#success-alert .modal-body').text('Invoice deleted successfully');
				$('#success-alert').modal('toggle');
				setTimeout(function() {
					location.reload();
				}, 2000);
			}
		},
		error: function(xhr, status, error) {
			// Close the confirmation modal
			$('#deleteInvoiceModal').modal('toggle');
			
			// Show error message
			var errorMessage = 'Failed to delete invoice';
			try {
				var response = JSON.parse(xhr.responseText);
				if (response.message) {
					errorMessage = response.message;
				}
			} catch(e) {
				console.error('Error parsing error response:', e);
			}
			$('#error-alert .modal-body').text(errorMessage);
			$('#error-alert').modal('toggle');
		}
	});
}
</script>
<style>
	/* Adjust column sizes for the table */
	#invoiceListTable th:nth-child(1) { width: 3%; } /* item */
	#invoiceListTable th:nth-child(2) { width: 30%; }  /* description */
	#invoiceListTable th:nth-child(3) { width: 5%; } /* year */
	#invoiceListTable th:nth-child(4) { width: 8%; } /* day */
	#invoiceListTable th:nth-child(5) { width: 4%; } /* start */
	#invoiceListTable th:nth-child(6) { width: 4%; } /* end */
	#invoiceListTable th:nth-child(7) { width: 4%; } /* weeks */
	#invoiceListTable th:nth-child(8) { width: 5%; } /* credit */
	#invoiceListTable th:nth-child(9) { width: 5%; } /* discount */
	#invoiceListTable th:nth-child(10) { width: 9%; } /* price % */
	#invoiceListTable th:nth-child(11) { width: 10%; } /* amount */
	#invoiceListTable th:nth-child(12) { width: 10%; } /* date */
	#invoiceListTable th:nth-child(13) { width: 3%; } /* note */

	#invoiceListTable td:nth-child(1) { width: 3%; } /* item */
	#invoiceListTable td:nth-child(2) { width: 30%; }  /* description */
	#invoiceListTable td:nth-child(3) { width: 5%; } /* year */
	#invoiceListTable td:nth-child(4) { width: 8%; } /* day */
	#invoiceListTable td:nth-child(5) { width: 4%; } /* start */
	#invoiceListTable td:nth-child(6) { width: 4%; } /* end */
	#invoiceListTable td:nth-child(7) { width: 4%; } /* weeks */
	#invoiceListTable td:nth-child(8) { width: 5%; } /* credit */
	#invoiceListTable td:nth-child(9) { width: 5%; } /* discount */
	#invoiceListTable td:nth-child(10) { width: 9%; } /* price % */
	#invoiceListTable td:nth-child(11) { width: 10%; } /* amount */
	#invoiceListTable td:nth-child(12) { width: 10%; } /* date */
	#invoiceListTable td:nth-child(13) { width: 3%; } /*note*/

	.row_odd{ background-color: rgba(0,0,0,0.07); }
	.row_even{ background-color: white; }

	/* Enhanced Modal Styling */
	#deleteInvoiceModal .modal-content {
		border-radius: 12px;
		overflow: hidden;
	}

	#deleteInvoiceModal .modal-header {
		padding: 1.5rem 1.5rem 1rem 1.5rem;
	}

	#deleteInvoiceModal .close:hover {
		opacity: 1 !important;
		transform: scale(1.1);
		transition: all 0.2s ease;
	}

	#deleteInvoiceModal .btn {
		border-radius: 6px;
		font-weight: 500;
		transition: all 0.3s ease;
	}

	#deleteInvoiceModal .btn-danger:hover {
		background-color: #c82333;
		border-color: #bd2130;
		transform: translateY(-1px);
		box-shadow: 0 4px 8px rgba(220, 53, 69, 0.3);
	}

	#deleteInvoiceModal .btn-outline-secondary:hover {
		transform: translateY(-1px);
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	}

	#deleteInvoiceModal .alert {
		border-radius: 8px;
	}

	#deleteInvoiceModal .modal-dialog {
		max-width: 480px;
	}

	/* Animation for the warning icon */
	#deleteInvoiceModal .bg-danger-light i {
		animation: pulse 2s infinite;
	}

	@keyframes pulse {
		0% {
			transform: scale(1);
		}
		50% {
			transform: scale(1.05);
		}
		100% {
			transform: scale(1);
		}
	}

	/* Bootstrap Icons margin fix for older Bootstrap versions */
	#deleteInvoiceModal .me-1 {
		margin-right: 0.25rem !important;
	}

	#deleteInvoiceModal .me-2 {
		margin-right: 0.5rem !important;
	}

	#deleteInvoiceModal .me-3 {
		margin-right: 1rem !important;
	}

	#deleteInvoiceModal .ms-2 {
		margin-left: 0.5rem !important;
	}

	#deleteInvoiceModal .mb-0 {
		margin-bottom: 0 !important;
	}

	#deleteInvoiceModal .mb-2 {
		margin-bottom: 0.5rem !important;
	}

	#deleteInvoiceModal .mb-3 {
		margin-bottom: 1rem !important;
	}

</style>
<!-- Main Body -->
<div class="modal-body mr-5" style="padding-left: 0px; padding-right: 5px;">
	<form id="">
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-6">
					<div class="row">
						<input type="hidden" id="hiddenInvoiceId" name="hiddenInvoiceId" />
						<div class="col-md-3">
							<p>Balance :</p>
						</div>
						<div class="col-md-2">
							<p><mark><strong class="text-danger" id="rxAmount" name="rxAmount">0.00</strong></mark></p>
						</div>
					</div>
				</div>
				<div class="col md-auto">
					<button type="button" class="btn btn-block btn-primary btn-sm" id="paymentBtn" onclick="displayPayment()">Payment</button>
				</div>
				<div class="col md-auto">
					<button type="button" class="btn btn-block btn-primary btn-sm" id="invoiceBtn" onclick="displayInvoiceInformation()">Invoice</button>
				</div>
				<div class="col md-auto">
					<button type="button" class="btn btn-block btn-primary btn-sm" onclick="sendInvoiceEmail()">Email</button>
				</div>
				<div class="col md-auto">
					<button type="button" class="btn btn-block btn-primary btn-sm" onclick="openPaymentHistory()">Record</button>				
				</div>
				<%--
					<!-- Delete Invoice Button -->
					<script>
						// Only show delete button for Admin/Director
						if(JSON.parse(window.isAdmin) || JSON.parse(window.isDirector)) {
							document.write('<div class="col md-auto"><button type="button" class="btn btn-block btn-danger btn-sm" onclick="deleteInvoice()">Delete</button></div>');
						}
					</script>
				--%>
			</div>
		</div>
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-12">
					<div class="table-wrap">
						<table id="invoiceListTable" class="table table-bordered"><thead class="table-primary">
								<tr>
									<th class="smaller-table-font text-center">Item</th>
									<th class="smaller-table-font text-center">Description</th>
									<th class="smaller-table-font text-center">Year</th>
									<th class="smaller-table-font text-center">Day</th>									
									<th class="smaller-table-font text-center">Start</th>
									<th class="smaller-table-font text-center">End</th>
									<th class="smaller-table-font text-center">Wks</th>
									<th class="smaller-table-font text-center">CR</th>
									<th class="smaller-table-font text-center">DC</th>
									<th class="smaller-table-font text-center">Price</th>
									<th class="smaller-table-font text-center">Amount</th>
									<th class="smaller-table-font text-center">Date</th>
									<th class="smaller-table-font text-center" data-orderable="false">Note</th>
								</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
					</div>
                </div>
			</div>
		</div>
	</form>
</div>

<!-- Payment Dialogue -->
<div class="modal fade" id="paymentModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
				<header class="text-primary font-weight-bold">Payment</header>
				<form id="makePayment">
					<div class="form-row mt-4">
						<div class="col-md-6">
							<label>Receivable Amount : </label> 
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="payRxAmount" name="payRxAmount" readonly>
						</div>						
					</div>
					<div class="form-row mt-2">
						<div class="col-md-6">
							<label>Payment Amount : </label> 
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="payAmount" name="payAmount">
						</div>						
					</div>
					<div class="form-row mt-2">
						<div class="col-md-6">
							<label>Outstanding : </label> 
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="payOutstanding" name="payOutstanding" readonly>
						</div>						
					</div>
					<div class="form-row mt-2">
						<div class="col-md-6">
							<label>Receive Item : </label> 
						</div>
						<div class="col-md-6">
							<select class="form-control" id="payItem" name="payItem">
								<option value="cash">Cash</option>
								<option value="bank">Bank</option>
								<option value="card">Card</option>
								<option value="cheque">Cheque</option>
							</select>	
						</div>						
					</div>
					<div class="form-row mt-3">
						<div class="col-md-6">
							<label>Receive Date : </label>
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control datepicker" id="payDate" name="payDate" placeholder="dd/mm/yyyy">
						</div>
					</div>
					<div class="form-row mt-2">
						<div class="col-md-6">
							<label>Other Information : </label> 
						</div>
						<div class="col-md-6">
							<input type="text" class="form-control" id="payInfo" name="payInfo">
						</div>						
					</div>
				</form>
				<div class="d-flex justify-content-end">
    				<button type="submit" class="btn btn-primary" onclick="makePayment()">Save</button>&nbsp;&nbsp;
    				<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="document.getElementById('makePayment').reset();">Cancel</button>
				</div>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Invoice Dialogue -->
<div class="modal fade" id="invoiceModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
				<header class="text-primary font-weight-bold">Invoice</header>
				<br>
				The following message will appear on the invoice.
				<form id="showInvoice">
					<div class="form-row mt-4">
						<div class="col-md-12">
							<textarea class="form-control" id="invoiceInfo" name="invoiceInfo" style="height: 8rem;"></textarea>
						</div>
					</div>
					<!-- <input type="hidden" id="invoId" name="invoId"></input> -->
					<div class="d-flex justify-content-end mt-4">
						<button type="button" class="btn btn-primary" onclick="issueInvoice()">OK</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="document.getElementById('showInvoice').reset();">Cancel</button>
					</div>
				</form>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Info Dialogue -->
<div class="modal fade" id="infoModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
				<header class="text-primary font-weight-bold">Note</header>
				<br>
				Please Add Internal Information
				<form id="showInformation">
					<div class="form-row mt-4">
						<div class="col-md-12">
							<textarea class="form-control" id="information" name="information" style="height: 8rem;"></textarea>
						</div>
					</div>
					<input type="hidden" id="infoDataType" name="infoDataType"></input>
					<input type="hidden" id="infoDataId" name="infoDataId"></input>
					<div class="d-flex justify-content-end mt-4">
						<button type="button" class="btn btn-primary" onclick="addInformation()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="document.getElementById('showInformation').reset();">Cancel</button>
					</div>
				</form>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Delete Invoice Confirmation Modal -->
<div class="modal fade" id="deleteInvoiceModal" tabindex="-1" role="dialog" aria-labelledby="deleteInvoiceModalLabel" aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered" role="document">
		<div class="modal-content border-0 shadow-lg">
			<div class="modal-header bg-danger text-white border-0">
				<div class="d-flex align-items-center">
					<i class="bi bi-exclamation-triangle-fill me-3" style="font-size: 1.5rem;"></i>
					<h5 class="modal-title mb-0 font-weight-bold text-white" id="deleteInvoiceModalLabel">Confirm Invoice Deletion</h5>
				</div>
				<button type="button" class="close text-white" data-dismiss="modal" aria-label="Close" style="opacity: 0.8;">
					<span aria-hidden="true" style="font-size: 1.2rem;">&times;</span>
				</button>
			</div>
			<div class="modal-body py-4 px-4">
				<div class="text-center mb-4">
					<div class="bg-danger-light rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px; background-color: rgba(220, 53, 69, 0.1);">
						<i class="bi bi-trash3-fill text-danger" style="font-size: 2.5rem;"></i>
					</div>
					<h6 class="font-weight-bold text-dark my-3">Are you sure you want to delete latest invoice?</h6>
					<!-- <p class="text-muted mb-3">Are you sure you want to delete latest invoice?</p> -->
				</div>
				<div class="alert alert-warning border-0 bg-warning-light" style="background-color: rgba(255, 193, 7, 0.1); border-left: 4px solid #ffc107;">
					<div class="d-flex align-items-center">
						<i class="bi bi-exclamation-triangle-fill text-warning me-2"></i>
						<small class="text-warning-dark mb-0">
							<strong>Warning:</strong> This action cannot be undone.<br> All related records will be permanently deleted.
						</small>
					</div>
				</div>
			</div>
			<div class="modal-footer border-0 pt-0 px-4 pb-4">
				<button type="button" class="btn btn-danger px-4 py-2 ms-2" onclick="confirmDeleteInvoice()">
					<i class="bi bi-trash3 me-1"></i>Delete
				</button>
				<button type="button" class="btn btn-secondary px-4 py-2" data-dismiss="modal">
					<i class="bi bi-x-circle me-1"></i>Cancel
				</button>
			</div>
		</div>
	</div>
</div>

