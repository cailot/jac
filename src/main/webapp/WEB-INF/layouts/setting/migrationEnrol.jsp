<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
	// Initialize DataTable for successful imports
	$('#hpiiTable').DataTable({
   	 dom: 'Bfrtip',
	        buttons: [
	            'copyHtml5', 'csvHtml5', 'excelHtml5', 
	            {
		            extend: 'pdfHtml5',
		            download: 'open',
		            pageSize: 'A0',
		            orientation: 'landscape'
		        }
	        ],
	    'lengthChange': false,
	    'order' : [],
	    'scrollX': true,
	    'autoWidth': false,
	    'initComplete': function(settings, json) {
	        // Add custom tooltip behavior
	        $('#hpiiTable td').each(function() {
	            if($(this).text().trim().length > 0) {
	                $(this).attr('title', $(this).text().trim());
	            }
	        });
	    }
	});
	
	// Initialize DataTable for failures with search and pagination
	$('#failureTable').DataTable({
		'pageLength': 25,
		'order': [[1, 'asc']], // Order by line number
		'searching': true,
		'scrollX': true
	});
	
	// Show loading indicator on form submit
	$('#uploadForm').on('submit', function() {
		$('#uploadButton').prop('disabled', true);
		$('#loadingIndicator').show();
		return true;
	});
});

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
/* Update container widths */
.container-wrapper {
    width: 85%;
    margin: 0 auto;
    padding: 20px;
}

.stats {
    width: 100%;
    overflow-x: auto;
    margin: 20px 0;
    background-color: #fff;
    border-radius: 4px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

#hpiiTable {
    table-layout: fixed;
    width: 100% !important;
    margin: 0;
    border-collapse: collapse;
}

/* Style consistency for both sections */
.alert-warning {
    border-radius: 4px;
    margin-top: 20px;
}

/* Ensure consistent spacing */
.row.m-3 {
    margin: 1rem 0 !important;
}

.justify-content-center {
    justify-content: center;
}

/* Update existing table styles */
#studentResult {
    padding: 0;
    width: 100%;
}

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

#hpiiTable th,
#hpiiTable td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 200px;
    position: relative; /* For tooltip positioning */
    cursor: default; /* Show pointer on hover */
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

.download-link:hover i {
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

/* Add tooltip styles */
#hpiiTable td:hover {
    overflow: visible;
    background-color: #f8f9fa;
    z-index: 1;
}

/* Ensure tooltips appear above other content */
#hpiiTable td[title] {
    position: relative;
}

/* Make sure the table cells don't wrap content */
#hpiiTable td {
    white-space: nowrap !important;
}

/* Ensure the table header stays on top */
#hpiiTable thead th {
    position: sticky;
    top: 0;
    background: white;
    z-index: 2;
}

/* Add a subtle transition effect */
#hpiiTable td {
    transition: background-color 0.2s ease;
}

/* Style the tooltip on hover */
#hpiiTable td:hover::after {
    content: attr(title);
    position: absolute;
    left: 0;
    top: 100%;
    min-width: 100%;
    border: 1px solid #ddd;
    border-radius: 4px;
    background-color: white;
    padding: 5px;
    z-index: 3;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    white-space: normal;
    word-wrap: break-word;
    max-width: 300px;
}

/* Loading indicator */
.loading-indicator {
    display: none;
    margin-top: 20px;
    text-align: center;
}

.spinner-border {
    width: 3rem;
    height: 3rem;
}

/* Failure summary box */
.failure-box {
    border-left: 5px solid #dc3545;
    background-color: #fff;
    padding: 15px;
    margin-top: 20px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

/* Summary stats */
.summary-stats {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    margin: 20px 0;
}

.stat-box {
    flex: 1;
    min-width: 200px;
    padding: 15px;
    border-radius: 5px;
    text-align: center;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

.stat-box.total {
    background-color: #e9ecef;
}

.stat-box.success {
    background-color: #d4edda;
}

.stat-box.failure {
    background-color: #f8d7da;
}

.stat-number {
    font-size: 24px;
    font-weight: bold;
    margin: 10px 0;
}

.stat-label {
    text-transform: uppercase;
    font-size: 14px;
}

/* Table column widths */
#failureTable th:nth-child(1) {
    min-width: 100px;
}

#failureTable th:nth-child(2) {
    min-width: 80px;
}

