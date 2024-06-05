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
		            pageSize: 'A0'
		        }
	        ],
	    'lengthChange': false,
	    'order' : []
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
	    <h2 class="text-center">Upload CSV File</h2>
	    <form method="post" action="${pageContext.request.contextPath}/migration/upload" enctype="multipart/form-data">
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
	<c:otherwise>
		<!-- Result Section -->
		<div class="row m-3 pt-5 justify-content-center">
		    <div id="studentResult" class="col-md-10">
		  	<c:choose>
				<c:when test="${not empty batchList}">
				<!-- Display data if hpiiList; is not empty -->
				<%--
				<p class="text-center text-primary">
					Success Rate of inserting Student Information: <fmt:formatNumber type="percent" maxIntegerDigits="3" value="${(batchSuccess / batchTotal)}" />
				</p>
				--%>
				<div class="stats">
					<!-- Display table if hpiiList is not empty -->
					<table id="hpiiTable" class="display">
						<!-- Table headers -->
						<thead>
							<tr>
								<th class="text-center" style="width: 20%">ID</th>
								<th class="text-center" style="width: 20%">Last Name</th>
								<th class="text-center" style="width: 20%">First Name</th>
								<th class="text-center" style="width: 20%">Grade</th>
								<th class="text-center" style="width: 20%">Contact 1</th>
								<th class="text-center" style="width: 15%;">Email 1</th>
								<th class="text-center" style="width: 5%">Relation 1</th>
								<th class="text-center" style="width: 20%">Contact 2</th>
								<th class="text-center" style="width: 15%;">Email 2</th>
								<th class="text-center" style="width: 5%">Relation 2</th>
								<th class="text-center" style="width: 20%">State</th>
								<th class="text-center" style="width: 15%;">Branch</th>
								<th class="text-center" style="width: 5%">Gender</th>
								<th class="text-center" style="width: 20%">Register Date</th>
								<th class="text-center" style="width: 15%;">End Date</th>
								<th class="text-center" style="width: 5%">Active</th>							
							</tr>
						</thead>
						<!-- Table body -->
						<tbody>
						<!-- Iterate over hpiiList -->
						<c:forEach items="${batchList}" var="record">
							<tr>
								<!-- Display record if not empty -->
								<c:if test="${not empty record}">
									<td class="small ellipsis"><span><c:out value="${record.id}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.lastName}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.firstName}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.grade}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.contactNo1}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.email1}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.relation1}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.contactNo2}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.email2}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.relation2}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.state}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.branch}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.gender}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.registerDate}" /></span></td>
									<td class="small ellipsis"><span><c:out value="${record.endDate}" /></span></td>
									<td class="small ellipsis text-center"><span><c:out value="${record.active}" /></span></td>
								</c:if>
							</tr>
						</c:forEach>
						</tbody>
					</table>
				</div>
				</c:when>
				<c:otherwise>
					<!-- Display warning message if hpiiList is empty -->
					<div class="alert alert-warning" role="alert">
						<h5>
						<i class="fa fa-info-circle fa-lg"></i>&nbsp;&nbsp;Please upload <strong>CSV</strong> file with <strong>Student Information</strong>.
						</h5>
					</div>
				</c:otherwise>
			</c:choose>  
		    </div>
		</div>
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
