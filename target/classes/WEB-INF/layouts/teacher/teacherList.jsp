<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.TeacherDTO"%>
<%@page import="hyung.jin.seo.jae.utils.JaeUtils"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
 
  
<script>
$(document).ready(function () {
    $('#teacherListTable').DataTable({
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
    

	$('table .password').on('click', function(){
		var username = $(this).parent().find('#username').val();
		$('#passwordModal #usernamepassword').val(username);
	});
	
	// Set default date format
	$.fn.datepicker.defaults.format = 'dd/mm/yyyy';

	$('.datepicker').datepicker({
		//format: 'dd/mm/yyyy',
		autoclose : true,
		todayHighlight : true
	});

    
});

// Register Teacher
function addTeacher() {
	// Get from form data
	var teacher = {
		state : $("#addState").val(),
		branch : $("#addBranch").val(),
		title : $("#addTitle").val(),
		firstName : $("#addFirstName").val(),
		lastName : $("#addLastName").val(),
		email : $("#addEmail").val(),
		phone : $("#addPhone").val(),
		address : $("#addAddress").val(),
		bank : $("#addBank").val(),
		bsb : $("#addBsb").val(),
		accountNumber : $("#addAccountNumber").val(),
		tfn : $("#addTfn").val(),
		superannuation : $("#addSuperannuation").val(),
		superMember : $("#addSuperMember").val(),
		memo : $("#addMemo").val(),
	}
	console.log(teacher);
	
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/teacher/register',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(teacher),
		contentType : 'application/json',
		success : function(teacher) {
			// Display the success alert
			$('#success-alert .modal-body').text(
					'Your action has been completed successfully.');
			$('#success-alert').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerStudentModal').modal('hide');
	// flush all registered data
	document.getElementById("teacherRegister").reset();
}


//Search Student with Keyword	
function retreiveTeacherInfo(std) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/teacher/get/' + std,
		type : 'GET',
		success : function(teacher) {
			$('#editTeacherModal').modal('show');
			// Update display info
			$("#editId").val(teacher.id);
			$("#editFirstName").val(teacher.firstName);
			$("#editLastName").val(teacher.lastName);
			$("#editEmail").val(teacher.email);
			$("#editTitle").val(teacher.title);
			$("#editAddress").val(teacher.address);
			$("#editPhone").val(teacher.phone);
			$("#editState").val(teacher.state);
			$("#editBranch").val(teacher.branch);
			$("#editBank").val(teacher.bank);
			$("#editBsb").val(teacher.bsb);
			$("#editAccountNumber").val(teacher.accountNumber);
			$("#editSuperannuation").val(teacher.superannuation);
			$("#editSuperMember").val(teacher.superMember);
			$("#editTfn").val(teacher.tfn);
			$("#editMemo").val(teacher.memo);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


function updateTeacherInfo(){
	
	// get from formData
	var teacher = {
		id : $('#editId').val(),
		firstName : $("#editFirstName").val(),
		lastName : $("#editLastName").val(),
		email : $("#editEmail").val(),
		address : $("#editAddress").val(),
		title : $("#editTitle").val(),
		phone : $("#editPhone").val(),
		memo : $("#editMemo").val(),
		state : $("#editState").val(),
		branch : $("#editBranch").val(),
		bank : $("#editBank").val(),
		bsb : $("#editBsb").val(),
		accountNumber : $("#editAccountNumber").val(),
		tfn : $("#editTfn").val(),
		superannuation : $("#editSuperannuation").val(),
		superMember : $("#editSuperMember").val()
	}
	
	
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/teacher/update',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify(teacher),
		contentType : 'application/json',
		success : function(value) {
			$('#editTeacherModal').modal('hide');
			// flush all registered data
			document.getElementById("teacherEdit").reset();
			
			// Display success alert
			$('#success-alert .modal-body').text(
					'ID : ' + value.id + ' is updated successfully.');
			$('#success-alert').modal('show');
			
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
	
}


//de-activate teacher
function inactivateTeacher(id) {
	if(confirm("Are you sure you want to de-activate this teacher?")){
		// send query to controller
		$.ajax({
			url : '${pageContext.request.contextPath}/teacher/inactivate/' + id,
			type : 'PUT',
			success : function(data) {
				// clear existing form
				$('#success-alert .modal-body').text(
						'ID : ' + id + ' is now inactivated');
				$('#success-alert').modal('show');
				//clearStudentForm();
			},
			error : function(xhr, status, error) {
				console.log('Error : ' + error);
			}
		}); 
	}else{
		return;
	}
}








//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Memo Modal
//////////////////////////////////////////////////////////////////////////////////////////////////////
function displayMemo(dataId, contents){
	document.getElementById("infoDataId").value = dataId;
	document.getElementById("information").value = contents;
	// display Receivable amount
    $('#infoModal').modal('toggle');
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Memo
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateMemoInformation(){
	var dataId = $('#infoDataId').val();
	var memo = $('#information').val();
	
	let encodeMemo = encodeDecodeString(memo).encoded;
	$.ajax({
		url : '${pageContext.request.contextPath}/teacher/updateMemo/' + dataId,
		type : 'POST',
		data : encodeMemo,
		contentType : 'application/json',
		success : function(response) {
			console.log('addInformation response : ' + response);
			// flush old data in the dialogue
			document.getElementById('showInformation').reset();
			// disappear information dialogue
			$('#infoModal').modal('toggle');
			//debugger;
			// // update memo <td> in invoiceListTable 
			// $('#invoiceListTable > tbody > tr').each(function() {
			// 		if(dataType === ENROLMENT){
			// 			if ($(this).find('.enrolment-match').text() === (dataType + '|' + dataId)) {
			// 				(isNotBlank(info)) ? $(this).find('.memo').html('<i class="bi bi-chat-square-text-fill text-primary" title="Internal Memo" onclick="displayAddInfo(ENROLMENT, ' + dataId + ', \'' + encodeInfo + '\')"></i>') : $(this).find('.memo').html('<i class="bi bi-chat-square-text text-primary" title="Internal Memo" onclick="displayAddInfo(ENROLMENT, ' + dataId + ', \'\')"></i>');		
			// 			}
			// 		}else if(dataType === OUTSTANDING){
			// 			if ($(this).find('.outstanding-match').text() === (dataType + '|' + dataId)) {
			// 				(isNotBlank(info)) ? $(this).find('.memo').html('<i class="bi bi-chat-square-text-fill text-primary" title="Internal Memo" onclick="displayAddInfo(OUTSTANDING, ' + dataId + ', \'' + encodeInfo + '\')"></i>') : $(this).find('.memo').html('<i class="bi bi-chat-square-text text-primary" title="Internal Memo" onclick="displayAddInfo(OUTSTANDING, ' + dataId + ', \'\')"></i>');
			// 			}
			// 		}else if(dataType === BOOK){
			// 			if ($(this).find('.book-match').text() === (dataType + '|' + dataId)) {
			// 				(isNotBlank(info)) ? $(this).find('.memo').html('<i class="bi bi-chat-square-text-fill text-primary" title="Internal Memo" onclick="displayAddInfo(BOOK, ' + dataId + ', \'' + encodeInfo + '\')"></i>') : $(this).find('.memo').html('<i class="bi bi-chat-square-text text-primary" title="Internal Memo" onclick="displayAddInfo(BOOK, ' + dataId + ', \'\')"></i>');
			// 			}
			// 		}
			// 	}
			// );
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});						
}

</script>

<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="teacherList" method="get" action="${pageContext.request.contextPath}/teacher/list">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<select class="form-control" id="listState" name="listState">
							<option value="All">All State</option>
							<option value="vic">Victoria</option>
							<option value="nsw">New South Wales</option>
							<option value="qld">Queensland</option>
							<option value="sa">South Australia</option>
							<option value="tas">Tasmania</option>
							<option value="wa">Western Australia</option>
							<option value="nt">Northern Territory</option>
							<option value="act">ACT</option>
						</select>
					</div>
					<div class="col-md-2">
						<select class="form-control" id="listBranch" name="listBranch">
							<option value="All">All Branch</option>
							<option value="braybrook">Braybrook</option>
							<option value="epping">Epping</option>
							<option value="balwyn">Balwyn</option>
							<option value="bayswater">Bayswater</option>
							<option value="boxhill">Box Hill</option>
							<option value="carolinesprings">Caroline Springs</option>
							<option value="chadstone">Chadstone</option>
							<option value="craigieburn">Craigieburn</option>
							<option value="cranbourne">Cranbourne</option>
							<option value="glenwaverley">Glen Waverley</option>
							<option value="mitcha">Mitcham</option>
							<option value="narrewarren">Narre Warren</option>
							<option value="ormond">Ormond</option>
							<option value="pointcook">Point Cook</option>
							<option value="preston">Preston</option>
							<option value="springvale">Springvale</option>
							<option value="stalbans">St Albans</option>
							<option value="werribee">Werribee</option>
							<option value="mernda">Mernda</option>
							<option value="melton">Melton</option>
							<option value="glenroy">Glenroy</option>
							<option value="packenham">Packenham</option>
						</select>
					</div>
					<div class="col-md-2">
						<select class="form-control" id="listActive" name="listActive">
							<option value="All">All Teachers</option>
							<option value="Current">Current Teachers</option>
							<option value="Stopped">Stopped Teachers</option>
						</select>
					</div>
					<div class="col mx-auto">
						<button type="submit" class="btn btn-primary btn-block" onclick="return validate()">Search</button>
					</div>
					<div class="col mx-auto">
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerStudentModal">New</button>
					</div>
				</div>
			</div>


			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="teacherListTable" class="table table-striped table-bordered"><thead class="table-primary">
									<tr>
										<th>ID</th>
										<th>First Name</th>
										<th>Last Name</th>
										<th>Title</th>
										<th>Phone</th>
										<th>Email</th>
										<th>Address</th>
										<th>TFN</th>
										<th>Start Date</th>
										<th>End Date</th>
										<th>Memo</th>
										<th>Action</th>
									</tr>
								</thead>
								<tbody id="list-teacher-body">
								<c:choose>
									<c:when test="${TeacherList != null}">
									
										<c:forEach items="${TeacherList}" var="teacher">
											<%--<c:out value="${teacher}"/>--%>
											<tr>
												<td class="small ellipsis" id="teacherId" name="teacherId"><span><c:out value="${teacher.id}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${teacher.firstName}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${teacher.lastName}" /></span></td>
												<td class="small text-capitalize align-middle">
													<c:out value="${teacher.title}" />
												</td>
												<td class="small ellipsis"><span><c:out value="${teacher.phone}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${teacher.email}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${teacher.address}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${teacher.tfn}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${teacher.startDate}" /></span></td>
												<td class="small ellipsis">
													<c:out value="${teacher.endDate}" />
												</td>
												<td class="small text-center">
													<c:choose>
														<c:when test="${not empty teacher.memo}">
															<i class="bi bi-chat-square-text-fill text-primary" title="Memo" onclick="displayMemo('${teacher.id}', '${teacher.memo}')"></i>
														</c:when>
														<c:otherwise>
															<i class="bi bi-chat-square-text text-primary" title="Memo" onclick="displayMemo('${teacher.id}', '${teacher.memo}')"></i>
														</c:otherwise>
													</c:choose>
												</td>
												<td>
													<i class="bi bi-pencil-square text-primary" data-toggle="tooltip" title="Edit" onclick="retreiveTeacherInfo('${teacher.id}')"></i>&nbsp;
													<a href="#passwordStudentModal" class="password" data-toggle="modal"><i class="bi bi-key text-warning" data-toggle="tooltip" title="Change Password"></i></a>&nbsp;
													<i class="bi bi-x-circle text-danger" data-toggle="tooltip" title="Suspend" onclick="inactivateTeacher('${teacher.id}')"></i>
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
<div class="modal fade" id="registerStudentModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h4 class="modal-title" id="myModalLabel">Teacher Register</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			</div>
			<div class="modal-body">
				<form id="teacherRegister">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-4">
								<label for="selectOption">State</label> <select
									class="form-control" id="addState" name="addState">
									<option value="vic">Victoria</option>
									<option value="nsw">New South Wales</option>
									<option value="qld">Queensland</option>
									<option value="sa">South Australia</option>
									<option value="tas">Tasmania</option>
									<option value="wa">Western Australia</option>
									<option value="nt">Northern Territory</option>
									<option value="act">ACT</option>
								</select>
							</div>
							<div class="col-md-6">
								<label for="selectOption">Branch</label> <select
									class="form-control" id="addBranch" name="addBranch">
									<option value="braybrook">Braybrook</option>
									<option value="epping">Epping</option>
									<option value="balwyn">Balwyn</option>
									<option value="bayswater">Bayswater</option>
									<option value="boxhill">Box Hill</option>
									<option value="carolinesprings">Caroline Springs</option>
									<option value="chadstone">Chadstone</option>
									<option value="craigieburn">Craigieburn</option>
									<option value="cranbourne">Cranbourne</option>
									<option value="glenwaverley">Glen Waverley</option>
									<option value="mitcha">Mitcham</option>
									<option value="narrewarren">Narre Warren</option>
									<option value="ormond">Ormond</option>
									<option value="pointcook">Point Cook</option>
									<option value="preston">Preston</option>
									<option value="springvale">Springvale</option>
									<option value="stalbans">St Albans</option>
									<option value="werribee">Werribee</option>
									<option value="mernda">Mernda</option>
									<option value="melton">Melton</option>
									<option value="glenroy">Glenroy</option>
									<option value="packenham">Packenham</option>
								</select>
							</div>
							<div class="col-md-2">
								<label for="selectOption">Title</label>
								<select class="form-control" id="addTitle" name="addTitle">
									<option value="mr">Mr</option>
									<option value="mrs">Mrs</option>
									<option value="ms">Ms</option>
									<option value="miss">Miss</option>
									<option value="other">Other</option>
								</select>
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-6">
								<label for="name">First Name:</label> <input type="text"
									class="form-control" id="addFirstName" name="addFirstName">
							</div>
							<div class="col-md-6">
								<label for="name">Last Name:</label> <input type="text"
									class="form-control" id="addLastName" name="addLastName">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-5">
								<label for="name">Email</label>
								<input type="text" class="form-control" id="addEmail" name="addEmail">
							</div>
							<div class="col-md-6">
								<label for="name">Phone</label>
								<input type="text" class="form-control" id="addPhone" name="addPhone">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-12">
								<label for="name">Address</label> 
								<input type="text" class="form-control" id="addAddress" name="addAddress">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-4">
								<label for="name">Bank</label> 
								<input type="text" class="form-control" id="addBank" name="addBank">
							</div>
							<div class="col-md-3">
								<label for="name">Bsb</label> 
								<input type="text" class="form-control" id="addBsb" name="addBsb">
							</div>
							<div class="col-md-5">
								<label for="name">Account #</label> 
								<input type="text" class="form-control" id="addAccountNumber" name="addAccountNumber">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-5">
								<label for="name">TFN</label> 
								<input type="text" class="form-control" id="addTfn" name="addTfnr">
							</div>
							<div class="col-md-4">
								<label for="name">Superannuation</label> 
								<input type="text" class="form-control" id="addSuperannuation" name="addSuperannuation">
							</div>
							<div class="col-md-3">
								<label for="name"> Membership #</label> 
								<input type="text" class="form-control" id="addSuperMember" name="addSuperMember">
							</div>
						</div>
					</div>

					<div class="form-group">
						<div class="form-row">
							<div class="col-md-12">
								<label for="message">Memo</label>
								<textarea class="form-control" id="addMemo" name="addMemo"></textarea>
							</div>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="submit" class="btn btn-primary" onclick="addTeacher()">Register</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editTeacherModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h4 class="modal-title" id="modalEditLabel">Teacher Edit</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			</div>
			<div class="modal-body">
				<form id="teacherEdit">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-4">
								<label for="selectOption">State</label> <select
									class="form-control" id="editState" name="editState">
									<option value="vic">Victoria</option>
									<option value="nsw">New South Wales</option>
									<option value="qld">Queensland</option>
									<option value="sa">South Australia</option>
									<option value="tas">Tasmania</option>
									<option value="wa">Western Australia</option>
									<option value="nt">Northern Territory</option>
									<option value="act">ACT</option>
								</select>
							</div>
							<div class="col-md-6">
								<label for="selectOption">Branch</label> <select
									class="form-control" id="editBranch" name="editBranch">
									<option value="braybrook">Braybrook</option>
									<option value="epping">Epping</option>
									<option value="balwyn">Balwyn</option>
									<option value="bayswater">Bayswater</option>
									<option value="boxhill">Box Hill</option>
									<option value="carolinesprings">Caroline Springs</option>
									<option value="chadstone">Chadstone</option>
									<option value="craigieburn">Craigieburn</option>
									<option value="cranbourne">Cranbourne</option>
									<option value="glenwaverley">Glen Waverley</option>
									<option value="mitcha">Mitcham</option>
									<option value="narrewarren">Narre Warren</option>
									<option value="ormond">Ormond</option>
									<option value="pointcook">Point Cook</option>
									<option value="preston">Preston</option>
									<option value="springvale">Springvale</option>
									<option value="stalbans">St Albans</option>
									<option value="werribee">Werribee</option>
									<option value="mernda">Mernda</option>
									<option value="melton">Melton</option>
									<option value="glenroy">Glenroy</option>
									<option value="packenham">Packenham</option>
								</select>
							</div>
							<div class="col-md-2">
								<label for="selectOption">Title</label>
								<select class="form-control" id="editTitle" name="editTitle">
									<option value="mr">Mr</option>
									<option value="mrs">Mrs</option>
									<option value="ms">Ms</option>
									<option value="miss">Miss</option>
									<option value="other">Other</option>
								</select>
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-2">
							<label for="name">Id:</label> <input type="text"
								class="form-control" id="editId" name="editId" readonly>
							</div>
							<div class="col-md-5">
								<label for="name">First Name:</label> <input type="text"
									class="form-control" id="editFirstName" name="editFirstName">
							</div>
							<div class="col-md-5">
								<label for="name">Last Name:</label> <input type="text"
									class="form-control" id="editLastName" name="editLastName">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-5">
								<label for="name">Email</label>
								<input type="text" class="form-control" id="editEmail" name="editEmail">
							</div>
							<div class="col-md-6">
								<label for="name">Phone</label>
								<input type="text" class="form-control" id="editPhone" name="editPhone">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-12">
								<label for="name">Address</label> 
								<input type="text" class="form-control" id="editAddress" name="editAddress">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-4">
								<label for="name">Bank</label> 
								<input type="text" class="form-control" id="editBank" name="editBank">
							</div>
							<div class="col-md-3">
								<label for="name">Bsb</label> 
								<input type="text" class="form-control" id="editBsb" name="editBsb">
							</div>
							<div class="col-md-5">
								<label for="name">Account #</label> 
								<input type="text" class="form-control" id="editAccountNumber" name="editAccountNumber">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-5">
								<label for="name">TFN</label> 
								<input type="text" class="form-control" id="editTfn" name="editTfn">
							</div>
							<div class="col-md-4">
								<label for="name">Superannuation</label> 
								<input type="text" class="form-control" id="editSuperannuation" name="editSuperannuation">
							</div>
							<div class="col-md-3">
								<label for="name"> Membership #</label> 
								<input type="text" class="form-control" id="editSuperMember" name="editSuperMember">
							</div>
						</div>
					</div>
		
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-12">
								<label for="message">Memo</label>
								<textarea class="form-control" id="editMemo" name="editMemo"></textarea>
							</div>
						</div>
					</div>
				
				
				
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="submit" class="btn btn-primary" onclick="updateTeacherInfo()">Save</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal -->










<!--  Password Modal HTML -->
<div id="passwordStudentModal" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<form method="POST" action="${pageContext.request.contextPath}/changePassword">
				<div class="modal-header">
					<h4 class="modal-title">Change Password</h4>
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				</div>
				<div class="modal-body">
					<div class="form-group">
						<label>Password</label> <input type="password" class="form-control" required="required" name="passwordpassword" id="passwordpassword" />
					</div>
					<div class="form-group">
						<label>Confirm Password</label> <input type="password" class="form-control" required="required" name="confirmPasswordpassword" id="confirmPasswordpassword"/>
					</div>
				</div>
				<div class="modal-footer">
					<input type="button" class="btn btn-default" data-dismiss="modal" value="Cancel">
					<button type="submit" class="btn btn-info" onclick="return passwordChange();">Change Password</button> 
					<input type="hidden" name="usernamepassword" id="usernamepassword" />
				</div>
			</form>
		</div>
	</div>
</div>
























<!-- Success Message Modal -->
<div class="modal fade" id="success-alert" tabindex="-1"
	aria-labelledby="successModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="successModalLabel">Success!</h5>
				<button type="button" class="close" data-dismiss="modal"
					aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body"></div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>


<!-- Info Dialogue -->
<div class="modal fade" id="infoModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
				<header class="text-primary font-weight-bold">Teacher Memo</header>
				<br>
				Please Add Memo
				<form id="showInformation">
					<div class="form-row mt-4">
						<div class="col-md-12">
							<textarea class="form-control" id="information" name="information" style="height: 8rem;"></textarea>
						</div>
					</div>
					<input type="hidden" id="infoDataId" name="infoDataId"></input>
					<div class="d-flex justify-content-end mt-4">
						<button type="button" class="btn btn-primary" onclick="updateMemoInformation()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="document.getElementById('showInformation').reset();">Cancel</button>
					</div>
				</form>	
				</section>
			</div>
		</div>
	</div>
</div>
