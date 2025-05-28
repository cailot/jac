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
const EMPTY = 'EMPTY';

$(document).ready(function () {
    $('#renewListTable').DataTable({
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
    document.getElementById("renewList").addEventListener("submit", function() {
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
//		Display Renewal Invoice
////////////////////////////////////////////////////////////////////////////////////////////////////
function displayRenewal(studentId, firstName, lastName, book) {
	var branch = window.branch;
	// branch code number...
	if(branch === '0'){
		branch = '90'; // head office
	}

	// Show confirmation modal with message
    var bookText = $('#book option:selected').text();
    var message = 'You are about to renew invoice for:<br><br>';
    message += '<b>Student : <span class="text-primary">' + firstName + ' ' + lastName + ' (' + studentId + ')</span></b><br>';
    message += '<b>Book Option : <span class="text-primary">' + bookText + '</span></b><br><br>';
    message += '<b>This action cannot be undone.</b>';
    
    $('#IndividualConfirmationMessage').html(message);
    $('#individualConfirm').modal('show');

    // Handle proceed button click
    $('#proceedIndividualRenewal').off('click').on('click', function() {
        $('#individualConfirm').modal('hide');
        proceedWithRenewal(studentId, firstName, lastName, book, branch);
    });
}

function proceedWithRenewal(studentId, firstName, lastName, book, branch) {
	console.log('Branch : ' + branch +  '  Student ID : ' + studentId + '  Book : ' + book);

	$.ajax({
		url : '${pageContext.request.contextPath}/invoice/renewInvoice/' + studentId + '/' + book + '/' + branch,
		type : 'POST',
		contentType : 'application/json',
		success : function(response) {
			if(response === EMPTY){
				$('#warning-alert .modal-body').text('Last invoice is not fully paid.');
				$('#warning-alert').modal('show');
				return;
			}

			// show invoice in another tab
			var branch = window.branch;
			if(branch === '0'){
				branch = '90'; // head office
			}	
			var url = '/invoice?invoiceId=' + response + '&studentId=' + studentId + '&firstName=' + firstName + '&lastName=' + lastName + '&branchCode=' + branch;  
			var win = window.open(url, '_blank');
			win.focus();
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Get Selected Book
////////////////////////////////////////////////////////////////////////////////////////////////////////
function getSelectedBook() {
    var bookSelect = document.getElementById('book');
    return bookSelect.options[bookSelect.selectedIndex].value;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Invoice All Students
////////////////////////////////////////////////////////////////////////////////////////////////////
function invoiceAll() {
    // Get checkbox state
    var isChecked = $('#selectAll').prop('checked');
    
    if(!isChecked) {
        return; // If unchecked, do nothing
    }

    // Get table data
    var table = $('#renewListTable').DataTable();
    var totalStudents = table.rows().count();
    
    if(totalStudents === 0) {
        $('#selectAll').prop('checked', false);
        $('#warning-alert .modal-body').text('No students found to process.');
        $('#warning-alert').modal('show');
        return;
    }

    // Show confirmation modal with message
    var book = getSelectedBook();
    var bookText = $('#book option:selected').text();
    var message = totalStudents + ' student(s) will be processed.<br><br>';
    message += '<b>Book Option : <span class="text-primary">' + bookText + '</span></b><br><br>';
    message += '<b>This action cannot be undone.</b>';
    
    $('#ReconfirmationMessage').html(message);
    $('#batchConfirm').modal('show');
}

// Add event handler for modal close/cancel
$('#batchConfirm').on('hidden.bs.modal', function () {
    $('#selectAll').prop('checked', false);
});

function processBatchInvoices() {
    var book = getSelectedBook();
    var branch = window.branch;
    // branch code number...
    if(branch === '0'){
        branch = '90'; // head office
    }

    // Get all rows from the table
    var table = $('#renewListTable').DataTable();
    var rows = table.rows().data();
    var processedCount = 0;
    var totalRows = rows.length;
    var successCount = 0;
    var failedCount = 0;

    // Hide confirmation modal
    $('#batchConfirm').modal('hide');

    // Process each row sequentially
    function processNextRow(index) {
        if (index >= totalRows) {
            // All rows processed
            $('#success-alert .modal-body').text('Processing completed. Success: ' + successCount + ', Failed: ' + failedCount);
            $('#success-alert').modal('show');
            $('#selectAll').prop('checked', false);
            return;
        }

        var studentId = rows[index][0].replace(/\D/g,''); // Extract student ID from the cell
        var firstName = rows[index][1];
        var lastName = rows[index][2];

        $.ajax({
            url: '${pageContext.request.contextPath}/invoice/renewInvoice/' + studentId + '/' + book + '/' + branch,
            type: 'POST',
            contentType: 'application/json',
            success: function(response) {
                if(response !== EMPTY) {
                    successCount++;
                } else {
                    failedCount++;
                }
            },
            error: function() {
                failedCount++;
            },
            complete: function() {
                processedCount++;
                // Process next row
                processNextRow(index + 1);
            }
        });
    }

    // Start processing from first row
    processNextRow(0);
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

	#renewListTable tr { 
		vertical-align: middle;
		height: 45px 	
	} 


</style>


<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="renewList" method="get" action="${pageContext.request.contextPath}/invoice/renewList">
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
						<label for="book" class="label-form">Book</label> 
						<select class="form-control" id="book" name="book">
							<option value="0">Not Charged</option>
							<option value="1">Vol. 1</option>
							<option value="2">Vol. 2</option>
							<option value="3">Vol. 3</option>
							<option value="4">Vol. 4</option>
							<option value="5">Vol. 5</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="start" class="label-form">From Date</label>
						<input type="text" class="form-control datepicker" id="start" name="start" placeholder="From" autocomplete="off" required>
					</div>
					<div class="col-md-2">
						<label for="end" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="end" name="end" placeholder="To" autocomplete="off" required>
					</div>
					<div class="offset-md-1"></div>
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
							<td class="text-center">Grade : 
								<span class="font-weight-bold">
									<script type="text/javascript">
										document.write(gradeName('${gradeInfo}'));
									</script>
								</span>
							</td>
							<td class="text-center">Book : <span class="font-weight-bold">								
								<c:choose>
									<c:when test="${bookInfo == '0'}">Not Charged</c:when>
									<c:when test="${bookInfo == '1'}">Vol. 1</c:when>
									<c:when test="${bookInfo == '2'}">Vol. 2</c:when>
									<c:when test="${bookInfo == '3'}">Vol. 3</c:when>
									<c:when test="${bookInfo == '4'}">Vol. 4</c:when>
									<c:when test="${bookInfo == '5'}">Vol. 5</c:when>
								</c:choose>
							</span></td>
							<td class="text-center"><span class="font-weight-bold">
								<c:out value="${startDateInfo}" /> ~ <c:out value="${endDateInfo}" />
							</span></td>
						</tr>
					</table>						
				</div>
			</c:if>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="renewListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 10%">ID</th>
										<th class="align-middle text-center" style="width: 15%">First Name</th>
										<th class="align-middle text-center" style="width: 15%">Last Name</th>
										<th class="align-middle text-center" style="width: 5%">Grade</th>
										<th class="align-middle text-center" style="width: 20%">Class</th>
										<th class="align-middle text-center" style="width: 5%">Start</th>
										<th class="align-middle text-center" style="width: 5%">End</th>
										<th class="align-middle text-center" style="width: 10%">Contact</th>
										<th class="align-middle text-center" style="width: 10%">Email</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 5%">
											<div class="d-flex align-items-center justify-content-center">
												Action
												<input type="checkbox" id="selectAll" class="ml-2" onclick="invoiceAll()" data-toggle="tooltip" title="Renew All Invoices"/>
											</div>
										</th>
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
												<!-- class -->
												<td class="small align-middle text-left text-capitalize ml-2"><span><c:out value="${student.address}" /></span></td>
												<td class="small align-middle text-center"><span><c:out value="${student.startWeek}" /></span></td>
												<td class="small align-middle text-center"><span><c:out value="${student.endWeek}" /></span></td>
												<td class="small align-middle text-left ml-1"><span><c:out value="${student.contactNo1}" /></span></td>
												<td class="small align-middle text-left ml-1"><span><c:out value="${student.email1}" /></span></td>
												<td class="text-center align-middle">
													<i class="bi bi-arrow-repeat text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Renew Invoice" onclick="displayRenewal('${student.id}', '${student.firstName}','${student.lastName}', getSelectedBook())"></i>&nbsp;
												</td>
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

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
			<i class="bi bi-check-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display jae-border-warning">
			<i class="fa fa-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Error Alert -->
<div id="error-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-danger alert-dialog-display jae-border-danger">
			<i class="fa fa-times-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>


<!-- Batch Confirmation Modal -->
<div class="modal fade" id="batchConfirm" tabindex="-1" role="dialog" aria-labelledby="batchConfirm" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content jae-border-warning">
            <div class="modal-header bg-warning">
                <h4 class="modal-title text-white" id="ReConfirmationModalLabel"><i class="bi bi-collection mr-2 text-dark"></i>&nbsp;&nbsp;Confirm Renew All Invoices</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close" onclick="$('#selectAll').prop('checked', false);">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="alert" role="alert" id="ReconfirmationMessage">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" onclick="processBatchInvoices()">Please, Proceed</button>
                <button type="button" class="btn btn-secondary" onclick="$('#selectAll').prop('checked', false);" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>

<!-- Individual Confirmation Modal -->
<div class="modal fade" id="individualConfirm" tabindex="-1" role="dialog" aria-labelledby="individualConfirm" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content jae-border-warning">
            <div class="modal-header bg-warning">
                <h4 class="modal-title text-white" id="IndividualConfirmationModalLabel"><i class="bi bi-arrow-repeat mr-2 text-dark"></i>&nbsp;&nbsp;Confirm Renew Invoice</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="alert" role="alert" id="IndividualConfirmationMessage">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" id="proceedIndividualRenewal">Please, Proceed</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>
