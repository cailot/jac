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
 <!-- Quill CSS -->
<link href="${pageContext.request.contextPath}/css/quill-1.3.7.css" rel="stylesheet">
<!-- Quill JS -->
<script src="${pageContext.request.contextPath}/js/quill-1.3.7.min.js"></script>

<script>
const HEAD_OFFICE = 90;
var quill;
var editQuill;

$(document).ready(function () {
	// Initialize Quill editor for email body
	quill = new Quill('#emailBody', {
		theme: 'snow'
	});
	editQuill = new Quill('#editBody', {
		theme: 'snow'
	});

    $('#emailListTable').DataTable({
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
		//pageLength: 20
    });
    
	// initialise state list when loading
	listState('#listState');
	listBranch('#listBranch');
	listGrade('#listGrade');
	listBranch('#addBranch');
	listBranch('#editBranch');
	listGrade('#addGrade');
	listGrade('#editGrade');

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		// avoid execute several times
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#listBranch").val(window.branch);
				// Disable #listBranch and #addBranch
				$("#listBranch").prop('disabled', true);
				// $("#editBranch").prop('disabled', true);
			}
		});
	}

	// Show different fields based on user role
	if (JSON.parse(window.isAdmin)) {
		$('#dynamicAdd').html(`
            <div class="row" id="adminFields">
				<div class="col-md-8">
					<label for="emailSubject" class="label-form h6 font-weight-bold">Subject</label>
					<input type="text" class="form-control" id="emailSubject" name="emailSubject" placeholder="Enter email subject" required>
				</div>
				<div class="col-md-2">
					<label for="addBranch" class="label-form h6 font-weight-bold">Branch</label>
					<select class="form-control" id="addBranch" name="addBranch">
						<option value="0">All Branch</option>
					</select>
				</div>
				<div class="col-md-2">
					<label for="addGrade" class="label-form h6 font-weight-bold">Grade</label>
					<select class="form-control" id="addGrade" name="addGrade">
						<option value="0">All Grade</option>
					</select>
				</div>
			</div>`);
		$('#dynamicEdit').html(`
			<div class="row" id="adminFieldsEdit">
				<div class="col-md-8">
					<label for="editSubject" class="label-form h6 font-weight-bold">Subject</label>
					<input type="text" class="form-control" id="editSubject" name="editSubject" placeholder="Enter email subject" required>
				</div>
				<div class="col-md-2">
					<label for="editBranch" class="label-form h6 font-weight-bold">Branch</label>
					<select class="form-control" id="editBranch" name="editBranch">
						<option value="0">All Branch</option>
					</select>
				</div>
				<div class="col-md-2">
					<label for="editGrade" class="label-form h6 font-weight-bold">Grade</label>
					<select class="form-control" id="editGrade" name="editGrade">
						<option value="0">All Grade</option>
					</select>
				</div>
			</div>`);
		$('#listSender').val(HEAD_OFFICE);
	} else {
		$('#dynamicAdd').html(`
           <div class="row" id="staffFields">
				<div class="col-md-10">
					<label for="emailSubject" class="label-form h6 font-weight-bold">Subject</label>
					<input type="text" class="form-control" id="emailSubject" name="emailSubject" placeholder="Enter email subject" required>
				</div>
				<input type="hidden" id="addBranch" name="addBranch"/>
				<div class="col-md-2">
					<label for="addGrade" class="label-form h6 font-weight-bold">Grade</label>
					<select class="form-control" id="addGrade" name="addGrade">
						<option value="0">All Grade</option>
					</select>
				</div>
			</div>
        `);
		$('#dynamicEdit').html(`
           <div class="row" id="staffFieldsEdit">
				<div class="col-md-10">
					<label for="editSubject" class="label-form h6 font-weight-bold">Subject</label>
					<input type="text" class="form-control" id="editSubject" name="editSubject" placeholder="Enter email subject" required>
				</div>
				<input type="hidden" id="editBranch" name="editBranch"/>
				<div class="col-md-2">
					<label for="editGrade" class="label-form h6 font-weight-bold">Grade</label>
					<select class="form-control" id="editGrade" name="editGrade">
						<option value="0">All Grade</option>
					</select>
				</div>
			</div>
        `);
		$('#addBranch').val(window.branch);
		$('#editBranch').val(window.branch);
		$('#listSender').val(window.branch);
	}

	// Enable listState & listBranch before form submission
    $('#emailList').on('submit', function(event) {
        $('#listState').prop('disabled', false);
		$('#listBranch').prop('disabled', false);
    });

	 // Clear email form when the modal is hidden
	 $('#registerNoticeModal').on('hidden.bs.modal', function () {
		clearEmailForm();
	});

	// Clear email edit form when the modal is hidden
	$('#editEmailModal').on('hidden.bs.modal', function () {
		clearEmailForm();
	});

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Email Form	
////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmAndSendEmail() {
    var branch = $('#addBranch').val(); // Assuming you have a select element with id 'listBranch'
    var grade = $('#addGrade').val(); // Assuming you have a select element with id 'listGrade'

	var confirmationMessage = '<h5>Are you sure you want to send this email to ? <br><br>Branch : <span class="text-primary font-weight-bold">' + branchName(branch) + '</span><br>Grade : <span class="text-primary font-weight-bold">' + gradeName(grade) + '</span><br><br>Once you send email, it can not be reverted.</h5>';
    $('#confirmationMessage').html(confirmationMessage);
	$('#confirmationModal').modal({
        backdrop: 'static',
        keyboard: false
    });
    $('#confirmationModal').modal('show');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Re-send Email Form	
