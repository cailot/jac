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
	var quill;

	$(document).ready(function () {
	// Initialize Quill editor for email body
	quill = new Quill('#emailBody', {
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

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		// avoid execute several times
		//var hiddenInput = false;
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#listBranch").val(window.branch);
				$("#addBranch").val(window.branch);
				// Disable #listBranch and #addBranch
				$("#listBranch").prop('disabled', true);
				$("#addBranch").prop('disabled', true);
				$("#editBranch").prop('disabled', true);
			}
		});
	}

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Email Form	
////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmAndSendEmail() {
    var branch = $('#listBranch').val(); // Assuming you have a select element with id 'listBranch'
    var grade = $('#listGrade').val(); // Assuming you have a select element with id 'listGrade'

	var confirmationMessage = '<h5>Are you sure you want to send this email to ? <br><br>Branch : <span class="text-primary font-weight-bold">' + branchName(branch) + '</span><br>Grade : <span class="text-primary font-weight-bold">' + gradeName(grade) + '</span><br><br>Once you send email, it can not be reverted.</h5>';
    $('#confirmationMessage').html(confirmationMessage);
	$('#confirmationModal').modal({
        backdrop: 'static',
        keyboard: false
    });
    $('#confirmationModal').modal('show');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Send Email	
////////////////////////////////////////////////////////////////////////////////////////////////////
function sendEmail() {

	var subject = $('#emailSubject').val();
    // var body = $('#emailBody').val();
	var body = quill.root.innerHTML; // Get the content from Quill editor

	console.log('Subject:', subject);
	console.log('Body:', body);

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
			state : window.state,
			branch : window.branch,
			grade : $('#listGrade').val(),
			subject : subject,
			body : body
		},
		success : function(data) {
			console.log('search - ' + data);
			
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
//		Clear All Email Form	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearEmailForm() {
	// clear email form
	document.getElementById("emailForm").reset();
	// clear Quill editor
	quill.setText('');
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
				<div class="offset-md-6"></div>
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
										<th class="align-middle text-center" style="width: 80%">Title</th>
										<th class="align-middle text-center" style="width: 10%">Date</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 10%">Action</th>
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
												<!-- <td class="small align-middle text-center"><span style="text-transform: capitalize;"><c:out value="${fn:toLowerCase(student.gender)}" /></span></td> -->
												<td class="small align-middle text-left">
													<c:out value="${student.contactNo2}" />
												</td>
												
												<td class="small align-middle text-center"><span><c:out value="${student.startWeek}" /></span></td>
												<td class="small align-middle text-center"><span><c:out value="${student.endWeek}" /></span></td>
												<td class="small align-middle text-center">
													<span>
														<fmt:parseDate var="studentRegistrationDate" value="${student.password}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${studentRegistrationDate}" pattern="dd/MM/yyyy" />
													</span>
												</td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${student.email1}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${student.contactNo1}" /></span></td>
												<!-- <td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${student.email2}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span class="ml-1"><c:out value="${student.contactNo2}" /></span></td> -->
												<td class="text-center align-middle">
													<i class="bi bi-clock-history text-success fa-lg hand-cursor" data-toggle="tooltip" title="Payment History" onclick="displayFullHistory('${student.id}')"></i>&nbsp;
													<i class="bi bi-pencil-square text-primary hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveStudentInfo('${student.id}')"></i>&nbsp;
													<i class="bi bi-key text-warning hand-cursor" data-toggle="tooltip" title="Change Password" onclick="showPasswordModal('${student.id}')"></i>&nbsp;
				 									<c:choose>
														<c:when test="${empty student.endDate}">
															<i class="bi bi-pause-circle text-danger hand-cursor" data-toggle="tooltip" title="Suspend" onclick="inactiveStudent('${student.id}')"></i>
														</c:when>
														<c:otherwise>
															<i class="bi bi-arrow-clockwise text-success hand-cursor" data-toggle="tooltip" title="Activate" onclick="activateStudent('${student.id}')"></i>
														</c:otherwise>
													</c:choose>
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
		<!-- </form> -->
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
                        <label for="emailSubject" class="label-form h6 font-weight-bold">Subject</label>
                        <input type="text" class="form-control" id="emailSubject" name="emailSubject" placeholder="Enter email subject" required>
                    </div>
                    <div class="form-group">
                        <label for="emailBody" class="label-form h6 font-weight-bold">Body</label>
                        <!-- Replace textarea with div for Quill -->
                        <div id="emailBody" name="emailBody" style="height: 300px;"></div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="confirmAndSendEmail()"><i class="bi bi-send"></i>&nbsp;Send Email</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="clearEmailForm()"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
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
                    <!-- Confirmation message will be inserted here -->
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
<div class="modal fade" id="editStudentModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Student Edit</header>
						<form id="studentEdit">
						<div class="form-row mt-3">
							<div class="col-md-4">
								<label for="editState" class="label-form">State</label> 
								<select class="form-control" id="editState" name="editState" disabled>
								</select>
							</div>
							<div class="col-md-5">
								<label for="editBranch" class="label-form">Branch</label> 
								<select class="form-control" id="editBranch" name="editBranch">
								</select>
							</div>
							<div class="col-md-3">
								<label for="editRegisterDate" class="label-form">Registration</label> 
								<input type="text" class="form-control datepicker" id="editRegisterDate" name="editRegisterDate" placeholder="dd/mm/yyyy">
							</div>
						</div>	
						<div class="form-row mt-3">
							<div class="col-md-3">
								<label for="editId" class="label-form">ID:</label> <input type="text" class="form-control" id="editId" name="editId" readonly>
							</div>
							<div class="col-md-4">
								<label for="editFirstName" class="label-form">First Name:</label> <input type="text" class="form-control" id="editFirstName" name="editFirstName">
							</div>
							<div class="col-md-3">
								<label for="editLastName" class="label-form">Last Name:</label> <input type="text" class="form-control" id="editLastName" name="editLastName">
							</div>
							<div class="col-md-2">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
								</select>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-3">
								<label for="editGender" class="label-form">Gender</label> <select class="form-control" id="editGender" name="editGender">
									<option value="male">Male</option>
									<option value="female">Female</option>
								</select>
							</div>
							<div class="col-md-9">
								<label for="editAddress" class="label-form">Address</label> <input type="text" class="form-control" id="editAddress" name="editAddress">
							</div>
						</div>
					
						<div class="form-row">
							<div class="col-md-12 mt-4">
								<section class="fieldset rounded" style="padding: 10px;">
									<header class="label-form" style="font-size: 0.9rem!important;">Main Contact</header>
								<div class="row">
									<div class="col-md-8">
										<input type="text" class="form-control" id="editContact1" name="editContact1" placeholder="Contact No">
									</div>
									<div class="col-md-4">
										<select class="form-control" id="editRelation1" name="editRelation1">
											<option value="mother">Mother</option>
											<option value="father">Father</option>
											<option value="sibling">Sibling</option>
											<option value="other">Other</option>
										</select>
									</div>	
								</div>
								<div class="row mt-2">
									<div class="col-md-12">
										<input type="text" class="form-control" id="editEmail1" name="editEmail1" placeholder="Email">
									</div>
								</div>
								</section>
							</div>
						</div>
						<div class="form-row">
							<div class="col-md-12 mt-4">
								<section class="fieldset rounded" style="padding: 10px;">
									<header class="label-form" style="font-size: 0.9rem!important;">Sub Contact</header>
								<div class="row">
									<div class="col-md-8">
										<input type="text" class="form-control" id="editContact2" name="editContact2" placeholder="Contact No">
									</div>
									<div class="col-md-4">
										<select class="form-control" id="editRelation2" name="editRelation2">
											<option value="mother">Mother</option>
											<option value="father">Father</option>
											<option value="sibling">Sibling</option>
											<option value="other">Other</option>
										</select>
									</div>	
								</div>
								<div class="row mt-2">
									<div class="col-md-12">
										<input type="text" class="form-control" id="editEmail2" name="editEmail2" placeholder="Email">
									</div>
								</div>
								</section>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-12">
								<label for="editMemo" class="label-form">Memo</label>
								<textarea class="form-control" style="height: 200px;" id="editMemo" name="editMemo"></textarea>
							</div>
						</div>
					</form>					
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateStudentInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</section>
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

