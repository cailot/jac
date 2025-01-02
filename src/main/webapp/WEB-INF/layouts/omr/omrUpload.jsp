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
	// initialise state list when loading
	listState('#state');
	listBranch('#branch');
	listGrade('#grade');
	updateVolumeOptions();

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
	// avoid execute several times
	$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in branch
			if (settings.url === '/code/branch') {
				$("#branch").val(window.branch);
				// Disable #branch and #addBranch
				$("#branch").prop('disabled', true);
				// $("#editBranch").prop('disabled', true);
			}
		});
	}
});


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Volume Options
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateVolumeOptions() {
	// Get the selected practice type text
	var testTypeSelect = document.getElementById("testGroup");
	var testTypeText = testTypeSelect.selectedOptions[0].text;

	// console.log(testTypeText);
	
	// Clear existing options
	var selectElement = document.getElementById("volume");
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
			// Append the option to the select element
			selectElement.appendChild(option);
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	Show uploading file
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateFileName(input) {
    var fileName = input.files[0].name;
    var fileNameContainer = document.getElementById("file-name-container");
    fileNameContainer.innerHTML = "<p>Selected file: " + fileName + "</p>";
}

</script> 

<style>

.upload-section {
	background-color: #f8f9fa;
	border-radius: 10px;
	padding: 20px;
	box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
}

.upload-section h2 {
	color: #007bff;
	margin-bottom: 20px;
}

.csv-image {
	max-width: 100%;
	border-radius: 10px;
	box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
}

.csv-template {
	font-weight: bold;
	color: #6c757d;
}

.download-link i {
	color: #007bff;
	text-decoration: none;
}

.download-link:hove i {
	color: #007bff;
}

.upload-button {
	background-color: #007bff;
	color: #fff;
	border: none;
	border-radius: 5px;
	padding: 10px 20px;
	cursor: pointer;
	transition: background-color 0.3s;
}

.upload-button:hover {
	background-color: #0056b3;
}

.file-input {
	display: none;
}

.upload-label {
	display: block;
	margin-top: 10px;
	color: #6c757d;
}
.upload-section .form-row .input-group {
	width: 100%;
}

.upload-section .form-row .upload-label {
    cursor: pointer;
}

.upload-section .form-row .file-input {
    display: none;
}

.upload-section .form-row {
    width: 100%;
}
    
.modal-dialog {
    display: flex !important;
    align-items: center !important; /* Vertically center modal */
    justify-content: center !important;
    height: 90vh !important; /* 90% of the viewport height */
    width: 80vw !important; /* 80% of the viewport width */
    max-width: 80vw !important; /* Ensure it respects 80% max width */
    margin: 30px auto !important; /* Center it horizontally and vertically */
}

.modal-content {
    height: 100% !important; /* Ensure the content takes the full height of the modal */
    width: 100% !important; /* Stretch content to fill the dialog */
    overflow: hidden !important; /* Prevent content overflow */
}

.modal-body {
    height: calc(100% - 120px) !important; /* Adjust for header and footer height */
    overflow-y: auto !important; /* Enable scrolling for content */
}

.full-fill {
	width: 100%;
	height: 100%;
	object-fit: cover;
}
</style>

<script>
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Edit Answer
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function editAnswer(id) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/connected/getPractice/1', //+ id,
		type: 'GET',
		success: function (answer) {
			// console.log(answer);

			$("#imageContainer").html('<img src="${pageContext.request.contextPath}/pdf/test/temp.jpg" alt="Logo" class="img-fluid full-fill">');
			
			
			// Create an editable table with Bootstrap styling and load it into #answerTable
			var table = `
				<table class="table table-bordered" style="width: 100%;">
					<tbody>
						<tr>
							<td>1</th>
							<td>2</th>
							<td>3</th>
							<td>4</th>
							<td>5</th>
							<td>6</th>
							<td>7</th>
							<td>8</th>
							<td>9</th>
							<td>10</th>
						</tr>
						<tr>
							<td contenteditable="true">A</td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true"></td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
						</tr>
						<tr>
							<td contenteditable="true">11</td>
							<td contenteditable="true">12</td>
							<td contenteditable="true">13</td>
							<td contenteditable="true">14</td>
							<td contenteditable="true">15</td>
							<td contenteditable="true">16</td>
							<td contenteditable="true">17</td>
							<td contenteditable="true">18</td>
							<td contenteditable="true">19</td>
							<td contenteditable="true">20</td>
						</tr>
						<tr>
							<td contenteditable="true">A</td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true"></td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
						</tr>
						<tr>
							<td contenteditable="true">21</td>
							<td contenteditable="true">22</td>
							<td contenteditable="true">23</td>
							<td contenteditable="true">24</td>
							<td contenteditable="true">25</td>
							<td contenteditable="true">26</td>
							<td contenteditable="true">27</td>
							<td contenteditable="true">28</td>
							<td contenteditable="true">29</td>
							<td contenteditable="true">30</td>
						</tr>
						<tr>
							<td contenteditable="true">A</td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true"></td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
						</tr>
						<tr>
							<td contenteditable="true">31</td>
							<td contenteditable="true">32</td>
							<td contenteditable="true">33</td>
							<td contenteditable="true">34</td>
							<td contenteditable="true">35</td>
							<td contenteditable="true">36</td>
							<td contenteditable="true">37</td>
							<td contenteditable="true">38</td>
							<td contenteditable="true">39</td>
							<td contenteditable="true">40</td>
						</tr>
						<tr>
							<td contenteditable="true">A</td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true"></td>
							<td contenteditable="true">B</td>
							<td contenteditable="true">D</td>
							<td contenteditable="true">A</td>
							<td contenteditable="true">C</td>
						</tr>
					</tbody>
				</table>
			`;
			$("#answerTable").html(table);
			
			
			
			
			
			$('#editModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Generate Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function generateTableData(elementId, data) {
    // console.log('Element ID:', elementId);
    // console.log('Data:', data);
    const target = document.getElementById(elementId);
    if (!target) {
        console.error(`Element with ID ${elementId} not found.`);
        return;
    }
    if (!Array.isArray(data) || data.length === 0) {
        target.innerHTML = "<p>No data available</p>";
        return;
    }
    const cols = 10; // Number of columns per row
    let tableHTML = "<table border='1' style='width: 100%; border-collapse: collapse;'>";
    // Generate rows dynamically
    for (let row = 0; row < Math.ceil(data.length / cols); row++) {
        // Add dynamic serial numbers as header for each row
        tableHTML += "<tr>";
        for (let col = 1; col <= cols; col++) {
            const serialNumber = row * cols + col;
            if (serialNumber <= data.length) {
                tableHTML += `<th style="background-color: #f0f0f0; color: #333; padding: 8px; text-align: center;">`+serialNumber+`</th>`;
            }
        }
        tableHTML += "</tr>";
        // Add data cells for the row
        tableHTML += "<tr>";
        for (let col = 1; col <= cols; col++) {
            const index = row * cols + (col - 1);
            if (index < data.length) {
                tableHTML += `<td style="padding: 8px; text-align: center;">`+data[index]+`</td>`;
            } else {
                tableHTML += `<td style="padding: 8px; text-align: center;"></td>`;
            }
        }
        tableHTML += "</tr>";
    }
    tableHTML += "</table>";
    // console.log('Generated Table HTML:', tableHTML);
    target.innerHTML = tableHTML;
    // console.log('Table rendered successfully!');
}


</script>

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display">
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Main page -->
<div style="width: 85%; margin:0 auto;">
	<!-- Search section -->
	<div class="row m-3 pt-5 justify-content-center">
		<div class="upload-section col-md-8">
	    <h2 class="text-center">Upload Scanned OMR Image</h2>
	    <form method="post" action="${pageContext.request.contextPath}/omr/upload" enctype="multipart/form-data">
	    	<div class="form-row p-4">
				<div class="col-md-3">
					<label for="state" class="label-form">State</label> 
					<select class="form-control" id="state" disabled>
					</select>
					<!-- hidden input to pass the value of disabled state -->
					 <input type="hidden" name="state" value="1">
				</div>
				<div class="col-md-3">
					<label for="branch" class="label-form">Branch</label> 
					<select class="form-control" id="branch" name="branch">
					</select>
				</div>
				<div class="col-md-3">
					<label for="testGroup" class="label-form">Test</label>
					<select class="form-control" id="testGroup" name="testGroup" onchange="updateVolumeOptions()">
						<option value="1">Mega Test</option>
						<option value="2">Revision Test</option>
						<option value="3">Edu Test</option>
						<option value="4">Acer Test</option>
						<option value="5">Mock Test</option>
					</select>
				</div>
				<div class="col-md-1">
					<label for="grade" class="label-form">Grade</label>
					<select class="form-control" id="grade" name="grade">
					</select>
				</div>
				<div class="col-md-2">
					<label for="volume" class="label-form">Set</label>
					<select class="form-control" id="volume" name="volume">
					</select>
				</div>
	        </div>
			<div class="form-row p-4">
	            <div class="col-md-8">
	                <!-- Include CSRF token -->
	                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	                <div class="input-group">
	                    <input type="file" name="file" class="file-input form-control" id="file-input" onchange="updateFileName(this)">
	                    <label for="file-input" class="upload-label input-group-text">Choose File</label>
	                </div>
	                <div id="file-name-container"></div>
	            </div>
	            <div class="col-md-4 text-right">
	                <button type="submit" id="file-upload" class="upload-button btn btn-primary">Upload</button>
	            </div>
	        </div>
	    </form>
		</div>
	</div>










	<!-- Result/Error display -->
	<c:choose>
		<c:when test="${error != null}">
			<!-- Handle errors -->
			<div class="row m-3 pt-5 justify-content-center">
				<div class="col-md-8 alert alert-danger" role="alert">
					<h5>
						<i class="fa fa-times-circle fa-lg"></i>&nbsp;&nbsp;<c:out value="${error}" />
					</h5>
				</div>
			</div>
		</c:when>
		<c:when test="${success != null}">
			<!-- Handle success -->
			<script>
				// float success alert 
				$('#success-alert .modal-body').html('<c:out value="${success}" />');
				$('#success-alert').modal('show');
				// disable selection criteria - branch, testGroup, grade, volume dropdown list & upload button
				$('#branch, #testGroup, #grade, #volume, #file-input, #file-upload').prop('disabled', true);       
			</script>
				<!-- Display OMR Scan Results -->
				<c:if test="${not empty results}">
					<div class="row m-3 pt-5 justify-content-center">
						<div class="col-md-12">
							<c:if test="${not empty meta}">
								<h4>
									<script type="text/javascript">
										document.write(
											branchName('${meta.branch}') + ' '  + 
											testGroupName('${meta.testGroup}') + ' ' + 
											gradeName('${meta.grade}') + ' ');
									</script>
									Set : 
									<c:choose>
										<c:when test="${meta.testGroup=='1' || meta.testGroup=='2'}">
											<c:choose>
												<c:when test="${meta.volume == '1'}">Vol.1</c:when>
												<c:when test="${meta.volume == '2'}">Vol.2</c:when>
												<c:when test="${meta.volume == '3'}">Vol.3</c:when>
												<c:when test="${meta.volume == '4'}">Vol.4</c:when>
												<c:when test="${meta.volume == '5'}">Vol.5</c:when>
												<c:otherwise></c:otherwise>
											</c:choose>
										</c:when>
										<c:otherwise>
											<c:out value="${meta.volume}" />
										</c:otherwise>
									</c:choose>
									
									- Number of results: ${fn:length(results)}</h4>
							</c:if>
							<div class="row justify-content-center">
								<c:forEach items="${results}" var="result" varStatus="status">
									<!-- Answer Sheet Card Section-->
									<div class="col-md-10 mb-4">
										<div class="card h-100">
											<div class="card-body">
												<div class="row">
													<div class="col-2 d-flex flex-column align-items-center justify-content-center" style="gap: 15px;">
														<div><c:out value="${result.studentId}" /> </div>
														<div><c:out value="${result.studentName}" /> </div>
														<div>
															<h3><i class="bi bi-file-earmark-text text-primary" data-toggle="tooltip" title="Edit Student Answer" onclick="editAnswer('${result.studentId}')"></i>
															</h3>	
														</div>		
													</div>
													<div class="col-10" id="resultTable${status.index}">
														<!-- generate table with result -->	
														<script>
															// eslint-disable-next-line-string
															const resultData${status.index} = JSON.parse('${result.answers}');
															generateTableData('resultTable${status.index}', resultData${status.index});
														</script>
													</div>

												</div>
											</div>
										</div>
									</div>
								</c:forEach>
							</div>
							<!-- Optional: Next Button if needed -->
							<div class="text-center mt-4">
								<button class="btn btn-success" onclick="proceedNext()">Confirm to Save</button>
							</div>
						</div>
					</div>
				</c:if>


			<!-- </div> -->
		</c:when>
		<c:otherwise>
			<!-- Other content -->
		</c:otherwise>
	</c:choose>
</div>


<!-- Pop up Edit modal -->
<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="editModalLabel" aria-hidden="true"  data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog modal-extra-large" role="document">
        <div class="modal-content" style="height: 90vh;">
            <div class="modal-header bg-primary text-white text-center">
                <h5 class="modal-title w-100" id="editModalLabel">Student Answer Edit Dialog</h5>
                <button type="button" class="close position-absolute" style="right: 1rem;" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
			<div class="modal-body bg-light" style="display: flex; flex-direction: column; height: 100%;">
				<!-- 70% Height Section -->
				<div class="row" style="flex: 7;">
					<div class="col-12 bg-white p-1 border">
						<div id="imageContainer">
						</div>
					</div>
				</div>
				<!-- 30% Height Section -->
				<div class="row" style="flex: 3;">
					<div class="col-12 bg-white p-1 border">
						<div id="answerTable">	
						</div>
					</div>
				</div>
			</div>
            <div class="modal-footer bg-dark text-white">
				<button type="submit" class="btn btn-primary" onclick="updateStudentAnswer()">Update</button>&nbsp;&nbsp;
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>