#failureTable th:nth-child(3) {
    min-width: 100px;
}

#failureTable th:nth-child(4) {
    min-width: 300px;
}
</style>

<div class="container-wrapper">
	<!-- Search section -->
	<div class="row justify-content-center">
		<div class="upload-section col-md-8">
	    <h2 class="text-center">Upload CSV File For Enrolment Migration</h2>
	    <form id="uploadForm" method="post" action="${pageContext.request.contextPath}/migration/enrol" enctype="multipart/form-data">
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
	                <button id="uploadButton" type="submit" class="upload-button btn btn-primary">Upload</button>
	            </div>
	        </div>
	    </form>
	    <div id="loadingIndicator" class="loading-indicator">
	        <div class="spinner-border text-primary" role="status">
	            <span class="sr-only">Loading...</span>
	        </div>
	        <p class="mt-2">Processing migration. This may take several minutes. Please wait...</p>
	    </div>
		</div>
	</div>
	
	<!-- Result/Error display -->
	<c:choose>
		<c:when test="${error != null}">
			<!-- Handle errors -->
			<div class="row justify-content-center">
				<div class="col-md-8 alert alert-danger" role="alert">
					<h5>
						<i class="fa fa-times-circle fa-lg"></i>&nbsp;&nbsp;<c:out value="${error}" />
					</h5>
				</div>
			</div>
		</c:when>
		<c:when test="${totalProcessed > 0}">
			<!-- Migration Summary Stats -->
			<div class="summary-stats">
				<div class="stat-box total">
					<div class="stat-label">Total Processed</div>
					<div class="stat-number">${totalProcessed}</div>
				</div>
				<div class="stat-box success">
					<div class="stat-label">Successfully Migrated</div>
					<div class="stat-number">${successCount}</div>
				</div>
				<div class="stat-box failure">
					<div class="stat-label">Failed Records</div>
					<div class="stat-number">${failureCount}</div>
				</div>
			</div>
			
			<!-- Failed Records (Display First) -->
			<c:if test="${not empty failedRecords}">
				<div class="failure-box">
					<h4 class="text-danger"><i class="fa fa-exclamation-triangle"></i> Failed Records</h4>
					<p>The following records could not be migrated. Please review the errors before attempting again.</p>
					<div class="table-responsive">
						<table id="failureTable" class="table table-bordered table-striped">
							<thead>
								<tr>
									<th>Enrolment ID</th>
									<th>Line #</th>
									<th>Field</th>
									<th>Error Message</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach items="${failedRecords}" var="error">
									<tr>
										<td>${error.studentId}</td>
										<td>${error.lineNumber}</td>
										<td>${error.fieldName}</td>
										<td>${error.errorMessage}</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</div>
			</c:if>
			
			<!-- Successfully Migrated Records -->
			<c:if test="${not empty batchList}">
				<div class="mt-4">
					<h4 class="text-success"><i class="fa fa-check-circle"></i> Successfully Migrated Records</h4>
					<div class="stats">
						<table id="hpiiTable" class="display w-100">
							<thead>
								<tr>
									<th>Student ID</th>
									<th>Invoice ID</th>
									<th>Invoice History ID</th>
									<th>Price</th>
									<th>Name</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach items="${batchList}" var="record">
									<tr>
										<td title="<c:out value='${record.studentId}'/>"><c:out value="${record.studentId}" /></td>
										<td title="<c:out value='${record.invoiceId}'/>"><c:out value="${record.invoiceId}" /></td>
										<td title="<c:out value='${record.invoiceHistoryId}'/>"><c:out value="${record.invoiceHistoryId}" /></td>
										<td>
											<c:out value="${record.price}" />
										</td>
										<td>
											<c:out value="${record.name}" />
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</div>
			</c:if>
		</c:when>
	</c:choose>
</div>

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>
