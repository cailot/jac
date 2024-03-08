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
	$('#practiceListTable').DataTable({
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
	listPracticeType('#listPracticeType');
	listPracticeType('#addPracticeType');
	listPracticeType('#editPracticeType');

	// duration field is disabled & make duration empty for Pdf
	// document.getElementById('addPdf').addEventListener('change', function() {
    //     var durationField = document.getElementById('addDuration');
    //     durationField.disabled = this.checked;
    //     if (this.checked) {
    //         durationField.value = '';
    //     }
    // });
	// document.getElementById('addVideo').addEventListener('change', function() {
    //     document.getElementById('addDuration').disabled = !this.checked;
    // });
	// document.getElementById('editPdf').addEventListener('change', function() {
    //     var durationField = document.getElementById('editDuration');
    //     durationField.disabled = this.checked;
    //     if (this.checked) {
    //         durationField.value = '';
    //     }
    // });
	// document.getElementById('editVideo').addEventListener('change', function() {
    //     document.getElementById('editDuration').disabled = !this.checked;
    // });

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Practice
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addPractice() {
	// Get from form data
	var practice = {
		practiceType : $("#addPracticeType").val(),
		grade: $("#addGrade").val(),
		volume: $("#addVolume").val(),
		info : $("#addInfo").val(),
		pdfPath : $("#addPdfPath").val()
	}
	console.log(practice);

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/addPractice',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(practice),
		contentType: 'application/json',
		success: function (data) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				'New Practice is registered successfully.');
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
	$('#registerPracticeModal').modal('hide');
	// flush all registered data
	document.getElementById("practiceRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Practice
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrievePracticeInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getPractice/' + id,
		type: 'GET',
		success: function (practice) {
			// console.log(homework);
			$("#editId").val(practice.id);
			$("#editPracticeType").val(practice.practiceType);
			$("#editGrade").val(practice.grade);
			$("#editVolume").val(practice.volume);
			$("#editInfo").val(practice.info);
			$("#editPdfPath").val(practice.pdfPath);	
			$("#editActive").val(practice.active);
			if (practice.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$('#editPracticeModal').modal('show');
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
//		Update Practice
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updatePracticeInfo() {
	var workId = $("#editId").val();
	// get from formData
	var practice = {
		id: workId,
		practiceType : $("#editPracticeType").val(),
		grade: $("#editGrade").val(),
		volume: $("#editVolume").val(),
		info: $("#editInfo").val(),
		pdfPath: $("#editPdfPath").val(),
		active: $("#editActive").val(),
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updatePractice',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(practice),
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

	$('#editPracticeModal').modal('hide');
	// flush all registered data
	clearHomeworkForm("practiceEdit");
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
		<form id="classList" method="get" action="${pageContext.request.contextPath}/connected/filterPractice">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-3">
						<label for="listPracticeType" class="label-form">Practice Type</label>
						<select class="form-control" id="listPracticeType" name="listPracticeType">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listVolume" class="label-form">Set</label>
						<select class="form-control" id="listVolume" name="listVolume">
						</select>
						<script>
							// Get a reference to the select element
							var selectElement = document.getElementById("listVolume");

							// Create a new option element for 'All'
							var allOption = document.createElement("option");

							// Set the value and text content for the 'All' option
							allOption.value = "0";
							allOption.textContent = "All";

							// Append the 'All' option to the select element
							selectElement.appendChild(allOption);

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
					<div class="offset-md-1"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerPracticeModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="practiceListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th>Practice Type</th>
										<th>Grade</th>
										<th>Set</th>
										<th>Document Path</th>
										<th>Information</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${PracticeList != null}">
											<c:forEach items="${PracticeList}" var="practice">
												<tr>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${practice.practiceType == '1'}">Mega English</c:when>
																<c:when test="${practice.practiceType == '2'}">Mega Mathematics</c:when>
																<c:when test="${practice.practiceType == '3'}">Mega General Ability</c:when>
																<c:when test="${practice.practiceType == '4'}">NAPLAN Math</c:when>
																<c:when test="${practice.practiceType == '5'}">NAPLAN Reading</c:when>
																<c:when test="${practice.practiceType == '6'}">NAPLAN LC</c:when>
																<c:when test="${practice.practiceType == '7'}">Revision English</c:when>
																<c:when test="${practice.practiceType == '8'}">Revision Mathematics</c:when>
																<c:when test="${practice.practiceType == '9'}">Revision Science</c:when>
																<c:when test="${practice.practiceType == '10'}">Reeading Comprehension (EDU)</c:when>
																<c:when test="${practice.practiceType == '11'}">Verbal Reasoning (EDU)</c:when>
																<c:when test="${practice.practiceType == '12'}">Mathematics (EDU)</c:when>
																<c:when test="${practice.practiceType == '13'}">Numerical Reasoning (EDU)</c:when>
																<c:when test="${practice.practiceType == '14'}">Humanities (ACER)</c:when>
																<c:when test="${practice.practiceType == '15'}">Mathematics (ACER)</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${practice.grade == '1'}">P2</c:when>
																<c:when test="${practice.grade == '2'}">P3</c:when>
																<c:when test="${practice.grade == '3'}">P4</c:when>
																<c:when test="${practice.grade == '4'}">P5</c:when>
																<c:when test="${practice.grade == '5'}">P6</c:when>
																<c:when test="${practice.grade == '6'}">S7</c:when>
																<c:when test="${practice.grade == '7'}">S8</c:when>
																<c:when test="${practice.grade == '8'}">S9</c:when>
																<c:when test="${practice.grade == '9'}">S10</c:when>
																<c:when test="${practice.grade == '10'}">S10E</c:when>
																<c:when test="${practice.grade == '11'}">TT6</c:when>
																<c:when test="${practice.grade == '12'}">TT8</c:when>
																<c:when test="${practice.grade == '13'}">TT8E</c:when>
																<c:when test="${practice.grade == '14'}">SRW4</c:when>
																<c:when test="${practice.grade == '15'}">SRW5</c:when>
																<c:when test="${practice.grade == '16'}">SRW6</c:when>
																<c:when test="${practice.grade == '17'}">SRW7</c:when>
																<c:when test="${practice.grade == '18'}">SRW8</c:when>
																<c:when test="${practice.grade == '19'}">JMSS</c:when>
																<c:when test="${practice.grade == '20'}">VCE</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${practice.volume}" />
														</span>
													</td>
													<td class="small text-truncate" style="max-width: 250px;">
														<span>
															<c:out value="${practice.pdfPath}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${practice.info}" />
														</span>
													</td>
													<c:set var="active" value="${practice.active}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrievePracticeInfo('${practice.id}')">
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
<div class="modal fade" id="registerPracticeModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Practice Registration</header>
					<form id="practiceRegister">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-8">
									<label for="addPracticeType" class="label-form">Practice Type</label>
									<select class="form-control" id="addPracticeType" name="addPracticeType">
									</select>
								</div>
								<div class="col-md-2">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-2">
									<label for="addVolume" class="label-form">Set</label>
									<select class="form-control" id="addVolume" name="addVolume">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("addVolume");
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
								<div class="col-md-12">
									<label for="addPdfPath" class="label-form">Document Path</label>
									<input type="text" class="form-control" id="addPdfPath" name="addPdfPath" placeholder="https://" title="Please enter document access address" />
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12">
									<label for="addInfo" class="label-form">Information</label>
									<input type="text" class="form-control" id="addInfo" name="addInfo" title="Please enter additional information" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="addPractice()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearHomeworkForm('practiceRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editPracticeModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Practice Edit</header>
					<form id="practiceEdit">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-7">
									<label for="editPracticeType" class="label-form">Practice Type</label>
									<select class="form-control" id="editPracticeType" name="editPracticeType" disabled>
									</select>
								</div>
								<div class="col-md-3">
									<label for="editGrade" class="label-form">Grade</label>
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-2">
									<label for="editVolume" class="label-form">Set</label>
									<select class="form-control" id="editVolume" name="editVolume">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("editVolume");
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
						<button type="submit" class="btn btn-primary" onclick="updatePracticeInfo()">Save</button>&nbsp;&nbsp;
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
