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

<script>
$(document).ready(function () {
	$('#extraworkListTable').DataTable({
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
	//listSubject('#listSubject');
	//listSubject('#addSubject');
	//listSubject('#editSubject');
});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Extrawork
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addExtrawork() {
	// Get from form data
	var extrawork = {
		// subject : $("#addSubject").val(),
		grade: $("#addGrade").val(),
		// year: $("#addYear").val(),
		// week: $("#addWeek").val(),
		name : $("#addName").val(),
		videoPath : $("#addVideoPath").val(),
		pdfPath : $("#addPdfPath").val()
	}
	// console.log(homework);

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/addExtrawork',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(extrawork),
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
	$('#registerExtraworkModal').modal('hide');
	// flush all registered data
	document.getElementById("extraworkRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Homework
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveHomeworkInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getHomework/' + id,
		type: 'GET',
		success: function (homework) {
			// console.log(homework);
			$("#editId").val(homework.id);
			$("#editSubject").val(homework.subject);
			$("#editGrade").val(extrawork.grade);
			$("#editYear").val(homework.year);			
			$("#editWeek").val(homework.week);
			$("#editInfo").val(homework.info);
			$("#editVideoPath").val(homework.videoPath);
			$("#editPdfPath").val(homework.pdfPath);	
			$("#editActive").val(homework.active);
			if (homework.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$('#editHomeworkModal').modal('show');
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
		editActiveInput.value = "true";
	} else {
		editActiveInput.value = "false";
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Homework
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateHomeworkInfo() {
	var workId = $("#editId").val();
	// get from formData
	var homework = {
		id: workId,
		subject : $("#editSubject").val(),
		grade: $("#editGrade").val(),
		year: $("#editYear").val(),
		week: $("#editWeek").val(),
		info: $("#editInfo").val(),
		videoPath: $("#editVideoPath").val(),
		pdfPath: $("#editPdfPath").val(),
		active: $("#editActive").val(),
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updateHomework',
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

	$('#editHomeworkModal').modal('hide');
	// flush all registered data
	clearHomeworkForm("homeworkEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearHomeworkForm(elementId) {
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
		<form id="extraworkList" method="get" action="${pageContext.request.contextPath}/connected/filterExtrawork">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
						</select>
					</div>
					<div class="offset-md-5"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerExtraworkModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="extraworkListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th>Name</th>
										<th>Grade</th>
										<th>Video Path</th>
										<th>Document Path</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${ExtraworkList != null}">
											<c:forEach items="${ExtraworkList}" var="extrawork">
												<tr>
													<td class="small ellipsis">
														<span>
															<c:out value="${extrawork.name}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${extrawork.grade == '1'}">P2</c:when>
																<c:when test="${extrawork.grade == '2'}">P3</c:when>
																<c:when test="${extrawork.grade == '3'}">P4</c:when>
																<c:when test="${extrawork.grade == '4'}">P5</c:when>
																<c:when test="${extrawork.grade == '5'}">P6</c:when>
																<c:when test="${extrawork.grade == '6'}">S7</c:when>
																<c:when test="${extrawork.grade == '7'}">S8</c:when>
																<c:when test="${extrawork.grade == '8'}">S9</c:when>
																<c:when test="${extrawork.grade == '9'}">S10</c:when>
																<c:when test="${extrawork.grade == '10'}">S10E</c:when>
																<c:when test="${extrawork.grade == '11'}">TT6</c:when>
																<c:when test="${extrawork.grade == '12'}">TT8</c:when>
																<c:when test="${extrawork.grade == '13'}">TT8E</c:when>
																<c:when test="${extrawork.grade == '14'}">SRW4</c:when>
																<c:when test="${extrawork.grade == '15'}">SRW5</c:when>
																<c:when test="${extrawork.grade == '16'}">SRW6</c:when>
																<c:when test="${extrawork.grade == '17'}">SRW7</c:when>
																<c:when test="${extrawork.grade == '18'}">SRW8</c:when>
																<c:when test="${extrawork.grade == '19'}">JMSS</c:when>
																<c:when test="${extrawork.grade == '20'}">VCE</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small text-truncate" style="max-width: 200px;">
														<span>
															<c:out value="${extrawork.videoPath}" />
														</span>
													</td>
													<td class="small text-truncate" style="max-width: 200px;">
														<span>
															<c:out value="${extrawork.pdfPath}" />
														</span>
													</td>
													<c:set var="active" value="${extrawork.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="text-center">
																<i class="bi bi-check-circle-fill text-success" title="Activated"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center">
																<i class="bi bi-check-circle-fill text-secondary" title="Deactivated"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center">
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveExtraworkInfo('${extrawork.id}')">
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
<div class="modal fade" id="registerExtraworkModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Extrawork Registration</header>
					<form id="extraworkRegister">
						<div class="form-group">
							<div class="form-row mt-3">
								<%--
								<div class="col-md-3">
									<label for="addSubject" class="label-form">Subject</label>
									<select class="form-control" id="addSubject" name="addSubject">
									</select>
								</div>
								--%>
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<%--
								<div class="col-md-4">
									<label for="addYear" class="label-form">Academic Year</label>
									<select class="form-control" id="addYear" name="addYear">
										<%
											Calendar addNow = Calendar.getInstance();
											int addCurrentYear = addNow.get(Calendar.YEAR);
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
								--%>
								<div class="offset-md-1"></div>
								<div class="col-md-8">
									<label for="addName" class="label-form">Name</label>
									<input type="text" class="form-control" id="addName" name="addName" title="Please enter extra material name" />
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12">
									<label for="addVideoPath" class="label-form">Video Path</label>
									<input type="text" class="form-control" id="addVideoPath" name="addVideoPath" placeholder="https://" title="Please enter video access address" />
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12">
									<label for="addPdfPath" class="label-form">Document Path</label>
									<input type="text" class="form-control" id="addPdfPath" name="addPdfPath" placeholder="https://" title="Please enter document access address" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="addExtrawork()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearHomeworkForm('extraworkRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editHomeworkModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Homework Edit</header>
					<form id="homeworkEdit">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-3">
									<label for="editSubject" class="label-form">Subject</label>
									<select class="form-control" id="editSubject" name="editSubject" disabled>
									</select>
								</div>
								<div class="col-md-3">
									<label for="editGrade" class="label-form">Grade</label>
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-4">
									<label for="editYear" class="label-form">Academic Year</label>
									<select class="form-control" id="editYear" name="editYear">
										<%
											Calendar editNow = Calendar.getInstance();
											int editCurrentYear = editNow.get(Calendar.YEAR);
										%>
										<option value="<%= editCurrentYear %>">Year <%= (editCurrentYear%100) %>/<%= (editCurrentYear%100)+1 %></option>
										<%
											// Adding the last three years
											for (int i = editCurrentYear - 1; i >= editCurrentYear - 3; i--) {
										%>
											<option value="<%= i %>">Year <%= (i%100) %>/<%= (i%100)+1 %></option>
										<%
										}
										%>
									</select>
								</div>
								<div class="col-md-2">
									<label for="editWeek" class="label-form">Week</label>
									<select class="form-control" id="editWeek" name="editWeek">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("editWeek");
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
						<div class="form-group mt-4">
							<div class="form-row">
								<div class="col-md-12">
									<label for="editVideoPath" class="label-form">Video Path</label>
									<input type="text" class="form-control" id="editVideoPath" name="editVideoPath" title="Please edit video path" />
								</div>
							</div>
						</div>
						<div class="form-group mt-4">
							<div class="form-row">
								<div class="col-md-12">
									<label for="editPdfPath" class="label-form">Pdf Path</label>
									<input type="text" class="form-control" id="editPdfPath" name="editPdfPath" title="Please edit pdf path" />
								</div>
							</div>
						</div>
						<div class="form-group mt-4 mb-4">
							<div class="form-row">
								<div class="col-md-8">
									<input type="text" class="form-control" id="editInfo" name="editInfo" placeholder="Information" />
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
						<input type="hidden" id="editId" name="editId" />
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateHomeworkInfo()">Save</button>&nbsp;&nbsp;
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
