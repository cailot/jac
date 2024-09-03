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

	// name validation
	var cd = document.getElementById('addName');
	if(cd.value== ""){
		$('#validation-alert .modal-body').text(
		'Please endter name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			cd.focus();
		});
		return false;
	}

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
				'New Extra Work is registered successfully.');
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
//		Retrieve Extrawork
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveExtraworkInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getExtrawork/' + id,
		type: 'GET',
		success: function (extrawork) {
			console.log(extrawork);
			$("#editId").val(extrawork.id);
			$("#editGrade").val(extrawork.grade);
			$("#editName").val(extrawork.name);
			$("#editVideoPath").val(extrawork.videoPath);
			$("#editPdfPath").val(extrawork.pdfPath);	
			$("#editActive").val(extrawork.active);
			if (extrawork.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$('#editExtraworkModal').modal('show');
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
//		Update Extrawork
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateExtraworkInfo() {

	// name validation
	var cd = document.getElementById('editName');
	if(cd.value== ""){
		$('#validation-alert .modal-body').text(
		'Please endter name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			cd.focus();
		});
		return false;
	}

	var workId = $("#editId").val();
	// get from formData
	var extrawork = {
		id: workId,
		grade: $("#editGrade").val(),
		name: $("#editName").val(),
		videoPath: $("#editVideoPath").val(),
		pdfPath: $("#editPdfPath").val(),
		active: $("#editActive").val(),
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updateExtrawork',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(extrawork),
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

	$('#editExtraworkModal').modal('hide');
	// flush all registered data
	clearHomeworkForm("extraworkEdit");
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
//		Confirm before deleting Work
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteWork(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Work
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteWork(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/deleteExtrawork/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Extra Work deleted successfully');
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
		height: 45px 	
	} 

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="extraworkList" method="get" action="${pageContext.request.contextPath}/connected/filterExtrawork">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
						</select>
					</div>
					<div class="offset-md-8"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerExtraworkModal"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th class="text-center align-middle" style="width: 10%">Name</th>
										<th class="text-center align-middle" style="width: 5%">Grade</th>
										<th class="text-center align-middle" style="width: 36%">Video Path</th>
										<th class="text-center align-middle" style="width: 36%">Document Path</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 8%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${ExtraworkList != null}">
											<c:forEach items="${ExtraworkList}" var="extrawork">
												<tr>
													<td class="small align-middle">
														<span>
															<c:out value="${extrawork.name}" />
														</span>
													</td>
													<td class="small align-middle text-center">
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
													<td class="small align-middle text-truncate" style="max-width: 200px;">
														<span>
															<c:out value="${extrawork.videoPath}" />
														</span>
													</td>
													<td class="small align-middle text-truncate" style="max-width: 200px;">
														<span>
															<c:out value="${extrawork.pdfPath}" />
														</span>
													</td>
													<c:set var="active" value="${extrawork.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-success" data-toggle="tooltip" title="Activated"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-secondary" data-toggle="tooltip" title="Deactivated"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveExtraworkInfo('${extrawork.id}')">
														</i>&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete" onclick="confirmDelete('${extrawork.id}')">
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
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Extrawork Registration</header>
					<form id="extraworkRegister">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
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
							<div class="form-row mb-4">
								<div class="col-md-12">
									<label for="addPdfPath" class="label-form">Document Path</label>
									<input type="text" class="form-control" id="addPdfPath" name="addPdfPath" placeholder="https://" title="Please enter document access address" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addExtrawork()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearHomeworkForm('extraworkRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editExtraworkModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Extrawork Edit</header>
					<form id="extraworkEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-2">
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-6">
									<input type="text" class="form-control" id="editName" name="editName" />
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
								<div class="col-md-12">
									<label for="editPdfPath" class="label-form">Pdf Path</label>
									<input type="text" class="form-control" id="editPdfPath" name="editPdfPath" title="Please edit pdf path" />
								</div>
							</div>
						</div>
						<input type="hidden" id="editId" name="editId" />
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateExtraworkInfo()">Save</button>&nbsp;&nbsp;
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
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Extra Work Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Extra Work ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>
