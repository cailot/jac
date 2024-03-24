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
	$('#testListTable').DataTable({
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
	listTestType('#listTestType');
	listTestType('#addTestType');
	listTestType('#editTestType');

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Test
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addTest() {
	// Get from form data
	var testItem = {
		testType : $("#addTestType").val(),
		grade: $("#addGrade").val(),
		volume: $("#addVolume").val(),
		info : $("#addInfo").val(),
		pdfPath : $("#addPdfPath").val()
	}
	console.log(testItem);

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/addTest',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(testItem),
		contentType: 'application/json',
		success: function (data) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				'New Test is registered successfully.');
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
	$('#registerTestModal').modal('hide');
	// flush all registered data
	document.getElementById("testRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Test
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveTestInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getTest/' + id,
		type: 'GET',
		success: function (testItem) {
			// console.log(homework);
			$("#editId").val(testItem.id);
			$("#editTestType").val(testItem.testType);
			$("#editGrade").val(testItem.grade);
			$("#editVolume").val(testItem.volume);
			$("#editInfo").val(testItem.info);
			$("#editPdfPath").val(testItem.pdfPath);	
			$("#editActive").val(testItem.active);
			if (testItem.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			$('#editTestModal').modal('show');
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
//		Update Test
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateTestInfo() {
	var workId = $("#editId").val();
	// get from formData
	var testItem = {
		id: workId,
		testType : $("#editTestType").val(),
		grade: $("#editGrade").val(),
		volume: $("#editVolume").val(),
		info: $("#editInfo").val(),
		pdfPath: $("#editPdfPath").val(),
		active: $("#editActive").val(),
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/updateTest',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(testItem),
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

	$('#editTestModal').modal('hide');
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
				// $("#addAnswerVideoPath").val(answerSheet.videoPath);
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
    // var answerVideoPath = document.getElementById("addAnswerVideoPath").value;
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
			// videoPath : answerVideoPath,
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
		<form id="classList" method="get" action="${pageContext.request.contextPath}/connected/filterTest">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-3">
						<label for="listTestType" class="label-form">Test Type</label>
						<select class="form-control" id="listTestType" name="listTestType">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
						</select>
					</div>
					<div class="col-md-2">
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
					<div class="offset-md-1"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerTestModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="testListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th>Test Type</th>
										<th>Grade</th>
										<th>Set</th>
										<th>Document Path</th>
										<th>Information</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${TestList != null}">
											<c:forEach items="${TestList}" var="testItem">
												<tr>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${testItem.testType == '1'}">Mega English</c:when>
																<c:when test="${testItem.testType == '2'}">Mega Mathematics</c:when>
																<c:when test="${testItem.testType == '3'}">Mega General Ability</c:when>
																<c:when test="${testItem.testType == '4'}">Revision English</c:when>
																<c:when test="${testItem.testType == '5'}">Revision Mathematics</c:when>
																<c:when test="${testItem.testType == '6'}">Revision Science</c:when>
																<c:when test="${testItem.testType == '7'}">Reeading Comprehension (EDU)</c:when>
																<c:when test="${testItem.testType == '8'}">Verbal Reasoning (EDU)</c:when>
																<c:when test="${testItem.testType == '9'}">Mathematics (EDU)</c:when>
																<c:when test="${testItem.testType == '10'}">Numerical Reasoning (EDU)</c:when>
																<c:when test="${testItem.testType == '11'}">Humanities (ACER)</c:when>
																<c:when test="${testItem.testType == '12'}">Mathematics (ACER)</c:when>
																<c:when test="${testItem.testType == '13'}">Mock Test</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:choose>
																<c:when test="${testItem.grade == '1'}">P2</c:when>
																<c:when test="${testItem.grade == '2'}">P3</c:when>
																<c:when test="${testItem.grade == '3'}">P4</c:when>
																<c:when test="${testItem.grade == '4'}">P5</c:when>
																<c:when test="${testItem.grade == '5'}">P6</c:when>
																<c:when test="${testItem.grade == '6'}">S7</c:when>
																<c:when test="${testItem.grade == '7'}">S8</c:when>
																<c:when test="${testItem.grade == '8'}">S9</c:when>
																<c:when test="${testItem.grade == '9'}">S10</c:when>
																<c:when test="${testItem.grade == '10'}">S10E</c:when>
																<c:when test="${testItem.grade == '11'}">TT6</c:when>
																<c:when test="${testItem.grade == '12'}">TT8</c:when>
																<c:when test="${testItem.grade == '13'}">TT8E</c:when>
																<c:when test="${testItem.grade == '14'}">SRW4</c:when>
																<c:when test="${testItem.grade == '15'}">SRW5</c:when>
																<c:when test="${testItem.grade == '16'}">SRW6</c:when>
																<c:when test="${testItem.grade == '17'}">SRW7</c:when>
																<c:when test="${testItem.grade == '18'}">SRW8</c:when>
																<c:when test="${testItem.grade == '19'}">JMSS</c:when>
																<c:when test="${testItem.grade == '20'}">VCE</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${testItem.volume}" />
														</span>
													</td>
													<td class="small text-truncate" style="max-width: 250px;">
														<span>
															<c:out value="${testItem.pdfPath}" />
														</span>
													</td>
													<td class="small ellipsis">
														<span>
															<c:out value="${testItem.info}" />
														</span>
													</td>
													<c:set var="active" value="${testItem.active}" />
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
														<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveTestInfo('${testItem.id}')">
														</i>&nbsp;&nbsp;
														<i class="bi bi-paperclip text-success fa-lg" data-toggle="tooltip" title="Answer Sheet" onclick="displayAnswerSheet('${testItem.id}')">
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
<div class="modal fade" id="registerTestModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Test Registration</header>
					<form id="testRegister">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-8">
									<label for="addTestType" class="label-form">Test Type</label>
									<select class="form-control" id="addTestType" name="addTestType">
									</select>
								</div>
								<div class="col-md-2">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-2">
									<label for="addVolume" class="label-form">Set</label>
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
									<label for="addInfo" class="label-form">Information</label>
									<input type="text" class="form-control" id="addInfo" name="addInfo" title="Please enter additional information" />
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="addTest()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearPracticeForm('testRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editTestModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Practice Edit</header>
					<form id="practiceEdit">
						<div class="form-group">
							<div class="form-row mt-3">
								<div class="col-md-8">
									<label for="editTestType" class="label-form">Practice Type</label>
									<select class="form-control" id="editTestType" name="editTestType" disabled>
									</select>
								</div>
								<div class="col-md-2">
									<label for="editGrade" class="label-form">Grade</label>
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-2">
									<label for="editVolume" class="label-form">Set</label>
									<select class="form-control" id="editVolume" name="editVolume">
									</select>
									<script>
										// Get a reference to the select element
										var selectElement = document.getElementById("editVolume");
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
									<label for="editPdfPath" class="label-form">Pdf Path</label>
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
						<button type="submit" class="btn btn-primary" onclick="updateTestInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">Close</button>
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
						<!-- <div class="form-group">
							<div class="form-row">
								<div class="col-md-12 mt-4">
									<label for="addAnswerVideoPath" class="label-form">Answer Video Path</label>
									<input type="text" class="form-control" id="addAnswerVideoPath" name="addAnswerVideoPath" placeholder="https://" title="Please enter video access address" />
								</div>
							</div>
						</div> -->
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
						<button type="button" class="btn btn-default btn-secondary" onclick="clearPracticeForm('testRegister')" data-dismiss="modal">Close</button>
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
