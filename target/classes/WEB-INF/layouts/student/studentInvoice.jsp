<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.StudentDTO"%>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
 
  
<script>
$(document).ready(function () {
    $('#studentInvoiceTable').DataTable({
    	language: {
    		search: 'Filter:'
    	},
    	dom: 'Blfrtip',	
    	buttons: [
    		'excelHtml5', 
            {
 	            extend: 'pdfHtml5',
 	            download: 'open',
 	            pageSize: 'A0'
 	        },
 	        'print'
        ],
		columnDefs : [
			{
				targets: 0,
				visible: false,
				orderable: true
			},
			{
				targets: 1,
				visible: false,
				orderable: true
			}
		],	
		order : [[0, 'desc'], [1, 'desc']], // order by invoiceId desc, id desc
		//pageLength: 20
    });
});

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//			Search Student with Keyword	
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStudent() {
	// debugger;
	//warn if keyword is empty
	if ($("#studentKeyword").val() == '') {
		$('#warning-alert .modal-body').text('Please fill in Student Info before search');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$('#studentListResultTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/student/search',
		type : 'GET',
		data : {
			keyword : $("#studentKeyword").val()
		},
		success : function(data) {
			// console.log('search - ' + data);
			if (data == '') {
				$('#warning-alert .modal-body').html('No record found with <b>' + $("#studentKeyword").val() + '</b>');
				$('#warning-alert').modal('toggle');
				clearStudentInfo();
				return;
			}
			$.each(data, function(index, value) {
				const cleaned = cleanUpJson(value);
				var row = $("<tr onclick='getInvoice(" + value.id + ")'>");		
				row.append($('<td>').text(value.id));
				row.append($('<td>').text(value.firstName));
				row.append($('<td>').text(value.lastName));
				row.append($('<td>').text(value.grade.toUpperCase()));
				row.append($('<td>').text((value.gender === "") ? "" : value.gender.slice(0, 1).toUpperCase() + value.gender.substring(1)));	
				row.append($('<td>').text(formatDate(value.registerDate)));
				row.append($('<td>').text(formatDate(value.endDate)));
				row.append($('<td>').text(value.email1));
				row.append($('<td>').text(value.contactNo1));
				row.append($('<td>').text(value.email2));
				row.append($('<td>').text(value.contactNo2));
				row.append($('<td>').text(value.address));
				$('#studentListResultTable > tbody').append(row);
			});
			$('#studentListResult').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Bring all Invoice by Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function getInvoice(studentId) {
	$("#studentKeyword").val(studentId);
	$('#studentListResult').modal('hide');
	//warn if keyword is empty
	if (studentId == '') {
		$('#warning-alert .modal-body').text('Please fill in Student Info before search');
		$('#warning-alert').modal('toggle');
		return;
	}
	var form = document.getElementById("studentInvoice");
	form.submit();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Payment History in another tab
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayPaymentHistory(studentId, firstName, lastName, invoiceId, paymentId){
	var url = '/invoice/receiptInfo?studentId=' + studentId + '&firstName=' + firstName + '&lastName=' + lastName + '&invoiceId=' + invoiceId + '&paymentId=' + paymentId;  
	var win = window.open(url, '_blank');
	win.focus();
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Student Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearStudentInfo() {
	$("#studentKeyword").val('');
	document.getElementById("studentInvoice").reset();
	document.getElementById("studentInfo").innerHTML = '';
	//studentInvoiceTable all rows remove
	$('#studentInvoiceTable').clear();
}

</script>

<style>
	#studentInvoiceTable th, tr {
		padding: 15px;
	}
	#studentInvoice .form-row {
  		margin-top: 20px;
		margin-bottom: 20px;
	}
	div.dataTables_filter {
		padding-top: 35px;
		padding-bottom: 35px;
	}
	div.dt-buttons {
		padding-top: 35px;
		padding-bottom: 10px;
	}
	div.dataTables_length{
		padding-top: 40px;
		padding-bottom: 10px;
	}
	tr { height: 50px } 

</style>


<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="studentInvoice" method="get" action="${pageContext.request.contextPath}/invoice/history">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listState" class="label-form">State</label> 
						<select class="form-control" id="listState" name="listState">
							<option value="All">All State</option>
							<option value="vic">Victoria</option>
							<option value="nsw">New South Wales</option>
							<option value="qld">Queensland</option>
							<option value="sa">South Australia</option>
							<option value="tas">Tasmania</option>
							<option value="wa">Western Australia</option>
							<option value="nt">Northern Territory</option>
							<option value="act">ACT</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listBranch" class="label-form">Branch</label> 
						<select class="form-control" id="listBranch" name="listBranch">
							<option value="All">All Branch</option>
							<option value="braybrook">Braybrook</option>
							<option value="epping">Epping</option>
							<option value="balwyn">Balwyn</option>
							<option value="bayswater">Bayswater</option>
							<option value="boxhill">Box Hill</option>
							<option value="carolinesprings">Caroline Springs</option>
							<option value="chadstone">Chadstone</option>
							<option value="craigieburn">Craigieburn</option>
							<option value="cranbourne">Cranbourne</option>
							<option value="glenwaverley">Glen Waverley</option>
							<option value="mitcha">Mitcham</option>
							<option value="narrewarren">Narre Warren</option>
							<option value="ormond">Ormond</option>
							<option value="pointcook">Point Cook</option>
							<option value="preston">Preston</option>
							<option value="springvale">Springvale</option>
							<option value="stalbans">St Albans</option>
							<option value="werribee">Werribee</option>
							<option value="mernda">Mernda</option>
							<option value="melton">Melton</option>
							<option value="glenroy">Glenroy</option>
							<option value="packenham">Packenham</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="studentKeyword" class="label-form">Student Info</label> 
						<input type="text" class="form-control" style="background-color: #FCF7CA;" id="studentKeyword" name="studentKeyword" placeholder="Name or ID">
					</div>
					<!-- put blank col-md-2 -->
					<div class="offset-md-2">
						<div id="studentName"></div>
					</div>
					<div class="col-md-2">
						<label class="label-form-white">Search</label> 
						<button type="button" class="btn btn-primary btn-block" onclick="return searchStudent()"> <i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col-md-2">
						<label class="label-form-white">Clear</label> 
						<button type="button" class="btn btn-block btn-success" onclick="clearStudentInfo()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
					</div>
				</div>
			</div>
			<!-- Student Info-->
			<c:set var="studentId" value="" />
			<c:set var="studentFirstName" value="" />
			<c:set var="studentLastName" value="" />
			<div id="studentInfo" class="alert alert-info">
				<c:if test="${not empty sessionScope.studentInfo}">
					<c:set var="student" value="${sessionScope.studentInfo}" />
					<table style="width: 100%;">
						<colgroup>
							<col style="width: 33.33%;" />
							<col style="width: 33.33%;" />
							<col style="width: 33.33%;" />
						</colgroup>
						<tr>
							<td class="text-right">Student ID : <span class="font-weight-bold"><c:out value="${student.id}" /></span></td>
							<td class="text-center">Name : <span class="font-weight-bold"><c:out value="${student.firstName} ${student.lastName}" /></span></td>
							<td class="text-left">Grade : <span class="font-weight-bold text-uppercase"><c:out value="${student.grade}" /></span></td>
						</tr>
					</table>
					
				</c:if>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="studentInvoiceTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th>Invoice ID</th>
										<th>ID</th>
										<th>Payment Date</th>
										<th>Method</th>
										<th>Paid</th>
										<th>Outstanding</th>
										<th>Total</th>
										<th>Course</th>
										<th data-orderable="false">Receipt</th>
									</tr>
								</thead>
								<tbody>
									<c:if test="${not empty sessionScope.payments}">
										<c:forEach var="payment" items="${payments}">
											<tr>
												<td>${payment.invoiceId}</td> <!-- invisible -->
												<td>${payment.id}</td> <!-- invisible -->
												<td> <!-- payment date with dd/MM/yyyy format -->
													<fmt:parseDate var="parsedDate" value="${payment.registerDate}" pattern="yyyy-MM-dd" />
													<fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
												</td>
												<%--												
												<td> 
													${fn:toUpperCase(fn:substring(payment.method, 0, 1))}${fn:substring(payment.method, 1, fn:length(payment.method))}
												</td>
												--%>
												<td class="text-capitalize"> <!-- payment method with first letter capitalized -->
													<c:out value="${payment.method}"/>	
												</td>

												<td> <!-- payment amount with 2 decimal places -->
													<fmt:formatNumber value="${payment.amount}" pattern="#0.00" />
												</td>
												<td> <!-- payment outstanding with 2 decimal places -->
													<fmt:formatNumber value="${payment.total - payment.amount}" pattern="#0.00" />
												</td>
												<td> <!-- payment total with 2 decimal places -->
													<fmt:formatNumber value="${payment.total}" pattern="#0.00" />
												</td>
												<!-- Display a property of each object -->
												<td style="white-space: nowrap; padding: 0px;">
													<table style="border-collapse: collapse; border-spacing: 0; border: none; background-color: transparent; margin: 0; padding: 0;">
														<c:forEach var="enrol" items="${payment.enrols}">
															<tr>
																<td><i class="bi bi-mortarboard" title="class"></i> &nbsp;&nbsp;&nbsp;&nbsp;</td>
																<td style="white-space: nowrap;">[${enrol.grade.toUpperCase()}] ${enrol.name}&nbsp;&nbsp;&nbsp;&nbsp;</td>
																<td style="white-space: nowrap;">(${enrol.extra})</td>
															</tr>
														</c:forEach>
													</table>
												</td>
																						
												<td><i class="bi bi-calculator text-success" data-toggle="tooltip" title="Receipt" onclick="displayPaymentHistory(${studentId}, '${studentFirstName}', '${studentLastName}', ${payment.invoiceId}, ${payment.id})"></i></td> 
											</tr>
										</c:forEach>
									</c:if>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</form> 
		</div>
	</div>
</div>

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display">
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="bi bi-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Search Result Dialog -->
<div class="modal fade" id="studentListResult">
	<div class="modal-dialog modal-xl modal-dialog-centered">
	  <div class="modal-content">
		<div class="modal-header bg-primary text-white">
		  <h5 class="modal-title">&nbsp;<i class="bi bi-card-list"></i>&nbsp;&nbsp; Student List</h5>
		  <button type="button" class="close" data-dismiss="modal">
			<span>&times;</span>
		  </button>
		</div>
		<div class="modal-body table-wrap">
		  <table class="table table-striped table-bordered" id="studentListResultTable" data-header-style="headerStyle" style="font-size: smaller;">
			<thead class="thead-light">
			  <tr>
				<th data-field="id">ID</th>
				<th data-field="firstname">First Name</th>
				<th data-field="lastname">Last Name</th>
				<th data-field="grade">Grade</th>
				<th data-field="grade">Gender</th>
				<th data-field="startdate">Start Date</th>
				<th data-field="enddate">End Date</th>
				<th data-field="email">Main Email</th>
				<th data-field="contact1">Main Contact</th>
				<th data-field="email">Sub Email</th>
				<th data-field="contact2">Sub Contact</th>
				<th data-field="address">Address</th>
			  </tr>
			</thead>
			<tbody>
			</tbody>
		  </table>
		</div>
		<div class="modal-footer">
		  <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
		</div>
	  </div>
	</div>
  </div>
  
<style>
	.table-wrap {
	  overflow-x: auto;
	}
	#studentListResultTable th, #studentListResultTable td { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	.form-group{
		margin-bottom: 30px;
	}
</style>
