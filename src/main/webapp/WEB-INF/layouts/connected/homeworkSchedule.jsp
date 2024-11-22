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
	$('#scheduleListTable').DataTable({
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

	$('#addGradeAll').on('change', function() {
        var isChecked = $(this).is(':checked');
        $('#addGradeCheckbox input[type="checkbox"]').prop('checked', isChecked);
    });

	$('#editGradeAll').on('change', function() {
        var isChecked = $(this).is(':checked');
        $('#editGradeCheckbox input[type="checkbox"]').prop('checked', isChecked);
    });

    $('#addGradeCheckbox input[type="checkbox"]').on('change', function() {
        var checkboxes = $('#addGradeCheckbox input[type="checkbox"]');
        var allChecked = checkboxes.length === checkboxes.filter(':checked').length;
        $('#addGradeAll').prop('checked', allChecked);
    });

	$('#editGradeCheckbox input[type="checkbox"]').on('change', function() {
        var checkboxes = $('#editGradeCheckbox input[type="checkbox"]');
        var allChecked = checkboxes.length === checkboxes.filter(':checked').length;
        $('#editGradeAll').prop('checked', allChecked);
    });

	$('#addSubjectAll').on('change', function() {
        var isChecked = $(this).is(':checked');
        $('#addSubjectCheckbox input[type="checkbox"]').prop('checked', isChecked);
    });

	$('#editSubjectAll').on('change', function() {
        var isChecked = $(this).is(':checked');
        $('#editSubjectCheckbox input[type="checkbox"]').prop('checked', isChecked);
    });

    $('#addSubjectCheckbox input[type="checkbox"]').on('change', function() {
        var checkboxes = $('#addSubjectCheckbox input[type="checkbox"]');
        var allChecked = checkboxes.length === checkboxes.filter(':checked').length;
        $('#addSubjectAll').prop('checked', allChecked);
    });

	$('#editSubjectCheckbox input[type="checkbox"]').on('change', function() {
        var checkboxes = $('#editSubjectCheckbox input[type="checkbox"]');
        var allChecked = checkboxes.length === checkboxes.filter(':checked').length;
        $('#editSubjectAll').prop('checked', allChecked);
    });

});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Practice into Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addPractice(action) {
	// Get the values from the select elements
	var practiceTypeSelect = document.getElementById(action + "PracticeTypeSearch");
	var practiceType = practiceTypeSelect.options[practiceTypeSelect.selectedIndex].text;

	var gradeSelect = document.getElementById(action + "GradeSearch");
	var grade = gradeSelect.options[gradeSelect.selectedIndex].text;

	var setSelect = document.getElementById(action + "SetSearch");
	var set = setSelect.options[setSelect.selectedIndex].text;
	var practiceId = document.getElementById(action + "SetSearch").value;

	// Get a reference to the table
	var table = document.getElementById(action + "ScheduleTable");

	/// Create a new row
	var row = $("<tr>");

	// Create the cells for the row
	var cell1 = $("<td>").text(practiceType);
	var cell2 = $("<td>").text(grade);
	var cell3 = $("<td>").text(set);

	// cell4
	var binIcon = $('<i class="bi bi-trash h5"></i>');
	var binIconLink = $("<a>")
		.attr("href", "javascript:void(0)")
		.attr("title", "Delete Practice")
		.click(function () {
			row.remove();
		});
	binIconLink.append(binIcon);
	var cell4 = $("<td>").addClass('text-center').append(binIconLink);

	// hidden td for practiceId
	var td = $("<td>").css("display", "none").addClass("practiceId").text(practiceId);

	// Append cells to the row
	row.append(cell1, cell2, cell3, cell4, td);

	// Append the row to the table
	$("#"+ action +"ScheduleTable").append(row);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Practice Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function registerSchedule() {

	//start, end, grade, subject validation
	var start = document.getElementById('addFrom');
	if(start.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter start date and time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			start.focus();
		});
		return false;
	}
	var end = document.getElementById('addTo');
	if(end.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter end date and time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			end.focus();
		});
		return false;
	}
    // Collect the values of the selected grade checkboxes
    var selectedGrades = [];
    var allGradesChecked = $('#addGradeCheckbox input[name="grades"]').length === $('#addGradeCheckbox input[name="grades"]:checked').length;
    if (allGradesChecked) {
        selectedGrades.push('0');
    } else {
        $('#addGradeCheckbox input[name="grades"]:checked').each(function() {
            selectedGrades.push($(this).val());
        });
    }
	// check if no grade is selected
	if(selectedGrades.length == 0){
		$('#validation-alert .modal-body').text(
		'Please select grade');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			$('#addGrade').focus();
		});
		return false;
	}
    // Collect the values of the selected subject checkboxes
    var selectedSubjects = [];
    var allSubjectsChecked = $('#addSubjectCheckbox input[name="subjects"]').length === $('#addSubjectCheckbox input[name="subjects"]:checked').length;
    if (allSubjectsChecked) {
        selectedSubjects.push('0');
    } else {
        $('#addSubjectCheckbox input[name="subjects"]:checked').each(function() {
            selectedSubjects.push($(this).val());
        });
    }
	// check if no subject is selected
	if(selectedSubjects.length == 0){
		$('#validation-alert .modal-body').text(
		'Please select subject');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			$('#addSubject').focus();
		});
		return false;
	}

    // Create the schedule object
    var schedule = {
        from: $("#addFrom").val(),
        to: $("#addTo").val(),
        info: $("#addInfo").val(),
        grade: selectedGrades,
        subject: selectedSubjects,
        subjectDisplay: $("#addSubjectDisplay").val(),
        answerDisplay: $("#addAnswerDisplay").val(),
        active: true
    };

    console.log(schedule);

    // Send AJAX to server
    $.ajax({
        url: '${pageContext.request.contextPath}/connected/addHomeworkSchedule',
        type: 'POST',
        dataType: 'json',
        data: JSON.stringify(schedule),
        contentType: 'application/json',
        success: function (dto) {
            // Display the success alert
            $('#success-alert .modal-body').text('New Homework Schedule is registered successfully.');
            $('#success-alert').modal('show');
            $('#success-alert').on('hidden.bs.modal', function (e) {
                location.reload();
            });
        },
        error: function (xhr, status, error) {
            console.log('Error : ' + error);
        }
    });

    $('#registerScheduleModal').modal('hide');
    // flush all registered data
    document.getElementById("scheduleRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Homework Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveScheduleInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getHomeworkSchedule/' + id,
		type: 'GET',
		success: function (scheduleItem) {
			// console.log('Schedule Item:', scheduleItem); // Log the scheduleItem to check the response
            // Ensure the scheduleItem has the expected structure and fields
            if (scheduleItem) {
                $("#editId").val(scheduleItem.id);
				 // Convert 'from' and 'to' to the format expected by datetime-local input
				var fromDateTime = convertToDateTimeLocal(scheduleItem.from);
                var toDateTime = convertToDateTimeLocal(scheduleItem.to);
                $("#editFrom").val(fromDateTime);
                $("#editTo").val(toDateTime);
                $("#editInfo").val(scheduleItem.info);
                $("#editActive").val(scheduleItem.active);
                if (scheduleItem.active == true) {
                    $("#editActiveCheckbox").prop('checked', true);
                } else {
                    $("#editActiveCheckbox").prop('checked', false);
                }
				// Check the corresponding grade checkboxes
				$('#editGradeCheckbox input[type="checkbox"]').prop('checked', false); // Uncheck all checkboxes first
				if(scheduleItem.grade.includes('0')) {
					$('#editGradeAll').prop('checked', true);
					$('#editGradeCheckbox input[type="checkbox"]').prop('checked', true);
				}else{
					scheduleItem.grade.forEach(function(grade) {
						$('#editGradeCheckbox input[type="checkbox"][value="' + grade + '"]').prop('checked', true);
					});
				}
				// Check the corresponding subject checkboxes
				$('#editSubjectCheckbox input[type="checkbox"]').prop('checked', false); // Uncheck all checkboxes first
				if(scheduleItem.subject.includes('0')) {
					$('#editSubjectAll').prop('checked', true);
					$('#editSubjectCheckbox input[type="checkbox"]').prop('checked', true);
				}else{
					scheduleItem.subject.forEach(function(subject) {
						$('#editSubjectCheckbox input[type="checkbox"][value="' + subject + '"]').prop('checked', true);
					});
				}
				$("#editSubjectDisplay").val(scheduleItem.subjectDisplay);
				$("#editAnswerDisplay").val(scheduleItem.answerDisplay);
				// Show the modal
				$('#editScheduleModal').modal('show');
            } else {
                console.log('No schedule item found.');
            }


		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}

	});
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Convert date time string to date time local format
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function convertToDateTimeLocal(dateTimeStr) {
    // Assuming the input format is 'dd/MM/yyyy, HH:mm'
    var parts = dateTimeStr.split(', ');
    var dateParts = parts[0].split('/');
    var timeParts = parts[1].split(':');
    var year = dateParts[2];
    var month = dateParts[1].padStart(2, '0');
    var day = dateParts[0].padStart(2, '0');
    var hours = timeParts[0].padStart(2, '0');
    var minutes = timeParts[1].padStart(2, '0');
    return year+'-'+month+'-'+day+'T'+hours+':'+minutes;
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
//		Update Homework Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateScheduleInfo() {

	// Collect the values of the selected grade checkboxes
	var selectedGrades = [];
    var allGradesChecked = $('#editGradeCheckbox input[name="grades"]').length === $('#editGradeCheckbox input[name="grades"]:checked').length;
    if (allGradesChecked) {
        selectedGrades.push('0');
    } else {
        $('#editGradeCheckbox input[name="grades"]:checked').each(function() {
            selectedGrades.push($(this).val());
        });
    }
	// check if no grade is selected
	if(selectedGrades.length == 0){
		$('#validation-alert .modal-body').text('Please select grade');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			$('#editGrade').focus();
		});
		return false;
	}
    // Collect the values of the selected subject checkboxes
    var selectedSubjects = [];
    var allSubjectsChecked = $('#editSubjectCheckbox input[name="subjects"]').length === $('#editSubjectCheckbox input[name="subjects"]:checked').length;
    if (allSubjectsChecked) {
        selectedSubjects.push('0');
    } else {
        $('#editSubjectCheckbox input[name="subjects"]:checked').each(function() {
            selectedSubjects.push($(this).val());
        });
    }
	// check if no subject is selected
	if(selectedSubjects.length == 0){
		$('#validation-alert .modal-body').text('Please select subject');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			$('#editSubject').focus();
		});
		return false;
	}

	// get from formData
	var scheduleItem = {
		id: $("#editId").val(),
		from: $("#editFrom").val(),
		to: $("#editTo").val(),
		grade: selectedGrades,
		subject: selectedSubjects,
		subjectDisplay: $("#editSubjectDisplay").val(),
		answerDisplay: $("#editAnswerDisplay").val(),
		info: $("#editInfo").val(),
		active: $("#editActive").val()
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updateHomeworkSchedule',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(scheduleItem),
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

	$('#editScheduleModal').modal('hide');
	// flush edit data
	clearForm("scheduleEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearForm(elementId) {
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
//		Confirm before deleting Homework Schedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(scheduleId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteHomeworkSchedule(scheduleId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Homework Schedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteHomeworkSchedule(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/deleteHomeworkSchedule/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Homework Schedule deleted successfully');
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

	#scheduleListTable tr { 
		vertical-align: middle;
		height: 45px 	
	} 

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="scheduleList" method="get" action="${pageContext.request.contextPath}/connected/filterHomeworkSchedule">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listYear" class="label-form">Academic Year</label>
						<select class="form-control" id="listYear" name="listYear">
							<option value="0">All</option>
							<%
								Calendar listNow = Calendar.getInstance();
								int listCurrentYear = listNow.get(Calendar.YEAR);
							%>
							<option value="<%= listCurrentYear %>">Academic Year <%= (listCurrentYear) %>/<%= (listCurrentYear)+1 %></option>
							<%
								// Adding the last three years
								for (int i = listCurrentYear - 1; i >= listCurrentYear - 3; i--) {
							%>
								<option value="<%= i %>">Academic Year <%= i %>/<%= i+1 %></option>
							<%
							}
							%>
						</select>
					</div>
					<div class="offset-md-7"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerScheduleModal" ><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="scheduleListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<!-- <th class="text-center align-middle" style="width: 20%">Academic Year</th> -->
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Start</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">End</th>
										<th class="text-center align-middle" style="width: 15%">Grade</th>
										<th class="text-center align-middle" style="width: 20%">Subject</th>
										<th class="text-center align-middle" style="width: 15%">Display</th>										
										<th class="text-center align-middle" style="width: 15%">Information</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${HomeworkScheduleList != null}">
											<c:forEach items="${HomeworkScheduleList}" var="scheduleItem">
												<tr>
													<td class="small align-middle">
														<span>
															<c:out value="${scheduleItem.from}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${scheduleItem.to}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:forEach var="grade" items="${scheduleItem.grade}" varStatus="status">
																<script type="text/javascript">
																	document.write(gradeName('${grade}'));
																</script>
																<c:if test="${!status.last}">, </c:if>
															</c:forEach>
														</span>
													</td>
													<td class="small align-middle text-truncate">
														<span>
															<c:forEach var="subject" items="${scheduleItem.subject}" varStatus="status">
																<script type="text/javascript">
																	document.write(subjectName('${subject}'));
																</script>	
																<c:if test="${!status.last}">, </c:if>
															</c:forEach>
														</span>
													</td>
													<td class="small align-middle">
														<span>
															Subject : <c:out value="${scheduleItem.subjectDisplay}" />,  Answer : <c:out value="${scheduleItem.answerDisplay}" />
														</span>
													</td>
													<td class="small align-middle text-truncate" style="min-width: 50px;">
														<span>
															<c:out value="${scheduleItem.info}" />
														</span>
													</td>
													<c:set var="active" value="${scheduleItem.active}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit Homework Schedule" onclick="retrieveScheduleInfo('${scheduleItem.id}')">
														</i>
														&nbsp;&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete Homework Schedule" onclick="confirmDelete('${scheduleItem.id}')">
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
<div class="modal fade" id="registerScheduleModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Homework Schedule</header>
					<form id="scheduleRegister">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-6">
									<label for="addFrom" class="label-form">From</label>
									<input type="datetime-local" class="form-control datepicker" id="addFrom" name="addFrom" placeholder="From" required>
								</div>
								<div class="col-md-6">
									<label for="addTo" class="label-form">To</label> 
									<input type="datetime-local" class="form-control datepicker" id="addTo" name="addTo" placeholder="To" required>
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
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 5px; margin-right: 5px;">
								<div class="form-row">
									<div class="col-md-3">										
										<label for="addGrade" class="label-form h6 badge badge-success">Grade</label>
										<div id="addGrade" name="addGrade">
											<div class="form-check">
												<input class="form-check-input" type="checkbox" id="addGradeAll" name="addGradeAll">
												<label class="form-check-label" for="addGradeAll">
													All/None
												</label>
											</div>
											<div id="addGradeCheckbox">
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="1" id="addP2" name="grades">
													<label class="form-check-label" for="addP2">
														P2
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="2" id="addP3" name="grades">
													<label class="form-check-label" for="addP3">
														P3
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="3" id="addP4" name="grades">
													<label class="form-check-label" for="addP4">
														P4
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="4" id="addP5" name="grades">
													<label class="form-check-label" for="addP5">
														P5
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="5" id="addP6" name="grades">
													<label class="form-check-label" for="addP6">
														P6
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="6" id="addS7" name="grades">
													<label class="form-check-label" for="addS7">
														S7
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="7" id="addS8" name="grades">
													<label class="form-check-label" for="addS8">
														S8
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="8" id="addS9" name="grades">
													<label class="form-check-label" for="addS9">
														S9
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="9" id="addS10" name="grades">
													<label class="form-check-label" for="addS10">
														S10
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="11" id="addTT6" name="grades">
													<label class="form-check-label" for="addTT6">
														TT6
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="12" id="addTT8" name="grades">
													<label class="form-check-label" for="addTT8">
														TT8
													</label>
												</div>

											</div>
										</div>
									</div>	

									<div class="col-md-5">										
										<label for="addSubject" class="label-form h6 badge badge-success">Subject</label>
										<div id="addSubject" name="addSubject">
											<div class="form-check">
												<input class="form-check-input" type="checkbox" id="addSubjectAll" name="addSubjectAll">
												<label class="form-check-label" for="addSubjectAll">
													All/None
												</label>
											</div>
											<div id="addSubjectCheckbox">
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="1" id="addEng" name="subjects">
													<label class="form-check-label" for="addEng">
														English
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="2" id="addMath" name="subjects">
													<label class="form-check-label" for="addMath">
														Mathematics
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="4" id="addWriting" name="subjects">
													<label class="form-check-label" for="addWriting">
														Writing
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="12" id="addSA" name="subjects">
													<label class="form-check-label" for="addSA">
														Short Answer
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="13" id="addSATT" name="subjects">
													<label class="form-check-label" for="addSATT">
														Short Answer (TT)
													</label>
												</div>
											</div>
										</div>
									</div>	

									<div class="col-md-4">										
										<label for="addSubject" class="label-form h6 badge badge-success">Display</label>
										<div id="addDisplay" name="addDisplay">
											<div>
												<label for="addSubjectDisplay" class="label-form mt-2">Subject</label> 
												<select class="form-control" id="addSubjectDisplay" name="addSubjectDisplay">
													<%
													for (int j = 3; j <= 10; j++) {
													%>
													<option value="<%= j %>"><%= j %> Sets</option>
													<%
													}
													%>
												</select>
											</div>

											<div>
												<label for="addAnswerDisplay" class="label-form mt-3">Answer</label> 
												<select class="form-control" id="addAnswerDisplay" name="addAnswerDisplay">
													<%
													for (int k = 2; k <= 10; k++) {
													%>
													<option value="<%= k %>"><%= k %> Sets</option>
													<%
													}
													%>
												</select>	
											</div>
										</div>
									</div>	
								
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="registerSchedule()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearForm('scheduleRegister');" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>






<!-- Edit Form Dialogue -->
<div class="modal fade" id="editScheduleModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Homework Schedule Edit</header>
					<form id="scheduleEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-6">
									<label for="editFrom" class="label-form">From</label>
									<input type="datetime-local" class="form-control datepicker" id="editFrom" name="editFrom" placeholder="From" required>
								</div>
								<div class="col-md-6">
									<label for="editTo" class="label-form">To</label> 
									<input type="datetime-local" class="form-control datepicker" id="editTo" name="editTo" placeholder="To" required>
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












						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="form-row">
									
									<div class="col-md-3">										
										<label for="editGrade" class="label-form h6 badge badge-success">Grade</label>
										<div id="editGrade" name="editGrade">
											<div class="form-check">
												<input class="form-check-input" type="checkbox" id="editGradeAll" name="editGradeAll">
												<label class="form-check-label" for="editGradeAll">
													All/None
												</label>
											</div>
											<div id="editGradeCheckbox">
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="1" id="editP2" name="grades">
													<label class="form-check-label" for="editP2">
														P2
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="2" id="editP3" name="grades">
													<label class="form-check-label" for="editP3">
														P3
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="3" id="editP4" name="grades">
													<label class="form-check-label" for="editP4">
														P4
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="4" id="editP5" name="grades">
													<label class="form-check-label" for="editP5">
														P5
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="5" id="editP6" name="grades">
													<label class="form-check-label" for="editP6">
														P6
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="6" id="editS7" name="grades">
													<label class="form-check-label" for="editS7">
														S7
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="7" id="editS8" name="grades">
													<label class="form-check-label" for="editS8">
														S8
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="8" id="editS9" name="grades">
													<label class="form-check-label" for="editS9">
														S9
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="9" id="editS10" name="grades">
													<label class="form-check-label" for="editS10">
														S10
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="11" id="editTT6" name="grades">
													<label class="form-check-label" for="editTT6">
														TT6
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="12" id="editTT8" name="grades">
													<label class="form-check-label" for="editTT8">
														TT8
													</label>
												</div>

											</div>
										</div>
									</div>	

									<div class="col-md-5">										
										<label for="editSubject" class="label-form h6 badge badge-success">Subject</label>
										<div id="editSubject" name="editSubject">
											<div class="form-check">
												<input class="form-check-input" type="checkbox" id="editSubjectAll" name="editSubjectAll">
												<label class="form-check-label" for="editSubjectAll">
													All/None
												</label>
											</div>
											<div id="editSubjectCheckbox">
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="1" id="editEng" name="subjects">
													<label class="form-check-label" for="editEng">
														English
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="2" id="editMath" name="subjects">
													<label class="form-check-label" for="editMath">
														Mathematics
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="4" id="editWriting" name="subjects">
													<label class="form-check-label" for="editWriting">
														Writing
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="12" id="editSA" name="subjects">
													<label class="form-check-label" for="adSA">
														Short Answer
													</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="13" id="editSATT" name="subjects">
													<label class="form-check-label" for="editSATT">
														Short Answer (TT)
													</label>
												</div>
											</div>
										</div>
									</div>	

									<div class="col-md-4">										
										<label for="editSubject" class="label-form h6 badge badge-success">Display</label>
										<div id="editDisplay" name="editDisplay">
											<div>
												<label for="editSubjectDisplay" class="label-form mt-2">Subject</label> 
												<select class="form-control" id="editSubjectDisplay" name="editSubjectDisplay">
													<%
													for (int j = 3; j <= 10; j++) {
													%>
													<option value="<%= j %>"><%= j %> Sets</option>
													<%
													}
													%>
												</select>
											</div>

											<div>
												<label for="editAnswerDisplay" class="label-form mt-3">Answer</label> 
												<select class="form-control" id="editAnswerDisplay" name="editAnswerDisplay">
													<%
													for (int k = 2; k <= 10; k++) {
													%>
													<option value="<%= k %>"><%= k %> Sets</option>
													<%
													}
													%>
												</select>	
											</div>
										</div>
									</div>	
		

								</div>
							</div>
						</div>
						<input type="hidden" id="editId" name="editId" />
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateScheduleInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearForm('scheduleEdit')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Add Answer Form Dialogue -->
<div class="modal fade" id="registerTestAnswerModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Test Answer Sheet</header>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12 mt-4">
									<label for="addAnswerVideoPath" class="label-form">Answer Video Path</label>
									<input type="text" class="form-control" id="addAnswerVideoPath" name="addAnswerVideoPath" placeholder="https://" title="Please enter video access address" />
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12 mt-4">
									<label for="addAnswerPdfPath" class="label-form">Answer Document Path</label>
									<input type="text" class="form-control" id="addAnswerPdfPath" name="addAnswerPdfPath" placeholder="https://" title="Please enter document access address" />
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="answerSheetTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="question" style="width: 10%;">Question#</th>
											<th data-field="answer" style="width: 10%;">Answer</th>
											<th data-field="topic" style="width: 70%;">Topic</th>
											<th data-field="remove" style="width: 10%;">Remove</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row align-items-center" style="border: 2px solid #28a745; padding: 10px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="col-md-3">
									<label for="answerQuestionNumber" class="label-form">Number</label>
									<select class="form-control" id="answerQuestionNumber" name="answerQuestionNumber">
										<c:forEach var="i" begin="1" end="50">
											<option value="${i}">${i}</option>
										</c:forEach>
									</select>
								</div>
								<div class="col-md-2">
									<label for="correctAnswerOption" class="label-form">Answer</label>
									<select class="form-control" id="correctAnswerOption" name="correctAnswerOption">
										<option value="1">A</option>
										<option value="2">B</option>
										<option value="3">C</option>
										<option value="4">D</option>
										<option value="5">E</option>
									</select>
								</div>
								<div class="col-md-5">
									<label for="answerTopic" class="label-form">Topic</label>
									<input type="text" class="form-control" name="answerTopic" id="answerTopic" placeholder="Add Topic" />
								</div>
								<div class="col-md-2">
									<label for="" class="label-form">&nbsp;</label>
									<button type="button" class="btn btn-success btn-block" onclick="addAnswerToTable()"> <i class="bi bi-plus"></i></button>
								</div>
							</div>
						</div>
						<input type="hidden" id="answerId" name="answerId" />
						<input type="hidden" id="testId4Answer" name="testId4Answer" />
					<div class="mt-4 d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="collectAndSubmitAnswers()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearForm('testRegister')" data-dismiss="modal">Close</button>
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

<!--Delete Confirmation Modal -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Homework Schedule Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Homework Schedule ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>
