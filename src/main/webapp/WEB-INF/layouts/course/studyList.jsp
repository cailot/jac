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
    $('#studyListTable').DataTable({
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
    document.getElementById("studyList").addEventListener("submit", function() {
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
</style>


<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="studyList" method="get" action="${pageContext.request.contextPath}/loginCheck/studyList">
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
					<div class="col-md-2">
						<label for="start" class="label-form">From Date</label>
						<input type="text" class="form-control datepicker" id="start" name="start" placeholder="From" required>
					</div>
					<div class="col-md-2">
						<label for="end" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="end" name="end" placeholder="To" required>
					</div>
					<div class="offset-md-3"></div>
					<div class="col mx-auto">
						<label class="label-form-white">Search</label> 
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="studyListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 10%;">Student ID</th>
										<th class="align-middle text-center" style="width: 10%;">First Name</th>
										<th class="align-middle text-center" style="width: 10%;">Last Name</th>
										<th class="align-middle text-center" style="width: 10%;">Grade</th>
										<th class="align-middle text-center" style="width: 15%;">Main Contact</th>
										<th class="align-middle text-center" style="width: 15%;">Main Email</th>								
										<th class="align-middle text-center" style="width: 10%;">Start Date</th>
										<th class="align-middle text-center" style="width: 5%;">Logins</th>
										<th class="align-middle text-center" style="width: 5%;">Total</th>
									</tr>
								</thead>
								<tbody id="list-student-body">
								<c:choose>
									<c:when test="${LoginList != null}">
										<c:forEach items="${LoginList}" var="login">
											<tr>
												<td class="small align-middle hand-cursor" data-toggle="tooltip" title="Link to Student Information" id="studentId" name="studentId" onclick="linkToStudent('${login.studentId}')">
													<span class="ml-1"><c:out value="${login.studentId}" /></span>
												</td>												
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.firstName}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.lastName}" /></span></td>
												<td class="small align-middle text-center">
													<span>
														<c:choose>
															<c:when test="${login.grade == '1'}">P2</c:when>
															<c:when test="${login.grade == '2'}">P3</c:when>
															<c:when test="${login.grade == '3'}">P4</c:when>
															<c:when test="${login.grade == '4'}">P5</c:when>
															<c:when test="${login.grade == '5'}">P6</c:when>
															<c:when test="${login.grade == '6'}">S7</c:when>
															<c:when test="${login.grade == '7'}">S8</c:when>
															<c:when test="${login.grade == '8'}">S9</c:when>
															<c:when test="${login.grade == '9'}">S10</c:when>
															<c:when test="${login.grade == '10'}">S10E</c:when>
															<c:when test="${login.grade == '11'}">TT6</c:when>
															<c:when test="${login.grade == '12'}">TT8</c:when>
															<c:when test="${login.grade == '13'}">TT8E</c:when>
															<c:when test="${login.grade == '14'}">SRW4</c:when>
															<c:when test="${login.grade == '15'}">SRW5</c:when>
															<c:when test="${login.grade == '16'}">SRW6</c:when>
															<c:when test="${login.grade == '17'}">SRW7</c:when>
															<c:when test="${login.grade == '18'}">SRW8</c:when>
															<c:when test="${login.grade == '19'}">JMSS</c:when>
															<c:when test="${login.grade == '20'}">VCE</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.contactNo1}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${login.email1}" /></span></td>
												<td class="small align-middle text-center">
													<span>
														<c:out value="${login.startDate}" />
													</span>
												</td>
												<!-- count -->
												<td class="small align-middle text-center"><span><c:out value="${login.count}" /></span></td>
												<!-- total -->
												<td class="small align-middle text-center"><span><c:out value="${login.total}" /></span></td>
											</tr>
										</c:forEach>
									</c:when>
								</c:choose>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</form>
	</div>
</div>

