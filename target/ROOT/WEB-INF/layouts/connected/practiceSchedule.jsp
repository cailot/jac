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


	// $('#addGradeAll').on('change', function() {
    //     var isChecked = $(this).is(':checked');
    //     $('#addGradeCheckbox input[type="checkbox"]').prop('checked', isChecked);
    // });

	// $('#addGradeCheckbox input[type="checkbox"]').on('change', function() {
    //     var checkboxes = $('#addGradeCheckbox input[type="checkbox"]');
    //     var allChecked = checkboxes.length === checkboxes.filter(':checked').length;
    //     $('#addGradeAll').prop('checked', allChecked);
    // });


	// $('#editGradeAll').on('change', function() {
	// 	var isChecked = $(this).is(':checked');
	// 	$('#editGradeCheckbox input[type="checkbox"]').prop('checked', isChecked);
	// });

	// $('#editGradeCheckbox input[type="checkbox"]').on('change', function() {
	// 	var checkboxes = $('#editGradeCheckbox input[type="checkbox"]');
	// 	var allChecked = checkboxes.length === checkboxes.filter(':checked').length;
	// 	$('#editGradeAll').prop('checked', allChecked);
	// });

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Practice into Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addPractice(action) {
	// Get the values from the select elements
	var practiceTypeSelect = document.getElementById(action + "PracticeType");
	var practiceTypeGroup = practiceTypeSelect.options[practiceTypeSelect.selectedIndex].value;
	var practiceTypeName = practiceTypeSelect.options[practiceTypeSelect.selectedIndex].text;

	var setSelect = document.getElementById(action + "Volume");
	var set = setSelect.options[setSelect.selectedIndex].text;
	var practiceTypeWeek = document.getElementById(action + "Volume").value;

	// Get a reference to the table
	var table = document.getElementById(action + "ScheduleTable");

	/// Create a new row
	var row = $("<tr>");

	// Create the cells for the row
	var cell1 = $("<td>").text(practiceTypeName);
	var cell2 = $("<td>").text(set);

	// cell3
	var binIcon = $('<i class="bi bi-trash h5"></i>');
	var binIconLink = $("<a>")
		.attr("href", "javascript:void(0)")
		.attr("title", "Delete Practice")
		.click(function () {
			row.remove();
		});
	binIconLink.append(binIcon);
	var cell3 = $("<td>").addClass('text-center').append(binIconLink);

	// hidden td for practiceTypeWeek
	var hidden1 = $("<td>").css("display", "none").addClass("practiceTypeWeek").text(practiceTypeWeek);
	var hidden2 = $("<td>").css("display", "none").addClass("practiceTypeGroup").text(practiceTypeGroup);

	// Append cells to the row
	row.append(cell1, cell2, cell3, hidden1, hidden2);

	// Append the row to the table
	$("#"+ action +"ScheduleTable").append(row);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Practice Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function registerSchedule() {
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

	// Get practiceTypeGroup & set form addScheduleTable
	var practiceGroups = [];
	var weeks = [];
	$('#addScheduleTable tr').each(function () {
		var practiceGroup = $(this).find('.practiceTypeGroup').text();
		var practiceSet = $(this).find('.practiceTypeWeek').text();
		console.log(practiceGroup + ' set : ' + practiceSet);
		if (practiceGroup != '') {
			//practiceDtos.push({group : practiceGroup, week : practiceSet});
			practiceGroups.push(practiceGroup);
			weeks.push(practiceSet);
		}
	});

	var schedule = {
		from: $("#addFrom").val(),
		to: $("#addTo").val(),
		info: $("#addInfo").val(),
		grade : selectedGrades,
		practiceGroup: practiceGroups,
		week: weeks
	}

	//console.log(schedule);
	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/addPracticeSchedule',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(schedule),
		contentType: 'application/json',
		success: function (dto) {
			// Display the success alert
			$('#success-alert .modal-body').text('New Practice Schedule is registered successfully.');
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
//		Retrieve Practice Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveScheduleInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getPracticeSchedule/' + id,
		type: 'GET',
		success: function (scheduleItem) {
			// console.log(scheduleItem);
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

			// add rows to the table
			// clear all rows on editScheduleTable
			$("#editScheduleTable").find("tr:gt(0)").remove();
			// Handle practiceGroup as String[]
			var practiceGroups = [];
			if (typeof scheduleItem.practiceGroup === 'string' && scheduleItem.practiceGroup) {
				practiceGroups = scheduleItem.practiceGroup.split(',').map(function(item) {
					return item.trim();
				});
			} else if (Array.isArray(scheduleItem.practiceGroup)) {
				if (scheduleItem.practiceGroup.length === 1 && scheduleItem.practiceGroup[0] === '') {
					practiceGroups = [];
				} else {
					practiceGroups = scheduleItem.practiceGroup;
				}
			}
			// Handle weeks as String[]
			var weeks = [];
			if (typeof scheduleItem.week === 'string' && scheduleItem.week) {
				weeks = scheduleItem.week.split(',').map(function(item) {
					return item.trim();
				});
			} else if (Array.isArray(scheduleItem.week)) {
				// weeks = scheduleItem.week;
				if (scheduleItem.week.length === 1 && scheduleItem.week[0] === '') {
					weeks = [];
				} else {
					weeks = scheduleItem.week;
				}
			}

			// add rows to the table for practiceGroup and week
			for (var i = 0; i < weeks.length; i++) {
				// Get the values from the select elements
				var practiceTypeGroup = practiceGroups[i];
				var practiceTypeWeek = weeks[i];
				// Get a reference to the table
				var table = document.getElementById("editScheduleTable");
				// Create a new row
				var row = $("<tr>");
				// Create the cells for the row
				var cell1 = $("<td>").text(practiceGroupName(practiceTypeGroup));
				// var cell2 = $("<td>").text(practiceTypeWeek);
				var cell2Text = '';
				if(practiceTypeGroup == 1 || practiceTypeGroup == 2){
					switch (practiceTypeWeek) {
						case '1':
							cell2Text = 'Vol 1-1';
							break;
						case '2':
							cell2Text = 'Vol 1-2';
							break;
						case '3':
							cell2Text = 'Vol 2-1';
							break;
						case '4':
							cell2Text = 'Vol 2-2';
							break;
						case '5':
							cell2Text = 'Vol 3-1';
							break;
						case '6':
							cell2Text = 'Vol 3-2';
							break;
						case '7':
							cell2Text = 'Vol 4-1';
							break;
						case '8':
							cell2Text = 'Vol 4-2';
							break;
						case '9':
							cell2Text = 'Vol 5-1';
							break;
						case '10':
							cell2Text = 'Vol 5-2';
							break;
						default:
							cell2Text = practiceTypeWeek;
							break;
					}
				}else{
					cell2Text = practiceTypeWeek;
				}
				var cell2 = $("<td>").text(cell2Text);	

				// cell3
				var binIcon = $('<i class="bi bi-trash h5"></i>');
				var binIconLink = $("<a>")
					.attr("href", "javascript:void(0)")
					.attr("title", "Delete Practice")
					.click((function(row) {
						return function() {
							row.remove();
						};
					})(row));
				binIconLink.append(binIcon);
				var cell3 = $("<td>").addClass('text-center').append(binIconLink);

				var hidden1 = $("<td>").css("display", "none").addClass("practiceTypeWeek").text(practiceTypeWeek);
				var hidden2 = $("<td>").css("display", "none").addClass("practiceTypeGroup").text(practiceTypeGroup);

				// Append cells to the row
				row.append(cell1, cell2, cell3, hidden1, hidden2);

				// Append the row to the table
				$("#editScheduleTable").append(row);
			}
			// show volume options
			updateVolumeOptions('edit');
			// display available set to be ready to select
			$('#editScheduleModal').modal('show');
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
//		Update Practice Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateScheduleInfo() {
	// Collect the values of the selected grade checkboxes
	var selectedGrades = [];
	var allGradesChecked = $('#editGradeCheckbox input[name="grades"]').length === $('#addGradeCheckbox input[name="grades"]:checked').length;
	if (allGradesChecked) {
		selectedGrades.push('0');
	} else {
		$('#editGradeCheckbox input[name="grades"]:checked').each(function() {
			selectedGrades.push($(this).val());
		});
	}
	// check if no grade is selected
	if(selectedGrades.length == 0){
		$('#validation-alert .modal-body').text(
		'Please select grade');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			$('#editGrade').focus();
		});
		return false;
	}

	// Get practiceTypeGroup & set form editScheduleTable
	var practiceGroups = [];
	var weeks = [];
	$('#editScheduleTable tr').each(function () {
		var practiceGroup = $(this).find('.practiceTypeGroup').text();
		var practiceSet = $(this).find('.practiceTypeWeek').text();
		// console.log(practiceGroup + ' set : ' + practiceSet);
		if (practiceGroup != '') {
			//practiceDtos.push({group : practiceGroup, week : practiceSet});
			practiceGroups.push(practiceGroup);
			weeks.push(practiceSet);
		}
	});

	var schedule = {
		id: $("#editId").val(),
		from: $("#editFrom").val(),
		to: $("#editTo").val(),
		info: $("#editInfo").val(),
		active: $("#editActive").val(),
		grade : selectedGrades,
		practiceGroup: practiceGroups,
		week: weeks
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updatePracticeSchedule',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(schedule),
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
//		Clear Table
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearTable(action) {
	var table = document.getElementById(action + "ScheduleTable");
	table.getElementsByTagName('tbody')[0].innerHTML = "";
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
//		Confirm before deleting PracticeSchedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(practiceId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deletePracticeSchedule(practiceId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete PracticeSchedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deletePracticeSchedule(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/deletePracticeSchedule/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Practice Schedule deleted successfully');
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
//		Update Volume Options
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateVolumeOptions(action) {
	// Get the selected practice type text
	var practiceTypeSelect = document.getElementById(action + "PracticeType");
	var practiceTypeText = practiceTypeSelect.selectedOptions[0].text;

	console.log(practiceTypeText);
	
	// Clear existing options
	var selectElement = document.getElementById(action + "Volume");
	selectElement.innerHTML = '';

	// Check if the practice type starts with "Mega" or "Revision"
	if (practiceTypeText.startsWith("Mega") || practiceTypeText.startsWith("Revision")) {
		// Loop to add options "Vol.1-1", "Vol.1-2", etc.
		for (var i = 1; i <= 5; i++) {
			for (var j = 1; j <= 2; j++) {
				// Create a new option element
				var option = document.createElement("option");
				// Set the value and text content for the option
				option.value = (i - 1) * 2 + j;
				option.textContent = "Vol " + i + "-" + j;
				// Append the option to the select element
				selectElement.appendChild(option);
			}
		}
	} else {
		// Loop to add options 1, 2, etc.
		for (var i = 1; i <= 25; i++) {
			// Create a new option element
			var option = document.createElement("option");
			// Set the value and text content for the option
			option.value = i;
			option.textContent = i;
			// Append the option to the select element
			selectElement.appendChild(option);
		}
	}
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

	.checkbox-container {
    display: flex;
    flex-wrap: nowrap; /* Prevents wrapping to the next line */
    gap: 10px; /* Adjusts spacing between checkboxes */
    justify-content: flex-start; /* Ensures alignment starts from the left */
}
.form-check {
    display: flex;
    align-items: center; /* Aligns checkboxes and labels vertically */
    margin-right: 2.8px; /* Adds spacing between checkboxes */
}

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="scheduleList" method="get" action="${pageContext.request.contextPath}/connected/filterPracticeSchedule">
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
					<div class="col-md-2">
						<label for="listPracticeType" class="label-form">Practice Type</label>
						<select class="form-control" id="listPracticeType" name="listPracticeType">
							<option value="0">All</option>
							<option value="1">Mega Practice</option>
							<option value="2">Revision Practice</option>
							<option value="3">Edu Practice</option>
							<option value="4">Acer Practice</option>
							<option value="5">NAPLAN Practice</option>
						</select>
					</div>
					<div class="offset-md-5"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerScheduleModal" onclick="updateVolumeOptions('add')"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th class="text-center align-middle" data-orderable="false" style="width: 12.5%">Start</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 12.5%">End</th>
										<th class="text-center align-middle" style="width: 20%">Practice Type</th>
										<th class="text-center align-middle" style="width: 15%">Grade</th>
										<th class="text-center align-middle" style="width: 10%">Week</th>
										<th class="text-center align-middle" style="width: 20%">Information</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 4%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 6%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${PracticeScheduleList != null}">
											<c:forEach items="${PracticeScheduleList}" var="scheduleItem">
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
															<c:forEach var="group" items="${scheduleItem.practiceGroup}" varStatus="status">
																<script type="text/javascript">
																	document.write(practiceGroupName('${group}'));
																</script>
																<c:if test="${!status.last}">, </c:if>
															</c:forEach>
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
													<td class="small align-middle">
														<span>
															<!-- Display Weeks for Each Group -->
															<c:forEach var="week" items="${scheduleItem.week}" varStatus="weekStatus">
																<c:choose>
																	<c:when test="${scheduleItem.practiceGroup[weekStatus.index] == 1 || scheduleItem.practiceGroup[weekStatus.index] == 2}">
																		<c:choose>
																			<c:when test="${week == '1'}">Vol 1-1</c:when>
																			<c:when test="${week == '2'}">Vol 1-2</c:when>
																			<c:when test="${week == '3'}">Vol 2-1</c:when>
																			<c:when test="${week == '4'}">Vol 2-2</c:when>
																			<c:when test="${week == '5'}">Vol 3-1</c:when>
																			<c:when test="${week == '6'}">Vol 3-2</c:when>
																			<c:when test="${week == '7'}">Vol 4-1</c:when>
																			<c:when test="${week == '8'}">Vol 4-2</c:when>
																			<c:when test="${week == '9'}">Vol 5-1</c:when>
																			<c:when test="${week == '10'}">Vol 5-2</c:when>
																			<c:otherwise><c:out value="${week}" /></c:otherwise>
																		</c:choose>
																	</c:when>
																	<c:otherwise>
																		<c:out value="${week}" />
																	</c:otherwise>
																</c:choose>
																<c:if test="${!weekStatus.last}">, </c:if>
															</c:forEach>
														</span>
													</td>													
													<td class="small align-middle text-truncate" style="min-width: 300px;">
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
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit Practice Schedule" onclick="retrieveScheduleInfo('${scheduleItem.id}')">
														</i>
														&nbsp;&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete Practice Schedule" onclick="confirmDelete('${scheduleItem.id}')">
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
					<header class="text-info font-weight-bold">Practice Schedule Registration</header>
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
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<div class="form-row">
									<div class="col-md-12">
										<label for="addGrade" class="label-form h6 badge badge-success">Grade</label>
										<div id="addGrade" name="addGrade">
											<!-- First Row -->
											<div id="addGradeCheckbox" class="checkbox-container">
												<!-- <div class="form-check">
													<input class="form-check-input" type="checkbox" id="addGradeAll" name="addGradeAll">
													<label class="form-check-label" for="addGradeAll">All/None</label>
												</div> -->
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="1" id="addP2" name="grades">
													<label class="form-check-label" for="addP2">P2</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="2" id="addP3" name="grades">
													<label class="form-check-label" for="addP3">P3</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="3" id="addP4" name="grades">
													<label class="form-check-label" for="addP4">P4</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="4" id="addP5" name="grades">
													<label class="form-check-label" for="addP5">P5</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="5" id="addP6" name="grades">
													<label class="form-check-label" for="addP6">P6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="11" id="addTT6" name="grades">
													<label class="form-check-label" for="addTT6">TT6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="12" id="addTT8" name="grades">
													<label class="form-check-label" for="addTT8">TT8</label>
												</div>
											</div>
											<!-- Second Row -->
											<div id="addGradeCheckbox" class="checkbox-container">
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="6" id="addS7" name="grades">
													<label class="form-check-label" for="addS7">S7</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="7" id="addS8" name="grades">
													<label class="form-check-label" for="addS8">S8</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="8" id="addS9" name="grades">
													<label class="form-check-label" for="addS9">S9</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="9" id="addS10" name="grades">
													<label class="form-check-label" for="addS10">S10</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="19" id="addJMSS" name="grades">
													<label class="form-check-label" for="addJMSS">JMSS</label>
												</div>
											</div>
										</div>
									</div>

								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<div class="form-row">
									<div class="col-md-12">
										<label class="label-form h6 badge badge-success">Practice</label>										
									</div>
								</div>
								<div class="form-row">
									<div class="col-md-7">
										<label for="addPracticeType" class="label-form">Type</label>
										<select class="form-control" id="addPracticeType" name="addPracticeType" onchange="updateVolumeOptions('add')">
											<option value="1">Mega Practice</option>
											<option value="2">Revision Practice</option>
											<option value="3">Edu Practice</option>
											<option value="4">Acer Practice</option>
											<option value="5">NAPLAN Practice</option>
										</select>
									</div>
									<div class="col-md-4">
										<label for="addVolume" class="label-form">Set</label>
										<select class="form-control" id="addVolume" name="addVolume">
										</select>
									</div>
									<div class="col-md-1 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addPractice('add')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="addScheduleTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 65%;">Practice</th>
											<th data-field="set" style="width: 25%;">Set</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="registerSchedule()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearForm('scheduleRegister'); clearTable('add')" data-dismiss="modal">Close</button>
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
					<header class="text-primary font-weight-bold">Practice Schedule Edit</header>
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
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<div class="form-row">
									<div class="col-md-12">
										<label for="editGrade" class="label-form h6 badge badge-success">Grade</label>
										<div id="editGrade" name="editGrade">
											<!-- First Row -->
											<div id="editGradeCheckbox" class="checkbox-container">
												<!-- <div class="form-check">
													<input class="form-check-input" type="checkbox" id="editGradeAll" name="editGradeAll">
													<label class="form-check-label" for="editGradeAll">All/None</label>
												</div> -->
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="1" id="editP2" name="grades">
													<label class="form-check-label" for="editP2">P2</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="2" id="editP3" name="grades">
													<label class="form-check-label" for="editP3">P3</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="3" id="editP4" name="grades">
													<label class="form-check-label" for="editP4">P4</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="4" id="editP5" name="grades">
													<label class="form-check-label" for="editP5">P5</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="5" id="editP6" name="grades">
													<label class="form-check-label" for="editP6">P6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="11" id="editTT6" name="grades">
													<label class="form-check-label" for="editTT6">TT6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="12" id="editTT8" name="grades">
													<label class="form-check-label" for="editTT8">TT8</label>
												</div>
											</div>
											<!-- Second Row -->
											<div id="editGradeCheckbox" class="checkbox-container">
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="6" id="editS7" name="grades">
													<label class="form-check-label" for="editS7">S7</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="7" id="editS8" name="grades">
													<label class="form-check-label" for="editS8">S8</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="8" id="editS9" name="grades">
													<label class="form-check-label" for="editS9">S9</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="9" id="editS10" name="grades">
													<label class="form-check-label" for="editS10">S10</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="checkbox" value="19" id="editJMSS" name="grades">
													<label class="form-check-label" for="editJMSS">JMSS</label>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<div class="form-row">
									<div class="col-md-12">
										<label class="label-form h6 badge badge-success">Practice</label>										
									</div>
								</div>
								<div class="form-row">
									<div class="col-md-7">
										<label for="editPracticeType" class="label-form">Type</label>
										<select class="form-control" id="editPracticeType" name="editPracticeType" onchange="updateVolumeOptions('edit')">
											<option value="1">Mega Practice</option>
											<option value="2">Revision Practice</option>
											<option value="3">Edu Practice</option>
											<option value="4">Acer Practice</option>
											<option value="5">NAPLAN Practice</option>
										</select>
									</div>
									<div class="col-md-4">
										<label for="editVolume" class="label-form">Set</label>
										<select class="form-control" id="editVolume" name="editVolume">
										</select>
									</div>
									<div class="col-md-1 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addPractice('edit')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="editScheduleTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 65%;">Practice</th>
											<th data-field="set" style="width: 25%;">Set</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
						<input type="hidden" id="editId" name="editId" />
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateScheduleInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearForm('scheduleEdit'); clearTable('edit')" data-dismiss="modal">Close</button>
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
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Practice Schedule Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Practice Schedule ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>
