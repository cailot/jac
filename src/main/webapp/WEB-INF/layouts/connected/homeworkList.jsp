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
	$('#homeworkListTable').DataTable({
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

	// initialise state list when loading
	listGrade('#listGrade');
	listGrade('#addGrade');
	listGrade('#editGrade');
	listSubject('#addSubject');

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Homework
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addHomework() {
	// Get from form data
	var homework = {
		subject : $("#addSubject").val(),
		grade: $("#addGrade").val(),
		year: $("#addYear").val(),
		week: $("#addWeek").val(),
		info : $("#addInfo").val(),
		type : $("input[name='addHomeworkType']:checked").val(),
		path : $("#addPath").val()
	}
		console.log(homework);

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/addHomework',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(homework),
		contentType: 'application/json',
		success: function (data) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				'New Homework is registered successfully.');
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
	$('#registerHomeworkModal').modal('hide');
	// flush all registered data
	document.getElementById("homeworkRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Online Session
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveOnlineInfo(onlineId) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/onlineSession/get/' + onlineId,
		type: 'GET',
		success: function (homework) {
			 console.log(homework);
			$("#editId").val(homework.id);
			$("#editClazzId").val(homework.clazzId);
			$("#editGrade").val(homework.grade);
			$("#editYear").val(homework.year);			
			$("#editDay").val(homework.day);
			$("#editWeek").val(homework.week);
			$("#editStartTime").val(homework.startTime);
			$("#editEndTime").val(homework.endTime);
			$("#editActive").val(homework.active);
			if (homework.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$("#editAddress").val(homework.address);
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
	var onlineId = $("#editId").val();
	// get from formData
	var homework = {
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
		data: JSON.stringify(homework),
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
							<!-- <option value="<%= nextYear %>">Academic Year <%= (nextYear%100) %>/<%= (nextYear%100)+1 %></option> -->
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
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Ssssearch</button>
					</div>
					<div class="col mx-auto">
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerHomeworkModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="homeworkListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th>Subject</th>
										<th>Grade</th>
										<th>Academic Year</th>
										<th>Week</th>
										<th>Information</th>
										<th>Type</th>
										<th>Access URL</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${HomeworkList != null}">
											<c:forEach items="${HomeworkList}" var="homework">
												<tr>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${homework.subject == '1'}">English</c:when>
																<c:when test="${homework.subject == '2'}">Maths</c:when>
																<c:when test="${homework.subject == '3'}">General Ability</c:when>
																<c:when test="${homework.subject == '4'}">Writing</c:when>
																<c:when test="${homework.subject == '5'}">Science</c:when>
																<c:when test="${homework.subject == '6'}">All</c:when>
																<c:when test="${homework.subject == '7'}">One Subject</c:when>
																<c:when test="${homework.subject == '8'}">Two Subjects</c:when>
																<c:when test="${homework.subject == '9'}">Three Subjects</c:when>
																<c:when test="${homework.subject == '10'}">Verbal Reasoning</c:when>
																<c:when test="${homework.subject == '11'}">Numeric Reasoning</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${homework.grade == '1'}">P2</c:when>
																<c:when test="${homework.grade == '2'}">P3</c:when>
																<c:when test="${homework.grade == '3'}">P4</c:when>
																<c:when test="${homework.grade == '4'}">P5</c:when>
																<c:when test="${homework.grade == '5'}">P6</c:when>
																<c:when test="${homework.grade == '6'}">S7</c:when>
																<c:when test="${homework.grade == '7'}">S8</c:when>
																<c:when test="${homework.grade == '8'}">S9</c:when>
																<c:when test="${homework.grade == '9'}">S10</c:when>
																<c:when test="${homework.grade == '10'}">S10E</c:when>
																<c:when test="${homework.grade == '11'}">TT6</c:when>
																<c:when test="${homework.grade == '12'}">TT8</c:when>
																<c:when test="${homework.grade == '13'}">TT8E</c:when>
																<c:when test="${homework.grade == '14'}">SRW4</c:when>
																<c:when test="${homework.grade == '15'}">SRW5</c:when>
																<c:when test="${homework.grade == '16'}">SRW6</c:when>
																<c:when test="${homework.grade == '17'}">SRW7</c:when>
																<c:when test="${homework.grade == '18'}">SRW8</c:when>
																<c:when test="${homework.grade == '19'}">JMSS</c:when>
																<c:when test="${homework.grade == '20'}">VCE</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															Year <c:out value="${homework.year}" />/<c:out value="${homework.year+1}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${homework.week}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${homework.info}" />
														</span>
													</td>
													<td class="text-center">
														<c:choose>
															<c:when test="${homework.type == '0'}">
																<i class="bi bi-play-btn" title="Video"></i>
															</c:when>
															<c:otherwise>
																<i class="bi bi-filetype-pdf" title="Pdf Document"></i>
															</c:otherwise>
														</c:choose>
													</td>
													<td class="small text-truncate" style="max-width: 150px;">
														<span>
															<c:out value="${homework.path}" />
														</span>
													</td>
													<c:set var="active" value="${homework.active}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveHomeworkInfo('${homework.id}')">
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
<div class="modal fade" id="registerHomeworkModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Homework Registration</header>
					<form id="homeworkRegister">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-3">
									<label for="addSubject" class="label-form">Subject</label>
									<select class="form-control" id="addSubject" name="addSubject">
									</select>
								</div>
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-4">
									<label for="addYear" class="label-form">Academic Year</label>
									<select class="form-control" id="addYear" name="addYear">
										<%
											Calendar addNow = Calendar.getInstance();
											int addCurrentYear = addNow.get(Calendar.YEAR);
											int addNextYear = addCurrentYear + 1;
										%>
										<option value="<%= addCurrentYear %>">Year <%= (addCurrentYear%100) %>/<%= (addCurrentYear%100)+1 %></option>
										<%
											// Adding the last three years
											for (int i = addCurrentYear - 1; i >= addCurrentYear - 3; i--) {
										%>
											<option value="<%= i %>">Year <%= (i%100) %>/<%= (i%100)+1 %></option>
										<%
										}
										%>
									</select>
								</div>
								<div class="col-md-2">
									<label for="addWeek" class="label-form">Week</label>
									<select class="form-control" id="addWeek" name="addWeek">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("addWeek");
										// Loop to add options from 1 to 50
										for (var i = 1; i <= 50; i++) {
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
							<div class="form-row">
								<div class="col-md-8">
									<label for="addInfo" class="label-form">Information</label>
									<input type="text" class="form-control" id="addInfo" name="addInfo" title="Please enter additional information" />
								</div>
								<div class="offset-md-1"></div>
								<div class="input-group col-md-3">
									<div class="form-check">
										<input class="form-check-input" type="radio" name="addHomeworkType" id="addVideo" value="0" checked>
										<label class="form-check-label" for="addVideo">Video</label>
									</div>
									<div class="form-check">
										<input class="form-check-input" type="radio" name="addHomeworkType" id="addPdf" value="1">
										<label class="form-check-label" for="addPdf">Pdf</label>
									</div>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12">
									<label for="addPath" class="label-form">Access Path</label>
									<input type="text" class="form-control" id="addPath" name="addPath" placeholder="https://" title="Please enter access address" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="addHomework()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearClassForm('homeworkRegister')" data-dismiss="modal">Close</button>
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
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Online Session Edit</header>

					<form id="onlineEdit">
						<div class="form-group">
							<div class="form-row mt-2">
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
									<select class="form-control" id="editDay" name="editDay">
										<option value="Monday">Monday</option>
										<option value="Tuesday">Tuesday</option>
										<option value="Wednesday">Wednesday</option>
										<option value="Thursday">Thursday</option>
										<option value="Friday">Friday</option>
										<option value="Saturday">Saturday</option>
										<option value="Sunday">Sunday</option>
									</select>
								</div>
								
								<div class="col-md-2">
									<label for="editWeek" class="label-form">Week</label>
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
							<div class="form-row">
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
							<div class="form-row">
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
