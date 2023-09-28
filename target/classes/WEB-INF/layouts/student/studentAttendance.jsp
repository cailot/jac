<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
    $('#attendanceTable').DataTable({
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
		order : [[0, 'desc'], [1, 'desc']] // order by invoiceId desc, id desc
				
    });
});

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//			Search Student with Keyword	
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStudent1() {
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

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Attendance Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearAttendanceInfo() {
	document.getElementById("studentAttend").reset();
	// Hide the studentInfo div
	var studentInfoDiv = document.getElementById("studentInfo");
	if (studentInfoDiv) {
  		studentInfoDiv.innerHTML = '';
		studentInfoDiv.style.display = 'none';
	}
	//attendanceTable all rows remove
	$('#attendanceTable > tobody').empty();
}

</script>

<style>
	#attendanceTable th, tr {
		padding: 15px;
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
		<form id="studentAttend" method="get" action="${pageContext.request.contextPath}/invoice/history">
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
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label> 
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
							<option value="p2">P2</option>
							<option value="p3">P3</option>
							<option value="p4">P4</option>
							<option value="p5">P5</option>
							<option value="p6">P6</option>
							<option value="s7">S7</option>
							<option value="s8">S8</option>
							<option value="s9">S9</option>
							<option value="s10">S10</option>
							<option value="s10e">S10E</option>
							<option value="tt6">TT6</option>
							<option value="tt8">TT8</option>
							<option value="tt8e">TT8E</option>
							<option value="srw4">SRW4</option>
							<option value="srw5">SRW5</option>
							<option value="srw6">SRW6</option>
							<option value="srw8">SRW8</option>
							<option value="jmss">JMSS</option>
							<option value="vce">VCE</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="fromDate" class="label-form">From Date</label> <input type="text" class="form-control datepicker" id="fromDate" name="fromDate" placeholder=" Select a date" required>
					</div>
					<div class="col-md-2">
						<label for="toDate" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="toDate" name="toDate" placeholder=" Select a date" required>
					</div>
					<!-- put blank col-md-2 -->
					<!-- <div class="offset-md-1">  -->
					<div class="col max-auto">
						<label class="label-form-white">Search</label> 
						<button type="button" class="btn btn-primary btn-block" onclick="return searchStudent()"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col max-auto">
						<label class="label-form-white">Clear</label> 
						<button type="button" class="btn btn-block btn-success" onclick="clearStudentInfo()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
					</div>
				</div>
			</div>
			<!-- Student Info-->
			<c:if test="${not empty sessionScope.studentInfo}">
				<div id="studentInfo" class="alert alert-info">
					<c:set var="student" value="${sessionScope.studentInfo}" />
					<c:set var="studentId" value="${student.id}" />
					<c:set var="studentFirstName" value="${student.firstName}" />
					<c:set var="studentLastName" value="${student.lastName}" />
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
				</div>
			</c:if>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="attendanceTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th>Invoice ID</th>
										<th>ID</th>
										<th>Payment Date</th>
										<th>Method</th>
										<th>Total</th>
										<th>Outstanding</th>
										<th>Paid</th>
										<th>Enrolled Course Information</th>
										<th data-orderable="false">Receipt</th>
									</tr>
								</thead>
								<tbody>
									<c:if test="${not empty sessionScope.payments}">
										<c:forEach var="payment" items="${payments}">
											<tr>
												<td>${payment.invoiceId}</td> <!-- invisible -->
												<td>${payment.id}</td> <!-- invisible -->
												<td class="small align-middle text-center"> <!-- payment date with dd/MM/yyyy format -->
													<fmt:parseDate var="parsedDate" value="${payment.registerDate}" pattern="yyyy-MM-dd" />
													<fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
												</td>
												<td class="small text-capitalize align-middle"> <!-- payment method with first letter capitalized -->
													<c:out value="${payment.method}"/>	
												</td>
												<td class="small align-middle text-right"> <!-- payment total with 2 decimal places -->
													<fmt:formatNumber value="${payment.total}" pattern="#0.00" />
												</td>
												<td class="small align-middle text-right"> <!-- payment outstanding with 2 decimal places -->
													<fmt:formatNumber value="${payment.total - payment.amount}" pattern="#0.00" />
												</td>
												<td class="small align-middle text-right"> 
													<fmt:formatNumber value="${payment.amount}" pattern="#0.00" />
												</td>
												<!-- Display a property of each object -->
												<td class="small align-middle" style="white-space: nowrap; padding: 0px;">
													<table class="table-borderless">
														<c:forEach var="enrol" items="${payment.enrols}">
															<tr style="background-color : transparent !important;">
																<td class="small align-middle" style="white-space: nowrap;">[${enrol.grade.toUpperCase()}] ${enrol.name}&nbsp;</td>
																<td class="small align-middle" style="white-space: nowrap;">(${enrol.extra})</td>
															</tr>
														</c:forEach>
													</table>
												</td>																						
												<td class="text-center align-middle">
													<i class="bi bi-calculator text-success" data-toggle="tooltip" title="Receipt" onclick="displayPaymentHistory('${studentId}', '${studentFirstName}', '${studentLastName}', '${payment.invoiceId}', '${payment.id}')"></i>
												</td> 
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

