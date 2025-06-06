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
			// $("#listSet").val(academicWeek);

		},
		error: function(jqXHR, textStatus, errorThrown) {
			console.log('Error : ' + errorThrown);
		}
	});

	$("#addResultDate").datepicker({
        dateFormat: 'dd/mm/yy',
        autoclose: true,
        todayHighlight: true
    }).datepicker("setDate", new Date()); // Set the default date format

	$("#editResultDate").datepicker({
        dateFormat: 'dd/mm/yy',
        autoclose: true,
        todayHighlight: true
    }).datepicker("setDate", new Date()); // Set the default date format

	// Add event listener to the icon
	 $('#adddatepicker .input-group-text').on('click', function () {
        $('#addResultDate').datepicker('show');
    });
	$('#editdatepicker .input-group-text').on('click', function () {
        $('#editResultDate').datepicker('show');
    });

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Test into Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addTest(action) {
	// Check if table already has a row
	var table = document.getElementById(action + "ScheduleTable");
	if (table.getElementsByTagName('tbody')[0].getElementsByTagName('tr').length > 0) {
		$('#validation-alert .modal-body').text('Only one test can be added at a time.');
		$('#validation-alert').modal('show');
		return;
	}

	// Get the values from the select elements
	var testTypeSelect = document.getElementById(action + "TestType");
	var testTypeGroup = testTypeSelect.options[testTypeSelect.selectedIndex].value;
	var testTypeName = testTypeSelect.options[testTypeSelect.selectedIndex].text;

	var setSelect = document.getElementById(action + "Volume");
	var set = setSelect.options[setSelect.selectedIndex].text;
	var testTypeWeek = document.getElementById(action + "Volume").value;

	// Create a new row
	var row = $("<tr>");

	// Create the cells for the row
	var cell1 = $("<td>").text(testTypeName);
	var cell2 = $("<td>").text(set);

	// cell3
	var binIcon = $('<i class="bi bi-trash h5"></i>');
	var binIconLink = $("<a>")
		.attr("href", "javascript:void(0)")
		.attr("title", "Delete Test")
		.click(function () {
			row.remove();
			// Recheck for Mega Test after deletion
			let stillHasMega = false;
			$("#" + action + "ScheduleTable tbody tr").each(function () {
				const testName = $(this).find("td").eq(0).text().trim();
				if ((testName.startsWith("Mega"))||(testName.startsWith("Revision"))) {
					stillHasMega = true;
				}
			});
			// Show or hide Explanation Schedule
			if (stillHasMega) {
				$("#" + action + "ExplanationSchedule").show();
			} else {
				$("#" + action + "ExplanationSchedule").hide();
			}
		});
	binIconLink.append(binIcon);
	var cell3 = $("<td>").addClass('text-center').append(binIconLink);

	// hidden td for testTypeWeek
	var hidden1 = $("<td>").css("display", "none").addClass("testTypeWeek").text(testTypeWeek);
	var hidden2 = $("<td>").css("display", "none").addClass("testTypeGroup").text(testTypeGroup);

	// Append cells to the row
	row.append(cell1, cell2, cell3, hidden1, hidden2);

	// Append the row to the table
	$("#"+ action +"ScheduleTable").append(row);

	// === SHOW or HIDE Explanation Schedule ===
	let hasMegaTest = false;
	$("#" + action + "ScheduleTable tbody tr").each(function () {
		const testName = $(this).find("td").eq(0).text().trim();
		if ((testName.startsWith("Mega"))||(testName.startsWith("Revision"))||(testName.startsWith("Mock"))) {
			hasMegaTest = true;
		}
	});

	if (hasMegaTest) {
		$("#" + action + "ExplanationSchedule").show();
	} else {
		$("#" + action + "ExplanationSchedule").hide();
	}	
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Test Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function registerSchedule() {
	// check if addResultDate is choosen
	if($('#addResultDate').val() == ''){
		$('#validation-alert .modal-body').text(
		'Please select schedule date');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			$('#addResultDate').focus();
		});
		return false;
	}
	//var selectedGrade = $('#addGradeRadio').val();
	// Get testTypeGroup & set form addScheduleTable
	var testGroup = '';
	var week = '';
	$('#addScheduleTable tr').each(function () {
		var group = $(this).find('.testTypeGroup').text();
		var testSet = $(this).find('.testTypeWeek').text();
		console.log(group + ' set : ' + testSet);
		if (group != '') {
			//practiceDtos.push({group : testGroup, week : testSet});
			testGroup = group; // Just take the first/last group
			week = testSet; // Just take the first/last week
		}
	});

	var schedule = {
		from: $("#addFrom").val(),
		to: $("#addTo").val(),
		explanationFrom: $("#addExplanationFrom").val(),
		explanationTo: $("#addExplanationTo").val(),
		resultDate: $("#addResultDate").val(),
		info: $("#addInfo").val(),
		// grade : $('#addGradeRadio').val(),
		grade: $('#addGradeRadio input[name="grades"]:checked').val(),
		testGroup: testGroup,
		week: week
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
			console.log(scheduleItem);
			$("#editId").val(scheduleItem.id);
			// Convert 'from' and 'to' to the format expected by datetime-local input
			var fromDateTime = convertToDateTimeLocal(scheduleItem.from);
            var toDateTime = convertToDateTimeLocal(scheduleItem.to);
			$("#editFrom").val(fromDateTime);
			$("#editTo").val(toDateTime);
			$("#editInfo").val(scheduleItem.info);
			$("#editResultDate").val(scheduleItem.resultDate);

			if(scheduleItem.explanationFrom != null && scheduleItem.explanationTo != null){
				$("#editExplanationFrom").val(convertToDateTimeLocal(scheduleItem.explanationFrom));
				$("#editExplanationTo").val(convertToDateTimeLocal(scheduleItem.explanationTo));
				$("#editExplanationSchedule").show();
			}else{
				$("#editExplanationSchedule").hide();
			}


			$("#editActive").val(scheduleItem.active);
			if (scheduleItem.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			// Uncheck all radio buttons first
			$('#editGradeRadio input[type="radio"]').prop('checked', false);
			// Check the radio button that matches the scheduleItem.grade value
			$('#editGradeRadio input[type="radio"][value="' + scheduleItem.grade + '"]').prop('checked', true);
			// add rows to the table
			// clear all rows on editScheduleTable
			$("#editScheduleTable").find("tr:gt(0)").remove();
			// Handle testGroup as String[]
			var testGroups = [];
			if (typeof scheduleItem.testGroup === 'string' && scheduleItem.testGroup) {
				testGroups = scheduleItem.testGroup.split(',').map(function(item) {
					return item.trim();
				});
			} else if (Array.isArray(scheduleItem.testGroup)) {
				if (scheduleItem.testGroup.length === 1 && scheduleItem.testGroup[0] === '') {
					testGroups = [];
				} else {
					testGroups = scheduleItem.testGroup;
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

			// add rows to the table for testGroup and week
			for (var i = 0; i < weeks.length; i++) {
				// Get the values from the select elements
				var testTypeGroup = testGroups[i];
				var testTypeWeek = weeks[i];
				// Get a reference to the table
				var table = document.getElementById("editScheduleTable");
				// Create a new row
				var row = $("<tr>");
				// Create the cells for the row
				var cell1 = $("<td>").text(testGroupName(testTypeGroup));
				// var cell2 = $("<td>").text(testTypeWeek);
				var cell2Text = '';
				if(testTypeGroup == 1 || testTypeGroup == 2){
					switch (testTypeWeek) {
						case '1':
							cell2Text = 'Vol 1';
							break;
						case '2':
							cell2Text = 'Vol 2';
							break;
						case '3':
							cell2Text = 'Vol 3';
							break;
						case '4':
							cell2Text = 'Vol 4';
							break;
						case '5':
							cell2Text = 'Vol 5';
							break;
						default:
							cell2Text = testTypeWeek;
							break;
					}
				}else{
					cell2Text = testTypeWeek;
				}
				var cell2 = $("<td>").text(cell2Text);	

				// cell3
				var binIcon = $('<i class="bi bi-trash h5"></i>');
				var binIconLink = $("<a>")
					.attr("href", "javascript:void(0)")
					.attr("title", "Delete Test")
					.click((function(row) {
						return function() {
							row.remove();
						};
					})(row));
				binIconLink.append(binIcon);
				var cell3 = $("<td>").addClass('text-center').append(binIconLink);

				var hidden1 = $("<td>").css("display", "none").addClass("testTypeWeek").text(testTypeWeek);
				var hidden2 = $("<td>").css("display", "none").addClass("testTypeGroup").text(testTypeGroup);

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
//		Update Test Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateScheduleInfo() {
	// Get testTypeGroup & set form editScheduleTable
	var testGroup = '';
	var week = '';
	$('#editScheduleTable tr').each(function () {
		var group = $(this).find('.testTypeGroup').text();
		var testSet = $(this).find('.testTypeWeek').text();
		// console.log(testGroup + ' set : ' + testSet);
		if (group != '') {
			//practiceDtos.push({group : testGroup, week : testSet});
			testGroup = group; // Just take the first/last group
			week = testSet; // Just take the first/last week
		}
	});
	var schedule = {
		id: $("#editId").val(),
		from: $("#editFrom").val(),
		explanationFrom: $("#editExplanationFrom").val(),
		explanationTo: $("#editExplanationTo").val(),
		to: $("#editTo").val(),
		info: $("#editInfo").val(),
		active: $("#editActive").val(),
		resultDate: $("#editResultDate").val(),
		grade: $('#editGradeRadio input[name="grades"]:checked').val(), // Get the selected grade
		testGroup: testGroup,
		week: week
	}
	console.log(schedule);
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updateTestSchedule',
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
//		Confirm before deleting TestSchedule
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(practiceId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').off('click').on('click', function() {
        deleteTestSchedule(practiceId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete PracticeSchedule
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Volume Options
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateVolumeOptions(action) {
	// Get the selected practice type text
	var testTypeSelect = document.getElementById(action + "TestType");
	var testTypeText = testTypeSelect.selectedOptions[0].text;

	// console.log(testTypeText);
	
	// Clear existing options
	var selectElement = document.getElementById(action + "Volume");
	selectElement.innerHTML = '';

	// Check if the practice type starts with "Mega" or "Revision"
	if (testTypeText.startsWith("Mega") || testTypeText.startsWith("Revision")) {
		// Loop to add options "Vol.1", "Vol.2", etc.
		for (var i = 1; i <= 5; i++) {
			// Create a new option element
			var option = document.createElement("option");
			// Set the value and text content for the option
			option.value = i;
			option.textContent = "Vol " + i;
			// Append the option to the select element
			selectElement.appendChild(option);
		}
	} else {
		// Loop to add options 1, 2, etc.
		for (var i = 1; i <= 40; i++) {
			// Create a new option element
			var option = document.createElement("option");
			// Set the value and text content for the option
			option.value = i;
			option.textContent = i;
			if(option.value == 36){
				option.textContent = "SIM 1";
			}else if(option.value == 37){
				option.textContent = "SIM 2";
			}else if(option.value == 38){
				option.textContent = "SIM 3";
			}else if(option.value == 39){
				option.textContent = "SIM 4";
			}else if(option.value == 40){
				option.textContent = "SIM 5";
			}
			// Append the option to the select element
			selectElement.appendChild(option);
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before processing Test reuslt
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmProcessResult(scheduleId) {
	// Get test stats by branch
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getTestBranchStat/' + scheduleId,
		type: 'GET',
		success: function (data) {
			$('#branchStats').empty();
			var tableData = $("<table class='table table-striped table-bordered col-md-10'>");
			tableData.append('<thead class="table-primary text-center"><tr><th>Branch</th><th>Count</th><th>Branch</th><th>Count</th></tr></thead>');
			tableData.append('<tbody>');
			var totalCount = 0;
			for (var i = 0; i < data.length; i += 2) {
				var row = $("<tr>");
				// First column set
				var branch1 = data[i];
				var branch1Name = branchName(branch1.branch + '');
				row.append($('<td class="nowrap-cell">').text(branch1Name));
				row.append($('<td class="text-center">').text(branch1.count));
				totalCount += branch1.count;

				// Second column set (check if exists)
				if (i + 1 < data.length) {
					var branch2 = data[i + 1];
					var branch2Name = branchName(branch2.branch + '');
					row.append($('<td class="nowrap-cell">').text(branch2Name));
					row.append($('<td class="text-center">').text(branch2.count));
					totalCount += branch2.count;
				} else {
					// Fill empty cells if odd number of branches
					row.append('<td></td><td></td>');
				}

				tableData.append(row);
			}

			// Append Total Row
			var totalRow = $("<tr class='table-primary'>");
			totalRow.append('<td colspan="3" class="text-right"><strong>Total</strong></td>');
			totalRow.append($('<td class="text-center">').html('<strong>' + totalCount + '</strong>'));
			tableData.append(totalRow);

			tableData.append('</tbody></table>');
			$('#branchStats').append(tableData);
		},
		error: function (error) {
			console.error(error);
		}
	});

    // Show the warning modal
    $('#processResultModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#processConfirmation').off('click').on('click', function() {
		processTestResult(scheduleId);
		$('#processResultModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Process Test Result
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function processTestResult(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/processTestResult/' + id,
		type: 'PUT',
		success: function (result) {
			$('#success-alert .modal-body').text(result);
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

	.radio-container {
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
						<label for="listTestType" class="label-form">Test Type</label>
						<select class="form-control" id="listTestType" name="listTestType">
							<option value="0">All</option>
							<option value="1">Mega Test</option>
							<option value="2">Revision Test</option>
							<option value="3">Edu Test</option>
							<option value="4">Acer Test</option>
							<option value="5">Mock Test</option>
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
										<th class="text-center align-middle" data-orderable="false" style="width: 14%">Start</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 14%">End</th>
										<th class="text-center align-middle" style="width: 15%">Test Type</th>
										<th class="text-center align-middle" style="width: 4.5%">Grade</th>
										<th class="text-center align-middle" style="width: 8.5%">Week</th>
										<th class="text-center align-middle" style="width: 18%">Information</th>
										<th class="text-center align-middle" style="width: 12%">Online Schedule</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 4%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${TestScheduleList != null}">
											<c:forEach items="${TestScheduleList}" var="scheduleItem">
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
															<!-- <c:out value="${scheduleItem.testGroup}" /> -->
															<script type="text/javascript">
																document.write(testGroupName('${scheduleItem.testGroup}'));
															</script>
														</span>
													</td>
													<td class="small align-middle text-center">
														<span>
															<script type="text/javascript">
																document.write(gradeName('${scheduleItem.grade}'));
															</script>
														</span>
													</td>
													<td class="small align-middle text-center">
														<span>
															<!-- Display Weeks for Each Group -->
															<c:choose>
																<c:when test="${scheduleItem.testGroup == '1' || scheduleItem.testGroup == '2'}">
																	<c:choose>
																		<c:when test="${scheduleItem.week == '1'}">Vol 1</c:when>
																		<c:when test="${scheduleItem.week == '2'}">Vol 2</c:when>
																		<c:when test="${scheduleItem.week == '3'}">Vol 3</c:when>
																		<c:when test="${scheduleItem.week == '4'}">Vol 4</c:when>
																		<c:when test="${scheduleItem.week == '5'}">Vol 5</c:when>
																		<c:otherwise><c:out value="${scheduleItem.week}" /></c:otherwise>
																	</c:choose>
																</c:when>
																<c:otherwise>
																	<c:choose>
																		<c:when test="${scheduleItem.week == '36'}">SIM 1</c:when>
																		<c:when test="${scheduleItem.week == '37'}">SIM 2</c:when>
																		<c:when test="${scheduleItem.week == '38'}">SIM 3</c:when>
																		<c:when test="${scheduleItem.week == '39'}">SIM 4</c:when>
																		<c:when test="${scheduleItem.week == '40'}">SIM 5</c:when>
																		<c:otherwise><c:out value="${scheduleItem.week}" /></c:otherwise>
																	</c:choose>
																</c:otherwise>
															</c:choose>
														</span>
													</td>													
													<td class="small align-middle text-truncate" style="min-width: 300px;">
														<span>
															<c:out value="${scheduleItem.info}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${scheduleItem.resultDate}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit Test Schedule" onclick="retrieveScheduleInfo('${scheduleItem.id}')">
														</i>
														&nbsp;&nbsp;
														<i class="bi bi-check2-square text-info fa-lg hand-cursor" data-toggle="tooltip" title="" onclick="confirmProcessResult('${scheduleItem.id}')" data-original-title="Schedule Test Result Process">
														</i>
														&nbsp;&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete Test Schedule" onclick="confirmDelete('${scheduleItem.id}')">
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
					<header class="text-info font-weight-bold">Test Schedule Registration</header>
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
										<label for="addGrade" class="label-form h6 badge badge-success text-white">Grade</label>
										<div id="addGrade" name="addGrade">
											<!-- First Row -->
											<div id="addGradeRadio" class="radio-container">
												<div class="form-check">
													<input class="form-check-input" type="radio" value="1" id="addP2" name="grades" checked>
													<label class="form-check-label" for="addP2">P2</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="2" id="addP3" name="grades">
													<label class="form-check-label" for="addP3">P3</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="3" id="addP4" name="grades">
													<label class="form-check-label" for="addP4">P4</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="4" id="addP5" name="grades">
													<label class="form-check-label" for="addP5">P5</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="5" id="addP6" name="grades">
													<label class="form-check-label" for="addP6">P6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="11" id="addTT6" name="grades">
													<label class="form-check-label" for="addTT6">TT6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="12" id="addTT8" name="grades">
													<label class="form-check-label" for="addTT8">TT8</label>
												</div>
											</div>
											<!-- Second Row -->
											<div id="addGradeRadio" class="radio-container">
												<div class="form-check">
													<input class="form-check-input" type="radio" value="6" id="addS7" name="grades">
													<label class="form-check-label" for="addS7">S7</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="7" id="addS8" name="grades">
													<label class="form-check-label" for="addS8">S8</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="8" id="addS9" name="grades">
													<label class="form-check-label" for="addS9">S9</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="9" id="addS10" name="grades">
													<label class="form-check-label" for="addS10">S10</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="19" id="addJMSS" name="grades">
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
										<label class="label-form h6 badge badge-success text-white">Class Test</label>										
									</div>
								</div>
								<div class="form-row">
									<div class="col-md-7">
										<label for="addTestType" class="label-form">Type</label>
										<select class="form-control" id="addTestType" name="addTestType" onchange="updateVolumeOptions('add')">
											<option value="1">Mega Test</option>
											<option value="2">Revision Test</option>
											<option value="3">Edu Test</option>
											<option value="4">Acer Test</option>
											<option value="5">Mock Test</option>
										</select>
									</div>
									<div class="col-md-4">
										<label for="addVolume" class="label-form">Set</label>
										<select class="form-control" id="addVolume" name="addVolume">
										</select>
									</div>
									<div class="col-md-1 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addTest('add')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="addScheduleTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 65%;">Test</th>
											<th data-field="set" style="width: 25%;">Set</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
						<!-- Result Schedule -->
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #007bff; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<label for="addResultDate" class="label-form h6 badge badge-primary text-white">Online Result Schedule</label>
								<div class="form-row">
									<div class="col-md-7">
										<span>The result will be processed</span>
									</div>
									<div class="col-md-5">
										<div class="input-group date" id="adddatepicker">
											<input type="text" class="form-control datepicker" id="addResultDate" name="addResultDate" placeholder="Schedule Date" autocomplete="off" required>
											<div class="input-group-append">
												<span class="input-group-text"><i class="bi bi-calendar"></i></span>
											</div>
										</div>	
									</div>
								</div>
							</div>
						</div>
						<!-- Explanation Schedule -->
						<div id="addExplanationSchedule" class="form-group" style="display: none;">
							<div class="mb-4" style="border: 2px solid #007bff; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<label for="addResultDate" class="label-form h6 badge badge-primary">Explanation Result Schedule</label>
								<div class="form-row">
									<div class="col-md-6">
										<label for="addExplanationFrom" class="label-form">From</label>
										<input type="datetime-local" class="form-control datepicker" id="addExplanationFrom" name="addExplanationFrom" placeholder="From" required>
									</div>
									<div class="col-md-6">
										<label for="addExplanationTo" class="label-form">To</label> 
										<input type="datetime-local" class="form-control datepicker" id="addExplanationTo" name="addExplanationTo" placeholder="To" required>
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
					<header class="text-primary font-weight-bold">Test Schedule Edit</header>
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
										<label for="editGrade" class="label-form h6 badge badge-success text-white">Grade</label>
										<div id="editGrade" name="editGrade">
											<!-- First Row -->
											<div id="editGradeRadio" class="radio-container">
												<div class="form-check">
													<input class="form-check-input" type="radio" value="1" id="editP2" name="grades">
													<label class="form-check-label" for="editP2">P2</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="2" id="editP3" name="grades">
													<label class="form-check-label" for="editP3">P3</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="3" id="editP4" name="grades">
													<label class="form-check-label" for="editP4">P4</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="4" id="editP5" name="grades">
													<label class="form-check-label" for="editP5">P5</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="5" id="editP6" name="grades">
													<label class="form-check-label" for="editP6">P6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="11" id="editTT6" name="grades">
													<label class="form-check-label" for="editTT6">TT6</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="12" id="editTT8" name="grades">
													<label class="form-check-label" for="editTT8">TT8</label>
												</div>
											</div>
											<!-- Second Row -->
											<div id="editGradeRadio" class="radio-container">
												<div class="form-check">
													<input class="form-check-input" type="radio" value="6" id="editS7" name="grades">
													<label class="form-check-label" for="editS7">S7</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="7" id="editS8" name="grades">
													<label class="form-check-label" for="editS8">S8</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="8" id="editS9" name="grades">
													<label class="form-check-label" for="editS9">S9</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="9" id="editS10" name="grades">
													<label class="form-check-label" for="editS10">S10</label>
												</div>
												<div class="form-check">
													<input class="form-check-input" type="radio" value="19" id="editJMSS" name="grades">
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
										<label class="label-form h6 badge badge-success text-white">Class Test</label>										
									</div>
								</div>
								<div class="form-row">
									<div class="col-md-7">
										<label for="editTestType" class="label-form">Type</label>
										<select class="form-control" id="editTestType" name="editTestType" onchange="updateVolumeOptions('edit')">
											<option value="1">Mega Test</option>
											<option value="2">Revision Test</option>
											<option value="3">Edu Test</option>
											<option value="4">Acer Test</option>
											<option value="5">Mock Test</option>
										</select>
									</div>
									<div class="col-md-4">
										<label for="editVolume" class="label-form">Set</label>
										<select class="form-control" id="editVolume" name="editVolume">
										</select>
									</div>
									<div class="col-md-1 d-flex flex-column justify-content-center">
										<label class="label-form text-white">Add</label>
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addTest('edit')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="editScheduleTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 65%;">Test</th>
											<th data-field="set" style="width: 25%;">Set</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>


						<!-- Result Schedule -->
						<div class="form-group">
							<div class="mb-4" style="border: 2px solid #007bff; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<label for="editResultDate" class="label-form h6 badge badge-primary text-white">Online Result Schedule</label>									
								<div class="form-row">
									<div class="col-md-7">
										<span>The result will be processed</span>
									</div>
									<div class="col-md-5">
										<div class="input-group date" id="editdatepicker">
											<input type="text" class="form-control datepicker" id="editResultDate" name="editResultDate" placeholder="Schedule Date" autocomplete="off" required>
											<div class="input-group-append">
												<span class="input-group-text"><i class="bi bi-calendar"></i></span>
											</div>
										</div>	
									</div>
								</div>
							</div>
						</div>
						<!-- Explanation Schedule -->
						<div id="editExplanationSchedule" class="form-group" style="display: none;">
							<div class="mb-4" style="border: 2px solid #007bff; padding: 15px; border-radius: 10px; margin-left: 8px; margin-right: 8px;">
								<label for="editResultDate" class="label-form h6 badge badge-primary text-white">Explanation Result Schedule</label>
								<div class="form-row">
									<div class="col-md-6">
										<label for="editExplanationFrom" class="label-form">From</label>
										<input type="datetime-local" class="form-control datepicker" id="editExplanationFrom" name="editExplanationFrom" placeholder="From" required>
									</div>
									<div class="col-md-6">
										<label for="editExplanationTo" class="label-form">To</label> 
										<input type="datetime-local" class="form-control datepicker" id="editExplanationTo" name="editExplanationTo" placeholder="To" required>
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
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
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
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Test Schedule Delete</h4>
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

<!--Process Result Modal -->
<div class="modal fade" id="processResultModal" tabindex="-1" role="dialog" aria-labelledby="processResultModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-info">
            <div class="modal-header btn-info">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-play-circle"></i>&nbsp;&nbsp;Schedule Test Result Process</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
				<p> Are you sure to schedule processing Test result?</p>
				<div id="branchStats" class="row mt-2 mb-2 justify-content-center"></div>
                <p>It will perform the follwoing actions at 11:30 p.m. and <b>can't be reverted.</b></p>
				<ol class="text-info font-weight-bold">
					<li>Calculate the average</li>
					<li>Send emails to all students</li>
				</ol>
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-info" id="processConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>
