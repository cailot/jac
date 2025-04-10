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

	/*
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
			// $("#listYear").val(academicYear);
			$("#listVolume").val(academicWeek);

		},
		error: function(jqXHR, textStatus, errorThrown) {
			console.log('Error : ' + errorThrown);
		}
	});
	*/

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
	// console.log(practice);

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
			// $("#editVolume").val(practice.volume);
			updateVolumeOptions('edit');
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
	clearPracticeForm("practiceEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearPracticeForm(elementId) {
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
//		Display Answer Sheet
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function displayAnswerSheet(practiceId) {
	//save practiceId 
	document.getElementById("practiceId4Answer").value = practiceId;
	// clear answerId
	document.getElementById("answerId").value = '';
	// check if answer exists or not
	// if exists, then display info
	// if not, show empty form to register
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/checkPracticeAnswer/' + practiceId,
		type: 'GET',
		success: function (answerSheet) {
			// debugger;
			console.log(answerSheet);
			if (answerSheet != null && answerSheet != '') {
				// Display the answer sheet info
				$("#answerId").val(answerSheet.id);				
				$("#addAnswerVideoPath").val(answerSheet.videoPath);
				$("#addAnswerPdfPath").val(answerSheet.pdfPath);
				$("#addAnswerCount").val(answerSheet.answerCount);

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
					// Align the content of the cells to the center
					cell1.style.textAlign = "center";
					cell2.style.textAlign = "center";
					cell3.style.textAlign = "center";
					// Populate cells with data
					cell1.innerHTML = i;
					cell2.innerHTML = numToChar[answerSheet.answers[i]];
					// Create a remove button in the third cell
					var removeIcon = document.createElement("i");
					removeIcon.className = "bi bi-trash icon-button text-danger";
					removeIcon.addEventListener('click', function () {
						answerSheetTableBody.removeChild(newRow);
					});
					// Append the remove button to the third cell
					cell3.appendChild(removeIcon);
					// Find the correct position to insert the new row based on the 'question' order
					var newRowQuestion = i;
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

				for (var i = 1; i < answerSheet.answers.length; i++) {
					createRow(i, answerSheet, numToChar, answerSheetTableBody);
				}

			} else {
				// Display an empty form to register the answer sheet
				$("#addAnswerVideoPath").val("");
				$("#addAnswerPdfPath").val("");
				var answerSheetTableBody = document.getElementById("answerSheetTable").getElementsByTagName('tbody')[0];
				answerSheetTableBody.innerHTML = "";
				var answerQuestionNumberSelect = document.getElementById("answerQuestionNumber");
				answerQuestionNumberSelect.value = "1";
			}

			// show count of answer
			updateRadioButtons();

			// Display the modal
			$('#registerPracticeAnswerModal').modal('show');
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
	// Get the selected question number
	var questionNumber = parseInt(document.getElementById("answerQuestionNumber").value);
	// Get the selected radio button
	var selectedRadioButton = document.querySelector('input[name="inlineRadioOptions"]:checked');
	// Check if a radio button is selected
	if (selectedRadioButton) {
		// Get the selected radio button value
		var radioButtonValue = selectedRadioButton.value;
		// Map numeric values to corresponding letters
		var letterMapping = ['A', 'B', 'C', 'D', 'E'];
		var letterValue = letterMapping[parseInt(radioButtonValue) - 1];
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
		// Align the content of the cells to the center
		cell1.style.textAlign = "center";
		cell2.style.textAlign = "center";
		cell3.style.textAlign = "center";
		// Populate cells with data
		cell1.innerHTML = questionNumber;
		cell2.innerHTML = letterValue;
		// Create a remove button in the third cell
		var removeIcon = document.createElement("i");
		removeIcon.className = "bi bi-trash icon-button text-danger";
		removeIcon.addEventListener('click', function () {
			tableBody.removeChild(newRow);
		});
		// Append the remove button to the third cell
		cell3.appendChild(removeIcon);
		// Automatically choose the next question number
		var nextQuestionNumber = questionNumber + 1;
		document.getElementById("answerQuestionNumber").value = nextQuestionNumber;
		// Clear the selected radio button
		selectedRadioButton.checked = false;
	} else {
		// Display an alert if no radio button is selected
		alert("Please choose an answer option before adding.");
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Collect Answer And Send 
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function collectAndSubmitAnswers() {
    // Collect values from the modal
	var answerId = document.getElementById("answerId").value;
	var practiceId = document.getElementById("practiceId4Answer").value;
    var answerVideoPath = document.getElementById("addAnswerVideoPath").value;
    var answerPdfPath = document.getElementById("addAnswerPdfPath").value;
	var answerCount = document.getElementById("addAnswerCount").value;

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

        answerList.push({
            question: questionNumber,
            answer: selectedRadioValue
        });
    }

    // Send the formData to the Spring controller using AJAX or other means
    $.ajax({
        url: '${pageContext.request.contextPath}/connected/savePracticeAnswerSheet', // Replace with your actual Spring controller endpoint
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
			answerId : answerId,
			practiceId : practiceId,
			videoPath : answerVideoPath,
			pdfPath : answerPdfPath,
			answerCount : answerCount,
			answers : answerList
		}),
        success: function (response) {
            // Handle success response
            console.log(response);
			// clear practionId to avoid confusion
			document.getElementById("practiceId4Answer").value = '';
    		// Optionally, close the modal after submitting
    		$('#registerPracticeAnswerModal').modal('hide');
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before deleting Practice
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').off('click').on('click', function() {
        deletePractice(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Practice
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deletePractice(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/deletePractice/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Practice deleted successfully');
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

	// console.log(practiceTypeText);
	
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Answer Radio Button Options
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateRadioButtons() {
	// Get the selected count
	var count = document.getElementById("addAnswerCount").value;
	console.log(count);
	// Get a reference to the container for the radio buttons
	var container = document.getElementById("radioButtonsContainer");
	// Clear existing radio buttons
	container.innerHTML = '';

	// Loop to add radio buttons based on the selected count
	for (var i = 1; i <= count; i++) {
		// Create a new radio button input element
		var radioInput = document.createElement("input");
		radioInput.className = "form-check-input";
		radioInput.type = "radio";
		radioInput.name = "inlineRadioOptions";
		radioInput.id = "inlineRadio" + i;
		radioInput.value = i;

		// Create a new label element
		var label = document.createElement("label");
		label.className = "form-check-label";
		label.htmlFor = "inlineRadio" + i;
		label.textContent = String.fromCharCode(64 + i); // Convert number to corresponding letter (A, B, C, ...)

		// Append the radio button and label to the container
		container.appendChild(radioInput);
		container.appendChild(label);
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

	#practiceListTable tr { 
		vertical-align: middle;
		height: 45px 	
	} 

	.form-check-input {
		margin-right: 5px;
	}

	.form-check-label {
		margin-right: 25px;
	}

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/connected/filterPractice">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listPracticeType" class="label-form">Practice Type</label>
						<select class="form-control" id="listPracticeType" name="listPracticeType">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-1">
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
					<div class="offset-md-5"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerPracticeModal" onclick="updateVolumeOptions('add')"><i class="bi bi-plus"></i>&nbsp;New</button>
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
										<th class="text-center align-middle" style="width: 15%">Practice Type</th>
										<th class="text-center align-middle" style="width: 5%">Grade</th>
										<th class="text-center align-middle" style="width: 10%">Set</th>
										<th class="text-center align-middle" style="width: 25%">Document Path</th>
										<th class="text-center align-middle" style="width: 20%">Information</th>
										<th class="text-center align-middle" style="width: 10%">Date</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${PracticeList != null}">
											<c:forEach items="${PracticeList}" var="practice">
												<tr>
													<td class="small align-middle">
														<span>
															<c:choose>
																<c:when test="${practice.practiceType == '1'}">Mega English</c:when>
																<c:when test="${practice.practiceType == '2'}">Mega Mathematics</c:when>
																<c:when test="${practice.practiceType == '3'}">Mega General Ability</c:when>
																<c:when test="${practice.practiceType == '4'}">Revision English</c:when>
																<c:when test="${practice.practiceType == '5'}">Revision Mathematics</c:when>
																<c:when test="${practice.practiceType == '6'}">Revision Science</c:when>
																<c:when test="${practice.practiceType == '7'}">Reeading Comprehension (EDU)</c:when>
																<c:when test="${practice.practiceType == '8'}">Verbal Reasoning (EDU)</c:when>
																<c:when test="${practice.practiceType == '9'}">Mathematics (EDU)</c:when>
																<c:when test="${practice.practiceType == '10'}">Numerical Reasoning (EDU)</c:when>
																<c:when test="${practice.practiceType == '11'}">Humanities (ACER)</c:when>
																<c:when test="${practice.practiceType == '12'}">Mathematics (ACER)</c:when>
																<c:when test="${practice.practiceType == '13'}">NAPLAN Math</c:when>
																<c:when test="${practice.practiceType == '14'}">NAPLAN Reading</c:when>
																<c:when test="${practice.practiceType == '15'}">NAPLAN LC</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-center">
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
													<td class="small align-middle text-center">
														<span>
															<c:choose>
																<c:when test="${fn:startsWith(practice.name, 'Mega') || fn:startsWith(practice.name, 'Revision')}">
																	<c:choose>
																		<c:when test="${practice.volume == '1'}">Vol.1-1</c:when>
																		<c:when test="${practice.volume == '2'}">Vol.1-2</c:when>
																		<c:when test="${practice.volume == '3'}">Vol.2-1</c:when>
																		<c:when test="${practice.volume == '4'}">Vol.2-2</c:when>
																		<c:when test="${practice.volume == '5'}">Vol.3-1</c:when>
																		<c:when test="${practice.volume == '6'}">Vol.3-2</c:when>
																		<c:when test="${practice.volume == '7'}">Vol.4-1</c:when>
																		<c:when test="${practice.volume == '8'}">Vol.4-2</c:when>
																		<c:when test="${practice.volume == '9'}">Vol.5-1</c:when>
																		<c:when test="${practice.volume == '10'}">Vol.5-2</c:when>
																		<c:otherwise></c:otherwise>
																	</c:choose>
																</c:when>
																<c:otherwise>
																	<c:out value="${practice.volume}" />
																</c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-truncate" style="max-width: 250px;">
														<span data-toggle="tooltip" title="${practice.pdfPath}">
															<c:out value="${practice.pdfPath}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${practice.info}" />
														</span>
													</td>
													<td class="small align-middle">
														<span>
															<c:out value="${practice.registerDate}" />
														</span>
													</td>
													<c:set var="active" value="${practice.active}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrievePracticeInfo('${practice.id}')">
														</i>&nbsp;
														<i class="bi bi-paperclip text-success fa-lg hand-cursor" data-toggle="tooltip" title="Answer Sheet" onclick="displayAnswerSheet('${practice.id}')">
														</i>&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete" onclick="confirmDelete('${practice.id}')">
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
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Practice Registration</header>
					<form id="practiceRegister">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-7">
									<label for="addPracticeType" class="label-form">Practice Type</label>
									<select class="form-control" id="addPracticeType" name="addPracticeType" onchange="updateVolumeOptions('add')">
									</select>
								</div>
								<div class="col-md-2">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-3">
									<label for="addVolume" class="label-form">Set</label>
									<select class="form-control" id="addVolume" name="addVolume">
									</select>
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
							<div class="form-row mb-4">
								<div class="col-md-12">
									<label for="addInfo" class="label-form">Information</label>
									<input type="text" class="form-control" id="addInfo" name="addInfo" title="Please enter additional information" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addPractice()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearPracticeForm('practiceRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editPracticeModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Practice Edit</header>
					<form id="practiceEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-7">
									<label for="editPracticeType" class="label-form">Practice Type</label>
									<select class="form-control" id="editPracticeType" name="editPracticeType" disabled>
									</select>
								</div>
								<div class="col-md-2">
									<label for="editGrade" class="label-form">Grade</label>
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-3">
									<label for="editVolume" class="label-form">Set</label>
									<select class="form-control" id="editVolume" name="editVolume">
									</select>
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

<!-- Add Answer Form Dialogue -->
<div class="modal fade" id="registerPracticeAnswerModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-success">
			<div class="modal-body">
				<section class="fieldset rounded border-success">
					<header class="text-success font-weight-bold">Practice Answer Sheet</header>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12 mt-4">
									<label for="addAnswerPdfPath" class="label-form">Answer Document Path</label>
									<input type="text" class="form-control" id="addAnswerPdfPath" name="addAnswerPdfPath" placeholder="https://" title="Please enter document access address" />
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-10">
									<label for="addAnswerVideoPath" class="label-form">Answer Video Path</label>
									<input type="text" class="form-control" id="addAnswerVideoPath" name="addAnswerVideoPath" placeholder="https://" title="Please enter video access address" />
								</div>
								<div class="col-md-2">
									<label for="addAnswerCount" class="label-form">Count</label>
									<select class="form-control" id="addAnswerCount" name="addAnswerCount" onchange="updateRadioButtons()">
										<option value="4">4</option>
										<option value="5">5</option>
									</select>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="answerSheetTable" data-header-style="headerStyle" style="font-size: smaller; width: 60%; margin-left: auto; margin-right: auto;">
        							<thead class="thead-light">
										<tr>
											<th data-field="question">Question #</th>
											<th data-field="answer">Answer</th>
											<th data-field="answer">Remove</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row d-flex align-items-center" style="border: 2px solid #28a745; padding: 10px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
								<div class="col-md-3">
									<select class="form-control" id="answerQuestionNumber" name="answerQuestionNumber">
										<c:forEach var="i" begin="1" end="60">
											<option value="${i}">${i}</option>
										</c:forEach>
									</select>
								</div>
								<div class="col-md-7" style="text-align: right;" id="radioButtonsContainer">
									<!--
									<input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio1" value="1">
									<label class="form-check-label" for="inlineRadio1">A</label>
									<input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio2" value="2">
									<label class="form-check-label" for="inlineRadio2">B</label>
									<input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio3" value="3">
									<label class="form-check-label" for="inlineRadio3">C</label>
									<input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio4" value="4">
									<label class="form-check-label" for="inlineRadio4">D</label>
									<input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio5" value="5">
									<label class="form-check-label" for="inlineRadio5">E</label> -->
								</div>
								<div class="col-md-2">
									<button type="button" class="btn btn-success btn-block" onclick="addAnswerToTable()"> <i class="bi bi-plus"></i></button>
								</div>
						</div>
						<input type="hidden" id="answerId" name="answerId" />
						<input type="hidden" id="practiceId4Answer" name="practiceId4Answer" />
					<!-- </form> -->
					<div class="mt-4 d-flex justify-content-end">
						<button type="submit" class="btn btn-success" onclick="collectAndSubmitAnswers()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearPracticeForm('practiceRegister')" data-dismiss="modal">Close</button>
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

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display jae-border-warning">
			<i class="fa fa-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Error Alert -->
<div id="error-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-danger alert-dialog-display jae-border-danger">
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
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Practice Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Practice ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>