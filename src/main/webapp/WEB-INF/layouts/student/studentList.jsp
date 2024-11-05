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
    $('#studentListTable').DataTable({
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
    
	$('table .password').on('click', function(){
		var username = $(this).parent().find('#username').val();
		$('#passwordModal #usernamepassword').val(username);
	});
	
	$("#addRegisterDate").datepicker({
		dateFormat: 'dd/mm/yy'
	});
	$("#editRegisterDate").datepicker({
		dateFormat: 'dd/mm/yy'
	});
	// initialise state list when loading
	listState('#listState');
	listState('#addState');
	listState('#editState');
	listBranch('#listBranch');
	listBranch('#addBranch');
	listBranch('#editBranch');
	listGrade('#listGrade');
	listGrade('#addGrade');
	listGrade('#editGrade');

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

	// send diabled select value via <form>
    document.getElementById("studentList").addEventListener("submit", function() {
        document.getElementById("listState").disabled = false;
		document.getElementById("listBranch").disabled = false;
    });

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function addStudent() {

	// lastName, email, password validation
	var last = document.getElementById('addLastName');
	if(last.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter last name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			last.focus();
		});
		return false;
	}
	var email = document.getElementById('addEmail1');
	if(email.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	let regex = new RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
	if(!regex.test(email.value)){
		$('#validation-alert .modal-body').text(
		'Please enter valid main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}

	// Get from form data
	var std = {
		firstName : $("#addFirstName").val(),
		lastName : $("#addLastName").val(),
		email1 : $("#addEmail1").val(),
		email2 : $("#addEmail2").val(),
		relation1 : $("#addRelation1").val(),
		relation2 : $("#addRelation2").val(),
		contactNo1 : $("#addContact1").val(),
		contactNo2 : $("#addContact2").val(),
		memo : $("#addMemo").val(),
		state : $("#addState").val(),
		branch : $("#addBranch").val(),
		grade : $("#addGrade").val(),
		gender : $("#addGender").val(),
		password : $("#addPassword").val(),
		enrolmentDate : $("#addEnrolment").val()
	}
	// Send AJAX to server
	$.ajax({
        url : '${pageContext.request.contextPath}/student/register',
        type : 'POST',
        dataType : 'json',
        data : JSON.stringify(std),
        contentType : 'application/json',
        success : function() {
			// Display the success alert
            $('#success-alert .modal-body').text(
                    'New Student is registered successfully.');
            $('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
        },
        error : function(xhr, status, error) {
            console.log('Error : ' + error);
        }
    });
	$('#registerStudentModal').modal('hide');
	// flush all registered data
	document.getElementById("studentRegister").reset();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateStudentInfo(){

	// lastName, email validation
	var last = document.getElementById('editLastName');
	if(last.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter last name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			last.focus();
		});
		return false;
	}
	var email = document.getElementById('editEmail1');
	if(email.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	let regex = new RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
	if(!regex.test(email.value)){
		$('#validation-alert .modal-body').text(
		'Please enter valid main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	
	// get from formData
	var std = {
		id : $('#editId').val(),
		firstName : $("#editFirstName").val(),
		lastName : $("#editLastName").val(),
		email1 : $("#editEmail1").val(),
		email2 : $("#editEmail2").val(),
		address : $("#editAddress").val(),
		contactNo1 : $("#editContact1").val(),
		contactNo2 : $("#editContact2").val(),
		relation1 : $("#editRelation1").val(),
		relation2 : $("#editRelation2").val(),
		memo : $("#editMemo").val(),
		state : $("#editState").val(),
		branch : $("#editBranch").val(),
		grade : $("#editGrade").val(),
		gender : $("#editGender").val(),
		registerDate : $("#editRegisterDate").val()
	}

	var user = window.username;
		
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/update',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify({student: std, user: user}),
		contentType : 'application/json',
		success : function(value) {
			// Display success alert
			$('#success-alert .modal-body').html('ID : <b>' + std.id + '</b> is updated successfully.');
			$('#success-alert').modal('show');
			// fetch data again
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
			
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
	$('#editStudentModal').modal('hide');
	// flush all registered data
	document.getElementById("studentEdit").reset();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Student by User's click	
////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveStudentInfo(std) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/get/' + std,
		type : 'GET',
		success : function(student) {
			$('#editStudentModal').modal('show');
			// Update display info
			// console.log(student);
			$("#editId").val(student.id);
			$("#editFirstName").val(student.firstName);
			$("#editLastName").val(student.lastName);
			$("#editEmail1").val(student.email1);
			$("#editEmail2").val(student.email2);
			$("#editRelation1").val(student.relation1);
			$("#editRelation2").val(student.relation2);
			$("#editAddress").val(student.address);
			$("#editContact1").val(student.contactNo1);
			$("#editContact2").val(student.contactNo2);
			$("#editMemo").val(student.memo);
			$("#editState").val(student.state);
			$("#editBranch").val(student.branch);
			$("#editGrade").val(student.grade);
			$("#editGender").val(student.gender);
			// Set date value
			var date = new Date(student.registerDate); // Replace with your date value
			$("#editRegisterDate").datepicker('setDate', date);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Update password
////////////////////////////////////////////////////////////////////////////////////////////////////////
function updatePassword() {
	var id = $("#pwdId").val();
	var newPwd = $("#newPwd").val();
	var confirmPwd = $("#confirmPwd").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search student record before password reset');
		$('#warning-alert').modal('toggle');
		return;
	}
	// warn if newPwd or confirmPwd is empty
	if (newPwd == '' || confirmPwd == '') {
		$('#warning-alert .modal-body').text('Please enter new password and confirm password');
		$('#warning-alert').modal('toggle');
		return;
	}
	//warn if newPwd is not same as confirmPwd
	if(newPwd != confirmPwd){
		$('#warning-alert .modal-body').text('New password and confirm password are not the same');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/updatePassword/' + id + '/' + confirmPwd,
		type : 'PUT',
		success : function(data) {
			console.log(data);
			$('#success-alert .modal-body').html('<b>Password</b> is now updated');
			$('#success-alert').modal('toggle');
			// clear fields
			clearPassword();
			// close modal
			$('#passwordModal').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
		
	}); 
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Show password dialogue
////////////////////////////////////////////////////////////////////////////////////////////////////////
function showPasswordModal(id) {
	clearPassword();
	$("#pwdId").val(id);
	$('#passwordModal').modal('show');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Clear password fields
////////////////////////////////////////////////////////////////////////////////////////////////////////
function clearPassword() {
	$("pwdId").val('');
	$("#newPwd").val('');
	$("#confirmPwd").val('');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Inactivate Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function inactiveStudent(id) {
    // Show the warning modal
    $('#deactivateModal').modal('show');
    // Attach the click event handler to the "I agree" button
    $('#agreeInactive').one('click', function() {
        inactivateStudent(id);
        $('#deactivateModal').modal('hide');
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		De-activate Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function inactivateStudent(id) {
	$.ajax({
		url : '${pageContext.request.contextPath}/student/inactivate/' + id,
		type : 'PUT',
		success : function(data) {
			// clear existing form
			$('#success-alert .modal-body').html('ID : <b>' + id + '</b> is now suspended');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	}); 
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		De-activate Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function activateStudent(id) {
	if(confirm("Are you sure you want to re-activate this student?")){
		// send query to controller
		$.ajax({
			url : '${pageContext.request.contextPath}/student/activate/' + id,
			type : 'PUT',
			success : function(data) {
				// clear existing form
				$('#success-alert .modal-body').text(
						'ID : ' + id + ' is now re-activated');
				$('#success-alert').modal('show');
				$('#success-alert').on('hidden.bs.modal', function(e) {
					location.reload();
				});
			},
			error : function(xhr, status, error) {
				console.log('Error : ' + error);
			}
		}); 
	}else{
		return;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Link To Student Admin
////////////////////////////////////////////////////////////////////////////////////////////////////
function linkToStudent(studentId) {
    //window.location.href = '/studentAdmin?id=' + studentId;
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

	#studentListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}
</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="studentList" method="get" action="${pageContext.request.contextPath}/student/all">
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
					<div class="col-md-2">
						<label for="listActive" class="label-form">Student Condition</label> 
						<select class="form-control" id="listActive" name="listActive">
							<option value="0">All Students</option>
							<option value="1">Current Students</option>
							<option value="2">Stopped Students</option>
						</select>
					</div>
					<div class="offset-md-5"></div>
					<div class="col mx-auto">
						<label class="label-form-white">Search</label> 
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<!-- <div class="col mx-auto">
						<label class="label-form-white">Registration</label> 
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerStudentModal"><i class="bi bi-plus"></i>&nbsp;Registration</button>
					</div> -->
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="studentListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center">ID</th>
										<th class="align-middle text-center">First Name</th>
										<th class="align-middle text-center">Last Name</th>
										<th class="align-middle text-center">Grade</th>
										<th class="align-middle text-center">Class</th>
										<th class="align-middle text-center">Start</th>
										<th class="align-middle text-center">End</th>
										<th class="align-middle text-center" data-orderable="false">Enrolment Date</th>
										<th class="align-middle text-center">Main Email</th>
										<th class="align-middle text-center">Main Contact</th>
										<!-- <th class="align-middle text-center">Sub Email</th>
										<th class="align-middle text-center">Sub Contact</th> -->
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
		</form>
	</div>
</div>

<!-- Register Form Dialogue -->
<div class="modal fade" id="registerStudentModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Student Registration</header>
					<form id="studentRegister">
						<div class="form-row mt-3">
							<div class="col-md-4">
								<label for="addState" class="label-form">State</label> 
								<select class="form-control" id="addState" name="addState" disabled>
								</select>
							</div>
							<div class="col-md-5">
								<label for="addBranch" class="label-form">Branch</label> 
								<select class="form-control" id="addBranch" name="addBranch">
								</select>
							</div>
							<div class="col-md-3">
								<label for="addRegisterDate" class="label-form">Registration</label> 
								<input type="text" class="form-control datepicker" id="addRegisterDate" name="addRegisterDate" placeholder="Select Date" required>
							</div>
							<script>
								var today = new Date();
								var day = today.getDate();
								var month = today.getMonth() + 1; // Note: January is 0
								var year = today.getFullYear();
								var formattedDate = (day < 10 ? '0' : '') + day + '/' + (month < 10 ? '0' : '') + month + '/' + year;
								document.getElementById('addRegisterDate').value = formattedDate;
							</script>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-5">
								<label for="addFirstName" class="label-form">First Name:</label> <input type="text" class="form-control" id="addFirstName" name="addFirstName">
							</div>
							<div class="col-md-4">
								<label for="addLastName" class="label-form">Last Name:</label> <input type="text" class="form-control" id="addLastName" name="addLastName">
							</div>
							<div class="col-md-3">
								<label for="addGrade" class="label-form">Grade</label> <select class="form-control" id="addGrade" name="addGrade">
								</select>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-3">
								<label for="addGender" class="label-form">Gender</label> <select class="form-control" id="addGender" name="addGender">
									<option value="male">Male</option>
									<option value="female">Female</option>
								</select>
							</div>
							<div class="col-md-9">
								<label for="addAddress" class="label-form">Address</label> <input type="text" class="form-control" id="addAddress" name="addAddress">
							</div>
						</div>
						<div class="form-row">
							<div class="col-md-12 mt-4">
								<section class="fieldset rounded" style="padding: 10px;">
									<header class="label-form" style="font-size: 0.9rem!important;">Main Contact</header>
								<div class="row">
									<div class="col-md-8">
										<input type="text" class="form-control" id="addContact1" name="addContact1" placeholder="Contact No">
									</div>
									<div class="col-md-4">
										<select class="form-control" id="addRelation1" name="addRelation1">
											<option value="mother">Mother</option>
											<option value="father">Father</option>
											<option value="sibling">Sibling</option>
											<option value="other">Other</option>
										</select>
									</div>	
								</div>
								<div class="row mt-2">
									<div class="col-md-12">
										<input type="text" class="form-control" id="addEmail1" name="addEmail1" placeholder="Email">
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
										<input type="text" class="form-control" id="addContact2" name="addContact2" placeholder="Contact No">
									</div>
									<div class="col-md-4">
										<select class="form-control" id="addRelation2" name="addRelation2">
											<option value="mother">Mother</option>
											<option value="father">Father</option>
											<option value="sibling">Sibling</option>
											<option value="other">Other</option>
										</select>
									</div>
								</div>
								<div class="row mt-2">
									<div class="col-md-12">
										<input type="text" class="form-control" id="addEmail2" name="addEmail2" placeholder="Email">
									</div>
								</div>
								</section>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-12">
								<label for="addMemo" class="label-form">Memo</label>
								<textarea class="form-control" style="height: 200px;" id="addMemo" name="addMemo"></textarea>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addStudent()">Register</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>	
				</section>
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

<!-- Password Reset Dialogue -->
<div class="modal fade" id="passwordModal" tabindex="-1" role="dialog" aria-labelledby="passwordModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-warning">
            <div class="modal-header bg-warning">
               <h4 class="modal-title text-white" id="passwordModal"><i class="bi bi-key-fill text-dark"></i>&nbsp;&nbsp;Student Password Reset</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <h5> Do you want to reset password for this student?</h5>
				<p>
					<div class="row mt-4">
						<div class="col-md-5">
							New Password
						</div>
						<div class="col-md-7">
							<input type="password" class="form-control" id="newPwd" name="newPwd"/>
						</div>
					</div>
					<div class="row mt-4">
						<div class="col-md-5">
							Confirm Password
						</div>
						<div class="col-md-7">
							<input type="password" class="form-control" id="confirmPwd" name="confirmPwd"/>
						</div>
					</div>
				</p>
				<input type="hidden" id="pwdId" name="pwdId"/>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-warning" onclick="updatePassword()"><i class="bi bi-check-circle"></i>&nbsp;Reset</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
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

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="bi bi-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>


<!-- Deactivate Dialogue -->
<div class="modal fade" id="deactivateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-pause"></i>&nbsp;&nbsp;Student Suspend</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Do you want to suspend this student?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeInactive" name="agreeInactive"><i class="bi bi-check-circle"></i> Suspend</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>