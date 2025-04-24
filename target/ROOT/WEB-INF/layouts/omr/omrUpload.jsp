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

const PDF_PREFIX = 'https://jacstorage.blob.core.windows.net/work/omr/';

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

	// spinner
	$("#uploadForm").on("submit", function () {
        // Show the spinner modal only when the form is submitted
        $("#loadingModal").fadeIn();
        // Disable the submit button to prevent multiple submissions
        $("#file-upload").prop("disabled", true);
    });
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
			if(option.value == 36){
				option.textContent = "SIM 1";
			} else if(option.value == 37){
				option.textContent = "SIM 2";
			} else if(option.value == 38){
				option.textContent = "SIM 3";
			} else if(option.value == 39){
				option.textContent = "SIM 4";
			} else if(option.value == 40){
				option.textContent = "SIM 5";
			} else {
				option.textContent = i;
			}
			//option.textContent = i;
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Edit Answer
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function editAnswer(tableIndex, fileName) {
	// set table index to hidden input
	document.getElementById("tableIndex").value = tableIndex;

	$("#imageContainer").html('<img src="' + PDF_PREFIX + fileName + '" class="img-fluid full-fill">');		
	$("#answerTable").empty();		
			
	// Count how many answer tables are related to this data (e.g., resultData0_0, resultData0_1, ...)
	const tableCount = document.querySelectorAll('[id^="resultTable' + tableIndex + '_"]').length;
	
	// console.log('Table Count:', tableCount);

	// Loop through each table
	for (let i = 0; i < tableCount; i++) {
		const resultTableId = 'resultTable' + tableIndex + '_' + i;
		// console.log('Result Table ID:', resultTableId);
		const resultTable = document.getElementById(resultTableId);
		if (!resultTable) {
			console.warn(`Missing table or data for: ${resultTableId}`);
			continue;
		}
		const cells = resultTable.querySelectorAll('td');
		// Convert NodeList to Array and map to text content
		const cellValues = Array.from(cells).map(cell => cell.textContent.trim());
		// console.log('Cells in ' + i + ':', cellValues);
	
		// Create an editable table with Bootstrap styling and load it into #answerTable
		const cols = 10; // Number of columns per row
		let tableHTML = "<table border='1' style='width: 100%; border-collapse: collapse;'>";
		// Generate rows dynamically
		for (let row = 0; row < Math.ceil(cellValues.length / cols); row++) {
			// Add dynamic serial numbers as header for each row
			tableHTML += "<tr>";
			for (let col = 1; col <= cols; col++) {
				const serialNumber = row * cols + col;
				if (serialNumber <= cellValues.length) {
					tableHTML += `<th style="background-color: #f0f0f0; color: #333; padding: 8px; text-align: center;">`+serialNumber+`</th>`;
				}
			}
			tableHTML += "</tr>";
			// Add data cells for the row
			tableHTML += "<tr>";
			for (let col = 1; col <= cols; col++) {
				const index = row * cols + (col - 1);
				if (index < cellValues.length) {

					if(cellValues[index]===''){ // make backgound color yellow for wrong answers
						tableHTML += `<td contenteditable="true" style="padding: 8px; text-align: center; background-color: yellow;"></td>`;
					} else {
						tableHTML += `<td contenteditable="true" style="padding: 8px; text-align: center;">`+ cellValues[index] +`</td>`;
					}

				} else {
					tableHTML += `<td contenteditable="true" style="padding: 8px; text-align: center;"></td>`;
					console.log('Never happens');
				}
			}
			tableHTML += "</tr>";
		}
		tableHTML += "</table>";

		// if tableCount = 3, div class = col-4; otherwise col-6
		if (tableCount == 3) {
			tableHTML = '<div class="col-4 mb-4">' + tableHTML + '</div>';
		} else {
			tableHTML = '<div class="col-6 mb-4">' + tableHTML + '</div>';
		}
		$("#answerTable").append(tableHTML);
			
	}// end of loop - each table (for example, resultTable0_0, resultTable0_1, ...)
	// Show the modal
	$('#editModal').modal('show');

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Generate Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function generateTableData(elementId, data) {
    //console.log('Element ID:', elementId);
    //console.log('Data:', data);
    const target = document.getElementById('resultTable'+elementId);
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
                tableHTML += `<td style="padding: 8px; text-align: center;">`+ answerName(data[index]) +`</td>`;
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateTestAnswer(){
	//debugger;
	// Get the table element
	const table = document.getElementById("answerTable");
	// Get table index
	const tableIndex = document.getElementById("tableIndex").value;
	// check how many tables are in the answerTable, can you search by table rather than id as table does not have id
	const tableCount = table.getElementsByTagName("table").length;
	// console.log('Table Count:', tableCount);

	for(let i=0; i<tableCount; i++){
		// Get the table element
		const table = document.getElementById("answerTable").getElementsByTagName("table")[i];
		// Get all the rows in the table
		const rows = table.getElementsByTagName("tr");
		const updatedAnswers = [];
		// Define a mapping from letters to numbers
		const letterToNumber = {
			'A': 1,
			'B': 2,
			'C': 3,
			'D': 4,
			'E': 5
			// Extend this mapping if you have more letters
		}
		// Loop through each row (assuming the first row is the header)
		for (let i = 1; i < rows.length; i++) {
			// Get all the cells in the current row
			const cells = rows[i].getElementsByTagName("td");			
			// Loop through each cell in the row
			for (let j = 0; j < cells.length; j++) {
				// Get the content of the cell, trim whitespace, and convert to uppercase
				const content = cells[j].textContent.trim().toUpperCase();
				let value;
				if (content === '' || content === null) {
					// Assign 0 for empty, null, or empty string values
					value = 0;
				} else if (letterToNumber.hasOwnProperty(content)) {
					// Map letters 'A' to 'E' to numbers 1 to 5
					value = letterToNumber[content];
				} else {
					// Handle unexpected values by assigning 0 or any default value
					console.warn('Unexpected value ' + content+ ' found in cell (' + i + ', ' + j + '). Assigning 0.');
					value = 0;
				}
				// Add the numerical value to the updatedAnswers array
				updatedAnswers.push(value);
			}
		}
		console.log('Updated Answers:', updatedAnswers);
		// apply the updated answers to the original data
		generateTableData(tableIndex + '_' + i, updatedAnswers);

	}
	// reset the table index
	document.getElementById("tableIndex").value = '';
	// Hide the modal
	$('#editModal').modal('hide');

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Confirm Proceed Answer Sheets
////////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmProceed() {
    // Show the warning modal
    $('#proceedWarningModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeProceedWarning').off('click').on('click', function() {
        $('#proceedWarningModal').modal('hide');
		proceedNext();
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Proceed Save Data
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function proceedNext() {
    // Get the meta values
    const branch = document.getElementById('metaBranch').textContent.trim();
    const testGroup = document.getElementById('metaTestGroup').textContent.trim();
    const grade = document.getElementById('metaGrade').textContent.trim();
    const volume = document.getElementById('metaVolume').textContent.trim();
    const metaDto = {
        branch: branch,
        testGroup: testGroup,
        grade: grade,
        volume: volume
    };
    // Scan all the table data
    const omrDtos = [];
    const tableGroups = countTablesByGroup();
    // console.log('Table Count:', tableGroups);
    // Iterate through each group (e.g., resultTable0_, resultTable1_, etc.)
    Object.keys(tableGroups).forEach(groupNumber => {
		const tableCount = tableGroups[groupNumber];
		// console.log('Number of tables for resultTable' + groupNumber + '_:', tableCount);
		for (let i = 0; i < tableCount; i++) {
    		const tableId = 'resultTable' + groupNumber + '_' + i;
    		const table = document.getElementById(tableId);
    		if (!table) {
        		console.warn('Table with ID ' + tableId + ' not found.');
        		continue;
    		}
			// Extract data from the table
			const rows = table.getElementsByTagName('tr');
			const answerData = [];
			for (let j = 1; j < rows.length; j++) { // Skip the header row
				const cells = rows[j].getElementsByTagName('td');
				for (let k = 0; k < cells.length; k++) {
					const cell = cells[k];
					if (!cell) {
						console.warn('Cell ('+j+', '+k+') not found in table '+ tableId + '. Skipping.');
						continue;
					}
					const content = cell.textContent.trim().toUpperCase();
					let value;
					if (content === '' || content === null) {
						value = 0; // Empty cells are treated as 0
					} else if (content === 'A') {
						value = 1;
					} else if (content === 'B') {
						value = 2;
					} else if (content === 'C') {
						value = 3;
					} else if (content === 'D') {
						value = 4;
					} else if (content === 'E') {
						value = 5;
					} else {
						console.warn('Unexpected value "' + content + '" found in cell (' + j + ', ' + k + '). Assigning 0.');
						value = 0;
					}
					answerData.push(value);
				}
			}
			// console.log('Extracted Answer Data for Table ' + tableId + ':', answerData);		
            // Create OMR Scan Result DTO
            const omrScanResultDTO = {
                studentId: document.getElementById('studentId'+groupNumber).textContent.trim(),
                testId: document.getElementById('testId'+groupNumber+'_'+i).value,
                answers: answerData
            };
			// Save final result to omrDtos
            omrDtos.push(omrScanResultDTO);
        }
    });

	// Send the data to the server
    $.ajax({
        url: '${pageContext.request.contextPath}/omr/saveResult', // Adjust the URL to match your controller's endpoint
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ metaDto: metaDto, omrDtos: omrDtos }),
		beforeSend: function() {
			// Show the loading modal before sending the request
			$('#loadingModal').fadeIn();
    	},
        success: function(response) {
            console.log('Data successfully sent to the server:', response);
            // Handle success response
            $('#success-alert .modal-body').html(response);
            $('#success-alert').modal('show');
            // Reload the page after the success alert is closed
            $('#success-alert').on('hidden.bs.modal', function () {
                location.href = window.location.pathname; // Reload the page
            });
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error('Error sending data to the server:', textStatus, errorThrown);
            $('#validation-alert .modal-body').html('Failed to save data. Please try again later.');
            $('#validation-alert').modal('show');
        },
		complete: function() {
			// Hide the loading modal after the request is complete
			$('#loadingModal').fadeOut();
    	}
    });

    // console.log('Meta DTO:', metaDto);
    // console.log('OMR DTOs:', omrDtos);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Count Tables by Group (resultTableN_M)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function countTablesByGroup() {
    // Use querySelectorAll to find all elements with IDs starting with 'resultTable'
    const tables = document.querySelectorAll('[id^="resultTable"]');
    const tableGroups = {};
    // Iterate through the matched elements
    tables.forEach(table => {
        const id = table.id;
        const match = id.match(/^resultTable(\d+)_/); // Extract the group number (N) from the ID
        if (match) {
            const groupNumber = match[1]; // Get the group number (N)
            if (!tableGroups[groupNumber]) {
                tableGroups[groupNumber] = 0; // Initialize the count for this group
            }
            tableGroups[groupNumber]++; // Increment the count for this group
        }
    });
	// for example, return { '0': 2, '1': 2, '2': 2 .....} 
    return tableGroups; 
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

.hidden {
	display: none;
}


#loadingModal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        color: white;
        font-size: 18px;
        font-weight: bold;
    }

    .spinner {
        font-size: 50px;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

	
	#file-upload:disabled {
		cursor: not-allowed;
	}

</style>


<!-- Loading Spinner Modal -->
<div id="loadingModal" style="display: none;">
    <div class="spinner-container">
		<img src="${pageContext.request.contextPath}/image/processing.gif" alt="Processing..." class="loading-image">
		<br><br>
        <p>Processing file, please wait...</p>
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

<!-- Main page -->
<div style="width: 85%; margin:0 auto;">
	<!-- Search section -->
	<div class="row m-3 pt-5 justify-content-center">
		<div class="upload-section col-md-8">
	    <h2 class="text-center">Upload Scanned OMR Image</h2>
	    <form id="uploadForm" method="post" action="${pageContext.request.contextPath}/omr/upload" enctype="multipart/form-data">
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
				<div class="col-md-2">
					<label for="testGroup" class="label-form">Test</label>
					<select class="form-control" id="testGroup" name="testGroup" onchange="updateVolumeOptions()">
						<option value="1">Mega Test</option>
						<option value="2">Revision Test</option>
						<option value="3">Edu Test</option>
						<option value="4">Acer Test</option>
						<option value="5">Mock Test</option>
					</select>
				</div>
				<div class="col-md-2">
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
	                    <label for="file-input" class="upload-label input-group-text bg-info text-white" id="upload-label">Choose File</label>
	                </div>
	                <div id="file-name-container"></div>
	            </div>
	            <div class="col-md-4 text-right">
	                <button type="submit" id="file-upload" class="upload-button btn btn-primary"><i class="bi bi-file-earmark-arrow-up"></i>&nbsp;Upload</button>
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
				$('#upload-label').removeClass('bg-info');
				$('#upload-label').removeClass('text-white');
				$('#upload-label').addClass('bg-mute');
				$('#upload-label').addClass('text-secondary');
				$('#upload-label').text('File Uploaded');
				$('#upload-label').css('cursor', 'not-allowed');
				// disable loading spinner
				// $('#loadingModal').hide();      
			</script>
				<!-- Display OMR Scan Results -->
				<c:if test="${not empty results}">
					<div class="row m-3 pt-5 justify-content-center">
						<div class="col-md-12">
							<c:if test="${not empty meta}">
							<div class="mb-5">
								<div class="card shadow border-1 rounded-3 text-center jae-border-primary w-75 mx-auto">
									<div class="card-header text-white bg-primary">
										<h4 class="mb-0">
											<i class="bi bi-filetype-pdf h2 mr-2"></i> Scanned OMR Summary
										</h4>
									</div>
									<div class="card-body">
										<!-- Hidden meta values -->
										<span id="metaBranch" class="d-none">${meta.branch}</span>
										<span id="metaTestGroup" class="d-none">${meta.testGroup}</span>
										<span id="metaGrade" class="d-none">${meta.grade}</span>
										<span id="metaVolume" class="d-none">${meta.volume}</span>
										<!-- Flex container for equal distribution -->
										<div class="d-flex justify-content-around text-center flex-wrap">											
											<div>
												<i class="fas fa-map-marker-alt text-primary"></i> 
												<strong>Branch</strong>
												<p id="branchText" class="text-dark fw-bold">${meta.branch}</p>
												<script>
													document.getElementById("branchText").innerText = branchName("${meta.branch}");
												</script>
											</div>
							
											<div>
												<i class="fas fa-book-open text-success"></i> 
												<strong>Test Group</strong>
												<p id="groupText" class="text-dark fw-bold">${meta.testGroup}</p>
												<script>
													document.getElementById("groupText").innerText = testGroupName("${meta.testGroup}");
												</script>
											</div>
							
											<div>
												<i class="fas fa-graduation-cap text-warning"></i> 
												<strong>Grade</strong>
												<p id="gradeText" class="text-dark fw-bold">${meta.grade}</p>
												<script>
													document.getElementById("gradeText").innerText = gradeName("${meta.grade}");
												</script>
											</div>
											<div>
												<i class="fas fa-layer-group text-info"></i> 
												<strong>Set</strong>
												<p class="text-dark fw-bold">
													<c:choose>
														<c:when test="${meta.testGroup=='1' || meta.testGroup=='2'}">
															<c:choose>
																<c:when test="${meta.volume == '1'}">Vol.1</c:when>
																<c:when test="${meta.volume == '2'}">Vol.2</c:when>
																<c:when test="${meta.volume == '3'}">Vol.3</c:when>
																<c:when test="${meta.volume == '4'}">Vol.4</c:when>
																<c:when test="${meta.volume == '5'}">Vol.5</c:when>
																<c:otherwise>N/A</c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<c:choose>
																<c:when test="${meta.volume == '36'}">SIM 1</c:when>
																<c:when test="${meta.volume == '37'}">SIM 2</c:when>
																<c:when test="${meta.volume == '38'}">SIM 3</c:when>
																<c:when test="${meta.volume == '39'}">SIM 4</c:when>
																<c:when test="${meta.volume == '40'}">SIM 5</c:when>
																<c:otherwise>
																	<c:out value="${meta.volume}" />
																</c:otherwise>
															</c:choose>
														</c:otherwise>
													</c:choose>
												</p>
											</div>
											<div>
												<i class="fas fa-file-alt text-danger"></i> 
												<strong>Number of Answer Sheets</strong>
												<p class="text-dark fw-bold">${fn:length(results)}</p>
											</div>
										</div>
									</div>
								</div>
							</div>
							</c:if>
							<div class="row justify-content-center">
								<c:forEach items="${results}" var="omrSheet" varStatus="status">
									<!-- Answer Omr Sheet Card Section-->
									<!-- Display OmrSheetDTO details -->
									<div class="col-md-12 mb-4">
										<div class="card h-100 shadow border-1 rounded-3">
											<div class="card-body">
												<div class="row">
													<!-- Display Student ID and Name once per OmrSheetDTO -->
													<div class="col-2 d-flex flex-column align-items-center justify-content-center" style="gap: 15px;">
														<div>
															<strong><c:out value="${omrSheet.studentTest[0].testName}" /></strong>
														</div>
														<div>
															<strong>Student ID:</strong>
															<span id="studentId${status.index}">
																<c:out value="${omrSheet.studentTest[0].studentId}" />
															</span>
														</div>
														<div>
															<strong>Name:</strong> <c:out value="${omrSheet.studentTest[0].studentName}" />
														</div>														
														<h3><i class="bi bi-pencil-square text-primary" data-toggle="tooltip" title="Edit Student Answer" onclick="editAnswer(${status.index}, '${omrSheet.studentTest[0].fileName}')"></i></h3>
													</div>
													
													<!-- Display Answer Sheets -->
													<div class="col-10">
														<div class="row">
															<c:forEach items="${omrSheet.studentTest}" var="studentTest" varStatus="testStatus">
																<!-- hide testId -->
																<input type="hidden" id="testId${status.index}_${testStatus.index}" value="${studentTest.testId}" />
																	
																<!-- Dynamically set column width based on studentTest size -->
																<div class='<c:choose><c:when test="${fn:length(omrSheet.studentTest) == 2}">col-md-6</c:when><c:otherwise>col-md-4</c:otherwise></c:choose> mb-4'>
																	<div id="resultTable${status.index}_${testStatus.index}">
																		<!-- Generate table with result -->
																		<script>
																			const resultData${status.index}_${testStatus.index} = JSON.parse("${studentTest.answers}");
																			generateTableData('${status.index}_${testStatus.index}', resultData${status.index}_${testStatus.index});
																		</script>
																	</div>
																</div>
															</c:forEach>
														</div>
													</div>

												</div>
											</div>
										</div>
									</div>



								</c:forEach>
							</div>
							<!-- Optional: Next Button if needed -->
							<div class="text-center mt-4">
								<button class="btn btn-success" onclick="confirmProceed()">Confirm to Save</button>
							</div>
						</div>
					</div>
				</c:if>
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
						<div id="answerTable" class="row">	
						</div>
					</div>
				</div>
			</div>
			<input type="hidden" id="tableIndex" value="">
            <div class="modal-footer bg-dark text-white">
				<button type="submit" class="btn btn-primary" onclick="updateTestAnswer()">Update</button>&nbsp;&nbsp;
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Proceed Warning Modal -->
<div class="modal fade" id="proceedWarningModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content" style="border: 2px solid #ffc107; border-radius: 10px; max-width: 500px; max-height: 400px; overflow-y: auto;">
            <div class="modal-header bg-warning text-center">
                <h6 class="modal-title w-100 font-weight-bold">Finalised Answer Sheets Submission</h6>
            </div>
            <div class="modal-body text-center bg-light p-3">
                <img src="${pageContext.request.contextPath}/image/submit.png" class="mb-3" style="width: 80px; height: 80px;">
                <p class="h6 mb-3">Please review all answers carefully before proceeding.</p>
                <p class="h6">
                    Once stored in the database, the answer sheets <br> <span class="text-danger font-weight-bold text-uppercase">cannot be modified or changed.</span>
                </p>
                <p class="h6 font-weight-bold mt-3">Are you sure you want to continue?</p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-primary btn-sm" id="agreeProceedWarning">Yes, Proceed</button>
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">No, Submit Later</button>
            </div>
        </div>
    </div>
</div>