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
	listGrade('#clazzGrade');
});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate class by grade
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getClazzByGrade() {
	// debugger;
	var grade = $('#clazzGrade').val();
	var year = $('#clazzYear').val();
	var state = $('#clazzState').val();
	var branch = $('#clazzBranch').val();
	$.ajax({
		url: '${pageContext.request.contextPath}/class/classes4Teacher',
		method: 'GET',
		data: {
			grade: grade,
			year: year,
			state: state,
			branch: branch
		},
		success: function (data) {
			$('#clazzId').empty(); // clear the previous options
			$.each(data, function (index, value) {
				const cleaned = cleanUpJson(value);
				console.log(cleaned);
				$('#clazzId').append($("<option value='" + value.id + "'>").text(value.name).val(value.id)); // add new option
			});
		},
		error: function (xhr, status, error) {
			console.error(xhr.responseText);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register User
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addUser() {
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
		url: '${pageContext.request.contextPath}/user/registerUser',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(user),
		contentType: 'application/json',
		success: function (teacher) {

			// Display the success alert
			$('#success-alert .modal-body').text('New user is registered successfully.');
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
//		Get Teacher Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retreiveTeacherInfo(std) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/teacher/get/' + std,
		type: 'GET',
		success: function (teacher) {
			// Update display info
			console.log(teacher);
			$("#editId").val(teacher.id);
			$("#editFirstName").val(teacher.firstName);
			$("#editLastName").val(teacher.lastName);
			$("#editEmail").val(teacher.email);
			$("#editTitle").val(teacher.title);
			$("#editAddress").val(teacher.address);
			$("#editPhone").val(teacher.phone);
			$("#editState").val(teacher.state);
			$("#editBranch").val(teacher.branch);
			$("#editBank").val(teacher.bank);
			$("#editBsb").val(teacher.bsb);
			$("#editAccountNumber").val(teacher.accountNumber);
			$("#editSuperannuation").val(teacher.superannuation);
			$("#editVitNumber").val(teacher.vitNumber);
			$("#editSuperMember").val(teacher.superMember);
			$("#editTfn").val(teacher.tfn);
			$("#editMemo").val(teacher.memo);
			// display modal
			$('#editModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Teacher Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateTeacherInfo() {
	// get from formData
	var teacher = {
		id: $('#editId').val(),
		firstName: $("#editFirstName").val(),
		lastName: $("#editLastName").val(),
		email: $("#editEmail").val(),
		address: $("#editAddress").val(),
		title: $("#editTitle").val(),
		phone: $("#editPhone").val(),
		memo: $("#editMemo").val(),
		state: $("#editState").val(),
		branch: $("#editBranch").val(),
		bank: $("#editBank").val(),
		bsb: $("#editBsb").val(),
		accountNumber: $("#editAccountNumber").val(),
		tfn: $("#editTfn").val(),
		superannuation: $("#editSuperannuation").val(),
		vitNumber: $("#editVitNumber").val(),
		superMember: $("#editSuperMember").val()
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/teacher/update',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(teacher),
		contentType: 'application/json',
		success: function (value) {
			// disappear modal
			$('#editModal').modal('hide');
			// Display the success alert
			$('#success-alert .modal-body').text('ID : ' + value.id + ' is updated successfully.');
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
	document.getElementById("teacherEdit").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Ativate Teacher
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function activateTeacher(id) {
	if (confirm("Are you sure you want to activate this teacher?")) {
		// send query to controller
		$.ajax({
			url: '${pageContext.request.contextPath}/teacher/activate/' + id,
			type: 'PUT',
			success: function (data) {
				// Display the success alert
				$('#success-alert .modal-body').text('ID : ' + id + ' is now activated again.');
				$('#success-alert').modal('show');
				$('#success-alert').on('hidden.bs.modal', function (e) {
					location.reload();
				});
			},
			error: function (xhr, status, error) {
				console.log('Error : ' + error);
			}
		});
	} else {
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		De-activate Teacher
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function inactivateTeacher(id) {
	if (confirm("Are you sure you want to de-activate this teacher?")) {
		// send query to controller
		$.ajax({
			url: '${pageContext.request.contextPath}/teacher/inactivate/' + id,
			type: 'PUT',
			success: function (data) {
				// clear existing form
				// $('#success-alert .modal-body').text(
				// 		'ID : ' + id + ' is now inactivated');
				// $('#success-alert').modal('show');
				//clearStudentForm();
				// Display the success alert
				$('#success-alert .modal-body').text('ID : ' + id + ' is now inactivated.');
				$('#success-alert').modal('show');
				$('#success-alert').on('hidden.bs.modal', function (e) {
					location.reload();
				});
			},
			error: function (xhr, status, error) {
				console.log('Error : ' + error);
			}
		});
	} else {
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Get Clazz Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retreiveClazzInfo(id, state, branch) {
	// console.log('retreiveClazzInfo : ' + id + ' - ' + state + ' - ' + branch);
	$('#clazzTeacher').val(id);
	$('#clazzState').val(state);
	$('#clazzBranch').val(branch);

	$('#clazzListResultTable tbody').empty();
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/teacher/getClazz/' + id,
		type: 'GET',
		success: function (data) {
			$.each(data, function (index, value) {
				// const cleaned = cleanUpJson(value);
				// console.log(cleaned);
				var row = $("<tr>");
				row.append($('<td>').text(value.name));
				row.append($('<td>').text(value.description));
				row.append($('<td>').text(value.day));
				var gradeText = gradeName(value.grade);
				row.append($('<td>').text(gradeText));
				row.append($('<td>').text(value.year));
				var isOnline = value.online;
				var onlineIcon = isOnline ? $('<i class="bi bi-check-circle-fill text-secondary h6"></i>') : $('<i class="bi bi-check-circle-fill text-success h6"></i>');
				row.append($('<td>').addClass('text-center').append(onlineIcon));
				var isActived = value.active;
				var activeIcon = isActived ? $('<i class="bi bi-toggle-on text-success h5"></i>') : $('<i class="bi bi-toggle-off text-secondary h5"></i>');
				row.append($('<td>').addClass('text-center').append(activeIcon));
				row.append($('<td hidden>').addClass("clazzId").text(value.id));
				// Create the bin icon and add an onClick event
				var binIcon = $('<i class="bi bi-trash h5"></i>');
				var binIconLink = $("<a>")
					.attr("href", "javascript:void(0)")
					.attr("title", "Delete Class")
					.click(function () {
						removeClazz(id, value.id);
						row.remove(); // Remove the corresponding <tr>
					});
				binIconLink.append(binIcon);
				row.append($("<td>").addClass('text-center').append(binIconLink));

				$('#clazzListResultTable > tbody').append(row);
			});
			$('#clazzList').modal('show');
			// display modal
			//$('#editModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Clazz
//////////////////////////////////////////////////////////////////////////////////////////////////////
function addClazz() {
	var teacherId = $('#clazzTeacher').val();
	var clazzId = $('#clazzId').val();
	// console.log('addClazz : ' + teacherId + ' - ' + clazzId);
	$.ajax({
		url: '${pageContext.request.contextPath}/teacher/addClazz/' + teacherId + '/' + clazzId,
		type: 'PUT',
		success: function (value) {
			// console.log('addClazz : ' + data);
			var row = $("<tr>");
			row.append($('<td>').text(value.name));
			row.append($('<td>').text(value.description));
			row.append($('<td>').text(value.day));
			var gradeText = gradeName(value.grade);
			row.append($('<td>').text(gradeText));
			row.append($('<td>').text(value.year));
			var isOnline = value.online;
			var onlineIcon = isOnline ? $('<i class="bi bi-check-circle-fill text-secondary h6"></i>') : $('<i class="bi bi-check-circle-fill text-success h6"></i>');
			row.append($('<td>').addClass('text-center').append(onlineIcon));
			var isActived = value.active;
			var activeIcon = isActived ? $('<i class="bi bi-toggle-on text-success h5"></i>') : $('<i class="bi bi-toggle-off text-secondary h5"></i>');
			row.append($('<td>').addClass('text-center').append(activeIcon));
			row.append($('<td hidden>').addClass("clazzId").text(value.id));
			// Create the bin icon and add an onClick event
			var binIcon = $('<i class="bi bi-trash h5"></i>');
			var binIconLink = $("<a>")
				.attr("href", "javascript:void(0)")
				.attr("title", "Delete Class")
				.click(function () {
					removeClazz(id, value.id);
					row.remove(); // Remove the corresponding <tr>
				});
			binIconLink.append(binIcon);
			row.append($("<td>").addClass('text-center').append(binIconLink));

			$('#clazzListResultTable > tbody').append(row);
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Remove Clazz
//////////////////////////////////////////////////////////////////////////////////////////////////////
function removeClazz(teacher, clazz) {
	$.ajax({
		url: '${pageContext.request.contextPath}/teacher/updateClazz/' + teacher + '/' + clazz,
		type: 'PUT',
		success: function (data) {
			// console.log('removeClazz : ' + data);
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear existing values on state & branch
//////////////////////////////////////////////////////////////////////////////////////////////////////
function clearStateNBranch() {
	$('#clazzTeacher').val('');
	$('#clazzState').val('');
	$('#clazzBranch').val('');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Update password
////////////////////////////////////////////////////////////////////////////////////////////////////////
function updatePassword() {
	var id = $("#emailId").val();
	var newPwd = $("#newPwd").val();
	var confirmPwd = $("#confirmPwd").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search teacher record before password reset');
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
		url : '${pageContext.request.contextPath}/teacher/updatePassword/' + id + '/' + confirmPwd,
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
	$("#emailId").val(id);
	$('#passwordModal').modal('show');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Clear password fields
////////////////////////////////////////////////////////////////////////////////////////////////////////
function clearPassword() {
	$("emailId").val('');
	$("#newPwd").val('');
	$("#confirmPwd").val('');
}


</script>

<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="teacherList" method="get"
			action="${pageContext.request.contextPath}/user/list">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<select class="form-control" id="listRole" name="listRole">
							<option value="All">All</option>
							<option value="Role_Administrator">Adminitrator</option>
							<option value="Role_Staff">Staff</option>
						</select>
					</div>
					<div class="col-md-2">
						<select class="form-control" id="listState" name="listState">
							<option value="All">All State</option>
						</select>
					</div>
					<div class="col-md-2">
						<select class="form-control" id="listBranch" name="listBranch">
							<option value="All">All Branch</option>
						</select>
					</div>
					<!-- put blank col-md-2 -->
					<div class="offset-md-2">
					</div>
					<div class="col-md-2">
						<button type="submit" class="btn btn-primary btn-block" onclick="return validate()"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col-md-2">
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerModal">
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
										<th>Username</th>
										<th>Last Name</th>
										<th>First Name</th>
										<th>Role</th>
										<th>Phone</th>
										<th>Email</th>
										<th>State</th>
										<th>Branch</th>
										<th data-orderable="false">Enabled</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-teacher-body">
									<c:choose>
										<c:when test="${UserList != null}">

											<c:forEach items="${UserList}" var="user">

												<tr>
													<td class="small ellipsis">
														<span>
															<c:out value="${user.username}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${user.lastName}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${user.firstName}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${user.role}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${user.phone}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${user.email}" />
														</span>
													</td>
													<td class="small ellipsis">
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
													<td class="small ellipsis">
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
															<td class="text-center">
																<i class="bi bi-check-circle-fill text-success" title="Enabled"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center">
																<i class="bi bi-check-circle-fill text-secondary" title="Disabled"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td>
														<i class="bi bi-pencil-square text-primary" data-toggle="tooltip" title="Edit" onclick="retreiveTeacherInfo('${user.username}')"></i>&nbsp;
														<i class="bi bi-key text-warning" data-toggle="tooltip" title="Change Password" onclick="showPasswordModal('${user.username}')"></i>&nbsp;
														<i class="bi bi-x-circle-fill text-danger" data-toggle="tooltip" title="Suspend" onclick="inactivateTeacher('${user.username}')"></i>
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
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">User Registration</header>
					<form id="userRegister">
						<div class="form-row mt-2">
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
						<div class="form-row mt-2">
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
						<div class="form-row mt-2">
							<div class="col-md-7">
								<label for="addPassword" class="label-form">Password</label>
								<input type="text" class="form-control" id="addPassword" name="addPassword">
							</div>
							<div class="col-md-5">
								<label for="addRole" class="label-form">Role</label>
								<select class="form-control" id="addRole" name="addRole">
									<option value="Role_Staff">Staff</option>
									<option value="Role_Administrator">Administrator</option>
								</select>
							</div>
						</div>
						<div class="form-row mt-2">
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
						<button type="submit" class="btn btn-primary" onclick="addUser()">Register</button>&nbsp;&nbsp;
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
<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Teacher Edit</header>
					<form id="teacherEdit">
						<div class="form-row mt-2">
							<div class="col-md-4">
								<label for="editState" class="label-form">State</label>
								<select class="form-control" id="editState" name="editState">
								</select>
							</div>
							<div class="col-md-6">
								<label for="editBranch" class="label-form">Branch</label>
								<select class="form-control" id="editBranch" name="editBranch">
								</select>
							</div>
							<div class="col-md-2">
								<label for="editTitle" class="label-form">Title</label>
								<select class="form-control" id="editTitle" name="editTitle">
									<option value="mr">Mr</option>
									<option value="mrs">Mrs</option>
									<option value="ms">Ms</option>
									<option value="miss">Miss</option>
									<option value="other">Other</option>
								</select>
							</div>
						</div>
						<div class="form-row mt-2">
							<!-- <div class="col-md-2">
								<label for="editId" class="label-form">Id:</label>
								<input type="text" class="form-control" id="editId" name="editId"
									readonly>
							</div> -->
							<input type="hidden" id="editId" name="editId" />
							<div class="col-md-6">
								<label for="editFirstName" class="label-form">First Name:</label>
								<input type="text" class="form-control" id="editFirstName"
									name="editFirstName">
							</div>
							<div class="col-md-6">
								<label for="editLastName" class="label-form">Last Name:</label>
								<input type="text" class="form-control" id="editLastName"
									name="editLastName">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-5">
								<label for="editEmail" class="label-form">Email</label>
								<input type="text" class="form-control" id="editEmail" name="editEmail" disabled>
							</div>
							<div class="col-md-6">
								<label for="editPhone" class="label-form">Phone</label>
								<input type="number" class="form-control" id="editPhone"
									name="editPhone">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-9">
								<label for="editAddress" class="label-form">Address</label>
								<input type="text" class="form-control" id="editAddress"
									name="editAddress">
							</div>
							<div class="col-md-3">
								<label for="editVitNumber" class="label-form">VIT/WWCC</label>
								<input type="text" class="form-control" id="editVitNumber"
									name="editVitNumber">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-4">
								<label for="editBank" class="label-form">Bank</label>
								<input type="text" class="form-control" id="editBank"
									name="editBank">
							</div>
							<div class="col-md-3">
								<label for="editBsb" class="label-form">Bsb</label>
								<input type="text" class="form-control" id="editBsb" name="editBsb">
							</div>
							<div class="col-md-5">
								<label for="editAccountNumber" class="label-form">Account #</label>
								<input type="number" class="form-control" id="editAccountNumber"
									name="editAccountNumber">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-5">
								<label for="editTfn" class="label-form">TFN</label>
								<input type="number" class="form-control" id="editTfn"
									name="editTfn">
							</div>
							<div class="col-md-4">
								<label for="editSuperannuation"
									class="label-form">Superannuation</label>
								<input type="text" class="form-control" id="editSuperannuation"
									name="editSuperannuation">
							</div>
							<div class="col-md-3">
								<label for="editSuperMember" class="label-form"> Membership
									#</label>
								<input type="text" class="form-control" id="editSuperMember"
									name="editSuperMember">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-12">
								<label for="editMemo" class="label-form">Memo</label>
								<textarea class="form-control" id="editMemo"
									name="editMemo"></textarea>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary"
							onclick="updateTeacherInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary"
							data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<!-- Clazz Form Dialogue -->
<div class="modal fade" id="clazzList">
	<div class="modal-dialog modal-xl modal-dialog-centered">
		<div class="modal-content">
			<div class="modal-header bg-primary text-white">
				<h5 class="modal-title">&nbsp;<i class="bi bi-card-list"></i>&nbsp;&nbsp; Associated Class</h5>
				<button type="button" class="close" data-dismiss="modal">
					<span>&times;</span>
				</button>
			</div>
			<div class="modal-body table-wrap">
				<table class="table table-striped table-bordered" id="clazzListResultTable"
					data-header-style="headerStyle" style="font-size: smaller;">
					<thead class="thead-light">
						<tr>
							<th data-field="name">Name</th>
							<th data-field="Description">Description</th>
							<th data-field="day">Day</th>
							<th data-field="grade">Grade</th>
							<th data-field="year">Academic Year</th>
							<th data-field="online">Online</th>
							<th data-field="active">Active</th>
							<th data-field="active">Remove</th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>

			<div class="form-group">
				<div
					style="border: 2px solid #017bfe; padding: 20px; border-radius: 10px; margin-left: 50px; margin-right: 50px;">
					<input type="hidden" id="clazzTeacher" name="clazzTeacher" />
					<input type="hidden" id="clazzState" name="clazzState" />
					<input type="hidden" id="clazzBranch" name="clazzBranch" />
					<div class="form-row">
						<div class="offset-md-1"></div>
						<div class="col-md-2">
							<label for="clazzGrade" class="label-form">Grade</label>
							<select class="form-control" id="clazzGrade" name="clazzGrade">
							</select>
						</div>
						<div class="col-md-2">
							<label for="clazzYear" class="label-form">Academic Year</label>
							<select class="form-control" id="clazzYear" name="clazzYear">
								<%
									Calendar now = Calendar.getInstance();
									int currentYear = now.get(Calendar.YEAR);
								%>
								<option value=0>All</option>
								<option value=<%= currentYear %>><%= currentYear %></option>
								<%
									// Adding the last five years
									for (int i = currentYear - 1; i >= currentYear - 3; i--) {
								%>
									<option value=<%= i %>><%= i %></option>
								<%
								}
								%>
							</select>
						</div>
						<div class="col-md-3">
							<label for="clazzId" class="label-form">Class</label>
							<select class="form-control" id="clazzId" name="clazzId">
							</select>
						</div>
						<div class="offset-md-1"></div>
						<div class="col mx-auto">
							<label for="addCourse" class="label-form">&nbsp;</label>

							<button type="button" class="btn btn-primary btn-block"
								onclick="addClazz()"> <i class="bi bi-plus"></i>&nbsp;Add</button>
						</div>
						<div class="offset-md-1"></div>
					</div>
				</div>
			</div>
			<div class="modal-footer" style="border-top: 0px;">
				<button type="button" class="btn btn-secondary" data-dismiss="modal"
					onclick='clearStateNBranch()'>Close</button>
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

<!-- Password Reset Dialogue -->
<div class="modal fade" id="passwordModal" tabindex="-1" role="dialog" aria-labelledby="passwordModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header btn-warning">
               <h4 class="modal-title text-white" id="passwordModal"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Teacher Password Reset</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <h5> Do you want to reset password for this teacher ?</h5>
				<p>
					<div class="row mt-4">
						<div class="col-md-5">
							New Password
						</div>
						<div class="col-md-7">
							<input type="text" class="form-control" id="newPwd" name="newPwd"/>
						</div>
					</div>
					<div class="row mt-4">
						<div class="col-md-5">
							Confirm Password
						</div>
						<div class="col-md-7">
							<input type="text" class="form-control" id="confirmPwd" name="confirmPwd"/>
						</div>
					</div>
				</p>
				<input type="hidden" id="emailId" name="emailId"/>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-warning" onclick="updatePassword()"><i class="bi bi-wrench-adjustable"></i>&nbsp;Reset</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-check-circle"></i>&nbsp;Close</button>
            </div>
    	</div>
	</div>
</div>
