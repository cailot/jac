<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.TeacherDTO" %>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils" %>
<%@ page import="java.util.Calendar" %>

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css">
</link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css">
</link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>

<script>
$(document).ready(function () {
	$('#userListTable').DataTable({
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


	$('#addRole').change(function() {
		if ($(this).val() == 'Role_Administrator') {
			$('#addBranch').val('90').prop('disabled', true);
		} else {
			$('#addBranch').prop('disabled', false);
		}
    });

	$('#editRole').change(function() {
		if ($(this).val() == 'Role_Administrator') {
			$('#editBranch').val('90').prop('disabled', true);
		} else {
			$('#editBranch').prop('disabled', false);
		}
    });

	$('table .password').on('click', function () {
		var username = $(this).parent().find('#username').val();
		$('#passwordModal #usernamepassword').val(username);
	});

	
	// initialise state list when loading
	listState('#listState');
	listState('#addState');
	listState('#editState');
	listBranch('#listBranch');
	listBranch('#addBranch');
	listBranch('#editBranch');

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		// avoid execute several times
		//var hiddenInput = false;
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#listBranch").val(window.branch);
				$("#addBranch").val(window.branch);
				$("#listRole").val('Role_Staff');
				
				// Disable #listBranch and #addBranch
				$("#listBranch").prop('disabled', true);
				$("#addBranch").prop('disabled', true);
				$("#editBranch").prop('disabled', true);
				$("#listRole").prop('disabled', true);
				$("#addRole").prop('disabled', true);
			}
		});
	}

	// send diabled select value via <form>
	document.getElementById("userList").addEventListener("submit", function() {
        document.getElementById("listState").disabled = false;
		document.getElementById("listBranch").disabled = false;
		document.getElementById("listRole").disabled = false;
    });
});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register User
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addUser() {
	
	// lastName, password
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
	var pass = document.getElementById('addPassword');
	if(pass.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter password');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			pass.focus();
		});
		return false;
	}

	// Get from form data
	var user = {
		state: $("#addState").val(),
		branch: $("#addBranch").val(),
		firstName: $("#addFirstName").val(),
		lastName: $("#addLastName").val(),
		email: $("#addEmail").val(),
		phone: $("#addPhone").val(),
		password : $("#addPassword").val(),
		role : $("#addRole").val()
	}
	// console.log(user);

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/user/register',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(user),
		contentType: 'application/json',
		success: function (value) {
			// Display the success alert
			$('#success-alert .modal-body').html('New user <b>'  + value.username + '</b> is registered successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerModal').modal('hide');
	// flush all registered data
	document.getElementById("userRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Get User Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retreiveUserInfo(username) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/user/get/' + username,
		type: 'GET',
		success: function (user) {
			// Update display info
			console.log(user);
			$("#editUsername").val(user.username);
			$("#editFirstName").val(user.firstName);
			$("#editLastName").val(user.lastName);
			$("#editRole").val(user.role);
			$("#editEmail").val(user.email);
			$("#editPhone").val(user.phone);
			$("#editState").val(user.state);
			$("#editBranch").val(user.branch);
			$("#editActive").val(user.enabled);
			// if clazz.active = true, tick the checkbox 'editActiveCheckbox'
			if (user.enabled == 0) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			// display modal
			$('#editModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update hidden value according to edit activive checkbox
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateEditActiveValue(checkbox) {
	var editActiveInput = document.getElementById("editActive");
	if (checkbox.checked) {
		editActiveInput.value = 0;
	} else {
		editActiveInput.value = 1;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update User Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateUserInfo() {

	// lastName validation
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

	// get from formData
	var user = {
		username: $('#editUsername').val(),
		firstName: $("#editFirstName").val(),
		lastName: $("#editLastName").val(),
		email: $("#editEmail").val(),
		state: $("#editState").val(),
		branch: $("#editBranch").val(),
		phone: $("#editPhone").val(),
		role: $("#editRole").val(),
		enabled: $("#editActive").val()
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/user/update',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(user),
		contentType: 'application/json',
		success: function (value) {
			// disappear modal
			$('#editModal').modal('hide');
			// Display the success alert
			$('#success-alert .modal-body').text('User is updated successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

	// flush all registered data
	document.getElementById("userEdit").reset();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Update password
////////////////////////////////////////////////////////////////////////////////////////////////////////
function updatePassword() {
	var id = $("#passwordId").val();
	var newPwd = $("#newPwd").val();
	var confirmPwd = $("#confirmPwd").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search user before password reset');
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
		url : '${pageContext.request.contextPath}/user/updatePassword/' + id + '/' + confirmPwd,
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
	$("#passwordId").val(id);
	$('#passwordModal').modal('show');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Clear password fields
////////////////////////////////////////////////////////////////////////////////////////////////////////
function clearPassword() {
	$("passwordId").val('');
	$("#newPwd").val('');
	$("#confirmPwd").val('');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Delete User
////////////////////////////////////////////////////////////////////////////////////////////////////////
function deleteUser(username) {
	//warn if Id is empty
	if (username == '') {
		$('#warning-alert .modal-body').text('Please search user before deleting');
		$('#warning-alert').modal('toggle');
		return;
	}
	
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/user/delete/' + username,
		type : 'PUT',
		success : function(data) {
			console.log(data);
			$('#success-alert .modal-body').html(data);
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

window.showWarning = function(id) {
    // Show the warning modal
    $('#deleteModal').modal('show');
    // Attach the click event handler to the "Delete" button
    $('#agreeDelete').off('click').on('click', function() {
        deleteUser(id);
        $('#deleteModal').modal('hide');
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

	#userListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="userList" method="get"
			action="${pageContext.request.contextPath}/user/list">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
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
					<div class="col-md-2">
						<label for="listRole" class="label-form">Role</label>
						<select class="form-control" id="listRole" name="listRole">
							<option value="0">All</option>
							<option value="Role_Administrator">Adminitrator</option>
							<option value="Role_Staff">Staff</option>
						</select>
					</div>
					<!-- put blank col-md-2 -->
					<div class="offset-md-3">
					</div>
					<div class="col md-auto">
						<label class="label-form-white">Search</label> 
						<button type="submit" class="btn btn-primary btn-block" onclick="return validate()"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col md-auto">
						<label class="label-form-white">Registration</label> 
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerModal">
							<i class="bi bi-plus"></i>&nbsp;&nbsp;Registration
						</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="userListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 10%">Username</th>
										<th class="align-middle text-center" style="width: 12.5%">Last Name</th>
										<th class="align-middle text-center" style="width: 12.5%">First Name</th>
										<th class="align-middle text-center" style="width: 10%">Role</th>
										<th class="align-middle text-center" style="width: 10%">Phone</th>
										<th class="align-middle text-center" style="width: 15%">Email</th>
										<th class="align-middle text-center" style="width: 5%">State</th>
										<th class="align-middle text-center" style="width: 10%">Branch</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 5%">Enabled</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-teacher-body">
									<c:choose>
										<c:when test="${UserList != null}">
											<c:forEach items="${UserList}" var="user">
												<tr>
													<td class="small align-middle text-center">
														<span>
															<c:out value="${user.username}" />
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:out value="${user.lastName}" />
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:out value="${user.firstName}" />
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:set var="roleArray" value="${fn:split(user.role, '_')}" />
        													<c:out value="${roleArray[1]}" />
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:out value="${user.phone}" />
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:out value="${user.email}" />
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:choose>
																<c:when test="${user.state == '1'}">Victoria</c:when>
																<c:when test="${user.state == '2'}">New South Wales</c:when>
																<c:when test="${user.state == '3'}">Queensland</c:when>
																<c:when test="${user.state == '4'}">South Australia</c:when>
																<c:when test="${user.state == '5'}">Tasmania</c:when>
																<c:when test="${user.state == '6'}">Western Australia</c:when>
																<c:when test="${user.state == '7'}">Northern Territory</c:when>
																<c:when test="${user.state == '8'}">ACT</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle ml-1">
														<span>
															<c:choose>
																<c:when test="${user.branch == '12'}">Box Hill</c:when>
																<c:when test="${user.branch == '13'}">Braybrook</c:when>
																<c:when test="${user.branch == '14'}">Chadstone</c:when>
																<c:when test="${user.branch == '15'}">Cranbourne</c:when>
																<c:when test="${user.branch == '16'}">Epping</c:when>
																<c:when test="${user.branch == '17'}">Glen Waverley</c:when>
																<c:when test="${user.branch == '18'}">Narre Warren</c:when>
																<c:when test="${user.branch == '19'}">Mitcham</c:when>
																<c:when test="${user.branch == '20'}">Preston</c:when>
																<c:when test="${user.branch == '21'}">Richimond</c:when>
																<c:when test="${user.branch == '22'}">Springvale</c:when>
																<c:when test="${user.branch == '23'}">St Albans</c:when>
																<c:when test="${user.branch == '24'}">Werribee</c:when>
																<c:when test="${user.branch == '25'}">Balwyn</c:when>
																<c:when test="${user.branch == '26'}">Rowville</c:when>
																<c:when test="${user.branch == '27'}">Caroline Springs</c:when>
																<c:when test="${user.branch == '28'}">Bayswater</c:when>
																<c:when test="${user.branch == '29'}">Point Cook</c:when>
																<c:when test="${user.branch == '30'}">Craigieburn</c:when>
																<c:when test="${user.branch == '31'}">Mernda</c:when>
																<c:when test="${user.branch == '32'}">Melton</c:when>
																<c:when test="${user.branch == '33'}">Glenroy</c:when>
																<c:when test="${user.branch == '34'}">Packenham</c:when>
																<c:when test="${user.branch == '90'}">JAC Head Office VIC</c:when>
																<c:when test="${user.branch == '99'}">Testing</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<c:set var="active" value="${user.enabled}" />
													<c:choose>
														<c:when test="${active == 0}">
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-success" data-toggle="tooltip" title="Enabled"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-secondary" data-toggle="tooltip" title="Disabled"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary hand-cursor" data-toggle="tooltip" title="Edit" onclick="retreiveUserInfo('${user.username}')"></i>&nbsp;
														<i class="bi bi-key text-warning hand-cursor" data-toggle="tooltip" title="Change Password" onclick="showPasswordModal('${user.username}')"></i>&nbsp;
														<i class="bi bi-trash text-danger hand-cursor" data-toggle="tooltip" title="Suspend" onclick="showWarning('${user.username}')"></i>
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

<!-- Add Form Dialogue -->
<div class="modal fade" id="registerModal" tabindex="-1" role="dialog"
	aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">User Registration</header>
					<form id="userRegister">
						<div class="form-row mt-3">
							<div class="col-md-5">
								<label for="addState" class="label-form">State</label>
								<select class="form-control" id="addState" name="addState" disabled>
								</select>
							</div>
							<div class="col-md-7">
								<label for="addBranch" class="label-form">Branch</label>
								<select class="form-control" id="addBranch" name="addBranch">
								</select>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-6">
								<label for="addFirstName" class="label-form">First Name:</label>
								<input type="text" class="form-control" id="addFirstName"
									name="addFirstName">
							</div>
							<div class="col-md-6">
								<label for="addLastName" class="label-form">Last Name:</label>
								<input type="text" class="form-control" id="addLastName"
									name="addLastName">
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-7">
								<label for="addPassword" class="label-form">Password</label>
								<input type="password" class="form-control" id="addPassword" name="addPassword">
							</div>
							<div class="col-md-5">
								<label for="addRole" class="label-form">Role</label>
								<select class="form-control" id="addRole" name="addRole">
									<option value="Role_Staff">Staff</option>
									<option value="Role_Administrator">Administrator</option>
								</select>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-6">
								<label for="addEmail" class="label-form">Email</label>
								<input type="text" class="form-control" id="addEmail"
									name="addEmail">
							</div>
							<div class="col-md-6">
								<label for="addPhone" class="label-form">Phone</label>
								<input type="number" class="form-control" id="addPhone"
									name="addPhone">
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addUser()">Register</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary"	data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">User Edit</header>
					<form id="userEdit">
						<div class="form-row mt-3">
							<div class="col-md-3">
								<label for="editUsername" class="label-form">Username</label>
								<input type="text" class="form-control" id="editUsername" name="editUsername" readonly>
							</div>
							<div class="col-md-4">
								<label for="editState" class="label-form">State</label>
								<select class="form-control" id="editState" name="editState" disabled>
								</select>
							</div>
							<div class="col-md-5">
								<label for="editBranch" class="label-form">Branch</label>
								<select class="form-control" id="editBranch" name="editBranch" disabled>
								</select>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-4">
								<label for="editFirstName" class="label-form">First Name</label>
								<input type="text" class="form-control" id="editFirstName" name="editFirstName">
							</div>
							<div class="col-md-4">
								<label for="editLastName" class="label-form">Last Name</label>
								<input type="text" class="form-control" id="editLastName" name="editLastName">
							</div>
							<div class="col-md-4">
								<label for="editRole" class="label-form">Role</label>
								<select class="form-control" id="editRole" name="editRole" disabled>
									<option value="Role_Staff">Staff</option>
									<option value="Role_Administrator">Administrator</option>
								</select>
							</div>
						</div>
						<div class="form-row mt-4 mb-4">
							<div class="col-md-4">
								<!-- <label for="editEmail" class="label-form">Email</label> -->
								<input type="text" class="form-control" id="editEmail" name="editEmail">
							</div>
							<div class="col-md-4">
								<!-- <label for="editPhone" class="label-form">Phone</label> -->
								<input type="number" class="form-control" id="editPhone" name="editPhone">
							</div>
							<div class="input-group col-md-4">
								<div class="input-group-prepend">
									<div class="input-group-text">
										<input type="checkbox" id="editActiveCheckbox" name="editActiveCheckbox" onchange="updateEditActiveValue(this)">
									</div>
								</div>
								<input type="hidden" id="editActive" name="editActive" value=1>
								<input type="text" id="editActiveLabel" class="form-control" placeholder="Activate">
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateUserInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal -->

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
			<i class="bi bi-exclamation-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Password Reset Dialogue -->
<div class="modal fade" id="passwordModal" tabindex="-1" role="dialog" aria-labelledby="passwordModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-warning">
            <div class="modal-header btn-warning">
               <h4 class="modal-title text-white" id="passwordModal"><i class="bi bi-key-fill text-dark"></i>&nbsp;&nbsp;User Password Reset</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <h5> Do you want to reset password for this user ?</h5>
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
				<input type="hidden" id="passwordId" name="passwordId"/>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-warning" onclick="updatePassword()"><i class="bi bi-check-circle"></i>&nbsp;Reset</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
            </div>
    	</div>
	</div>
</div>

<!-- Delete Dialogue -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="deleteModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;User Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Do you want to delete this user ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeDelete"><i class="bi bi-check-circle"></i>&nbsp;Delete</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>