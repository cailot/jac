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
<!-- Date Time picker -->
<script src="${pageContext.request.contextPath}/js/jquery-ui-timepicker-addon-1.6.3.min.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery-ui-timepicker-addon-1.6.3.min.css"></link>

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

	$("#addStart").datetimepicker({
		dateFormat: 'dd/mm/yy',
		timeFormat: 'HH:mm'
	});
	$("#addEnd").datetimepicker({
		dateFormat: 'dd/mm/yy',
		timeFormat: 'HH:mm'
	});
	$("#editStart").datetimepicker({
		dateFormat: 'dd/mm/yy',
		timeFormat: 'HH:mm'
	});
	$("#editEnd").datetimepicker({
		dateFormat: 'dd/mm/yy',
		timeFormat: 'HH:mm'
	});

	// When the academic year dropdown changes, send an Ajax request to get the corresponding Practice
	$('#addTestTypeSearch').change(function () {
		getTestByTypeNGrade('add');
	});
	$('#addGradeSearch').change(function () {
		getTestByTypeNGrade('add');
	});
	$('#editTestTypeSearch').change(function () {
		getTestByTypeNGrade('edit');
	});
	$('#editGradeSearch').change(function () {
		getTestByTypeNGrade('edit');
	});
		
	// initialise state list when loading
	listGrade('#addGradeSearch');
	listGrade('#editGradeSearch');
	listTestType('#addTestTypeSearch');
	listTestType('#editTestTypeSearch');

});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate Practice by type and grade
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getTestByTypeNGrade(action) {
	// debugger;
	var type = $('#'+action+'TestTypeSearch').val();
	var grade = $('#'+action+'GradeSearch').val();

	$.ajax({
		url: '${pageContext.request.contextPath}/connected/test4Schedule/' + type + '/' + grade,
		method: 'GET',
		success: function (data) {
			// clean up existing options
			$('#'+action+'SetSearch').empty();
			$.each(data, function (index, value) {
				// console.log(value.volume);
				$('#'+action+'SetSearch').append($("<option value='" + value.id + "'>" + value.volume + "</option>")); // add new option
			});
		},
		error: function (xhr, status, error) {
			console.error(xhr.responseText);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Test into Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addTest(action) {
	// Get the values from the select elements
	var testTypeSelect = document.getElementById(action + "TestTypeSearch");
	var testType = testTypeSelect.options[testTypeSelect.selectedIndex].text;

	var gradeSelect = document.getElementById(action + "GradeSearch");
	var grade = gradeSelect.options[gradeSelect.selectedIndex].text;

	var setSelect = document.getElementById(action + "SetSearch");
	var set = setSelect.options[setSelect.selectedIndex].text;
	var testId = document.getElementById(action + "SetSearch").value;

	// Get a reference to the table
	var table = document.getElementById(action + "ScheduleTable");

	/// Create a new row
	var row = $("<tr>");

	// Create the cells for the row
	var cell1 = $("<td>").text(testType);
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

	// hidden td for testId
	var td = $("<td>").css("display", "none").addClass("testId").text(testId);

	// Append cells to the row
	row.append(cell1, cell2, cell3, cell4, td);

	// Append the row to the table
	$("#"+ action +"ScheduleTable").append(row);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Test Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function registerSchedule() {

	// start, end validation
	var start = document.getElementById('addStart');
	if(start.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter start date & time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			start.focus();
		});
		return false;
	}
	var end = document.getElementById('addEnd');
	if(end.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter end date & time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			end.focus();
		});
		return false;
	}

	// Get testIds form addScheduleTable
	var testDtos = [];
	$('#addScheduleTable tr').each(function () {
		var testId = $(this).find('.testId').text();
		if (testId != '') {
			testDtos.push({id : testId});
		}
	});
	var startTime = $("#addStart").val();
	var endTime = $("#addEnd").val();
	//debugger;
	var schedule = {
		year: $("#addYear").val(),
		week: $("#addVolume").val(),
		startDate: startTime,
		endDate: endTime,
		info: $("#addInfo").val(),
		tests: testDtos
	}
	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/addTestSchedule',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(schedule),
		contentType: 'application/json',
		success: function (dto) {
			// Display the success alert
			$('#success-alert .modal-body').text('New Test Schedule is registered successfully.');
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
//		Retrieve Test Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveScheduleInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getTestSchedule/' + id,
		type: 'GET',
		success: function (scheduleItem) {
			// console.log(scheduleItem);
			$("#editId").val(scheduleItem.id);
			$("#editYear").val(scheduleItem.year);
			$("#editWeek").val(scheduleItem.week);
			$("#editStart").val(scheduleItem.startDate);
			$("#editEnd").val(scheduleItem.endDate);
			$("#editInfo").val(scheduleItem.info);
			$("#editActive").val(scheduleItem.active);
			if (scheduleItem.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			// clear all rows on editScheduleTable
			$("#editScheduleTable").find("tr:gt(0)").remove();	
			// append Test Info into table
			var tests = scheduleItem.tests;
			$.each(tests, function (index, value) {
				// Get the values from the select elements
				var gradeSelect = document.getElementById("editGradeSearch");
				var grade = gradeSelect.options[value.grade].text;
				// Get a reference to the table
				var table = document.getElementById("editScheduleTable");
				// Create a new row
				var row = $("<tr>");
				// Create the cells for the row
				var cell1 = $("<td>").text(value.name);
				var cell2 = $("<td>").text(grade);
				var cell3 = $("<td>").text(value.volume);

				// cell4
				var binIcon = $('<i class="bi bi-trash h5"></i>');
				var binIconLink = $("<a>")
					.attr("href", "javascript:void(0)")
					.attr("title", "Delete Test")
					.click(function () {
						row.remove();
					});
				binIconLink.append(binIcon);
				var cell4 = $("<td>").addClass('text-center').append(binIconLink);

				// hidden td for testId
				var td = $("<td>").css("display", "none").addClass("testId").text(value.id);

				// Append cells to the row
				row.append(cell1, cell2, cell3, cell4, td);

				// Append the row to the table
				$("#editScheduleTable").append(row);
			});
			// display available set to be ready to select
			getTestByTypeNGrade('edit');
			$('#editScheduleModal').modal('show');
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
//		Update Test Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateScheduleInfo() {

	// start, end validation
	var start = document.getElementById('editStart');
	if(start.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter start date & time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			start.focus();
		});
		return false;
	}
	var end = document.getElementById('editEnd');
	if(end.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter end date & time');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			end.focus();
		});
		return false;
	}

	// get from formData
	var testDtos = [];
	$('#editScheduleTable tr').each(function () {
		var testId = $(this).find('.testId').text();
		if (testId != '') {
			testDtos.push({id : testId});
		}
	});
	var scheduleItem = {
		id: $("#editId").val(),
		year: $("#editYear").val(),
		week: $("#editWeek").val(),
		startDate: $("#editStart").val(),
		endDate: $("#editEnd").val(),
		info: $("#editInfo").val(),
		active: $("#editActive").val(),
		tests: testDtos
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updateTestSchedule',
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
//		Confirm before deleting TestSchedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteTestSchedule(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete TestSchedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteTestSchedule(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/deleteTestSchedule/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Test Schedule deleted successfully');
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
		height: 50px 	
	} 

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="scheduleList" method="get" action="${pageContext.request.contextPath}/connected/filterTestSchedule">
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
						<label for="listWeek" class="label-form">Set Schedule</label>
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
								if (i === 10) {
									option.textContent = 'Volume 1 (' + i + ')';
								}else if (i === 20) {
									option.textContent = 'Volume 2 (' + i + ')';
								} else if (i === 30) {
									option.textContent = 'Volume 3 (' + i + ')';
								} else if (i === 40) {
									option.textContent = 'Volume 4 (' + i + ')';
								} else if ((i === 49) || (i === 50)) {
									option.textContent = 'Volume 5 (' + i + ')';
								} else {
									option.textContent = i;
								}
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
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerScheduleModal" onclick="getTestByTypeNGrade('add')"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th class="text-center align-middle" style="width: 15%">Academic Year</th>
										<th class="text-center align-middle" style="width: 15%">Set</th>
										<th class="text-center align-middle" style="width: 10%">Start</th>
										<th class="text-center align-middle" style="width: 10%">End</th>
										<th class="text-center align-middle" style="width: 40%">Information</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${TestScheduleList != null}">
											<c:forEach items="${TestScheduleList}" var="scheduleItem">
												<tr>
													<td class="small align-middle">
														<span>
															Academic Year <c:out value="${scheduleItem.year}" />/<c:out value="${scheduleItem.year+1}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:choose>
																<c:when test="${scheduleItem.week == 10}">End of Volume 1 (10)</c:when>
																<c:when test="${scheduleItem.week == 20}">End of Volume 2 (20)</c:when>
																<c:when test="${scheduleItem.week == 30}">End of Volume 3 (30)</c:when>
																<c:when test="${scheduleItem.week == 40}">End of Volume 4 (40)</c:when>
																<c:when test="${scheduleItem.week >= 49}">End of Volume 5 (50)</c:when>
																<c:otherwise><c:out value="${scheduleItem.week}" /></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-center">
														<span>
															<c:out value="${scheduleItem.startDate}" />
														</span>
													</td>
													<td class="small align-middle text-center">
														<span>
															<c:out value="${scheduleItem.endDate}" />
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
																<i class="bi bi-check-circle-fill text-success" title="Activated"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-secondary" title="Deactivated"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit Practice Schedule" onclick="retrieveScheduleInfo('${scheduleItem.id}')">
														</i>
														&nbsp;&nbsp;
														<i class="bi bi-trash text-danger fa-lg" data-toggle="tooltip" title="Delete Practice Schedule" onclick="confirmDelete('${scheduleItem.id}')">
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
					<header class="text-info font-weight-bold">Class Test Schedule</header>
					<form id="scheduleRegister">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-7">
									<label for="addYear" class="label-form">Academic Year</label>
									<select class="form-control" id="addYear" name="addYear">
										<%
											Calendar addNow = Calendar.getInstance();
											int addCurrentYear = addNow.get(Calendar.YEAR);
										%>
										<option value="<%= addCurrentYear %>">Academic Year <%= (addCurrentYear) %>/<%= (addCurrentYear)+1 %></option>
										<%
											// Adding the last three years
											for (int i = addCurrentYear - 1; i >= addCurrentYear - 3; i--) {
										%>
											<option value="<%= i %>">Academic Year <%= i %>/<%= i+1 %></option>
										<%
										}
										%>
									</select>
								</div>
								<!-- <div class="offset-md-1"></div> -->
								<div class="col-md-5">
									<label for="addVolume" class="label-form">Set Schedule</label>
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
										  //option.textContent = i;
										  if (i === 10) {
											option.textContent = 'Volume 1 (' + i + ')';
										  }else if (i === 20) {
											option.textContent = 'Volume 2 (' + i + ')';
										  } else if (i === 30) {
											option.textContent = 'Volume 3 (' + i + ')';
										  } else if (i === 40) {
											option.textContent = 'Volume 4 (' + i + ')';
										  } else if ((i === 49) || (i === 50)) {
											option.textContent = 'Volume 5 (' + i + ')';
										  } else {
												option.textContent = i;
										  }
										  // Append the option to the select element
										  selectElement.appendChild(option);
										}
									</script>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-6">
									<label for="addStart" class="label-form">Start Date & Time</label>
									<input type="text" class="form-control" id="addStart" name="addStart" title="Please set Start Date & Time" />
								</div>
								<div class="col-md-6">
									<label for="addEnd" class="label-form">End Date & Time</label>
									<input type="text" class="form-control" id="addEnd" name="addEnd" title="Please set End Date & Time" />
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
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="addScheduleTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 70%;">Test</th>
											<th data-field="grade" style="width: 10%;">Grade</th>
											<th data-field="set" style="width: 10%;">Set</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="form-row">
									<div class="col-md-7">
										<label for="addTestTypeSearch" class="label-form">Test</label>
										<select class="form-control" id="addTestTypeSearch" name="addTestTypeSearch">
										</select>
									</div>
									<div class="col-md-2">
										<label for="addGradeSearch" class="label-form">Grade</label>
										<select class="form-control" id="addGradeSearch" name="addGradeSearch">
										</select>
									</div>
									<div class="col-md-2">
										<label for="addSetSearch" class="label-form">Set</label>
										<select class="form-control" id="addSetSearch" name="addSetSearch">
										</select>
									</div>
									<div class="col-md-1 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addTest('add')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
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
					<header class="text-primary font-weight-bold">Class Test Schedule Edit</header>
					<form id="scheduleEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-7">
									<label for="editYear" class="label-form">Academic Year</label>
									<select class="form-control" id="editYear" name="editYear">
										<%
											Calendar editNow = Calendar.getInstance();
											int editCurrentYear = editNow.get(Calendar.YEAR);
										%>
										<option value="<%= editCurrentYear %>">Academic Year <%= (editCurrentYear) %>/<%= (editCurrentYear)+1 %></option>
										<%
											// Adding the last three years
											for (int i = editCurrentYear - 1; i >= editCurrentYear - 3; i--) {
										%>
											<option value="<%= i %>">Academic Year <%= i %>/<%= i+1 %></option>
										<%
										}
										%>
									</select>
								</div>
								<div class="col-md-5">
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
										//   option.textContent = i;
										  if (i === 10) {
											option.textContent = 'Volume 1 (' + i + ')';
										  }else if (i === 20) {
											option.textContent = 'Volume 2 (' + i + ')';
										  } else if (i === 30) {
											option.textContent = 'Volume 3 (' + i + ')';
										  } else if (i === 40) {
											option.textContent = 'Volume 4 (' + i + ')';
										  } else if ((i === 49) || (i === 50)) {
											option.textContent = 'Volume 5 (' + i + ')';
										  } else {
												option.textContent = i;
										  }
										  // Append the option to the select element
										  selectElement.appendChild(option);
										}
									</script>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-6">
									<label for="editStart" class="label-form">Start Date & Time</label>
									<input type="text" class="form-control" id="editStart" name="editStart" title="Please set Start Date & Time" />
								</div>
								<div class="col-md-6">
									<label for="editEnd" class="label-form">End Date & Time</label>
									<input type="text" class="form-control" id="editEnd" name="editEnd" title="Please set End Date & Time" />
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
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="editScheduleTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 70%;">Practice</th>
											<th data-field="grade" style="width: 10%;">Grade</th>
											<th data-field="set" style="width: 10%;">Set</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="form-row">
									<div class="col-md-7">
										<label for="editTestTypeSearch" class="label-form">Practice</label>
										<select class="form-control" id="editTestTypeSearch" name="editTestTypeSearch">
										</select>
									</div>
									<div class="col-md-2">
										<label for="editGradeSearch" class="label-form">Grade</label>
										<select class="form-control" id="editGradeSearch" name="editGradeSearch">
										</select>
									</div>
									<div class="col-md-2">
										<label for="editSetSearch" class="label-form">Set</label>
										<select class="form-control" id="editSetSearch" name="editSetSearch">
										</select>
									</div>
									<div class="col-md-1 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addTest('edit')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
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
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Class Test Schedule Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Test Schedule ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>
