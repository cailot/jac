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
</style>

<div class="container-wrapper">
	<!-- Search section -->
	<div class="row justify-content-center">
		<div class="upload-section col-md-8">
	    <h2 class="text-center">Upload CSV File For Invoice Migration</h2>
	    <form method="post" action="${pageContext.request.contextPath}/migration/invoice" enctype="multipart/form-data">
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
			<div class="row justify-content-center">
				<div class="col-md-8 alert alert-danger" role="alert">
					<h5>
						<i class="fa fa-times-circle fa-lg"></i>&nbsp;&nbsp;<c:out value="${error}" />
					</h5>
				</div>
			</div>
		</c:when>
	<c:otherwise>
		<!-- Result Section -->
		<div class="row justify-content-center">
		    <div id="studentResult">
		  	<c:choose>
				<c:when test="${not empty batchList}">
				<div class="stats">
					<!-- Display table if batchList is not empty -->
					<table id="hpiiTable" class="display w-100">
						<!-- Table headers -->
						<thead>
							<tr>
								<th>ID</th>
								<th>Last Name</th>
								<th>First Name</th>
								<th>Grade</th>
								<th>Contact 1</th>
								<th>Email 1</th>
								<th>Relation 1</th>
								<th>Contact 2</th>
								<th>Email 2</th>
								<th>Relation 2</th>
								<th>Address</th>
								<th>State</th>
								<th>Branch</th>
								<th>Gender</th>
								<th>Register Date</th>
								<th>End Date</th>
								<th>Active</th>
								<th>Memo</th>
							</tr>
						</thead>
						<!-- Table body -->
						<tbody>
						<!-- Iterate over batchList -->
						<c:forEach items="${batchList}" var="record">
							<tr>
								<!-- Display record if not empty -->
								<c:if test="${not empty record}">
									<td title="<c:out value='${record.id}'/>"><c:out value="${record.id}" /></td>
									<td title="<c:out value='${record.lastName}'/>"><c:out value="${record.lastName}" /></td>
									<td title="<c:out value='${record.firstName}'/>"><c:out value="${record.firstName}" /></td>
									<td title="<c:out value='${record.grade}'/>"><c:out value="${record.grade}" /></td>
									<td title="<c:out value='${record.contactNo1}'/>"><c:out value="${record.contactNo1}" /></td>
									<td title="<c:out value='${record.email1}'/>"><c:out value="${record.email1}" /></td>
									<td title="<c:out value='${record.relation1}'/>"><c:out value="${record.relation1}" /></td>
									<td title="<c:out value='${record.contactNo2}'/>"><c:out value="${record.contactNo2}" /></td>
									<td title="<c:out value='${record.email2}'/>"><c:out value="${record.email2}" /></td>
									<td title="<c:out value='${record.relation2}'/>"><c:out value="${record.relation2}" /></td>
									<td title="<c:out value='${record.address}'/>"><c:out value="${record.address}" /></td>
									<td title="<c:out value='${record.state}'/>"><c:out value="${record.state}" /></td>
									<td title="<c:out value='${record.branch}'/>"><c:out value="${record.branch}" /></td>
									<td title="<c:out value='${record.gender}'/>"><c:out value="${record.gender}" /></td>
									<td title="<c:out value='${record.registerDate}'/>"><c:out value="${record.registerDate}" /></td>
									<td title="<c:out value='${record.endDate}'/>"><c:out value="${record.endDate}" /></td>
									<td title="<c:out value='${record.active}'/>"><c:out value="${record.active}" /></td>
									<td title="<c:out value='${record.memo}'/>"><c:out value="${record.memo}" /></td>
								</c:if>
							</tr>
						</c:forEach>
						</tbody>
					</table>
				</div>
				</c:when>
				<c:otherwise>
					<!-- Display warning message if batchList is empty -->
					<!-- <div class="alert alert-warning" role="alert">
						<h5>
						<i class="fa fa-info-circle fa-lg"></i>&nbsp;&nbsp;Please upload <strong>CSV</strong> file with <strong>Student Information</strong>.
						</h5>
					</div> -->
				</c:otherwise>
			</c:choose>  
		    </div>
		</div>
	</c:otherwise>
	</c:choose>

	<!-- Migration Results -->
	<c:if test="${not empty migrationErrors}">
	    <div class="alert alert-warning mt-3">
	        <h5 class="text-danger">Migration Summary:</h5>
	        <div class="stats mb-3">
	            <p><strong>Total Processed:</strong> ${totalProcessed}</p>
	            <p><strong>Successfully Migrated:</strong> ${successCount}</p>
	            <p><strong>Failed:</strong> ${failureCount}</p>
	        </div>
	        <hr>
	        <h5 class="text-danger">Failed Records:</h5>
	        <div class="table-responsive">
	            <table class="table table-bordered table-striped">
	                <thead>
	                    <tr>
	                        <th>Original Student ID</th>
	                        <th>Line Number</th>
	                        <th>Failed Field</th>
	                        <th>Error Details</th>
	                    </tr>
	                </thead>
	                <tbody>
	                    <c:forEach items="${failedRecords}" var="record">
	                        <tr>
	                            <td>${record.studentId}</td>
	                            <td>${record.lineNumber}</td>
	                            <td>${record.fieldName}</td>
	                            <td>${record.errorMessage}</td>
	                        </tr>
	                    </c:forEach>
	                </tbody>
	            </table>
	        </div>
	    </div>
	</c:if>
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