////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmAndReSendEmail() {
    var branch = $('#editBranch').val(); // Assuming you have a select element with id 'editBranch'
    var grade = $('#editGrade').val(); // Assuming you have a select element with id 'editGrade'

	var confirmationMessage = '<h5>Are you sure you want to send this email to ? <br><br>Branch : <span class="text-primary font-weight-bold">' + branchName(branch) + '</span><br>Grade : <span class="text-primary font-weight-bold">' + gradeName(grade) + '</span><br><br>Once you send email, it can not be reverted.</h5>';
    $('#ReconfirmationMessage').html(confirmationMessage);
	$('#ReConfirmationModal').modal({
        backdrop: 'static',
        keyboard: false
    });
    $('#ReConfirmationModal').modal('show');
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Send Email	
////////////////////////////////////////////////////////////////////////////////////////////////////
function sendEmail() {

	var subject = $('#emailSubject').val();
	var body = quill.root.innerHTML; // Get the content from Quill editor

	// console.log('Subject:', subject);
	// console.log('Body:', body);

	if ((subject == '') || (body == '')) {
		$('#warning-alert .modal-body').text('Please fill in Subject & Message');
		$('#warning-alert').modal('toggle');
		return;
	}

    // Perform your email sending logic here
	$.ajax({
		url : '${pageContext.request.contextPath}/email/sendAnnouncement',
		type : 'GET',
		data : {
			state : $('#listState').val(),
			branch : $('#addBranch').val(),
			grade : $('#addGrade').val(),
			sender : JSON.parse(window.isAdmin)? HEAD_OFFICE : window.branch,
			subject : subject,
			body : body
		},
		success : function(count) {
			// Display success alert
			$('#success-alert .modal-body').html('Email sent to <b>' + count + '</b> recepients successfully.');
			$('#success-alert').modal('toggle');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
			
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

    // Close the modals after sending the email
	clearEmailForm();
    $('#confirmationModal').modal('hide');
    $('#registerNoticeModal').modal('hide');
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Re-Send Email	
////////////////////////////////////////////////////////////////////////////////////////////////////
function ReSendEmail() {

	var subject = $('#editSubject').val();
	var body = editQuill.root.innerHTML; // Get the content from Quill editor

	if ((subject == '') || (body == '')) {
		$('#warning-alert .modal-body').text('Please fill in Subject & Message');
		$('#warning-alert').modal('toggle');
		return;
	}

	// Perform your email sending logic here
	$.ajax({
		url : '${pageContext.request.contextPath}/email/sendAnnouncement',
		type : 'GET',
		data : {
			state : $('#editState').val(),
			branch : $('#editBranch').val(),
			grade : $('#editGrade').val(),
			sender : JSON.parse(window.isAdmin)? HEAD_OFFICE : window.branch,
			subject : subject,
			body : body
		},
		success : function(count) {
			// Display success alert
			$('#success-alert .modal-body').html('Email sent to <b>' + count + '</b> recepients successfully.');
			$('#success-alert').modal('toggle');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.href = window.location.href;
			});
			
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

	// Close the modals after sending the email
	clearEmailForm();
	$('#ReConfirmationModal').modal('hide');
	$('#editEmailModal').modal('hide');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear All Email Form	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearEmailForm() {
	// clear email form
	document.getElementById("emailForm").reset();
	// clear email edit form
	document.getElementById("emailEdit").reset();
	// clear Quill editor
	if (quill) {
		quill.setText('');
	}
	if (editQuill) {
		editQuill.setText('');
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Float Sent Email Form	
////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveEmailInfo(id) {

	// get sent email info
	$.ajax({
		url : '${pageContext.request.contextPath}/email/get/' + id,
		type : 'GET',
		success : function(email) {
			// console.log(email);
			// set email info to edit form
			$('#editSubject').val(email.title);
			// $('#editBody').val(email.body);
			editQuill.root.innerHTML = email.body;
			$('#editState').val(email.state);
			$('#editBranch').val(email.branch);
			$('#editGrade').val(email.grade);
			$('#editEmailModal').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

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

	#emailListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}
</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="emailList" method="get" action="${pageContext.request.contextPath}/email/emailList">
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-1">
					<label for="listState" class="label-form">State</label> 
					<select class="form-control" id="listState" name="listState" disabled>
					</select>
				</div>
				<div class="col-md-2">
					<label for="listBranch" class="label-form">Branch</label> 
					<select class="form-control" id="listBranch" name="listBranch">
						<option value="0">All Branch</option>
					</select>
				</div>
				<div class="col-md-1">
					<label for="listGrade" class="label-form">Grade</label> 
					<select class="form-control" id="listGrade" name="listGrade">
						<option value="0">All</option>
					</select>
				</div>
				<input type="hidden" id="listSender" name="listSender"/>
				<div class="offset-md-5"></div>
				<div class="col mx-auto">
					<label class="label-form"><span style="color: white;">0</span></label>
					<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
				</div>
				<div class="col mx-auto">
					<label class="label-form-white">Search</label> 
					<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerNoticeModal"><i class="bi bi-plus-circle"></i>&nbsp;&nbsp;&nbsp;Create Notice</button>
				</div>
			</div>
		</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="emailListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 65%">Title</th>
										<th class="align-middle text-center" style="width: 15%">Branch</th>
										<th class="align-middle text-center" style="width: 5%">Grade</th>
										<th class="align-middle text-center" style="width: 10%">Date</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 5%">Action</th>
									</tr>
								</thead>
								<tbody>
								<c:choose>
									<c:when test="${EmailList != null}">
										<c:forEach items="${EmailList}" var="email">
											<tr>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${email.title}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;">
													<span class="ml-1">
														<script type="text/javascript">
															document.write(branchName('${email.branch}'));
														</script>
													</span>
												</td>
												<td class="small align-middle text-center">
													<span>
														<script type="text/javascript">
															document.write(gradeName('${email.grade}'));
														</script>
													</span>
												</td>
												<td class="small align-middle text-center">
													<span>
														<c:out value="${email.registerDate}" />
													</span>
												</td>
												<td class="text-center align-middle">
													<i class="bi bi-envelope text-primary hand-cursor" data-toggle="tooltip" title="Resend" onclick="retrieveEmailInfo('${email.id}')"></i>&nbsp;
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

<!-- Email Writing Modal -->
<div class="modal fade" id="registerNoticeModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">    
    <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
        <div class="modal-content jae-border-primary">
            <div class="modal-header bg-primary text-white">
                <h3 class="modal-title" id="emailModalLabel"><i class="bi bi-envelope"></i>&nbsp;&nbsp;&nbsp;Write Email</h3>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="emailForm">
                    <div class="form-group">
						<div id="dynamicAdd"></div>
                    </div>
                    <div class="form-group">
                        <label for="emailBody" class="label-form h6 font-weight-bold">Body</label>
                        <div id="emailBody" name="emailBody" style="height: 300px;"></div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="confirmAndSendEmail()"><i class="bi bi-send"></i>&nbsp;Send Email</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Confirmation Modal -->
<div class="modal fade" id="confirmationModal" tabindex="-1" role="dialog" aria-labelledby="confirmationModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content jae-border-warning">
            <div class="modal-header bg-warning">
                <h4 class="modal-title text-white" id="confirmationModalLabel"><i class="bi bi-send text-dark"></i>&nbsp;&nbsp;Confirm Email Sending</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="alert" role="alert" id="confirmationMessage">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" onclick="sendEmail()"><i class="bi bi-check-circle"></i>&nbsp;Confirm</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editEmailModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog modal-xl modal-dialog-centered" role="document">
		<div class="modal-content jae-border-primary">
			<div class="modal-header bg-primary text-white">
                <h3 class="modal-title" id="emailModalLabel"><i class="bi bi-envelope"></i>&nbsp;&nbsp;&nbsp;Resend Email</h3>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
				<form id="emailEdit">
                    <div class="form-group">
						<div id="dynamicEdit"></div>
                    </div>
                    <div class="form-group">
                        <label for="editBody" class="label-form h6 font-weight-bold">Body</label>
                        <div id="editBody" name="editBody" style="height: 300px;"></div>
                    </div>
					<input type="hidden" id="editState" name="editState">
					<input type="hidden" id="editBranch" name="editBranch"/>
                </form>
			</div>
			<div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="confirmAndReSendEmail()"><i class="bi bi-send"></i>&nbsp;Re-Send Email</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="clearEmailForm()"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
            </div>
		</div>
	</div>
</div>

<!-- Confirmation Modal for Re-sending-->
<div class="modal fade" id="ReConfirmationModal" tabindex="-1" role="dialog" aria-labelledby="ReConfirmationModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content jae-border-warning">
            <div class="modal-header bg-warning">
                <h4 class="modal-title text-white" id="ReConfirmationModalLabel"><i class="bi bi-send text-dark"></i>&nbsp;&nbsp;Confirm Email Sending</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="alert" role="alert" id="ReconfirmationMessage">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" onclick="ReSendEmail()"><i class="bi bi-check-circle"></i>&nbsp;Confirm</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display">
			<i class="bi bi-check-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

