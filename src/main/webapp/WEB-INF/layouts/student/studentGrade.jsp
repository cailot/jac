<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.StudentDTO"%>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils"%>
<%@page import="java.util.Calendar"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<!-- <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.1/font/bootstrap-icons.css"> -->
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
 
  
<script>
$(document).ready(function () {
	$('#studentListTable').DataTable({
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
		paging : false,
		searching : false
    });
    
	// initialise state list when loading
	listState('#listState');
	listBranch('#listBranch');
	listGrade('#listCurrentGrade');
	listGrade('#listToGrade');

	 // When the "Select All" checkbox is checked or unchecked
	 $('#select-all').change(function() {
        // Check or uncheck all checkboxes in the table body
        $('#list-student-body input[type="checkbox"]').prop('checked', $(this).prop('checked'));
    });

	// send diabled select value via <form>
	document.getElementById("studentList").addEventListener("submit", function() {
        document.getElementById("listState").disabled = false;
	});

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Upgrade Student's Grade
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateStudentInfo(){
	
	var listTo = $('#listToGrade').val();

	// if listTo is null or empty, then display error message and exit
	if(listTo == null || listTo == ''){
		$('#warning-alert .modal-body').html('Please select grade to upgrade.');
		$('#warning-alert').modal('show');
		return;
	}


	var std = [];
	$('#list-student-body input[type=checkbox]').each(function(){
		if(this.checked){
			// console.log(this.id);
			std.push(this.id);
		}
	});
		
	$.ajax({
		url : '${pageContext.request.contextPath}/student/updateGrade/' + listTo,
		type : 'POST',
		data : JSON.stringify(std),
		contentType : 'application/json',
		success : function(value) {
			// dismiss confirm dialogue
			$('#confirmModal').modal('hide');

			var gradeText = gradeName(listTo);
        	$('#success-alert .modal-body').html('Upgrade to <span class="font-weight-bold text-danger">' + gradeText + '</span> is successfully updated.');
	        $('#success-alert').modal('show');

			// Attach an event listener to the success alert close event
			$('#success-alert').on('hidden.bs.modal', function () {
				// Reload the page after the success alert is closed
				location.href = window.location.pathname; // Passing true forces a reload from the server and not from the cache
			});

		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
}

</script>

<style>

	div.dt-buttons {
		padding-top: 35px;
		padding-bottom: 30px;
	}

	tr { height: 50px } 

</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="studentList" method="get" action="${pageContext.request.contextPath}/student/upgrade">
			<div class="form-group">
				<div class="form-row">
					<c:choose>
							<c:when test="${empty UpgradeList}">
								<div class="col-md-2">
									<label for="listState" class="label-form">State</label> 
									<select class="form-control" id="listState" name="listState" disabled>
									</select>
								</div>
								<div class="col-md-2">
									<label for="listBranch" class="label-form">Branch</label> 
									<select class="form-control" id="listBranch" name="listBranch">
										<option value="0">All Branch</option>
									</select>
								</div>
								<div class="col-md-1">
									<label for="listCurrentGrade" class="label-form">Current</label> 
									<select class="form-control" id="listCurrentGrade" name="listCurrentGrade">
									</select>
								</div>
								<div class="col-md-1">
									<label for="listToGrade" class="label-form">To</label> 
									<select class="form-control" id="listToGrade" name="listToGrade" disabled>
										<option value="100"></option>
									</select>
								</div>
								<div class="offset-md-3"></div>
								<div class="col mx-auto">
									<label class="label-form-white">Search</label> 
									<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
								</div>
								<div class="col mx-auto">
									<label class="label-form-white">Upgrade</label> 
									<button type="button" class="btn btn-block btn-secondary" data-toggle="modal" data-target="#confirmModal" disabled><i class="bi bi bi-arrow-up-circle"></i>&nbsp;Grade Upgrade</button>
								</div>
							</c:when>
							<c:otherwise>
								<div class="col-md-2">
									<label for="listState" class="label-form">State</label> 
									<select class="form-control" id="listState" name="listState" disabled>
										<option value="All">All State</option>
									</select>
								</div>
								<div class="col-md-2">
									<label for="listBranch" class="label-form">Branch</label> 
									<select class="form-control" id="listBranch" name="listBranch" disabled>
										<option value="All">All Branch</option>
									</select>
								</div>
								<div class="col-md-1">
									<label for="listCurrentGrade" class="label-form">Current</label> 
									<select class="form-control" id="listCurrentGrade" name="listCurrentGrade" disabled>
									</select>
								</div>
								<div class="col-md-1">
									<label for="listToGrade" class="label-form">To</label> 
									<select class="form-control" id="listToGrade" name="listToGrade">
										<option value=""></option>
									</select>
								</div>
								<div class="offset-md-2"></div>
								<div class="col mx-auto">
									<label class="label-form-white">Search</label> 
									<button type="submit" class="btn btn-secondary btn-block" disabled> <i class="bi bi-search"></i>&nbsp;Search</button>
								</div>
								<div class="col mx-auto">
									<label class="label-form-white">Upgrade</label> 
									<button type="button" class="btn btn-block btn-danger" data-toggle="modal" data-target="#confirmModal"><i class="bi bi bi-arrow-up-circle"></i>&nbsp;Upgrade</button>
								</div>
								<div class="col mx-auto">
									<label class="label-form-white">Clear</label> 
									<button type="button" class="btn btn-block btn-success" onclick="window.location.href='${pageContext.request.contextPath}/studentGrade';"><i class="bi bi bi-arrow-clockwise"></i>&nbsp;Clear</button>
								</div>
							</c:otherwise>
					</c:choose>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="studentListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 5%">ID</th>
										<th class="align-middle text-center" style="width: 15%">First Name</th>
										<th class="align-middle text-center" style="width: 15%">Last Name</th>
										<th class="align-middle text-center" style="width: 5%">Grade</th>
										<th class="align-middle text-center" style="width: 5%">Gender</th>
										<th class="align-middle text-center" style="width: 10%">Register Date</th>
										<th class="align-middle text-center" style="width: 10%">Main Email</th>
										<th class="align-middle text-center" style="width: 10%">Main Contact</th>
										<th class="align-middle text-center" style="width: 10%">Sub Email</th>
										<th class="align-middle text-center" style="width: 10%">Sub Contact</th>
										<th class="align-middle text-center" style="width: 5%" data-orderable="false">
											<input type="checkbox" id="select-all" checked/>
										</th>
									</tr>
								</thead>
								<tbody id="list-student-body">
								<c:choose>
									<c:when test="${UpgradeList != null}">
										<c:forEach items="${UpgradeList}" var="student">
											<tr>
												<td class="small align-middle" id="studentId" name="studentId"><span><c:out value="${student.id}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.firstName}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.lastName}" /></span></td>
												<td class="small align-middle">
													<span>
														<c:choose>
															<c:when test="${student.grade == '1'}">P2</c:when>
															<c:when test="${student.grade == '2'}">P3</c:when>
															<c:when test="${student.grade == '3'}">P4</c:when>
															<c:when test="${student.grade == '4'}">P5</c:when>
															<c:when test="${student.grade == '5'}">P6</c:when>
															<c:when test="${student.grade == '6'}">S7</c:when>
															<c:when test="${student.grade == '7'}">S8</c:when>
															<c:when test="${student.grade == '8'}">S9</c:when>
															<c:when test="${student.grade == '9'}">S10</c:when>
															<c:when test="${student.grade == '10'}">S10E</c:when>
															<c:when test="${student.grade == '11'}">TT6</c:when>
															<c:when test="${student.grade == '12'}">TT8</c:when>
															<c:when test="${student.grade == '13'}">TT8E</c:when>
															<c:when test="${student.grade == '14'}">SRW4</c:when>
															<c:when test="${student.grade == '15'}">SRW5</c:when>
															<c:when test="${student.grade == '16'}">SRW6</c:when>
															<c:when test="${student.grade == '17'}">SRW7</c:when>
															<c:when test="${student.grade == '18'}">SRW8</c:when>
															<c:when test="${student.grade == '19'}">JMSS</c:when>
															<c:when test="${student.grade == '20'}">VCE</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="small align-middle"><span style="text-transform: capitalize;"><c:out value="${fn:toLowerCase(student.gender)}" /></span></td>
												<td class="small align-middle">
													<span>
														<fmt:parseDate var="studentRegistrationDate" value="${student.registerDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${studentRegistrationDate}" pattern="dd/MM/yyyy" />
													</span>
												</td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.email1}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.contactNo1}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.email2}" /></span></td>
												<td class="small align-middle ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.contactNo2}" /></span></td>
												<td class="small align-middle text-center"><input type="checkbox" checked value="${student.id}" id="${student.id}" /><span></span></td>											
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
			<i class="bi bi-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Confirmation Dialogue -->
<div class="modal fade" id="confirmModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Grade Update</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to apply new grade ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" onclick="updateStudentInfo()"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>


