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



});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Inactive Students
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInactiveStudent() {
	$.ajax({
		url: '${pageContext.request.contextPath}/batch/updateInactiveStudent',
		type: 'GET',
		success: function (count) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				count + ' students updated successfully.');
			$('#success-alert').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Create Course Template
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function createCourseTemplate() {

	// get value of 'courseYear' dropdown
	var courseYear = $('#courseYear').val();
	console.log(courseYear);

	$.ajax({
		url: '${pageContext.request.contextPath}/batch/createCourse/' + courseYear,
		type: 'GET',
		success: function (count) {
			// Display the success alert
			$('#success-alert .modal-body').text(count);
			$('#success-alert').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Create Online Template
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function createOnlineTemplate1() {

	// get value of 'courseYear' dropdown
	var onlineYear = $('#onlineYear').val();
	console.log(onlineYear);

	$.ajax({
	url: '${pageContext.request.contextPath}/batch/createOnline/' + onlineYear,
	type: 'GET',
	success: function (count) {
		// Display the success alert
		$('#success-alert .modal-body').text(count);
		$('#success-alert').modal('show');
	},
	error: function (xhr, status, error) {
		console.log('Error : ' + error);
	}
	});
}

function createOnlineTemplate() {
	// Create a FormData object
	const formData = new FormData();
	
	// Get the file from the file input
	const fileInput = document.getElementById('file-input');
	if (fileInput.files.length > 0) {
		const file = fileInput.files[0];
		formData.append('file', file);
	} else {
		alert('Please select a file to upload.');
		return;
	}
	
	// Get the selected year from the dropdown
	const yearSelect = document.getElementById('onlineYear');
	const selectedYear = yearSelect.value;
	formData.append('year', selectedYear);
	
	// Use fetch API to send the FormData to the server
	fetch('${pageContext.request.contextPath}/batch/createOnline', {
		method: 'POST',
		body: formData
	})
	.then(response => {
		if (response.ok) {
			return response.json();
		}
		throw new Error('Network response was not ok.');
	})
	.then(data => {
		// Display the success alert
		$('#success-alert .modal-body').text(data);
		$('#success-alert').modal('show');
	})
	.catch(error => {
		console.error('There was a problem with the fetch operation:', error);
		alert('Error uploading file and year.');
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Update Inactive Student
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmInactiveStudent() {
    // Show the warning modal
    $('#inactiveStudentModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeInactiveStudent').one('click', function() {
        updateInactiveStudent();
        $('#inactiveStudentModal').modal('hide');
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Create Course Template
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmCreateCourse() {
    // Show the warning modal
    $('#createCourseModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeCreateCourse').one('click', function() {
        createCourseTemplate();
        $('#createCourseModal').modal('hide');
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Create Online Class Template
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmCreateOnline() {
    // Show the warning modal
    $('#createOnlineModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeCreateOnline').one('click', function() {
        createOnlineTemplate();
        $('#createOnlineModal').modal('hide');
    });
}
</script>

<style>
	div.dataTables_length{
		padding-top: 40px;
		padding-bottom: 10px;
	}

	div.dataTables_filter {
		padding-top: 35px;
		padding-bottom: 35px;
	}

	#cycleListTable tr { 
		vertical-align: middle;
		height: 50px 	
	} 
</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="row h-100 justify-content-center align-items-center" style="width: 50%; margin:0 auto;">
		<table class="table table-hover" id="detailTable">
		<thead>
			<tr height="10px">
				<span class="text-dark mt-5 mb-5 h3">Batch Jobs</span>
			</tr>
		</thead>
		<tr height="80px">
			<td class="left-cell" style="vertical-align: middle;"><b>Update Inactive Students</b></td>
			<td class="text-right" style="vertical-align: middle;">
				<button type="button" class="btn btn-success" style="width: 120px;" onclick="confirmInactiveStudent()"><i class="bi bi-arrow-up-circle"></i>&nbsp;&nbsp;Update</button>
			</td>
		</tr>
		<tr height="80px">
			<td class="left-cell" style="vertical-align: middle;"><b>Create Course Template</b></td>
			<td class="text-right" style="vertical-align: middle;">
				<button type="button" class="btn btn-primary" style="width: 120px;" onclick="confirmCreateCourse()"><i class="bi bi-plus-circle"></i>&nbsp;&nbsp;Create</button>
			</td>
		</tr>
		<tr height="80px">
			<td class="left-cell" style="vertical-align: middle;"><b>Create Online Class Template</b><span class="text-warning">  (JAC Study)</span></td>
			<td class="text-right" style="vertical-align: middle;">
				<button type="button" class="btn btn-primary" style="width: 120px;" onclick="confirmCreateOnline()"><i class="bi bi-plus-circle"></i>&nbsp;&nbsp;Create</button>
			</td>
		</tr>
		</table> 
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

<!--Inactive Student Modal -->
<div class="modal fade" id="inactiveStudentModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content" style="border: 2px solid #ffc107; border-radius: 10px;">
            <div class="modal-header bg-warning" style="display: block;">
                <p style="text-align: center; margin-bottom: 0;"><span style="font-size:18px"><strong>Update Inactive Student Batch</strong></span></p>
            </div>
            <div class="modal-body" style="background-color: #f8f9fa; border-radius: 5px; padding: 20px;">
                <div style="text-align: center; margin-bottom: 20px;">
                    <img src="${pageContext.request.contextPath}/image/inactive.png" style="width: 150px; height: 150px; border-radius: 5%;">
                </div>
                <span class="text-primary"><strong>Inactive Student</strong></span>
				The system will scan and update all students. If a student's most recent enrollment is more than 180 days old, their status will be updated to inactive.                
                <br><br><p class="text-center"><strong>Are you still want to proceed this ?</strong></p>      
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="agreeInactiveStudent">Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">No, I don't want</button>
            </div>
        </div>
    </div>
</div>

<!--Create Course Modal -->
<div class="modal fade" id="createCourseModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered" role="document">
		<div class="modal-content" style="border: 2px solid #ffc107; border-radius: 10px;">
			<div class="modal-header bg-warning" style="display: block;">
				<p style="text-align: center; margin-bottom: 0;"><span style="font-size:18px"><strong>Create Course Batch</strong></span></p>
			</div>
			<div class="modal-body" style="background-color: #f8f9fa; border-radius: 5px; padding: 20px;">
				<div style="text-align: center; margin-bottom: 20px;">
					<img src="${pageContext.request.contextPath}/image/course_template.png" style="width: 80px; height: 80px; border-radius: 5%;">
				</div>
				<!-- Year Selection Dropdown -->
				<div class="form-group">
					<label for="courseYear">Select Year:</label>
					<select class="form-control" id="courseYear" name="courseYear">
						<%
							Calendar now = Calendar.getInstance();
							int currentYear = now.get(Calendar.YEAR);
							int nextYear = currentYear + 1;
						%>
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
				<span class="text-primary"><strong>Create Course Template</strong></span>
				The system will generate a basic template for courses associated with a specific academic cycle. Please review the generated courses and make any necessary modifications, such as adjusting the price
				<br><br>
				<p class="text-center"><strong>Are you still want to proceed this ?</strong></p>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-primary" id="agreeCreateCourse">Yes, I am sure</button>
				<button type="button" class="btn btn-secondary" data-dismiss="modal">No, I don't want</button>
			</div>
		</div>
	</div>
</div>

<!-- Online Modal -->
<div class="modal fade" id="createOnlineModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered" role="document">
		<div class="modal-content" style="border: 2px solid #ffc107; border-radius: 10px;">
			<div class="modal-header bg-warning" style="display: block;">
				<p style="text-align: center; margin-bottom: 0;"><span style="font-size:18px"><strong>Create Online Session for JAC Study Batch</strong></span></p>
			</div>
			<div class="modal-body" style="background-color: #f8f9fa; border-radius: 5px; padding: 20px;">
				<div style="text-align: center; margin-bottom: 20px;">
					<img src="${pageContext.request.contextPath}/image/online_template.png" style="width: 80px; height: 80px; border-radius: 5%;">
				</div>
				<!-- Year Selection Dropdown -->
				<div class="form-group">
					<div class="form-row">
						<div class="col-md-6">
							<label for="onlineYear">Select Year:</label>
							<select class="form-control" id="onlineYear" name="onlineYear">
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
						<div class="col-md-6 d-flex justify-content-center align-items-center mt-4">
							<p>
								<a href="${pageContext.request.contextPath}/template/online_template.csv">Download CSV Template</a>
							</p>
						</div>
					</div>
					<div class="form-row mt-3">
						<div class="col-md-12">
							<span class="text-bold"><strong>Create Online Session Template</strong></span>
							The system will generate a basic template for an online session tailored to the specific academic cycle of JAC Study. Please note the following prerequisites:
							<ul class="text-danger mt-2 font-italic font-bold">
								<li>The academic cycle MUST be registered.</li>
								<li>The online course MUST be registered.</li>
							</ul>
						</div>
					</div>
					<div class="form-row mt-3">
						<div class="col-md-12 text-center">
							<span class="text-bold"><strong>Ready to upload CSV template file ?</strong></span>
						</div>
					</div>
					<div class="form-row mt-3">
						<div class="offset-md-4"></div>
						<div class="col-md-7">
							<!-- Include CSRF token -->
							<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
							<div class="input-group">
								<input type="file" name="file" class="file-input" id="file-input">
							</div>
							<div id="file-name-container"></div>
						</div>
						<div class="offset-md-1">
						</div>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-primary" id="agreeCreateOnline">Please, Process Template</button>
				<button type="button" class="btn btn-secondary" data-dismiss="modal">No, I don't want</button>
			</div>
		</div>
	</div>
</div>

