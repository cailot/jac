<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.StudentDTO"%>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils"%>
<%@page import="java.util.Calendar"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
 
  
<script>
$(document).ready(function () {
    $('#paymentListTable').DataTable({
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

		// sum for paid
		footerCallback: function (row, data, start, end, display) {
    		var api = this.api();
    		// Custom function to parse and sum values
			var parseAndSum = function (data) {
				var total = 0;
				for (var i = 0; i < data.length; i++) {
					var value = parseFloat(data[i].replace(/[^\d.-]/g, ''));
					if (!isNaN(value)) {
						total += value;
					}
				}
				return total;
			};
			// Total over all pages - only show for Admin & Director
			if(JSON.parse(window.isAdmin) || JSON.parse(window.isDirector)) {
				var totalOutstanding = parseAndSum(api.column(6, { search: 'applied' }).data());
				// Update footer with comma formatting
				$(api.column(6).footer()).html('<span class="text-primary font-weight-bold">$' + totalOutstanding.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span>');
				// Show the footer
				$(api.table().footer()).show();
			}else{
				// Hide the entire footer for staff
				$(api.table().footer()).hide();
			}
		}


    });
    
	$("#start").datepicker({
		dateFormat: 'dd/mm/yy',
		onClose: function (selectedDate) {
			$("#end").datepicker("option", "minDate", selectedDate);
		}
	});
	$("#end").datepicker({
		dateFormat: 'dd/mm/yy',
		onClose: function (selectedDate) {
			$("#start").datepicker("option", "maxDate", selectedDate);
		}
	});

	// initialise state list when loading
	listState('#listState');
	listBranch('#branch');
	listGrade('#grade');

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		// avoid execute several times
		//var hiddenInput = false;
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#branch").val(window.branch);
				// Disable #listBranch and #addBranch
				$("#branch").prop('disabled', true);
			}
		});
	}

	// send diabled select value via <form>
    document.getElementById("paymentList").addEventListener("submit", function() {
        document.getElementById("listState").disabled = false;
		document.getElementById("branch").disabled = false;
    });

});
////////////////////////////////////////////////////////////////////////////////////////////////////
//		Link To Student Admin
////////////////////////////////////////////////////////////////////////////////////////////////////
function linkToStudent(studentId) {
	var url = '/studentAdmin?id=' + studentId;  
	var win = window.open(url, '_blank');
	win.focus();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Payment History
////////////////////////////////////////////////////////////////////////////////////////////////////
function displayFullHistory(studentId) {
	var url = '/invoice/history?studentKeyword=' + studentId;  
	var win = window.open(url, '_blank');
	win.focus();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Receipt in another tab
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayReceipt(studentId, firstName, lastName, invoiceId, invoiceHistoryId, paymentId){
	var branch = window.branch;
	if(branch === '0'){
		branch = '90'; // head office
	}
	var url = '/invoice/receiptInfo?studentId=' + studentId + '&firstName=' + firstName + '&lastName=' + lastName + '&invoiceId=' + invoiceId + '&invoiceHistoryId=' + invoiceHistoryId + '&paymentId=' + paymentId + '&branchCode=' + branch;  
	var win = window.open(url, '_blank');
	win.focus();
}

</script>

<style>
	div.dataTables_length{
		padding-left: 50px;
		padding-top: 40px;
		padding-bottom: 10px;
	}

	div.dt-buttons {
		padding-top: 35px;
		padding-bottom: 10px;
	}

	div.dataTables_filter {
		padding-top: 35px;
		padding-bottom: 35px;
	}

	#paymentListTable tr { 
		vertical-align: middle;
		height: 45px 	
	} 

</style>


<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="paymentList" method="get" action="${pageContext.request.contextPath}/invoice/paymentList">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-1">
						<label for="listState" class="label-form">State</label> 
						<select class="form-control" id="listState" name="listState" disabled>
						</select>
					</div>
					<div class="col-md-2">
						<label for="branch" class="label-form">Branch</label> 
						<select class="form-control" id="branch" name="branch">
							<option value="0">All Branch</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="grade" class="label-form">Grade</label> 
						<select class="form-control" id="grade" name="grade">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="grade" class="label-form">Payment</label> 
						<select class="form-control" id="payment" name="payment">
							<option value="0">All</option>
							<option value="cash">Cash</option>
							<option value="bank">Bank</option>
							<option value="card">Card</option>
							<option value="cheque">Cheque</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="start" class="label-form">From Date</label>
						<input type="text" class="form-control datepicker" id="start" name="start" placeholder="From" autocomplete="off" required>
					</div>
					<div class="col-md-1">
						<label for="end" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="end" name="end" placeholder="To" autocomplete="off" required>
					</div>
					<div class="col-md-1">
						<label for="date" class="label-form">Select</label> 
						<select class="form-control" id="date" name="date">
							<option value="payDate">Received</option>
							<option value="registerDate">Registered</option>
						</select>
					</div>					
					<div class="offset-md-2"></div>
					<div class="col mx-auto">
						<label class="label-form-white">Search</label> 
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
				</div>
			</div>
			<!-- Search Info-->
			<c:if test="${branchInfo != null}">
				<div id="searchInfo" class="alert alert-info jae-border-info py-3 mt-4">
					<table style="width: 100%;">
						<colgroup>
							<col style="width: 20%;" />
							<col style="width: 20%;" />
							<col style="width: 15%;" />
							<col style="width: 15%;" />
							<col style="width: 30%;" />
						</colgroup>
						<tr>
							<td class="text-center">State : <span class="font-weight-bold">
								<script type="text/javascript">
									document.write(stateName('1'));
								</script>
							</span></td>
							<td class="text-center">Branch : <span class="font-weight-bold">
								<script type="text/javascript">
									document.write(branchName('${branchInfo}'));
								</script>
							</span></td>
							<td class="text-center">Payment : <span class="font-weight-bold">								
								<c:choose>
									<c:when test="${paymentInfo == '0'}">All</c:when>
									<c:when test="${paymentInfo == 'cash'}">Cash</c:when>
									<c:when test="${paymentInfo == 'bank'}">Bank</c:when>
									<c:when test="${paymentInfo == 'card'}">Card</c:when>
									<c:when test="${paymentInfo == 'cheque'}">Cheque</c:when>
								</c:choose>
							</span></td>
							<td class="text-center">Grade : 
								<span class="font-weight-bold">
									<script type="text/javascript">
										document.write(gradeName('${gradeInfo}'));
									</script>
								</span>
							</td>
							<td class="text-center"><span class="font-weight-bold">
								<fmt:parseDate var="startDate" value="${startDateInfo}" pattern="yyyy-MM-dd" />
								<fmt:formatDate value="${startDate}" pattern="dd/MM/yyyy" /> ~
								<fmt:parseDate var="endDate" value="${endDateInfo}" pattern="yyyy-MM-dd" />
								<fmt:formatDate value="${endDate}" pattern="dd/MM/yyyy" />							
							</span></td>
						</tr>
					</table>						
				</div>
			</c:if>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="paymentListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center">ID</th>
										<th class="align-middle text-center">First Name</th>
										<th class="align-middle text-center">Last Name</th>
										<th class="align-middle text-center">Grade</th>
										<th class="align-middle text-center">Method</th>
										<th class="align-middle text-center" data-orderable="false">Payment Date</th>
										<th class="align-middle text-center">Amount</th>
										<th class="align-middle text-center" data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-student-body">
								<c:choose>
									<c:when test="${StudentList != null}">
										<c:forEach items="${StudentList}" var="student">
											<tr>
												<td class="small align-middle hand-cursor" data-toggle="tooltip" title="Link to Student Information" id="studentId" name="studentId" onclick="linkToStudent('${student.id}')">
													<span class="ml-1"><c:out value="${student.id}" /></span>
												</td>												
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${student.firstName}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${student.lastName}" /></span></td>
												<td class="small align-middle text-center">
													<span>
														<c:choose>
															<c:when test="${student.grade == '1'}">P2</c:when>
															<c:when test="${student.grade == '2'}">P3</c:when>
															<c:when test="${student.grade == '3'}">P4</c:when>
															<c:when test="${student.grade == '4'}">P5</c:when>
															<c:when test="${student.grade == '5'}">P6</c:when>
															<c:when test="${student.grade == '6'}">S7</c:when>
															<c:when test="${student.grade == '7'}">S8</c:when>
															<c:when test="${student.grade == '8'}">S9</c:when>
															<c:when test="${student.grade == '9'}">S10</c:when>
															<c:when test="${student.grade == '10'}">S10E</c:when>
															<c:when test="${student.grade == '11'}">TT6</c:when>
															<c:when test="${student.grade == '12'}">TT8</c:when>
															<c:when test="${student.grade == '13'}">TT8E</c:when>
															<c:when test="${student.grade == '14'}">SRW4</c:when>
															<c:when test="${student.grade == '15'}">SRW5</c:when>
															<c:when test="${student.grade == '16'}">SRW6</c:when>
															<c:when test="${student.grade == '17'}">SRW7</c:when>
															<c:when test="${student.grade == '18'}">SRW8</c:when>
															<c:when test="${student.grade == '19'}">JMSS</c:when>
															<c:when test="${student.grade == '20'}">VCE</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<!-- paid method -->
												<td class="small align-middle text-left text-capitalize ml-2"><span><c:out value="${student.relation1}" /></span></td>
												<!-- paid date -->
												<td class="small align-middle text-center">
													<span>
														<fmt:parseDate var="studentRegistrationDate" value="${student.registerDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${studentRegistrationDate}" pattern="dd/MM/yyyy" />
													</span>
												</td>
												<!-- paid amount -->
												<td class="small align-middle text-right mr-1">
													<fmt:formatNumber value="${student.relation2}" pattern="#0.00" />
												</td>	
												<td class="text-center align-middle">
													<i class="bi bi-clock-history text-success fa-lg hand-cursor" data-toggle="tooltip" title="Payment History" onclick="displayFullHistory('${student.id}')"></i>&nbsp;
													<i class="bi bi-calculator text-primary hand-cursor" data-toggle="tooltip" title="Receipt" onclick="displayReceipt('${student.id}', '${student.firstName}', '${student.lastName}', '${student.contactNo1}', '${student.email1}', '${student.contactNo2}')"></i>
												</td>
											</tr>
										</c:forEach>
									</c:when>
								</c:choose>
								</tbody>
								<tfoot>
									<tr>
										<td colspan="6" style="text-align:right;"><strong>Total Amount:</strong></td>
										<td id="totalAmount" class="text-right">0.00</td>
										<td></td>
									</tr>
								</tfoot>
							</table>
						</div>
					</div>
				</div>
			</div>
		</form>
	</div>
</div>

