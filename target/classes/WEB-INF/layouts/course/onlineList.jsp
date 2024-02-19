<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.Calendar" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css">
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

	// When the Grade dropdown changes, send an Ajax request to get the corresponding Type
	$('#addGrade').change(function () {
		var grade = $(this).val();
		getCoursesByGrade(grade, '#addCourse');
	});

	// When the Grade dropdown changes, send an Ajax request to get the corresponding Type
	$('#editGrade').change(function () {
		var grade = $(this).val();
		getCoursesByGrade(grade, '#editCourse');
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
		console.log(online);

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
//		Retrieve Class
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveClassInfo(clazzId) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/class/get/class/' + clazzId,
		type: 'GET',
		success: async function (clazz) {
			//console.log(clazz);
			// firstly populate courses by grade then set the selected option
			await editInitialiseCourseByGrade(clazz.grade, clazz.courseId);
			$("#editId").val(clazz.id);
			$("#editState").val(clazz.state);
			$("#editBranch").val(clazz.branch);
			// Set date value
			var date = new Date(clazz.startDate); // Replace with your date value
			$("#editStartDate").datepicker('setDate', date);
			$("#editGrade").val(clazz.grade);
			$("#editDay").val(clazz.day);
			$("#editPrice").val(clazz.price.toFixed(2));
			$("#editName").val(clazz.name);
			$("#editActive").val(clazz.active);
			// if clazz.active = true, tick the checkbox 'editActiveCheckbox'
			if (clazz.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$('#editClassModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Class
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateClassInfo() {
	var clazzId = $("#editId").val();
	// get from formData
	var clazz = {
		id: clazzId,
		state: $("#editState").val(),
		branch: $("#editBranch").val(),
		startDate: $("#editStartDate").val(),
		name: $("#editName").val(),
		grade: $("#editGrade").val(),
		courseId: $("#editCourse").val(),
		day: $("#editDay").val(),
		active: $("#editActive").val(),
		price : $("#editPrice").val()
	}

	// console.log(clazz);
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/class/update/class',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(clazz),
		contentType: 'application/json',
		success: function (value) {
			// Display success alert
			$('#success-alert .modal-body').text(
				'Class is updated successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

	$('#editClassModal').modal('hide');
	// flush all registered data
	clearClassForm("classEdit");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate courses by grade
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getCoursesByGrade(grade, toWhere) {
	$.ajax({
		url: '${pageContext.request.contextPath}/class/listCoursesByGrade',
		method: 'GET',
		data: { grade: grade },
		success: function (data) {
			$(toWhere).empty(); // clear the previous options
			$.each(data, function (index, value) {
				const cleaned = cleanUpJson(value);
				//console.log(cleaned);
				$(toWhere).append($("<option value='" + value.id + "'>").text(value.description).val(value.id)); // add new option
			});
		},
		error: function (xhr, status, error) {
			console.error(xhr.responseText);
		}
	});
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
// 		Initialise courses by grade in edit dialog
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function editInitialiseCourseByGrade(grade, courseId) {
	$.ajax({
		url: '${pageContext.request.contextPath}/class/listCoursesByGrade',
		method: 'GET',
		data: { grade: grade },
		success: function (data) {
			$('#editCourse').empty(); // clear the previous options
			$.each(data, function (index, value) {
				const cleaned = cleanUpJson(value);
				console.log(cleaned);
				$('#editCourse').append($("<option value='" + value.id + "'>").text(value.description).val(value.id)); // add new option
			});
			// Set the selected option
			$("#editCourse").val(courseId);
		},
		error: function (xhr, status, error) {
			console.error(xhr.responseText);
		}
	});
}

</script>

<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/onlineSession/filterSession">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
						</select>
					</div>
					<div class="col-md-2">
						<select class="form-control" id="listYear" name="listYear">
							<%
								Calendar now = Calendar.getInstance();
								int currentYear = now.get(Calendar.YEAR);
								int nextYear = currentYear + 1;
							%>
							<option value="All">All</option>
							<option value="<%= nextYear %>">Academic Year <%= (nextYear%100) %>/<%= (nextYear%100)+1 %></option>
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
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerOnlineSessionModal" onclick="getCoursesByGrade('1', '#addCourse')"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th>Grade</th>
										<th>Academic Year</th>
										<th>Day</th>
										<th>Week</th>
										<th>Start Time</th>
										<th>End Time</th>
										<th>Access URL</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${OnlineList != null}">
											<c:forEach items="${OnlineList}" var="online">
												<tr>
													<td class="small ellipsis">
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
													<td class="small ellipsis">
														<span>
															Year <c:out value="${online.year}" />/<c:out value="${online.year+1}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span class="text-capitalize">
															<c:out value="${online.day}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${online.week}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${online.startTime}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${online.endTime}" />
														</span>
													</td>
													<td class="small text-truncate" style="max-width: 150px;">
														<span>
															<c:out value="${online.address}" />
														</span>
													</td>
													<c:set var="active" value="${online.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="text-center">
																<i class="bi bi-check-circle text-success"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center">
																<i class="bi bi-check-circle text-secondary"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center">
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveClassInfo('${online.id}')">
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
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Online Session Registration</header>

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
										<option value="<%= addNextYear %>">Academic Year <%= (addNextYear%100)  %>/<%= (addNextYear%100)+1  %></option>
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
										<option value="Monday">Monday</option>
										<option value="Tuesday">Tuesday</option>
										<option value="Wednesday">Wednesday</option>
										<option value="Thursday">Thursday</option>
										<option value="Friday">Friday</option>
										<option value="Saturday">Saturday</option>
										<option value="Sunday">Sunday</option>
									</select>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-2">
									<label for="addWeek" class="label-form">Week</label>
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
								<div class="col-md-12">
									<label for="addAddress" class="label-form">Access URL</label>
									<input type="text" class="form-control" id="addAddress" name="addAddress" placeholder="https://" title="Please enter access address" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary"
							onclick="addOnline()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary"
							onclick="clearClassForm('onlineSessionRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editClassModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Class Edit</header>

					<form id="classEdit">
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-4">
									<label for="editState" class="label-form">State</label> 
									<select class="form-control" id="editState" name="editState">
									</select>
								</div>
								<div class="col-md-5">
									<label for="editBranch" class="label-form">Branch</label>
									<select class="form-control" id="editBranch" name="editBranch">
									</select>
								</div>
								<div class="col-md-3">
									<label for="editStartDate" class="label-form">Start Date</label>
									<input type="text" class="form-control datepicker" id="editStartDate"
										name="editStartDate" placeholder="dd/mm/yyyy">
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-3">
									<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
									</select>
								</div>
								<div class="col-md-5">
									<label for="editCourse" class="label-form">Course</label>
									<select class="form-control" id="editCourse" name="editCourse">
									</select>
								</div>
								<div class="col-md-4">
									<label for="editDay" class="label-form">Day</label>
									<select class="form-control" id="editDay" name="editDay">
										<option value="All">All</option>
										<option value="Monday">Monday</option>
										<option value="Tuesday">Tuesday</option>
										<option value="Wednesday">Wednesday</option>
										<option value="Thursday">Thursday</option>
										<option value="Friday">Friday</option>
										<option value="Saturday">Saturday</option>
										<option value="Sunday">Sunday</option>
									</select>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-5">
									<input type="text" class="form-control" id="editName" name="editName" title="Please enter Class name">
								</div>
								<div class="col-md-3">
									<input type="text" class="form-control" id="editPrice" name="editPrice" title="Please enter Class name">
								</div>
								<div class="input-group col-md-4">
									<div class="input-group-prepend">
										<div class="input-group-text">
											<input type="checkbox" id="editActiveCheckbox" name="editActiveCheckbox" onchange="updateEditActiveValue(this)">
										</div>
									</div>
									<input type="hidden" id="editActive" name="editActive" value="false">
									<input type="text" id="editActiveLabel" class="form-control" placeholder="Activate">
								</div>
							</div>
						</div>
						<input type="hidden" id="editId" name="editId">
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary"
							onclick="updateClassInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary"
							data-dismiss="modal">Close</button>
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
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
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

<!-- Confirmation Alert -->
<div id="confirm-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="fa fa-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
			<div class="d-flex justify-content-end">
				<button type="submit" class="btn btn-primary" onclick="confirmAction()">Yes</button>&nbsp;&nbsp;
				<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">No</button>
			</div>
		</div>
	</div>
</div>

<!-- Delete Confirmation Alert -->
<div id="delete-confirm-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="fa fa-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
			<div class="d-flex justify-content-end">
				<button type="submit" class="btn btn-primary" onclick="confirmDeleteAction()">Yes</button>&nbsp;&nbsp;
				<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">No</button>
			</div>
		</div>
	</div>
</div>

<!-- Confirmation Alert -->
<div id="confirm-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="fa fa-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
