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
    $('#courseListTable').DataTable({
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
		//pageLength: 20
    });

	// initialise grade list
	listGrade('#listGrade');
	listGrade('#addGrade');
	listGrade('#editGrade');
    
});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Course
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addCourse() {
	// Get from form data
	var course = {
		name : $("#addName").val(),
		grade : $("#addGrade").val(),
		description : $("#addDescription").val(),
		online : $("#addOnline").is(':checked') ? true : false
	}
	// console.log(course);
	
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/class/registerCourse',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(course),
		contentType : 'application/json',
		success : function(response) {
			// console.log(response);
			// Display the success alert
            $('#success-alert .modal-body').text('New Class is registered successfully.');
            $('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerCourseModal').modal('hide');
	// flush all registered data
	document.getElementById("courseRegister").reset();
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Course
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveCourseInfo(courseId) {
	// console.log(courseId);
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/get/course/' + courseId,
		type : 'GET',
		success : function(course) {
			console.log(course);
			$("#editId").val(course.id);
			$("#editGrade").val(course.grade);
			$("#editName").val(course.name);
			$("#editPrice").val(course.price);
			$("#editDescription").val(course.description);
			// if course.online is true, then #editOnline is checked; otherwise #editOnsite is checked
			if (course.online) {
				$("#editOnline").prop('checked', true);
			} else {
				$("#editOnsite").prop('checked', true);
			}
			$('#editClassModal').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Course
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateCourseInfo(){
	var courseId = $("#editId").val();
	// get from formData
	var course = {
		id : courseId,
		name : $("#editName").val(),
		grade : $("#editGrade").val(),
		online : $("#editOnline").is(':checked') ? true : false,
		description : $("#editDescription").val()
	}
	
	console.log(course);
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/update/course',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify(course),
		contentType : 'application/json',
		success : function(value) {
			// Display success alert
			$('#success-alert .modal-body').text('Course is updated successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
	$('#editClassModal').modal('hide');
	// flush all registered data
	clearCourseForm("courseEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearCourseForm(elementId) {
	document.getElementById(elementId).reset();
}


</script>
<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="courseList" method="get" action="${pageContext.request.contextPath}/class/listCourse">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-3">
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All Grade</option>
						</select>
					</div>
					<div class="offset-md-4"></div>
					<div class="col mx-auto">
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerCourseModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="courseListTable" class="table table-striped table-bordered"><thead class="table-primary">
									<tr>
										<th>Name</th>
										<th>Description</th>
										<th>Grade</th>
										<th data-orderable="false">Type</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
								<c:choose>
									<c:when test="${CourseList != null}">
										<c:forEach items="${CourseList}" var="course">
											<tr>
												<td class="small ellipsis"><span><c:out value="${course.name}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${course.description}" /></span></td>
												<td class="small ellipsis">
													<span>
														<c:choose>
															<c:when test="${course.grade == '1'}">P2</c:when>
															<c:when test="${course.grade == '2'}">P3</c:when>
															<c:when test="${course.grade == '3'}">P4</c:when>
															<c:when test="${course.grade == '4'}">P5</c:when>
															<c:when test="${course.grade == '5'}">P6</c:when>
															<c:when test="${course.grade == '6'}">S7</c:when>
															<c:when test="${course.grade == '7'}">S8</c:when>
															<c:when test="${course.grade == '8'}">S9</c:when>
															<c:when test="${course.grade == '9'}">S10</c:when>
															<c:when test="${course.grade == '10'}">S10E</c:when>
															<c:when test="${course.grade == '11'}">TT6</c:when>
															<c:when test="${course.grade == '12'}">TT8</c:when>
															<c:when test="${course.grade == '13'}">TT8E</c:when>
															<c:when test="${course.grade == '14'}">SRW4</c:when>
															<c:when test="${course.grade == '15'}">SRW5</c:when>
															<c:when test="${course.grade == '16'}">SRW6</c:when>
															<c:when test="${course.grade == '17'}">SRW7</c:when>
															<c:when test="${course.grade == '18'}">SRW8</c:when>
															<c:when test="${course.grade == '19'}">JMSS</c:when>
															<c:when test="${course.grade == '20'}">VCE</c:when>
															<c:otherwise></c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="text-center">
													<c:choose>
														<c:when test="${course.online}">
															<i class="bi bi-display" title="Online"></i>
														</c:when>
														<c:otherwise>
															<i class="bi bi-person-fill" title="Onsite"></i>
														</c:otherwise>
													</c:choose>
													
												</td>
												<td class="text-center">
													<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveCourseInfo('${course.id}')"></i>&nbsp;
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
<div class="modal fade" id="registerCourseModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Course Registration</header>
					<form id="courseRegister">
						<div class="form-group mt-3">
							<div class="form-row">
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-9">
									<label for="addName" class="label-form">Name</label> 
									<input type="text" class="form-control" id="addName" name="addName" placeholder="Name" title="Please enter Course name">
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-9">
									<label for="addDescription" class="label-form">Course Description</label> 
									<input type="text" class="form-control" id="addDescription" name="addDescription" placeholder="Description" title="Please enter Course description">
								</div>
								<div class="input-group col-md-3">
									<div class="form-check">
										<input class="form-check-input" type="radio" name="addCourseType" id="addOnsite" checked>
										<label class="form-check-label" for="addOnsite">Onsite</label>
									</div>
									<div class="form-check">
										<input class="form-check-input" type="radio" name="addCourseType" id="addOnline">
										<label class="form-check-label" for="addOnline">Online</label>
									</div>
								</div>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="addCourse()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearCourseForm('courseRegister')" data-dismiss="modal">Close</button>	
					</div>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editClassModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Course Edit</header>
			
				<form id="courseEdit">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-3">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
								</select>
							</div>
							<div class="col-md-9">
								<label for="editName" class="label-form">Name</label> 
								<input type="text" class="form-control" id="editName" name="editName">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">									
							<div class="col-md-9">
								<label for="editDescription" class="label-form">Description</label> 
								<input type="text" class="form-control" id="editDescription" name="editDescription">
							</div>
							<div class="input-group col-md-3">
								<div class="form-check">
									<input class="form-check-input" type="radio" name="editCourseType" id="editOnsite">
									<label class="form-check-label" for="editOnsite">Onsite</label>
								</div>
								<div class="form-check">
									<input class="form-check-input" type="radio" name="editCourseType" id="editOnline">
									<label class="form-check-label" for="editOnline">Online</label>
								</div>
							</div>
							
						</div>
					</div>
					<input type="hidden" id="editId" name="editId">
				</form>
				<div class="d-flex justify-content-end">
					<button type="submit" class="btn btn-primary" onclick="updateCourseInfo()">Save</button>&nbsp;&nbsp;
					<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">Close</button>	
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
			<i class="bi bi-check-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>