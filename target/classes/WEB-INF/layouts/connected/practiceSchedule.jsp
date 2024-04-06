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

	// When the academic year dropdown changes, send an Ajax request to get the corresponding Practice
	$('#addPracticeTypeSearch').change(function () {
		getPracticeByTypeNGrade('add');
	});
	$('#addGradeSearch').change(function () {
		getPracticeByTypeNGrade('add');
	});
	$('#editPracticeTypeSearch').change(function () {
		getPracticeByTypeNGrade('edit');
	});
	$('#editGradeSearch').change(function () {
		getPracticeByTypeNGrade('edit');
	});
		
	// initialise state list when loading
	listGrade('#addGradeSearch');
	listGrade('#editGradeSearch');
	listPracticeType('#addPracticeTypeSearch');
	listPracticeType('#editPracticeTypeSearch');

});


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate Practice by type and grade
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getPracticeByTypeNGrade(action) {
	// debugger;
	var type = $('#'+action+'PracticeTypeSearch').val();
	var grade = $('#'+action+'GradeSearch').val();

	$.ajax({
		url: '${pageContext.request.contextPath}/connected/practice4Schedule/' + type + '/' + grade,
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
	// Get practiceIds form addScheduleTable
	var practiceDtos = [];
	$('#addScheduleTable tr').each(function () {
		var practiceId = $(this).find('.practiceId').text();
		if (practiceId != '') {
			practiceDtos.push({id : practiceId});
		}
	});
	var schedule = {
		year: $("#addYear").val(),
		week: $("#addVolume").val(),
		info: $("#addInfo").val(),
		practices: practiceDtos
	}
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
			console.log(scheduleItem);
			$("#editId").val(scheduleItem.id);
			$("#editYear").val(scheduleItem.year);
			$("#editWeek").val(scheduleItem.week);
			$("#editInfo").val(scheduleItem.info);
			$("#editActive").val(scheduleItem.active);
			if (scheduleItem.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}

			// append Practice Info into table
			var practices = scheduleItem.practices;
			$.each(practices, function (index, value) {
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
					.attr("title", "Delete Practice")
					.click(function () {
						row.remove();
					});
				binIconLink.append(binIcon);
				var cell4 = $("<td>").addClass('text-center').append(binIconLink);

				// hidden td for practiceId
				var td = $("<td>").css("display", "none").addClass("practiceId").text(value.id);

				// Append cells to the row
				row.append(cell1, cell2, cell3, cell4, td);

				// Append the row to the table
				$("#editScheduleTable").append(row);
			});
			// display available set to be ready to select
			getPracticeByTypeNGrade('edit');
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
//		Update Practice Schedule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateScheduleInfo() {
	// get from formData
	var practiceDtos = [];
	$('#editScheduleTable tr').each(function () {
		var practiceId = $(this).find('.practiceId').text();
		if (practiceId != '') {
			practiceDtos.push({id : practiceId});
		}
	});
	var schedule = {
		id: $("#editId").val(),
		year: $("#editYear").val(),
		week: $("#editWeek").val(),
		info: $("#editInfo").val(),
		active: $("#editActive").val(),
		practices: practiceDtos
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updatePracticeSchedule',
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
//		Display Answer Sheet
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function displayAnswerSheet(testId) {
	//save testId 
	document.getElementById("testId4Answer").value = testId;
	// clear answerId
	document.getElementById("answerId").value = '';

	// check if answer exists or not
	// if exists, then display info
	// if not, show empty form to register
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/checkTestAnswer/' + testId,
		type: 'GET',
		success: function (answerSheet) {
			// debugger;
			// console.log(answerSheet);
			if (answerSheet != null && answerSheet != '') {
				// Display the answer sheet info
				$("#answerId").val(answerSheet.id);				
				$("#addAnswerVideoPath").val(answerSheet.videoPath);
				$("#addAnswerPdfPath").val(answerSheet.pdfPath);
				// Display the answer sheet table
				var answerSheetTableBody = document.getElementById("answerSheetTable").getElementsByTagName('tbody')[0];
				answerSheetTableBody.innerHTML = "";
				var numToChar = ['', 'A', 'B', 'C', 'D', 'E'];  // add 0 index = ''
				function createRow(i, answerSheet, numToChar, answerSheetTableBody) {
					// Create a new row
					var newRow = answerSheetTableBody.insertRow(answerSheetTableBody.rows.length);
					// Insert cells into the row
					var cell1 = newRow.insertCell(0);
					var cell2 = newRow.insertCell(1);
					var cell3 = newRow.insertCell(2);
					var cell4 = newRow.insertCell(3);
					// Align the content of the cells to the center
					cell1.style.textAlign = "center";
					cell2.style.textAlign = "center";
					cell3.style.textAlign = "left";
					cell4.style.textAlign = "center";
					// Populate cells with data
					// console.log(answerSheet.answers[i]);
					cell1.innerHTML = answerSheet.answers[i].question;
					cell2.innerHTML = numToChar[answerSheet.answers[i].answer];
					cell3.innerHTML = answerSheet.answers[i].topic;
					// Create a remove button in the third cell
					var removeIcon = document.createElement("i");
					removeIcon.className = "bi bi-trash icon-button text-danger";
					removeIcon.addEventListener('click', function () {
						answerSheetTableBody.removeChild(newRow);
					});
					// Append the remove button to the third cell
					cell4.appendChild(removeIcon);

					// Find the correct position to insert the new row based on the 'question' order
					var newRowQuestion = parseInt(answerSheet.answers[i].question);
					var rows = answerSheetTableBody.getElementsByTagName("tr");
					var insertIndex = 0;
					for (var j = 0; j < rows.length; j++) {
						var rowQuestion = parseInt(rows[j].getElementsByTagName("td")[0].innerHTML);
						if (newRowQuestion < rowQuestion) {
							insertIndex = j;
							break;
						} else {
							insertIndex = j + 1;
						}
					}
					// Insert the new row at the correct position
					if (insertIndex >= rows.length) {
						answerSheetTableBody.appendChild(newRow);
					} else {
						answerSheetTableBody.insertBefore(newRow, rows[insertIndex]);
					}
				}
				for (var i = 0; i < answerSheet.answers.length; i++) {
					createRow(i, answerSheet, numToChar, answerSheetTableBody);
				}
			} else {
				// Display an empty form to register the answer sheet
				// $("#addAnswerVideoPath").val("");
				$("#addAnswerPdfPath").val("");
				var answerSheetTableBody = document.getElementById("answerSheetTable").getElementsByTagName('tbody')[0];
				answerSheetTableBody.innerHTML = "";
				var answerQuestionNumberSelect = document.getElementById("answerQuestionNumber");
				answerQuestionNumberSelect.value = "1";
				var correctAnswerSelect = document.getElementById("correctAnswerOption");
				correctAnswerSelect.value = "1";
				var answerTopicSelect = document.getElementById("answerTopic");
				answerTopicSelect.value = "";
			}
			// Display the modal
			$('#registerTestAnswerModal').modal('show');
		},
		error: function (error) {
            // Handle error response
            console.error(error);
        }
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Answer To Table
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function addAnswerToTable() {
	// Get user selections
	var questionNumber = parseInt(document.getElementById("answerQuestionNumber").value);
	var selectedAnswerOption = document.getElementById("correctAnswerOption").value;
	var answerTopicDescription = document.getElementById("answerTopic").value;
	// Map numeric values to corresponding letters
	var letterMapping = ['A', 'B', 'C', 'D', 'E'];
	var letterValue = letterMapping[parseInt(selectedAnswerOption) - 1];
	// Get the table body
	var tableBody = document.getElementById("answerSheetTable").getElementsByTagName('tbody')[0];
	// Find the correct position to insert the new row
	var position = 0;
	for (; position < tableBody.rows.length; position++) {
		if (parseInt(tableBody.rows[position].cells[0].innerHTML) > questionNumber) {
			break;
		}
	}
	// Create a new row at the correct position
	var newRow = tableBody.insertRow(position);
	// Insert cells into the row
	var cell1 = newRow.insertCell(0);
	var cell2 = newRow.insertCell(1);
	var cell3 = newRow.insertCell(2);
	var cell4 = newRow.insertCell(3);
	// Align the content of the cells to the center
	cell1.style.textAlign = "center";
	cell2.style.textAlign = "center";
	cell3.style.textAlign = "left";
	cell4.style.textAlign = "center";
	// Populate cells with data
	cell1.innerHTML = questionNumber;
	cell2.innerHTML = letterValue;
	cell3.innerHTML = answerTopicDescription;
	// Create a remove button in the third cell
	var removeIcon = document.createElement("i");
	removeIcon.className = "bi bi-trash icon-button text-danger";
	removeIcon.addEventListener('click', function() {
		tableBody.removeChild(newRow);
	});
	// Append the remove button to the third cell
	cell4.appendChild(removeIcon);
	// Automatically choose the next question number
	var nextQuestionNumber = questionNumber + 1;
	document.getElementById("answerQuestionNumber").value = nextQuestionNumber;
	// Clear the topic input value
	document.getElementById("answerTopic").value = "";
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Collect Answer And Send 
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function collectAndSubmitAnswers() {
    // Collect values from the modal
	var answerId = document.getElementById("answerId").value;
	var testId = document.getElementById("testId4Answer").value;
    var answerVideoPath = document.getElementById("addAnswerVideoPath").value;
    var answerPdfPath = document.getElementById("addAnswerPdfPath").value;

    // Collect question number and selected value from the answerSheetTable
    var answerList = [];
    var answerTableBody = document.getElementById("answerSheetTable").getElementsByTagName('tbody')[0];
    var rows = answerTableBody.getElementsByTagName("tr");

	// Create a mapping object
	var charToNum = {
		'A': 1,
		'B': 2,
		'C': 3,
		'D': 4,
		'E': 5
		// Add more mappings if needed
	};

    for (var i = 0; i < rows.length; i++) {
        var cells = rows[i].getElementsByTagName("td");
        var questionNumber = cells[0].innerHTML;
        // var selectedRadioValue = cells[1].innerHTML;
		var selectedRadioValue = charToNum[cells[1].innerHTML];  // Convert the character to a number
		var answerTopic = cells[2].innerHTML;

        answerList.push({
            question: questionNumber,
            answer: selectedRadioValue,
			topic : answerTopic
        });
    }
    // Send the formData to the Spring controller using AJAX or other means
    $.ajax({
        url: '${pageContext.request.contextPath}/connected/saveTestAnswerSheet', // Replace with your actual Spring controller endpoint
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
			answerId : answerId,
			testId : testId,
			videoPath : answerVideoPath,
			pdfPath : answerPdfPath,
			answers : answerList
		}),
        success: function (response) {
            // Handle success response
            console.log(response);
			// clear practionId to avoid confusion
			document.getElementById("testId4Answer").value = '';
    		// Optionally, close the modal after submitting
    		$('#registerTestAnswerModal').modal('hide');
			$('#success-alert .modal-body').html('Answer Sheet is successfully updated.');
	        $('#success-alert').modal('show');
			// Attach an event listener to the success alert close event
			$('#success-alert').on('hidden.bs.modal', function () {
				// Reload the page after the success alert is closed
				location.href = window.location.pathname; // Passing true forces a reload from the server and not from the cache
			});

        },
        error: function (error) {
            // Handle error response
            console.error(error);
        }
    });
}

</script>

<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="scheduleList" method="get" action="${pageContext.request.contextPath}/connected/filterPracticeSchedule">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-4">
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
					<div class="col-md-3">
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
					<!-- <div class="offset-md-1"></div> -->
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerScheduleModal" onclick="getPracticeByTypeNGrade('add')"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th>Academic Year</th>
										<th>Set</th>
										<th>Information</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${PracticeScheduleList != null}">
											<c:forEach items="${PracticeScheduleList}" var="scheduleItem">
												<tr>
													<td class="small ellipsis">
														<span>
															Academic Year <c:out value="${scheduleItem.year}" />/<c:out value="${scheduleItem.year+1}" />
														</span>
													</td>
													<td class="small ellipsis">
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
													<td class="small text-truncate" style="min-width: 300px;">
														<span>
															<c:out value="${scheduleItem.info}" />
														</span>
													</td>
													<c:set var="active" value="${scheduleItem.active}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveScheduleInfo('${scheduleItem.id}')">
														</i>
														<!-- &nbsp;&nbsp;
														<i class="bi bi-paperclip text-success fa-lg" data-toggle="tooltip" title="Answer Sheet" onclick="displayAnswerSheet('${scheduleItem.id}')">
														</i> -->
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
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Practice Schedule</header>
					<form id="scheduleRegister">
						<div class="form-group">
							<div class="form-row mt-3">
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
							<div style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="form-row">
									<div class="col-md-7">
										<label for="addPracticeTypeSearch" class="label-form">Practice</label>
										<select class="form-control" id="addPracticeTypeSearch" name="addPracticeTypeSearch">
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
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addPractice('add')"><i class="bi bi-plus"></i></button>
									</div>
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="registerSchedule()">Create</button>&nbsp;&nbsp;
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
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Practice Schedule Edit</header>
					<form id="scheduleEdit">
						<div class="form-group">
							<div class="form-row mt-3">
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
							<div style="border: 2px solid #28a745; padding: 15px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="form-row">
									<div class="col-md-7">
										<label for="editPracticeTypeSearch" class="label-form">Practice</label>
										<select class="form-control" id="editPracticeTypeSearch" name="editPracticeTypeSearch">
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
										<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="addPractice('edit')"><i class="bi bi-plus"></i></button>
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
