<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.Calendar" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>

<!-- Timepicker library -->
<script src="${pageContext.request.contextPath}/js/gijgo-1.9.14.min.js" type="text/javascript"></script>
<link href="${pageContext.request.contextPath}/css/gijgo-1.9.14.min.css" rel="stylesheet" type="text/css" />

<script>
$(document).ready(function () {
	$('#onlineListTable').DataTable({
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

	$('#addStartTime').timepicker({
		uiLibrary: 'bootstrap'
	});
	$('#addEndTime').timepicker({
		uiLibrary: 'bootstrap'
	});
	$('#editStartTime').timepicker({
		uiLibrary: 'bootstrap'
	});
	$('#editEndTime').timepicker({
		uiLibrary: 'bootstrap'
	});

	// initialise state list when loading
	listGrade('#listGrade');
	listGrade('#addGrade');
	listGrade('#editGrade');

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register OnlineSession
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addOnline() {

	//start, end, url validation
	var start = document.getElementById('addStartTime');
	if(start.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter start time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			start.focus();
		});
		return false;
	}
	var end = document.getElementById('addEndTime');
	if(end.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter end time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			end.focus();
		});
		return false;
	}
	var address = document.getElementById('addAddress');
	if(address.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter access URL');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			address.focus();
		});
		return false;
	}

	// Get from form data
	var online = {
		grade: $("#addGrade").val(),
		year: $("#addYear").val(),
		day: $("#addDay").val(),
		week: $("#addWeek").val(),
		startTime: $("#addStartTime").val(),
		endTime: $("#addEndTime").val(),
		address : $("#addAddress").val()
	}

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/onlineSession/register',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(online),
		contentType: 'application/json',
		success: function (data) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				'New Online Session is registered successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			if(xhr.status==417){
				$('#warning-alert .modal-body').text(xhr.responseJSON);
				$('#warning-alert').modal('show');
			}else{
				console.log('Error : ' + error);
			}
		}
	});
	$('#registerOnlineSessionModal').modal('hide');
	// flush all registered data
	document.getElementById("onlineSessionRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Online Session
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveOnlineInfo(onlineId) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/onlineSession/get/' + onlineId,
		type: 'GET',
		success: function (online) {
			 console.log(online);
			$("#editId").val(online.id);
			$("#editClazzId").val(online.clazzId);
			$("#editGrade").val(online.grade);
			$("#editYear").val(online.year);			
			$("#editDay").val(online.day);
			$("#editWeek").val(online.week);
			$("#editStartTime").val(online.startTime);
			$("#editEndTime").val(online.endTime);
			$("#editActive").val(online.active);
			if (online.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$("#editAddress").val(online.address);
			$('#editOnlineModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Online Session
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateOnlineInfo() {

	//start, end, url validation
	var start = document.getElementById('editStartTime');
	if(start.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter start time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			start.focus();
		});
		return false;
	}
	var end = document.getElementById('editEndTime');
	if(end.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter end time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			end.focus();
		});
		return false;
	}
	var address = document.getElementById('editAddress');
	if(address.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter access URL');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			address.focus();
		});
		return false;
	}

	var onlineId = $("#editId").val();
	// get from formData
	var online = {
		id: onlineId,
		grade: $("#editGrade").val(),
		year: $("#editYear").val(),
		day: $("#editDay").val(),
		week: $("#editWeek").val(),
		startTime: $("#editStartTime").val(),
		endTime: $("#editEndTime").val(),
		active: $("#editActive").val(),
		address: $("#editAddress").val(),
		clazzId : $("#editClazzId").val()
	}

	// console.log(clazz);
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/onlineSession/update',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(online),
		contentType: 'application/json',
		success: function (value) {
			// Display success alert
			//debugger
			$('#success-alert .modal-body').text(value);
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

	$('#editOnlineModal').modal('hide');
	// flush all registered data
	clearClassForm("onlineEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearClassForm(elementId) {
	document.getElementById(elementId).reset();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update hidden value according to edit activive checkbox
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateEditActiveValue(checkbox) {
	var editActiveInput = document.getElementById("editActive");
	if (checkbox.checked) {
		editActiveInput.value = "true";
	} else {
		editActiveInput.value = "false";
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before deleting Online
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteOnline(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Online
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteOnline(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/onlineSession/delete/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Online Session deleted successfully');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (error) {
            // Handle error response
            console.error(error);
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

	tr { 
		vertical-align: middle;
		height: 50px 	
	} 

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/onlineSession/filterSession">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listSet" class="label-form">Set</label>
						<select class="form-control" id="listSet" name="listSet">
						</select>
						<script>
							// Get a reference to the select element
							var selectElement = document.getElementById("listSet");
							// Create a new option element for 'All'
							var allOption = document.createElement("option");
							// Set the value and text content for the 'All' option
							allOption.value = "0";
							allOption.textContent = "All";
							// Append the 'All' option to the select element
							selectElement.appendChild(allOption);
							// Loop to add options from 1 to 49
							for (var i = 1; i <= 49; i++) {
								// Create a new option element
								var option = document.createElement("option");
								// Set the value and text content for the option
								option.value = i;
								option.textContent = i;
								// Append the option to the select element
								selectElement.appendChild(option);
							}
						</script>
					</div>
					<div class="col-md-2">
						<label for="listYear" class="label-form">Academic Year</label>
						<select class="form-control" id="listYear" name="listYear">
							<%
								Calendar now = Calendar.getInstance();
								int currentYear = now.get(Calendar.YEAR);
								int nextYear = currentYear + 1;
							%>
							<option value="0">All</option>
							<option value="<%= currentYear %>">Academic Year <%= (currentYear%100) %>/<%= (currentYear%100)+1 %></option>
							<%
								// Adding the last five years
								for (int i = currentYear - 1; i >= currentYear - 5; i--) {
							%>
								<option value="<%= i %>">Academic Year <%= (i%100) %>/<%= (i%100)+1 %></option>
							<%
							}
							%>
						</select>
					</div>
					<div class="offset-md-5"></div>
					<div class="col mx-auto">
						<label for="listState" class="label-form text-white">0</label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label for="listState" class="label-form text-white">0</label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerOnlineSessionModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="onlineListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th class="text-center align-middle" style="width: 5%">Grade</th>
										<th class="text-center align-middle" style="width: 10%">Academic Year</th>
										<th class="text-center align-middle" style="width: 10%">Day</th>
										<th class="text-center align-middle" style="width: 5%">Set</th>
										<th class="text-center align-middle" style="width: 10%">Start Time</th>
										<th class="text-center align-middle" style="width: 10%">End Time</th>
										<th class="text-center align-middle" style="width: 35%">Access URL</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${OnlineList != null}">
											<c:forEach items="${OnlineList}" var="online">
												<tr>
													<td class="small align-middle text-center">
														<span>
															<c:choose>
																<c:when test="${online.grade == '1'}">P2</c:when>
																<c:when test="${online.grade == '2'}">P3</c:when>
																<c:when test="${online.grade == '3'}">P4</c:when>
																<c:when test="${online.grade == '4'}">P5</c:when>
																<c:when test="${online.grade == '5'}">P6</c:when>
																<c:when test="${online.grade == '6'}">S7</c:when>
																<c:when test="${online.grade == '7'}">S8</c:when>
																<c:when test="${online.grade == '8'}">S9</c:when>
																<c:when test="${online.grade == '9'}">S10</c:when>
																<c:when test="${online.grade == '10'}">S10E</c:when>
																<c:when test="${online.grade == '11'}">TT6</c:when>
																<c:when test="${online.grade == '12'}">TT8</c:when>
																<c:when test="${online.grade == '13'}">TT8E</c:when>
																<c:when test="${online.grade == '14'}">SRW4</c:when>
																<c:when test="${online.grade == '15'}">SRW5</c:when>
																<c:when test="${online.grade == '16'}">SRW6</c:when>
																<c:when test="${online.grade == '17'}">SRW7</c:when>
																<c:when test="${online.grade == '18'}">SRW8</c:when>
																<c:when test="${online.grade == '19'}">JMSS</c:when>
																<c:when test="${online.grade == '20'}">VCE</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<!-- Year <c:out value="${online.year}" />/<c:out value="${online.year+1}" /> -->
															Year <c:out value="${fn:substring(online.year, 2, 4)}" />/<c:out value="${fn:substring(online.year+1, 2, 4)}" />
														</span>
													</td>
													<td class="small align-middle">
														<span class="text-capitalize">
															<!-- <c:out value="${online.day}" /> -->
															<c:choose>
																<c:when test="${online.day == '1'}">Monday</c:when>
																<c:when test="${online.day == '2'}">Tuesday</c:when>
																<c:when test="${online.day == '3'}">Wednessday</c:when>
																<c:when test="${online.day == '4'}">Thursday</c:when>
																<c:when test="${online.day == '5'}">Friday</c:when>
																<c:when test="${online.day == '6'}">Saturday Morning</c:when>
																<c:when test="${online.day == '7'}">Saturday Afternoon</c:when>
																<c:when test="${online.day == '8'}">Sunday Morning</c:when>
																<c:when test="${online.day == '9'}">Sunday Afternoon</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-center">
														<span>
															<c:out value="${online.week}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${online.startTime}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${online.endTime}" />
														</span>
													</td>
													<td class="small align-middle text-truncate" style="max-width: 150px;">
														<span>
															<c:out value="${online.address}" />
														</span>
													</td>
													<c:set var="active" value="${online.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-success"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-secondary"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveOnlineInfo('${online.id}')">
														</i>&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete" onclick="confirmDelete('${online.id}')">
														</i>
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
<div class="modal fade" id="registerOnlineSessionModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Online Session Registration</header>

					<form id="onlineSessionRegister">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<!-- <div class="offset-md-1"></div> -->
								<div class="col-md-6">
									<label for="addYear" class="label-form">Academic Year</label>
									<select class="form-control" id="addYear" name="addYear">
										<%
											Calendar addNow = Calendar.getInstance();
											int addCurrentYear = addNow.get(Calendar.YEAR);
											int addNextYear = addCurrentYear + 1;
										%>
										<!-- <option value="<%= addNextYear %>">Academic Year <%= (addNextYear%100)  %>/<%= (addNextYear%100)+1  %></option> -->
										<option value="<%= addCurrentYear %>">Academic Year <%= (addCurrentYear%100) %>/<%= (addCurrentYear%100)+1 %></option>
										<%
											// Adding the last three years
											for (int i = addCurrentYear - 1; i >= addCurrentYear - 3; i--) {
										%>
											<option value="<%= i %>">Academic Year <%= (i%100) %>/<%= (i%100)+1 %></option>
										<%
										}
										%>
									</select>
								</div>
								<!-- <div class="offset-md-1"></div> -->
								<div class="col-md-3">
									<label for="addDay" class="label-form">Day</label>
									<select class="form-control" id="addDay" name="addDay">
										<option value="1">Monday</option>
										<option value="2">Tuesday</option>
										<option value="3">Wednesday</option>
										<option value="4">Thursday</option>
										<option value="5">Friday</option>
										<option value="6">Saturday Morning</option>
										<option value="7">Saturday Afternoon</option>
										<option value="8">Sunday Morning</option>
										<option value="9">Sunday Afternoon</option>
									</select>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-2">
									<label for="addWeek" class="label-form">Set</label>
									<select class="form-control" id="addWeek" name="addWeek">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("addWeek");
									  
										// Loop to add options from 1 to 49
										for (var i = 1; i <= 49; i++) {
										  // Create a new option element
										  var option = document.createElement("option");
									  
										  // Set the value and text content for the option
										  option.value = i;
										  option.textContent = i;
									  
										  // Append the option to the select element
										  selectElement.appendChild(option);
										}
									</script>
								</div>
								<div class="offset-md-1"></div>
								<div class="col-md-4">
									<label for="addStartTime" class="label-form">Start Time</label>
									<!-- <input type="text" class="form-control datetimepicker-input" id="addStartTime" name="addStartTime" placeholder="HH:mm" /> -->
									<input id="addStartTime" name="addStartTime" />
								</div>
								<div class="offset-md-1"></div>
								<div class="col-md-4">
									<label for="addEndTime" class="label-form">End Time</label>
									<!-- <input type="text" class="form-control datepicker" id="addEndTime" name="addEndTime" placeholder="HH:mm" /> -->
									<input id="addEndTime" name="addEndTime" />
								</div>
								<div class="offset-md-1"></div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12 mb-4">
									<label for="addAddress" class="label-form">Access URL</label>
									<input type="text" class="form-control" id="addAddress" name="addAddress" placeholder="https://" title="Please enter access address" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addOnline()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearClassForm('onlineSessionRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editOnlineModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Online Session Edit</header>
					<form id="onlineEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-2">
									<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-5">
									<label for="editYear" class="label-form">Academic Year</label>
									<select class="form-control" id="editYear" name="editYear" disabled>
									<%
										Calendar editNow = Calendar.getInstance();
										int editCurrentYear = editNow.get(Calendar.YEAR);
										int editNextYear = editCurrentYear + 1;
									%>
									<option value="<%= addNextYear %>"> Year <%= (editNextYear%100)  %>/<%= (editNextYear%100)+1  %></option>
									<option value="<%= addCurrentYear %>"> Year <%= (editCurrentYear%100) %>/<%= (editCurrentYear%100)+1 %></option>
									<%
										// Adding the last three years
										for (int i = editCurrentYear - 1; i >= editCurrentYear - 3; i--) {
									%>
										<option value="<%= i %>"> Year <%= (i%100) %>/<%= (i%100)+1 %></option>
									<%
									}
									%>
									</select>
								</div>
								<div class="col-md-3">
									<label for="editDay" class="label-form">Day</label>
									<select class="form-control" id="editDay" name="editDay" disabled>
										<option value="1">Monday</option>
										<option value="2">Tuesday</option>
										<option value="3">Wednesday</option>
										<option value="4">Thursday</option>
										<option value="5">Friday</option>
										<option value="6">Saturday Morning</option>
										<option value="7">Saturday Afternoon</option>
										<option value="8">Sunday Morning</option>
										<option value="9">Sunday Afternoon</option>
									</select>
								</div>
								
								<div class="col-md-2">
									<label for="editWeek" class="label-form">Set</label>
									<select class="form-control" id="editWeek" name="editWeek">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("editWeek");
									  
										// Loop to add options from 1 to 49
										for (var i = 1; i <= 49; i++) {
										  // Create a new option element
										  var option = document.createElement("option");
									  
										  // Set the value and text content for the option
										  option.value = i;
										  option.textContent = i;
									  
										  // Append the option to the select element
										  selectElement.appendChild(option);
										}
									</script>
								</div>
								
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-4">
									<input id="editStartTime" name="editStartTime" />
								</div>
								<div class="col-md-4">
									<input id="editEndTime" name="editEndTime" />
								</div>
								<div class="input-group col-md-4">
									<div class="input-group-prepend">
										<div class="input-group-text">
											<input type="checkbox" id="editActiveCheckbox" name="editActiveCheckbox" onchange="updateEditActiveValue(this)">
										</div>
									</div>
									<input type="hidden" id="editActive" name="editActive" value="false">
									<input type="text" id="editActiveLabel" class="form-control" placeholder="Active">
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-3 mb-4">
								<div class="col-md-12">
									<label for="editAddress" class="label-form">Access URL</label>
									<input type="text" class="form-control" id="editAddress" name="editAddress" />
								</div>
							</div>
						</div>
						<input type="hidden" id="editId" name="editId" />
						<input type="hidden" id="editClazzId" name="editClazzId" />
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateOnlineInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">Close</button>
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

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="fa fa-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Error Alert -->
<div id="error-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-danger alert-dialog-display">
			<i class="fa fa-times-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!--Delete Confirmation Modal -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Online Session Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Online Session ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>