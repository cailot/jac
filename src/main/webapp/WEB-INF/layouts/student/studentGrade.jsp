<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.StudentDTO"%>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils"%>
<%@page import="java.util.Calendar"%>

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

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Upgrade Student's Grade
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateStudentInfo(){
	
	// how to get all checked student id saved in checkbox's value



	var std = [];
	$('#list-student-body input[type=checkbox]').each(function(){
		if(this.checked){
			console.log(this.id);
			std.push(this.id);
		}
	});
		
	// send query to controller
	// $.ajax({
	// 	url : '${pageContext.request.contextPath}/student/update',
	// 	type : 'PUT',
	// 	dataType : 'json',
	// 	data : JSON.stringify(std),
	// 	contentType : 'application/json',
	// 	success : function(value) {
	// 		// Display success alert
	// 		$('#success-alert .modal-body').text('ID : ' + value.id + ' is updated successfully.');
	// 		$('#success-alert').modal('show');
	// 		// fetch data again
	// 		$('#success-alert').on('hidden.bs.modal', function(e) {
	// 			location.reload();
	// 		});
			
	// 	},
	// 	error : function(xhr, status, error) {
	// 		console.log('Error : ' + error);
	// 	}
	// });
	
}

</script>

<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="studentList" method="get" action="${pageContext.request.contextPath}/student/upgrade">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listState" class="label-form">State</label> 
						<select class="form-control" id="listState" name="listState">
							<option value="All">All State</option>
						</select>
					</div>
					<div class="col-md-2">
						<label for="listBranch" class="label-form">Branch</label> 
						<select class="form-control" id="listBranch" name="listBranch">
							<option value="All">All Branch</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="listCurrentGrade" class="label-form">Current</label> 
						<select class="form-control" id="listCurrentGrade" name="listCurrentGrade">
						</select>
					</div>
					<div class="col-md-1">
						<label for="listToGrade" class="label-form">To</label> 
						<select class="form-control" id="listToGrade" name="listToGrade">
						</select>
					</div>
					<div class="offset-md-2"></div>
					<div class="col mx-auto">
						<label class="label-form-white">Search</label> 
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form-white">Upgrade</label> 
						<button type="button" class="btn btn-block btn-success" onclick="updateStudentInfo()"><i class="bi bi-plus"></i>&nbsp;Grade Upgrade</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="studentListTable" class="table table-striped table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th>ID</th>
										<th>First Name</th>
										<th>Last Name</th>
										<th>Grade</th>
										<th>Gender</th>
										<th>Register Date</th>
										<th>Main Email</th>
										<th>Main Contact</th>
										<th>Sub Email</th>
										<th>Sub Contact</th>
										<th data-orderable="false">Select</th>
									</tr>
								</thead>
								<tbody id="list-student-body">
								<c:choose>
									<c:when test="${StudentList != null}">
										<c:forEach items="${StudentList}" var="student">
											<tr>
												<td class="small ellipsis" id="studentId" name="studentId"><span><c:out value="${student.id}" /></span></td>
												<td class="small ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.firstName}" /></span></td>
												<td class="small ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.lastName}" /></span></td>
												<td class="small ellipsis">
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
												<td class="small ellipsis"><span style="text-transform: capitalize;"><c:out value="${fn:toLowerCase(student.gender)}" /></span></td>
												<td class="small ellipsis">
													<span>
														<fmt:parseDate var="studentRegistrationDate" value="${student.registerDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${studentRegistrationDate}" pattern="dd/MM/yyyy" />
													</span>
												</td>
												<td class="small ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.email1}" /></span></td>
												<td class="small ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.contactNo1}" /></span></td>
												<td class="small ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.email2}" /></span></td>
												<td class="small ellipsis text-truncate" style="max-width: 0; overflow: hidden;"><span><c:out value="${student.contactNo2}" /></span></td>
												<td class="small"><input type="checkbox" checked value="${student.id}" id="${student.id}" /><span></span></td>											
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
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
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


