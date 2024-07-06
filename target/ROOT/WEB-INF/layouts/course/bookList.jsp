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
    $('#bookListTable').DataTable({
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
	// initialise subject list
	listSubject('#addSubject');
	listSubject('#editSubject');
    
});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Book
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addBook() {
	// name, description validation
	var name = document.getElementById('addName');
	if(name.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			name.focus();
		});
		return false;
	}
	var price = document.getElementById('addPrice');
	if(price.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter price');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			price.focus();
		});
		return false;
	}
	// Get practiceIds form addScheduleTable
	var subjectIds = [];
	$('#addSubjectTable tr').each(function () {
		var subjectId = $(this).find('.subjectId').text();
		if (subjectId != '') {
			subjectIds.push({id : subjectId});
		}
	});
	// Get from form data
	var book = {
		name : $("#addName").val(),
		grade : $("#addGrade").val(),
		price: $("#addPrice").val(),
		subjects : subjectIds
	}
	console.log(book);
	
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/book/register',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(book),
		contentType : 'application/json',
		success : function(response) {
            $('#success-alert .modal-body').text('New Book is registered successfully.');
            $('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerBookModal').modal('hide');
	// flush all registered data
	document.getElementById("bookRegister").reset();
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Book
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveBookInfo(bookId) {
	// console.log(courseId);
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/book/get/' + bookId,
		type : 'GET',
		success : function(book) {
			//console.log(book);
			$("#editId").val(book.id);
			$("#editGrade").val(book.grade);
			$("#editName").val(book.name);
			$("#editPrice").val(book.price);
			$("#editActive").val(book.active);
			if (book.active == true) {
				$("#editActiveCheckbox").prop('checked', true);
			} else {
				$("#editActiveCheckbox").prop('checked', false);
			}
			// clear all rows on editScheduleTable
			$("#editSubjectTable").find("tr:gt(0)").remove();	
			
			var subjects = book.subjects;
			$.each(subjects, function (index, value) {
				//console.log(value);
				// Create a new row
				var row = $("<tr>");
				// Create the cells for the row
				var cell = $("<td>").text(value.name);
				// cell4
				var binIcon = $('<i class="bi bi-trash h5"></i>');
				var binIconLink = $("<a>")
					.attr("href", "javascript:void(0)")
					.attr("title", "Delete Practice")
					.click(function () {
						row.remove();
					});
				binIconLink.append(binIcon);
				var deleteCell = $("<td>").addClass('text-center').append(binIconLink);

				// hidden td for practiceId
				var td = $("<td>").css("display", "none").addClass("subjectId").text(value.id);

				// Append cells to the row
				row.append(cell, deleteCell, td);

				// Append the row to the table
				$("#editSubjectTable").append(row);
			});
			$('#editClassModal').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Book
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateBookInfo(){

	// name, description validation
	var name = document.getElementById('editName');
	if(name.value== ""){
		$('#validation-alert .modal-body').text(
				'Please enter name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			name.focus();
		});
		return false;
	}
	var bookId = $("#editId").val();
	var subjectDtos = [];
	$('#editSubjectTable tr').each(function () {
		var subjectId = $(this).find('.subjectId').text();
		if (subjectId != '') {
			subjectDtos.push({id : subjectId});
		}
	});
	// get from formData
	var book = {
		id : bookId,
		name : $("#editName").val(),
		grade : $("#editGrade").val(),
		price : $("#editPrice").val(),
		active: $("#editActive").val(),
		subjects : subjectDtos
	}
	
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/book/update',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify(book),
		contentType : 'application/json',
		success : function(value) {
			// Display success alert
			$('#success-alert .modal-body').text('Book is updated successfully.');
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
	clearBookForm("courseEdit");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearBookForm(elementId) {
	document.getElementById(elementId).reset();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm before deleting Book
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function confirmDelete(testId) {
    // Show the warning modal
    $('#deleteConfirmModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeConfirmation').one('click', function() {
        deleteBook(testId);
        $('#deleteConfirmModal').modal('hide');
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Book
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function deleteBook(id) {
	$.ajax({
		url: '${pageContext.request.contextPath}/book/delete/' + id,
		type: 'DELETE',
		success: function (result) {
			$('#success-alert .modal-body').text('Book deleted successfully');
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add Subject into Table
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateSubjects(action) {
	// Get the values from the select elements
	var subjectSelect = document.getElementById(action + "Subject");
	var subjectName = subjectSelect.options[subjectSelect.selectedIndex].text;
	var subjectId = subjectSelect.value;
	// Get a reference to the table
	var table = document.getElementById(action + "SubjectTable");
	/// Create a new row
	var row = $("<tr>");
	// Create the cells for the row
	var cell = $("<td>").text(subjectName);
	// cell4
	var binIcon = $('<i class="bi bi-trash h5"></i>');
	var binIconLink = $("<a>")
		.attr("href", "javascript:void(0)")
		.attr("title", "Delete Practice")
		.click(function () {
			row.remove();
		});
	binIconLink.append(binIcon);
	var deleteCell = $("<td>").addClass('text-center').append(binIconLink);
	// hidden td for practiceId
	var td = $("<td>").css("display", "none").addClass("subjectId").text(subjectId);
	// Append cells to the row
	row.append(cell,deleteCell, td);
	// Append the row to the table
	$("#"+ action +"SubjectTable").append(row);
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

	tr { height: 50px } 
</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="courseList" method="get" action="${pageContext.request.contextPath}/book/list">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listGrade" class="label-form">Grade</label>
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All Grade</option>
						</select>
					</div>
					<div class="offset-md-7"></div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form"><span style="color: white;">0</span></label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerBookModal"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="bookListTable" class="table table-striped table-bordered"><thead class="table-primary">
									<tr>
										<th class="align-middle text-center" style="width: 30%">Name</th>
										<th class="align-middle text-center" style="width: 10%">Grade</th>
										<th class="align-middle text-center" style="width: 35%">Subject(s)</th>
										<th class="align-middle text-center" style="width: 10%">Price</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 5%">Activated</th>
										<th class="align-middle text-center" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
								<c:choose>
									<c:when test="${BookList != null}">
										<c:forEach items="${BookList}" var="book">
											<tr>
												<td class="small align-middle"><span><c:out value="${book.name}" /></span></td>
												<td class="small align-middle text-center">
													<span>
														<c:choose>
															<c:when test="${book.grade == '1'}">P2</c:when>
															<c:when test="${book.grade == '2'}">P3</c:when>
															<c:when test="${book.grade == '3'}">P4</c:when>
															<c:when test="${book.grade == '4'}">P5</c:when>
															<c:when test="${book.grade == '5'}">P6</c:when>
															<c:when test="${book.grade == '6'}">S7</c:when>
															<c:when test="${book.grade == '7'}">S8</c:when>
															<c:when test="${book.grade == '8'}">S9</c:when>
															<c:when test="${book.grade == '9'}">S10</c:when>
															<c:when test="${book.grade == '10'}">S10E</c:when>
															<c:when test="${book.grade == '11'}">TT6</c:when>
															<c:when test="${book.grade == '12'}">TT8</c:when>
															<c:when test="${book.grade == '13'}">TT8E</c:when>
															<c:when test="${book.grade == '14'}">SRW4</c:when>
															<c:when test="${book.grade == '15'}">SRW5</c:when>
															<c:when test="${book.grade == '16'}">SRW6</c:when>
															<c:when test="${book.grade == '17'}">SRW7</c:when>
															<c:when test="${book.grade == '18'}">SRW8</c:when>
															<c:when test="${book.grade == '19'}">JMSS</c:when>
															<c:when test="${book.grade == '20'}">VCE</c:when>
															<c:otherwise>All Grade</c:otherwise>
														</c:choose>
													</span>
												</td>
												<td class="small align-middle">
													<c:forEach var="subject" items="${book.subjects}" varStatus="status">
														<c:out value="${subject.name}" />
														<c:if test="${!status.last}">, </c:if>
													</c:forEach>
												</td>
												<td class="small align-middle text-right"><span><c:out value="${book.price}" /></span></td>
												<c:set var="active" value="${book.active}" />
													<c:choose>
														<c:when test="${active == true}">
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-success"></i>
															</td>
														</c:when>
														<c:otherwise>
															<td class="text-center align-middle">
																<i class="bi bi-check-circle-fill text-secondary"></i>
															</td>
														</c:otherwise>
													</c:choose>
												<td class="text-center align-middle">
													<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveBookInfo('${book.id}')"></i>&nbsp;&nbsp;
													<i class="bi bi-trash text-danger fa-lg hand-cursor" data-toggle="tooltip" title="Delete" onclick="confirmDelete('${book.id}')"></i>
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
<div class="modal fade" id="registerBookModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Book Registration</header>
					<form id="bookRegister">
						<div class="form-group mt-3">
							<div class="form-row">
								<div class="col-md-3">
									<label for="addGrade" class="label-form">Grade</label>
									<select class="form-control" id="addGrade" name="addGrade">
									</select>
								</div>
								<div class="col-md-6">
									<label for="addName" class="label-form">Name</label> 
									<input type="text" class="form-control" id="addName" name="addName" placeholder="Name" title="Please enter Course name">
								</div>
								<div class="col-md-3">
									<label for="addPrice" class="label-form">Price</label> 
									<input type="text" class="form-control" id="addPrice" name="addPrice" title="Please enter Course price">
								</div>
							</div>
						</div>
						<div class="form-group mt-4">
							<div class="form-row">
								<div class="offset-md-1"></div>
								<div class="col-md-7">
									<label for="addSubject" class="label-form">Subject</label>
									<select class="form-control" id="addSubject" name="addSubject">
									</select>
								</div>
								<div class="offset-md-1"></div>
								<div class="col-md-2 d-flex flex-column justify-content-center">
									<label class="label-form text-white">Add</label>
									<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="updateSubjects('add')"><i class="bi bi-plus"></i></button>
								</div>
								<div class="offset-md-1"></div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row mt-4">
								<table class="table table-striped table-bordered" id="addSubjectTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
									<thead class="thead-light">
										<tr>
											<th data-field="type" style="width: 80%;">Subject</th>
											<th data-field="action" style="width: 10%;">Action</th>
										</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addBook()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearBookForm('bookRegister')" data-dismiss="modal">Close</button>	
					</div>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editClassModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Book Edit</header>
			
				<form id="courseEdit">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-3">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
								</select>
							</div>
							<div class="col-md-6">
								<label for="editName" class="label-form">Name</label> 
								<input type="text" class="form-control" id="editName" name="editName">
							</div>
							<div class="col-md-3">
								<label for="editPrice" class="label-form">Price</label> 
								<input type="number" class="form-control" id="editPrice" name="editPrice">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">							
							<div class="input-group col-md-4">
								<div class="input-group-prepend">
									<div class="input-group-text">
										<input type="checkbox" id="editActiveCheckbox" name="editActiveCheckbox" onchange="updateEditActiveValue(this)">
									</div>
								</div>
								<input type="hidden" id="editActive" name="editActive" value="false">
								<input type="text" id="editActiveLabel" class="form-control" placeholder="Activate">
							</div>
							<div class="col-md-6">
								<select class="form-control" id="editSubject" name="editSubject">
								</select>
							</div>
							<div class="col-md-2 d-flex flex-column justify-content-center">
								<button type="button" class="btn btn-success btn-block d-flex justify-content-center align-items-center" onclick="updateSubjects('edit')"><i class="bi bi-plus"></i></button>
							</div>
							<div class="offset-md-1"></div>
						</div>
					</div>	
					<div class="form-group">
						<div class="form-row mt-4">
							<table class="table table-striped table-bordered" id="editSubjectTable" data-header-style="headerStyle" style="font-size: smaller; width: 90%; margin-left: auto; margin-right: auto;">
								<thead class="thead-light">
									<tr>
										<th data-field="type" style="width: 80%;">Subject</th>
										<th data-field="action" style="width: 10%;">Action</th>
									</tr>
								</thead>
								<tbody>
								</tbody>
							</table>
						</div>
					</div>
					<input type="hidden" id="editId" name="editId">
				</form>
				<div class="d-flex justify-content-end">
					<button type="submit" class="btn btn-primary" onclick="updateBookInfo()">Save</button>&nbsp;&nbsp;
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

<!--Delete Confirmation Modal -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Book Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Are you sure to delete Book ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeConfirmation"><i class="bi bi-check-circle"></i> Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>