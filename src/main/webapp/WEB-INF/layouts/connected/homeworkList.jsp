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

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Homework
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addHomework() {

	// Get from form data
	var homework = {
		subject : $("#addSubject").val(),
		grade: $("#addGrade").val(),
		week: $("#addWeek").val(),
		info : $("#addInfo").val(),
		videoPath : $("#addVideoPath").val(),
		pdfPath : $("#addPdfPath").val()
	}

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
			$("#editGrade").val(homework.grade);
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before deleting Homework
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteHomework(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Homework
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteHomework(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/deleteHomework/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Homework deleted successfully');
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

	#homeworkListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}


</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/connected/filterHomework">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listSubject" class="label-form">Subject</label>
						<select class="form-control" id="listSubject" name="listSubject">
							<option value="0">All</option>
							<option value="1">English</option>
							<option value="2">Mathematics</option>
							<option value="4">Writing</option>
							<option value="12">Short Answer</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listWeek" class="label-form">Set</label>
						<select class="form-control" id="listWeek" name="listWeek">
						</select>
						<script>
							// Get a reference to the select element
							var selectElement = document.getElementById("listWeek");

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
					<div class="offset-md-5"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerHomeworkModal"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th class="text-center align-middle" style="width: 10%">Subject</th>
										<th class="text-center align-middle" style="width: 5%">Grade</th>
										<!-- <th class="text-center align-middle" style="width: 10%">Academic Year</th> -->
										<th class="text-center align-middle" style="width: 5%">Week</th>
										<th class="text-center align-middle" style="width: 24%">Document Path</th>
										<th class="text-center align-middle" style="width: 24%">Video Path</th>
										<th class="text-center align-middle" style="width: 10%">Information</th>
										<th class="text-center align-middle" style="width: 7%">Date</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${HomeworkList != null}">
											<c:forEach items="${HomeworkList}" var="homework">
												<tr>
													<td class="small align-middle">
														<span>
															<c:choose>
																<c:when test="${homework.subject == '1'}">English</c:when>
																<c:when test="${homework.subject == '2'}">Maths</c:when>
																<c:when test="${homework.subject == '4'}">Writing</c:when>
																<c:when test="${homework.subject == '12'}">Short Answer</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-center">
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
													<td class="small align-middle text-center">
														<span>
															<c:out value="${homework.week}" />
														</span>
													</td>
													<td class="small align-middle text-truncate" style="max-width: 150px;">
														<span data-toggle="tooltip" title="${homework.pdfPath}">
															<c:out value="${homework.pdfPath}" />
														</span>
													</td>
													<td class="small align-middle text-truncate" style="max-width: 150px;">
														<span data-toggle="tooltip" title="${homework.videoPath}">
															<c:out value="${homework.videoPath}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${homework.info}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${homework.registerDate}" />
														</span>
													</td>
													<c:set var="active" value="${homework.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="align-middle text-center">
																<i class="bi bi-check-circle-fill text-success" data-toggle="tooltip" title="Activated"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="align-middle text-center">
																<i class="bi bi-check-circle-fill text-secondary" data-toggle="tooltip" title="Deactivated"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveHomeworkInfo('${homework.id}')">
														</i>&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete" onclick="confirmDelete('${homework.id}')">
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
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Homework Registration</header>
					<form id="homeworkRegister">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-7">
									<label for="addSubject" class="label-form">Subject</label>
									<select class="form-control" id="addSubject" name="addSubject">
										<option value="1">English</option>
										<option value="2">Mathematics</option>
										<option value="4">Writing</option>
										<option value="12">Short Answer</option>
									</select>
								</div>
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-2">
									<label for="addWeek" class="label-form">Set</label>
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
								<div class="col-md-12">
									<label for="addPdfPath" class="label-form">Document Path</label>
									<input type="text" class="form-control" id="addPdfPath" name="addPdfPath" placeholder="https://" title="Please enter document access address" />
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
								<div class="col-md-12 mb-4">
									<label for="addInfo" class="label-form">Information</label>
									<input type="text" class="form-control" id="addInfo" name="addInfo" title="Please enter additional information" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addHomework()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearHomeworkForm('homeworkRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- 
<script>
    // Function to handle the enabling/disabling of the Video Path field
    document.addEventListener("DOMContentLoaded", function() {
        const subjectSelect = document.getElementById("addSubject");
        const videoPathInput = document.getElementById("addVideoPath");
        // Add an event listener to the Subject dropdown
        subjectSelect.addEventListener("change", function() {
            if (subjectSelect.value === "12") { // Check if 'Short Answer' is selected
                videoPathInput.disabled = true; // Disable the Video Path input
                videoPathInput.value = ""; // Clear the field
            } else {
                videoPathInput.disabled = false; // Enable the Video Path input
            }
        });
    });
</script> -->



<!-- Edit Form Dialogue -->
<div class="modal fade" id="editHomeworkModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Homework Edit</header>
					<form id="homeworkEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-7">
									<label for="editSubject" class="label-form">Subject</label>
									<select class="form-control" id="editSubject" name="editSubject" disabled>
										<option value="1">English</option>
										<option value="2">Mathematics</option>
										<option value="4">Writing</option>
										<option value="12">Short Answer</option>
									</select>
								</div>
								<div class="col-md-3">
									<label for="editGrade" class="label-form">Grade</label>
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-2">
									<label for="editWeek" class="label-form">Set</label>
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
									<label for="editPdfPath" class="label-form">Document Path</label>
									<input type="text" class="form-control" id="editPdfPath" name="editPdfPath" title="Please edit pdf path" />
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

<script>
    // Unified function to handle the enabling/disabling of the Video Path field
    document.addEventListener("DOMContentLoaded", function () {
        const dropdowns = [
            { subject: "addSubject", videoPath: "addVideoPath" },
            { subject: "editSubject", videoPath: "editVideoPath" }
        ];

        // Add event listeners to both dropdowns
        dropdowns.forEach(({ subject, videoPath }) => {
            const subjectSelect = document.getElementById(subject);
            const videoPathInput = document.getElementById(videoPath);

            if (subjectSelect && videoPathInput) {
                subjectSelect.addEventListener("change", function () {
                    if (subjectSelect.value === "12") { // Check if 'Short Answer' is selected
                        videoPathInput.disabled = true; // Disable the Video Path input
                        videoPathInput.value = ""; // Clear the field
                    } else {
                        videoPathInput.disabled = false; // Enable the Video Path input
                    }
                });

                // Trigger the logic once when the respective modal is shown
                const modalId = subject === "addSubject" ? "#registerHomeworkModal" : "#editHomeworkModal";
                $(modalId).on("shown.bs.modal", function () {
                    if (subjectSelect.value === "12") {
                        videoPathInput.disabled = true; // Disable if 'Short Answer' is already selected
                    } else {
                        videoPathInput.disabled = false; // Enable otherwise
                    }
                });
            }
        });
    });
</script>

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
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Homework Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Homework ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>
