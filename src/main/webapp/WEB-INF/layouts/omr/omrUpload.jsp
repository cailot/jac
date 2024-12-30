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
       
    #studentResult {
        padding: 20px;
    }
    
    label {
        font-weight: bold;
    }
    .form-check-input {
        margin-top: 5px;
    }
    .btn-primary {
        background-color: #007bff;
        border-color: #007bff;
    }
    .btn-secondary {
        background-color: #6c757d;
        border-color: #6c757d;
    }
    
    .stats {
        margin-top: 20px;
    }

    #hpiiTable {
        width: 100%;
        border-collapse: collapse;
    }

    #hpiiTable th,
    #hpiiTable td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }

    #hpiiTable th {
        background-color: #f2f2f2;
    }

    #hpiiTable tbody tr:nth-child(even) {
        background-color: #f9f9f9;
    }

    #hpiiTable tbody tr:hover {
        background-color: #f2f2f2;
    }

    .ellipsis {
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
    }
    
	
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
    
	
</style>

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
	                <button type="submit" class="upload-button btn btn-primary">Upload</button>
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
			<div class="row m-3 pt-5 justify-content-center">
				<div class="col-md-8 alert alert-success" role="alert">
					<h5>
						<i class="fa fa-check-circle fa-lg"></i>&nbsp;&nbsp;<c:out value="${success}" />
					</h5>
				</div>
			</div>	
				<!-- Redirect to the result page -->
				<!-- <c:choose> 
					<c:when test="${results != null}">
						<c:forEach items="${results}" var="result">
							<c:out value="${result.studentName}" />
						</c:forEach>
					</c:when>
					<c:otherwise>
						Nothing....
					</c:otherwise>
				</c:choose> -->


				<!-- Display OMR Scan Results -->
				
				<c:if test="${not empty results}">
					<div class="row m-3 pt-5 justify-content-center">
						<div class="col-md-12">
							<h4>OMR Scan Results - Number of results: ${fn:length(results)}</h4>
							<div class="row justify-content-center">
								<c:forEach items="${results}" var="result">
									<div class="col-md-10 mb-4">
										<div class="card h-100">
											<div class="card-body">
												<h5 class="card-title text-primary"><c:out value="${result.studentName}" /> (<c:out value="${result.studentId}" />)</h5>
												<h6 class="card-title text-success"><c:out value="${result.testId}" /> ~~~~ <c:out value="${result.testName}" /></h6>
												
												<!-- Add more details if available -->
												<p class="card-text">
													Here we go with the details of the student.
												</p>
											</div>
											<div class="card-footer text-center">
												<button class="btn btn-primary btn-sm" onclick="viewDetails('${result.studentId}')">View Details</button>
											</div>
										</div>
									</div>
								</c:forEach>
							</div>
							<!-- Optional: Next Button if needed -->
							<div class="text-center mt-4">
								<button class="btn btn-success" onclick="proceedNext()">Next</button>
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

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display">
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>
