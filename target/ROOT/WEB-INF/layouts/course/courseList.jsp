<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
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
    $('#courseListTable').DataTable({
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

	// initialise grade list
	listGrade('#listGrade');
	listGrade('#addGrade');
	listGrade('#editGrade');
	// initialise subject list
	listSubject('#addSubject');
	listSubject('#editSubject');
    
	// set current year & week
	$.ajax({
		url : '${pageContext.request.contextPath}/class/academy',
		method: "GET",
		success: function(response) {
			// save the response into the variable
			const academicYear = response[0];
			const academicWeek = response[1];
			// console.log('Academic Year : ' + academicYear);
			// console.log('Academic Week : ' + academicWeek);
			$("#listYear").val(academicYear);
			// $("#listWeek").val(academicWeek);

		},
		error: function(jqXHR, textStatus, errorThrown) {
			console.log('Error : ' + errorThrown);
		}
	});

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Course
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addCourse() {


	// name, description validation
	var name = document.getElementById('addName');
	if(name.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			name.focus();
		});
		return false;
	}
	var price = document.getElementById('addPrice');
	if(price.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter price');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			price.focus();
		});
		return false;
	}
	var desc = document.getElementById('addDescription');
	if(desc.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter description');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			desc.focus();
		});
		return false;
	}

	// Get practiceIds form addScheduleTable
	var subjectIds = [];
	$('#addSubjectTable tr').each(function () {
		var subjectId = $(this).find('.subjectId').text();
		if (subjectId != '') {
			subjectIds.push({id : subjectId});
		}
	});
	// Get from form data
	var course = {
		name : $("#addName").val(),
		grade : $("#addGrade").val(),
		price: $("#addPrice").val(),
		year : $("#addYear").val(),
		description : $("#addDescription").val(),
		online : $("#addOnline").is(':checked') ? true : false,
		subjects : subjectIds
	}
	//console.log(course);
	
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/class/registerCourse',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(course),
		contentType : 'application/json',
		success : function(response) {
			// console.log(response);
			// Display the success alert
            $('#success-alert .modal-body').text('New Course is registered successfully.');
            $('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerCourseModal').modal('hide');
	// flush all registered data
	document.getElementById("courseRegister").reset();
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Course
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveCourseInfo(courseId) {
	// console.log(courseId);
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/get/course/' + courseId,
		type : 'GET',
		success : function(course) {
			//console.log(course);
			$("#editId").val(course.id);
			$("#editGrade").val(course.grade);
			$("#editName").val(course.name);
			$("#editPrice").val(course.price);
			$("#editDescription").val(course.description);
			// if course.online is true, then #editOnline is checked; otherwise #editOnsite is checked
			if (course.online) {
				$("#editOnline").prop('checked', true);
			} else {
				$("#editOnsite").prop('checked', true);
			}
			// clear all rows on editScheduleTable
			$("#editSubjectTable").find("tr:gt(0)").remove();	
			
			var subjects = course.subjects;
			$.each(subjects, function (index, value) {
				//console.log(value);
				// Create a new row
				var row = $("<tr>");
				// Create the cells for the row
				var cell = $("<td>").text(value.name);
				// cell4
				var binIcon = $('<i class="bi bi-trash h5"></i>');
				var binIconLink = $("<a>")
					.attr("href", "javascript:void(0)")
					.attr("title", "Delete Practice")
					.click(function () {
						row.remove();
					});
				binIconLink.append(binIcon);
				var deleteCell = $("<td>").addClass('text-center').append(binIconLink);

				// hidden td for practiceId
				var td = $("<td>").css("display", "none").addClass("subjectId").text(value.id);

				// Append cells to the row
				row.append(cell, deleteCell, td);

				// Append the row to the table
				$("#editSubjectTable").append(row);
			});
			$('#editClassModal').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Course
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateCourseInfo(){

	// name, description validation
	var name = document.getElementById('editName');
	if(name.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			name.focus();
		});
		return false;
	}
	var desc = document.getElementById('editDescription');
	if(desc.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter description');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			desc.focus();
		});
		return false;
	}

	var courseId = $("#editId").val();
	var scheduleDtos = [];
	$('#editSubjectTable tr').each(function () {
		var subjectId = $(this).find('.subjectId').text();
		if (subjectId != '') {
			scheduleDtos.push({id : subjectId});
		}
	});
	// get from formData
	var course = {
		id : courseId,
		name : $("#editName").val(),
		grade : $("#editGrade").val(),
		online : $("#editOnline").is(':checked') ? true : false,
		description : $("#editDescription").val(),
		price : $("#editPrice").val(),
		subjects : scheduleDtos
	}
	
	console.log(course);
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/update/course',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify(course),
		contentType : 'application/json',
		success : function(value) {
			// Display success alert
			$('#success-alert .modal-body').text('Course is updated successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
	$('#editClassModal').modal('hide');
	// flush all registered data
	clearCourseForm("courseEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearCourseForm(elementId) {
	document.getElementById(elementId).reset();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before deactivate Course
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDeactivate(testId) {
    // Show the warning modal
    $('#deactivateConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeDeactivate').off('click').on('click', function() {
        deactivateCourse(testId);
        $('#deactivateConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before reactivate Course
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmReactivate(testId) {
    // Show the warning modal
    $('#reactivateConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeReactivate').off('click').on('click', function() {
        reactivateCourse(testId);
        $('#reactivateConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		De-activate Course
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deactivateCourse(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/class/deactivateCourse/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Course de-activated successfully');
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Re-activate Course
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function reactivateCourse(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/class/reactivateCourse/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Course re-activated successfully');
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Subject into Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateSubjects(action) {
	// Get the values from the select elements
	var subjectSelect = document.getElementById(action + "Subject");
	var subjectName = subjectSelect.options[subjectSelect.selectedIndex].text;
	var subjectId = subjectSelect.value;
	// Get a reference to the table
	var table = document.getElementById(action + "SubjectTable");
	/// Create a new row
	var row = $("<tr>");
	// Create the cells for the row
	var cell = $("<td>").text(subjectName);
	// cell4
	var binIcon = $('<i class="bi bi-trash h5"></i>');
	var binIconLink = $("<a>")
		.attr("href", "javascript:void(0)")
		.attr("title", "Delete Practice")
		.click(function () {
			row.remove();
		});
	binIconLink.append(binIcon);
	var deleteCell = $("<td>").addClass('text-center').append(binIconLink);
	// hidden td for practiceId
	var td = $("<td>").css("display", "none").addClass("subjectId").text(subjectId);
	// Append cells to the row
	row.append(cell,deleteCell, td);
	// Append the row to the table
	$("#"+ action +"SubjectTable").append(row);
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

	#courseListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="courseList" method="get" action="${pageContext.request.contextPath}/class/listCourse">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listYear" class="label-form">Year</label>
						<select class="form-control" id="listYear" name="listYear">
							<%
								Calendar now = Calendar.getInstance();
								int currentYear = now.get(Calendar.YEAR);
								int nextYear = currentYear + 1;
							%>
							<option value="0">All</option>
							<option value="<%= currentYear %>">Academic Year <%= currentYear %>/<%= (currentYear%100)+1 %></option>
							<%
								// Adding the last five years
								for (int i = currentYear - 1; i >= currentYear - 5; i--) {
							%>
								<option value="<%= i %>">Academic Year <%= i %>/<%= (i%100)+1 %></option>
							<%
							}
							%>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="0">All</option>
						</select>
					</div>
					<div class="offset-md-6"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerCourseModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="courseListTable" class="table table-striped table-bordered"><thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 20%">Name</th>
										<th class="align-middle text-center" style="width: 30%">Description</th>
										<th class="align-middle text-center" style="width: 10%">Academic Year</th>
										<th class="align-middle text-center" style="width: 10%">Grade</th>
										<th class="align-middle text-center" style="width: 10%">Price</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 5%">Type</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 5%">Activated</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
								<c:choose>
									<c:when test="${CourseList != null}">
										<c:forEach items="${CourseList}" var="course">
											<tr>
												<td class="small align-middle"><span><c:out value="${course.name}" /></span></td>
												<td class="small align-middle"><span><c:out value="${course.description}" /></span></td>
												<td class="small align-middle text-right">
													<span>
														<c:set var="lastTwoDigits" value="${course.year % 100}" />
														<c:set var="nextYearLastTwoDigits" value="${lastTwoDigits + 1}" />
														<c:choose>
															<c:when test="${lastTwoDigits < 10}">
																<!-- Ensures single digit years are properly formatted (e.g., '09') -->
																Year 0<c:out value="${lastTwoDigits}" />/0<c:out value="${nextYearLastTwoDigits}" />
															</c:when>
															<c:otherwise>
																Year <c:out value="${lastTwoDigits}" />/<c:out value="${nextYearLastTwoDigits}" />
															</c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="small align-middle text-center">
													<span>
														<c:choose>
															<c:when test="${course.grade == '1'}">P2</c:when>
															<c:when test="${course.grade == '2'}">P3</c:when>
															<c:when test="${course.grade == '3'}">P4</c:when>
															<c:when test="${course.grade == '4'}">P5</c:when>
															<c:when test="${course.grade == '5'}">P6</c:when>
															<c:when test="${course.grade == '6'}">S7</c:when>
															<c:when test="${course.grade == '7'}">S8</c:when>
															<c:when test="${course.grade == '8'}">S9</c:when>
															<c:when test="${course.grade == '9'}">S10</c:when>
															<c:when test="${course.grade == '10'}">S10E</c:when>
															<c:when test="${course.grade == '11'}">TT6</c:when>
															<c:when test="${course.grade == '12'}">TT8</c:when>
															<c:when test="${course.grade == '13'}">TT8E</c:when>
															<c:when test="${course.grade == '14'}">SRW4</c:when>
															<c:when test="${course.grade == '15'}">SRW5</c:when>
															<c:when test="${course.grade == '16'}">SRW6</c:when>
															<c:when test="${course.grade == '17'}">SRW7</c:when>
															<c:when test="${course.grade == '18'}">SRW8</c:when>
															<c:when test="${course.grade == '19'}">JMSS</c:when>
															<c:when test="${course.grade == '20'}">VCE</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="small align-middle text-right"><span><c:out value="${course.price}" /></span></td>
												<td class="text-center align-middle">
													<c:choose>
														<c:when test="${course.online}">
															<i class="bi bi-display" data-toggle="tooltip" title="Online"></i>
														</c:when>
														<c:otherwise>
															<i class="bi bi-person-fill" data-toggle="tooltip" title="Onsite"></i>
														</c:otherwise>
													</c:choose>
												</td>
												<c:set var="active" value="${course.active}" />
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
													<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveCourseInfo('${course.id}')"></i>&nbsp;&nbsp;
													<c:choose>
														<c:when test="${active == true}">
															<i class="bi bi-pause-circle text-danger hand-cursor" data-toggle="tooltip" title="Inactivate" onclick="confirmDeactivate('${course.id}')"></i>
														</c:when>
														<c:otherwise>
															<i class="bi bi-arrow-clockwise text-success hand-cursor" data-toggle="tooltip" title="Activate" onclick="confirmReactivate('${course.id}')"></i>
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

<!-- Add Form Dialogue -->
<div class="modal fade" id="registerCourseModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Course Registration</header>
					<form id="courseRegister">
						<div class="form-group mt-3">
							<div class="form-row">
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-6">
									<label for="addName" class="label-form">Name</label> 
									<input type="text" class="form-control" id="addName" name="addName" placeholder="Name" title="Please enter Course name">
								</div>
								<div class="col-md-3">
									<label for="addPrice" class="label-form">Price</label> 
									<input type="text" class="form-control" id="addPrice" name="addPrice" title="Please enter Course price">
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-4">
									<label for="addYear" class="label-form">Academic Year</label> 
									<select class="form-control" id="addYear" name="addYear">
										<option value="<%= currentYear %>">Year <%= (currentYear%100) %>/<%= (currentYear%100)+1 %></option>
										<%
											// Adding the last five years
											for (int i = currentYear - 1; i >= currentYear - 2; i--) {
										%>
											<option value="<%= i %>">Year <%= (i%100) %>/<%= (i%100)+1 %></option>
										<%
										}
										%>
									</select>
								</div>
								<div class="col-md-8">
									<label for="addDescription" class="label-form">Course Description</label> 
									<input type="text" class="form-control" id="addDescription" name="addDescription" placeholder="Description" title="Please enter Course description">
								</div>
							</div>
							<div class="form-group mt-4">
								<div class="form-row">
									<div class="input-group col-md-3">
										<div class="form-check">
											<input class="form-check-input" type="radio" name="addCourseType" id="addOnsite" checked>
											<label class="form-check-label" for="addOnsite">Onsite</label>
										</div>
										<div class="form-check">
											<input class="form-check-input" type="radio" name="addCourseType" id="addOnline">
											<label class="form-check-label" for="addOnline">Online</label>
										</div>
									</div>
									<div class="col-md-7">
										<label for="addSubject" class="label-form">Subject</label>
										<select class="form-control" id="addSubject" name="addSubject">
										</select>
									</div>
									<div class="col-md-2 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="updateSubjects('add')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
							</div>
							<div class="form-group">
								<div class="form-row mt-4">
									<table class="table table-striped table-bordered" id="addSubjectTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
										<thead class="thead-light">
											<tr>
												<th data-field="type" style="width: 80%;">Subject</th>
												<th data-field="action" style="width: 10%;">Action</th>
											</tr>
										</thead>
										<tbody>
										</tbody>
									</table>
								</div>
							</div>							
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addCourse()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearCourseForm('courseRegister')" data-dismiss="modal">Close</button>	
					</div>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editClassModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Course Edit</header>
			
				<form id="courseEdit">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-3">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
								</select>
							</div>
							<div class="col-md-6">
								<label for="editName" class="label-form">Name</label> 
								<input type="text" class="form-control" id="editName" name="editName">
							</div>
							<div class="col-md-3">
								<label for="editPrice" class="label-form">Price</label> 
								<input type="number" class="form-control" id="editPrice" name="editPrice">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-4">
								<label for="editYear" class="label-form">Academic Year</label> 
								<select class="form-control" id="editYear" name="editYear" disabled>
									<option value="<%= currentYear %>">Year <%= (currentYear%100) %>/<%= (currentYear%100)+1 %></option>
									<%
										// Adding the last five years
										for (int i = currentYear - 1; i >= currentYear - 2; i--) {
									%>
										<option value="<%= i %>">Year <%= (i%100) %>/<%= (i%100)+1 %></option>
									<%
									}
									%>
								</select>
							</div>									
							<div class="col-md-8">
								<label for="editDescription" class="label-form">Description</label> 
								<input type="text" class="form-control" id="editDescription" name="editDescription">
							</div>							
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="input-group col-md-3">
								<div class="form-check">
									<input class="form-check-input" type="radio" name="editCourseType" id="editOnsite">
									<label class="form-check-label" for="editOnsite">Onsite</label>
								</div>
								<div class="form-check">
									<input class="form-check-input" type="radio" name="editCourseType" id="editOnline">
									<label class="form-check-label" for="editOnline">Online</label>
								</div>
							</div>
							<div class="col-md-7">
								<label for="editSubject" class="label-form">Subject</label>
								<select class="form-control" id="editSubject" name="editSubject">
								</select>
							</div>
							<div class="col-md-2 d-flex flex-column justify-content-center">
								<label class="label-form text-white">Add</label>
								<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="updateSubjects('edit')"><i class="bi bi-plus"></i></button>
							</div>				
						</div>
					</div>	
					<div class="form-group">
						<div class="form-row mt-4">
							<table class="table table-striped table-bordered" id="editSubjectTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
								<thead class="thead-light">
									<tr>
										<th data-field="type" style="width: 80%;">Subject</th>
										<th data-field="action" style="width: 10%;">Action</th>
									</tr>
								</thead>
								<tbody>
								</tbody>
							</table>
						</div>
					</div>
					<input type="hidden" id="editId" name="editId">
				</form>
				<div class="d-flex justify-content-end">
					<button type="submit" class="btn btn-primary" onclick="updateCourseInfo()">Save</button>&nbsp;&nbsp;
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
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!--Deactivate Confirmation Modal -->
<div class="modal fade" id="deactivateConfirmModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Course Inactivate</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to inactivate Course ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeDeactivate"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>

<!--Reactivate Confirmation Modal -->
<div class="modal fade" id="reactivateConfirmModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-success">
            <div class="modal-header btn-success">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Course Activate</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to activate Course ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-success" id="agreeReactivate"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>