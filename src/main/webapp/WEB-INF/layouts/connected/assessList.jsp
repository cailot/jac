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
	$('#assessListTable').DataTable({
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

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Assessment
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addAssessment() {
	// Get from form data
	var assessment = {
		subject : $("#addSubject").val(),
		grade: $("#addGrade").val(),
		pdfPath : $("#addPdfPath").val()
	}
	console.log(assessment);

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/assessment/addAssessment',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(assessment),
		contentType: 'application/json',
		success: function (data) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				'New Assessment is registered successfully.');
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
	$('#registerAssessModal').modal('hide');
	// flush all registered data
	document.getElementById("assessRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Assessment
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveAssessInfo(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/assessment/getAssessment/' + id,
		type: 'GET',
		success: function (assessment) {
			//console.log(assessment);
			$("#editId").val(assessment.id);
			$("#editGrade").val(assessment.grade);
			$("#editSubject").val(assessment.subject);
			$("#editPdfPath").val(assessment.pdfPath);	
			$("#editActive").val(assessment.active);
			if (assessment.active == true) {
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
//		Update Assessment
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateAssessInfo() {
	var workId = $("#editId").val();
	// get from formData
	var assessment = {
		id: workId,
		grade: $("#editGrade").val(),
		subject: $("#editSubject").val(),
		pdfPath: $("#editPdfPath").val(),
		active: $("#editActive").val(),
	}

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/assessment/updateAssessment',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(assessment),
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
	clearAssessForm("practiceEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearAssessForm(elementId) {
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
//		Confirm before deleting Practice
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteAssess(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Assessment
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteAssess(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/assessment/delete/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Assessment deleted successfully');
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
//		Display Answer Sheet
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function displayAnswerSheet(assessId) {
	//debugger
	//save testId 
	document.getElementById("assessId4Answer").value = assessId;
	// clear answerId
	document.getElementById("answerId").value = '';

	// check if answer exists or not
	// if exists, then display info
	// if not, show empty form to register
	$.ajax({
		url: '${pageContext.request.contextPath}/assessment/checkAssessAnswer/' + assessId,
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
			$('#registerAssessAnswerModal').modal('show');
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
	var assessId = document.getElementById("assessId4Answer").value;

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
        url: '${pageContext.request.contextPath}/assessment/saveAssessAnswer', // Replace with your actual Spring controller endpoint
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
			answerId : answerId,
			assessId : assessId,
			answers : answerList
		}),
        success: function (response) {
            // Handle success response
            console.log(response);
			// clear practionId to avoid confusion
			document.getElementById("assessId4Answer").value = '';
    		// Optionally, close the modal after submitting
    		$('#registerAssessAnswerModal').modal('hide');
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
		height: 50px 	
	} 

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/assessment/listAssessment">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="0">All</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listSubject" class="label-form">Subject</label>
						<select class="form-control" id="listSubject" name="listSubject">
							<option value="0">All</option>
							<option value="1">English</option>
							<option value="2">Maths</option>
							<option value="3">General Ability</option>
						</select>
					</div>					
					<div class="offset-md-6"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerAssessModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="assessListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th class="text-center align-middle" style="width: 5%">Grade</th>
										<th class="text-center align-middle" style="width: 5%">Subject</th>
										<th class="text-center align-middle" style="width: 30%">Document Path</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 5%">Activated</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${AssessList != null}">
											<c:forEach items="${AssessList}" var="assessment">
												<tr>
													<td class="small align-middle text-center">
														<span>
															<c:choose>
																<c:when test="${assessment.grade == '1'}">P2</c:when>
																<c:when test="${assessment.grade == '2'}">P3</c:when>
																<c:when test="${assessment.grade == '3'}">P4</c:when>
																<c:when test="${assessment.grade == '4'}">P5</c:when>
																<c:when test="${assessment.grade == '5'}">P6</c:when>
																<c:when test="${assessment.grade == '6'}">S7</c:when>
																<c:when test="${assessment.grade == '7'}">S8</c:when>
																<c:when test="${assessment.grade == '8'}">S9</c:when>
																<c:when test="${assessment.grade == '9'}">S10</c:when>
																<c:when test="${assessment.grade == '10'}">S10E</c:when>
																<c:when test="${assessment.grade == '11'}">TT6</c:when>
																<c:when test="${assessment.grade == '12'}">TT8</c:when>
																<c:when test="${assessment.grade == '13'}">TT8E</c:when>
																<c:when test="${assessment.grade == '14'}">SRW4</c:when>
																<c:when test="${assessment.grade == '15'}">SRW5</c:when>
																<c:when test="${assessment.grade == '16'}">SRW6</c:when>
																<c:when test="${assessment.grade == '17'}">SRW7</c:when>
																<c:when test="${assessment.grade == '18'}">SRW8</c:when>
																<c:when test="${assessment.grade == '19'}">JMSS</c:when>
																<c:when test="${assessment.grade == '20'}">VCE</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-center">
														<span>
															<c:choose>
																<c:when test="${assessment.subject == '1'}">English</c:when>
																<c:when test="${assessment.subject == '2'}">Maths</c:when>
																<c:when test="${assessment.subject == '3'}">General Ability</c:when>
																<c:otherwise></c:otherwise>
															</c:choose>
														</span>
													</td>
													<td class="small align-middle text-truncate" style="max-width: 250px;">
														<span>
															<c:out value="${assessment.pdfPath}" />
														</span>
													</td>
													<c:set var="active" value="${assessment.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="align-middle text-center">
																<i class="bi bi-check-circle-fill text-success" title="Activated"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="align-middle text-center">
																<i class="bi bi-check-circle-fill text-secondary" title="Deactivated"></i>
															</td>
														</c:otherwise>
													</c:choose>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveAssessInfo('${assessment.id}')">
														</i>&nbsp;
														<i class="bi bi-paperclip text-success fa-lg hand-cursor" data-toggle="tooltip" title="Answer Sheet" onclick="displayAnswerSheet('${assessment.id}')">
														</i>&nbsp;
														<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete" onclick="confirmDelete('${assessment.id}')">
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
<div class="modal fade" id="registerAssessModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Assessment Registration</header>
					<form id="assessRegister">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-4">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-8">
									<label for="addSubject" class="label-form">Subject</label>
									<select class="form-control" id="addSubject" name="addSubject">
										<option value="1">English</option>
										<option value="2">Maths</option>
										<option value="3">General Ability</option>
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
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addAssessment()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearAssessForm('assessRegister')" data-dismiss="modal">Close</button>
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
					<header class="text-primary font-weight-bold">Assessment Edit</header>
					<form id="practiceEdit">
						<div class="form-group">
							<div class="form-row mt-4">
								<div class="col-md-4">
									<label for="editGrade" class="label-form">Grade</label>
									<select class="form-control" id="editGrade" name="editGrade" disabled>
									</select>
								</div>
								<div class="col-md-8">
									<label for="editSubject" class="label-form">Subject</label>
									<select class="form-control" id="editSubject" name="editSubject" disabled>
										<option value="1">English</option>
										<option value="2">Maths</option>
										<option value="3">General Ability</option>
									</select>
								</div>
							</div>
						</div>
						<div class="form-group mt-4 mb-4">
							<div class="form-row">
								<div class="col-md-8">
									<input type="text" class="form-control" id="editPdfPath" name="editPdfPath" title="Please edit pdf path" />
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
						<button type="submit" class="btn btn-primary" onclick="updateAssessInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Add Answer Form Dialogue -->
<div class="modal fade" id="registerAssessAnswerModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-success">
			<div class="modal-body">
				<section class="fieldset rounded border-success">
					<header class="text-success font-weight-bold">Assessment Answer Sheet</header>
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
							<div class="form-row align-items-center mb-4" style="border: 2px solid #28a745; padding: 10px; border-radius: 10px; margin-left: 10px; margin-right: 10px;">
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
						<input type="hidden" id="assessId4Answer" name="assessId4Answer" />
					<div class="mt-4 d-flex justify-content-end">
						<button type="submit" class="btn btn-success" onclick="collectAndSubmitAnswers()">Save</button>&nbsp;&nbsp;
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

<!--Delete Confirmation Modal -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Assessment Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Assessment ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>