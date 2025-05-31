<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<script>
$(function() {

	// initiate datepicker
	$( "#formRegisterDate" ).datepicker({
		dateFormat: 'dd/mm/yy'
	});
	$( "#addRegisterDate" ).datepicker({
		dateFormat: 'dd/mm/yy'
	});
	// key enter event for 'formKeyword' field
	$('#formKeyword').keypress(function(event){
		var keycode = (event.keyCode ? event.keyCode : event.which);
		if(keycode == '13'){
			searchStudent();
		}
	});
	// initialise state, branch, grade list when loading
	listState('#formState');
	listState('#addState');
	// listBranch('#formBranch'); - initialised issue if URL contains student Id, so better to initialise manually.
	listBranch('#addBranch');
	// listGrade('#formGrade')
	listGrade('#addGrade');

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#formBranch").val(window.branch);
				$("#addBranch").val(window.branch);
				// Disable #formBranch and #addBranch
				$("#formBranch").prop('disabled', true);
				$("#addBranch").prop('disabled', true);
			}
		});
	}

});
	
///////////////////////////////////////////////////////////////////////////
// 		Add Student
///////////////////////////////////////////////////////////////////////////
function addStudent() {

	// lastName, email, password validation
	var last = document.getElementById('addLastName');
	if(last.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter last name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			last.focus();
		});
		return false;
	}
	var email = document.getElementById('addEmail1');
	if(email.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	let regex = new RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
	if(!regex.test(email.value)){
		$('#validation-alert .modal-body').text(
		'Please enter valid main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}

	// Get from form data
	var std = {
		firstName : $("#addFirstName").val(),
		lastName : $("#addLastName").val(),
		gender : $("#addGender").val(),
		password : $("#addPassword").val(),
		email1 : $("#addEmail1").val(),
		email2 : $("#addEmail2").val(),
		relation1 : $("#addRelation1").val(),
		relation2 : $("#addRelation2").val(),
		contactNo1 : $("#addContact1").val(),
		contactNo2 : $("#addContact2").val(),
		address : $("#addAddress").val(),
		memo : $("#addMemo").val(),
		state : $("#addState").val(),
		branch : $("#addBranch").val(),
		grade : $("#addGrade").val(),
		registerDate : $("#addRegisterDate").val(),
	}
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/student/register',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(std),
		contentType : 'application/json',
		success : function(student) {
			//debugger;
			// Display the success alert
			$('#success-alert .modal-body').html('New student is registered successfully.');
			$('#success-alert').modal('toggle');
			// Update display info
			$("#formId").val(student.id);
			$("#formFirstName").val(student.firstName);
			$("#formLastName").val(student.lastName);
			$("#formEmail1").val(student.email1);
			$("#formEmail2").val(student.email2);
			$("#formRelation1").val(student.relation1);
			$("#formRelation2").val(student.relation2);
			$("#formGrade").val(student.grade);
			$("#formGender").val(student.gender);
			$("#formAddress").val(student.address);
			$("#formContact1").val(student.contactNo1);
			$("#formContact2").val(student.contactNo2);
			$("#formMemo").val(student.memo);
			$("#formState").val(student.state);
			$("#formBranch").val(student.branch);
			$('#formActive').prop('checked', true);
			$("#formActive").prop("disabled", true);
			// Set date value
			var date = new Date(student.registerDate); // Replace with your date value
			$("#formRegisterDate").datepicker('setDate', date);

			// clear enrolment basket
			clearEnrolmentBasket();
			// clear invoice table
			clearInvoiceTable();
			// clear course register section
			clearCourseRegisteration();
			// clear attendance table
			clearAttendanceTable();
			// ready for course registration
			readyForCourseRegistration(student.grade);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerModal').modal('hide');
	// flush all registered data
	document.getElementById("studentRegister").reset();		
	// if staff, set branch to current branch
	if(!JSON.parse(window.isAdmin)){
		$("#formBranch").val(window.branch);
		$("#addBranch").val(window.branch);
	}

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Deactivate student
////////////////////////////////////////////////////////////////////////////////////////////////////////
function inactivateStudent() {
	var id = $("#formId").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search student record before suspend');
		$('#warning-alert').modal('toggle');
		return;
	}

	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/inactivate/' + id,
		type : 'PUT',
		success : function(data) {
			$('#deactivateModal').modal('hide');
			$('#success-alert .modal-body').html('ID : <b>' + id + '</b> is now suspended');
			$('#success-alert').modal('toggle');
			clearStudentForm();
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	}); 
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Re-activate student
////////////////////////////////////////////////////////////////////////////////////////////////////////
function reactivateStudent() {
	var id = $("#formId").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search student record before activate');
		$('#warning-alert').modal('toggle');
		return;
	}
		// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/activate/' + id,
		type : 'PUT',
		success : function(data) {
			$('#success-alert .modal-body').html('ID : <b>' + id + '</b> is now activated');
			$('#success-alert').modal('toggle');
			displayStudentInfo(data);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	}); 
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Update password
////////////////////////////////////////////////////////////////////////////////////////////////////////
function updatePassword() {
	var id = $("#formId").val();
	var newPwd = $("#newPwd").val();
	var confirmPwd = $("#confirmPwd").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search student record before password reset');
		$('#warning-alert').modal('toggle');
		return;
	}
	// warn if newPwd or confirmPwd is empty
	if (newPwd == '' || confirmPwd == '') {
		$('#warning-alert .modal-body').text('Please enter new password and confirm password');
		$('#warning-alert').modal('toggle');
		return;
	}
	//warn if newPwd is not same as confirmPwd
	if(newPwd != confirmPwd){
		$('#warning-alert .modal-body').text('New password and confirm password are not the same');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/updatePassword/' + id + '/' + confirmPwd,
		type : 'PUT',
		success : function(data) {
			console.log(data);
			$('#success-alert .modal-body').html('<b>Password</b> is now updated');
			$('#success-alert').modal('toggle');
			// clear fields
			clearPassword();
			// close modal
			$('#passwordModal').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
		
	}); 
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Clear password fields
////////////////////////////////////////////////////////////////////////////////////////////////////////
function clearPassword() {
	$("#newPwd").val('');
	$("#confirmPwd").val('');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//			Search Student with Keyword	
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStudent() {
	//warn if keyword is empty
	if ($("#formKeyword").val() == '') {
		$('#warning-alert .modal-body').text('Please fill in keyword before search');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$('#studentListResultTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/student/search',
		type : 'GET',
		data : {
			keyword : $("#formKeyword").val(),
			state : window.state,
			branch : window.branch
		},
		success : function(data) {
			//console.log('search - ' + data);
			if (data == '') {
				$('#warning-alert .modal-body').html('No record found with <b>' + $("#formKeyword").val() + '</b>');
				$('#warning-alert').modal('toggle');
				clearStudentForm();
				return;
			}
			$.each(data, function(index, value) {
				const cleaned = cleanUpJson(value);
				var row = $("<tr onclick='displayStudentInfo(" + cleaned + ")'>");		
				row.append($('<td>').text(value.id));
				row.append($('<td>').text(value.firstName));
				row.append($('<td>').text(value.lastName));
				var gradeText = gradeName(value.grade);
				row.append($('<td>').text(gradeText));
				row.append($('<td class="text-capitalize">').text((value.gender === "") ? "" : value.gender));	
				row.append($('<td>').text(formatDate(value.registerDate)));
				row.append($('<td>').text(formatDate(value.endDate)));
				row.append($('<td>').text(value.email1));
				row.append($('<td>').text(value.contactNo1));
				row.append($('<td>').text(value.email2));
				row.append($('<td>').text(value.contactNo2));
				row.append($('<td>').text(value.address));
				$('#studentListResultTable > tbody').append(row);
			});
			$('#studentListResult').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update existing student
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function updateStudentInfo() {
	// check if student search is done
	if($("#formId").val() == ''){
		$('#warning-alert .modal-body').text('Please search student record before update');
		$('#warning-alert').modal('toggle');
		return;
	}

	// lastName, email, password validation
	var last = document.getElementById('formLastName');
	if(last.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter last name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			last.focus();
		});
		return false;
	}
	var email = document.getElementById('formEmail1');
	if(email.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	let regex = new RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
	if(!regex.test(email.value)){
		$('#validation-alert .modal-body').text(
		'Please enter valid main email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}

	// if activate process, then call activateStudent()
	// if($('#formEndDate').val()!='' && $('#formActive').prop('checked')){
	if($('#formActiveStatus').val()=='0' && $('#formActive').prop('checked')){
		reactivateStudent();
		return;
	}		
	//warn if Id is empty
	if ($("#formId").val() == '') {
		$('#warning-alert .modal-body').text('Please search student record before update');
		$('#warning-alert').modal('toggle');
		return;
	}
	// get from formData
	var std = {
		id : $('#formId').val(),
		firstName : $("#formFirstName").val(),
		lastName : $("#formLastName").val(),
		email1 : $("#formEmail1").val(),
		email2 : $("#formEmail2").val(),
		relation1 : $("#formRelation1").val(),
		relation2 : $("#formRelation2").val(),
		address : $("#formAddress").val(),
		contactNo1 : $("#formContact1").val(),
		contactNo2 : $("#formContact2").val(),
		gender : $("#formGender").val(),
		memo : $("#formMemo").val(),
		state : $("#formState").val(),
		branch : $("#formBranch").val(),
		grade : $("#formGrade").val(),
		registerDate : $("#formRegisterDate").val(),
	}
	var user = window.username;
		
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/update',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify({student: std, user: user}),
		contentType : 'application/json',
		success : function(value) {
			// Display success alert
			$('#success-alert .modal-body').html('ID : <b>' + $("#formId").val() + '</b> is updated successfully.');
			$('#success-alert').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display selected student in student search
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function displayStudentInfo(value) {
	clearStudentForm();
	console.log(value);
	$("#formId").val(value['id']);
	if(value['active']===1){ // active student
		$("#formFirstName").val(value['firstName']).css("color", "black").prop('disabled', false);
		$("#formLastName").val(value['lastName']).css("color", "black").prop('disabled', false);
		$("#formEmail1").val(value['email1']).css("color", "black").prop('disabled', false);
		$("#formEmail2").val(value['email2']).css("color", "black").prop('disabled', false);
		$("#formRelation1").val(value['relation1']).css("color", "black").prop('disabled', false);
		$("#formRelation2").val(value['relation2']).css("color", "black").prop('disabled', false);
		$("#formGrade").val(value['grade']).css("color", "black").prop('disabled', false);
		$("#formGender").val(value['gender']).css("color", "black").prop('disabled', false);
		$("#formAddress").val(value['address']).css("color", "black").prop('disabled', false);
		$("#formContact1").val(value['contactNo1']).css("color", "black").prop('disabled', false);
		$("#formContact2").val(value['contactNo2']).css("color", "black").prop('disabled', false);
		$("#formMemo").val(value['memo']).css("color", "black").prop('disabled', false);
		$("#formState").prop('disabled', true);
		if(!JSON.parse(window.isAdmin)){ // if staff, disable branch choice
			$("#formBranch").prop('disabled', true);
		}
		$("#formRegisterDate").prop('disabled', false);
		$('#formActive').prop('checked', true);
		$("#formActive").prop("disabled", true);
	}else{ // inactive student
		$("#formFirstName").val(value['firstName']).css("color", "red").prop('disabled', true);
		$("#formLastName").val(value['lastName']).css("color", "red").prop('disabled', true);
		$("#formEmail1").val(value['email1']).css("color", "red").prop('disabled', true);
		$("#formEmail2").val(value['email2']).css("color", "red").prop('disabled', true);
		$("#formRelation1").val(value['relation1']).css("color", "red").prop('disabled', true);
		$("#formRelation2").val(value['relation2']).css("color", "red").prop('disabled', true);
		$("#formGrade").val(value['grade']).css("color", "red").prop('disabled', true);
		$("#formGender").val(value['gender']).css("color", "red").prop('disabled', true);
		$("#formAddress").val(value['address']).css("color", "red").prop('disabled', true);
		$("#formContact1").val(value['contactNo1']).css("color", "red").prop('disabled', true);
		$("#formContact2").val(value['contactNo2']).css("color", "red").prop('disabled', true);
		$("#formMemo").val(value['memo']).css("color", "red").prop('disabled', true);
		$("#formState").prop('disabled', true);
		$("#formRegisterDate").prop('disabled', true);
		$('#formActive').prop('checked', false);
		$("#formActive").prop("disabled", false);
	}
	$("#formState").val(value['state']);
	$("#formBranch").val(value['branch']);
	$("#formEndDate").val(value['endDate']);
	$("#formActiveStatus").val(value['active']);
	
	// set dateFormat again for direct link from enrolment page
	$("#formRegisterDate").datepicker({
		dateFormat: 'dd/mm/yy'
	});
	var date = new Date(value['registerDate']); // Replace with your date value
	$("#formRegisterDate").datepicker('setDate', date);
	
	// dispose modal
	$('#studentListResult').modal('hide');
	// clear search keyword
	$("#formKeyword").val('');

	// associate courseInfo.jsp 
	// 1. display same selected grade to Course Register section in courseInfo.jsp
	readyForCourseRegistration(value['grade']);
	// 2. trigger 'retrieveEnrolment' in courseInfo.jsp
	retrieveEnrolment(value['id']);
	// 3. trigger 'retrievAttenance' in attendanceInfo.jsp
	retrieveAttendance(value['id']);

}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear All Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearStudentForm() {
	document.getElementById("studentInfo").reset();
	
	// Enable fields and set text color to black except state, branch, id, and activated
	$("#formFirstName, #formLastName, #formEmail1, #formEmail2, #formRelation1, #formRelation2, #formGrade, #formGender, #formAddress, #formContact1, #formContact2, #formMemo, #formRegisterDate").each(function() {
		$(this).prop('disabled', false).css("color", "black");
	});

	// clear enrolment basket
	clearEnrolmentBasket();
	// clear invoice table
	clearInvoiceTable();
	// clear course register section
	clearCourseRegisteration();
	// clear attendance table
	clearAttendanceTable();
	// clear passwords
	clearPassword();
	// if staff, set branch to current branch
	if(!JSON.parse(window.isAdmin)){
		$("#formBranch").val(window.branch);
		$("#addBranch").val(window.branch);
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 	Initialise Course Register section
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function readyForCourseRegistration(grade){
	$("#registerGrade").val(grade);
	listCourses(grade);
	listBooks(grade);	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 	Clear Course Register section
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function clearCourseRegisteration(){
	// reset course register section
	document.getElementById("courseRegister").reset();	
	$('#basketTable > tbody').empty();
	$('#elearnTable > tbody').empty();		
	$('#courseTable > tbody').empty();
	$('#bookTable > tbody').empty();			
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 	Search Student by Id
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStudentById(id){
	$.ajax({
		url : '${pageContext.request.contextPath}/student/get/' + id,
		type : 'GET',
		success : function(data) {
			displayStudentInfo(data);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


</script>

<!-- Search Result Dialog -->
<div class="modal fade" id="studentListResult">
	<div class="modal-dialog modal-xl modal-dialog-centered">
	  <div class="modal-content jae-border-primary">
		<div class="modal-header bg-primary text-white">
		  <h5 class="modal-title text-white"><i class="ml-2bi bi-card-list"></i>&nbsp;&nbsp; Student List</h5>
		  <button type="button" class="close" data-dismiss="modal">
			<span>&times;</span>
		  </button>
		</div>
		<div class="modal-body table-wrap">
		  <table class="table table-striped table-bordered" id="studentListResultTable" data-header-style="headerStyle" style="font-size: smaller;">
			<thead class="thead-light">
			  <tr>
				<th data-field="id">ID</th>
				<th data-field="firstname">First Name</th>
				<th data-field="lastname">Last Name</th>
				<th data-field="grade">Grade</th>
				<th data-field="grade">Gender</th>
				<th data-field="startdate">Start Date</th>
				<th data-field="enddate">End Date</th>
				<th data-field="email">Main Email</th>
				<th data-field="contact1">Main Contact</th>
				<th data-field="email">Sub Email</th>
				<th data-field="contact2">Sub Contact</th>
				<th data-field="address">Address</th>
			  </tr>
			</thead>
			<tbody>
			</tbody>
		  </table>
		</div>
		<div class="modal-footer">
		  <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
		</div>
	  </div>
	</div>
</div>
  
<style>
	.table-wrap {
	  overflow-x: auto;
	}
	#studentListResultTable th, #studentListResultTable td { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	.form-group{
		margin-bottom: 30px;
	}
</style>

<!-- Administration Body -->
<div class="modal-body">
	<form id="studentInfo">
		<div class="form-row">
			<div class="col-md-8">
				<input type="text" class="form-control" style="background-color: #FCF7CA;" id="formKeyword" name="formKeyword" placeholder="ID, Name, Email or Mobile Number" />
			</div>
			<div class="col-md-4 d-flex justify-content-center align-items-center" data-toggle="tooltip" title="Search Student by Id/Name">
				<button type="button" class="btn btn-block btn-primary" onclick="searchStudent()"><i class="bi bi-search"></i></button>
			</div>
		</div>

		<div class="form-row mt-3">
			<div class="col mx-auto"  data-toggle="tooltip"  title="Register New Student">
				<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerModal"><i class="bi bi-plus-circle"></i></button>
			</div>
			<div class="col mx-auto" data-toggle="tooltip" title="Update Student Information">
				<button type="button" class="btn btn-block btn-success" onclick="updateStudentInfo()"><i class="bi bi-pencil-square"></i></button>
			</div>
			<div class="col mx-auto" data-toggle="tooltip" title="Reset Student Password">
				<button type="button" class="btn btn-block btn-warning" data-toggle="modal" data-target="#passwordModal" onclick="clearPassword()"><i class="bi bi-key-fill"></i></button>
			</div>
			<div class="col mx-auto" data-toggle="tooltip" title="Inactivate Student">
				<button type="button" class="btn btn-block btn-danger" data-toggle="modal" data-target="#deactivateModal"><i class="bi bi-pause"></i></button>
			</div>
			<div class="col mx-auto" data-toggle="tooltip" title="Clear Student Information">
				<button type="button" class="btn btn-block btn-secondary" onclick="clearStudentForm()"><i class="bi bi-eraser"></i></button>
			</div>
		</div>
		<div class="form-row mt-3">
			<div class="col-md-4">
				<label for="formState" class="label-form">State</label> 
				<select class="form-control" id="formState" name="formState" disabled>
				</select>
			</div>
			<div class="col-md-4">
				<label for="formBranch" class="label-form">Branch</label> 
				<select class="form-control" id="formBranch" name="formBranch">	
					<option value="12">Box Hill</option>
					<option value="13">Braybrook</option>
					<option value="15">Cranbourne</option>
					<option value="16">Epping</option>
					<option value="17">Glen Waverley</option>
					<option value="18">Narre Warren</option>
					<option value="19">Mitcham</option>
					<option value="20">Preston</option>
					<option value="21">Richmond</option>
					<option value="22">Springvale</option>
					<option value="23">St.Albans</option>
					<option value="24">Werribee</option>
					<option value="25">Balwyn</option>
					<option value="26">Rowville</option>
					<option value="27">Caroline Springs</option>
					<option value="28">Bayswater</option>
					<option value="29">Point Cook</option>
					<option value="30">Craigieburn</option>
					<option value="31">Mernda</option>
					<option value="32">Melton</option>
					<option value="33">Glenroy</option>
					<option value="34">Pakenham</option>
					<option value="35">Tarneit</option>
					<option value="36">Clyde</option>
					<option value="90">JAC Head Office Vic</option>
					<option value="99">Testing</option>				
				</select>
			</div>
			<div class="col-md-4">
				<label for="formRegisterDate" class="label-form">Registration Date</label> <input type="text" class="form-control datepicker" id="formRegisterDate" name="formRegisterDate" placeholder=" Select a date" required>
			</div>
		</div>
		<div class="form-row mt-3">
			<div class="col-md-4">
				<input type="text"
					class="form-control" id="formId" name="formId" placeholder="ID" readonly>
			</div>
			<div class="input-group col-md-5">
				<div class="input-group-prepend">
				<div class="input-group-text">
					<input type="checkbox" id="formActive" name="formActive" disabled>
				</div>
				</div>
				<input type="text" id="formActiveLabel" class="form-control" placeholder="Activated" readonly>
			</div>
			<div class="col-md-3">
				<!-- <select class="form-control" id="formGrade" name="formGrade">
				</select> -->
				<select class="form-control" id="formGrade" name="formGrade">
					<option value="1">P2</option>
					<option value="2">P3</option>
					<option value="3">P4</option>
					<option value="4">P5</option>
					<option value="5">P6</option>
					<option value="6">S7</option>
					<option value="7">S8</option>
					<option value="8">S9</option>
					<option value="9">S10</option>
					<option value="10">S10E</option>
					<option value="11">TT6</option>
					<option value="12">TT8</option>
					<option value="13">TT8E</option>
					<option value="14">SRW4</option>
					<option value="15">SRW5</option>
					<option value="16">SRW6</option>
					<option value="17">SRW7</option>
					<option value="18">SRW8</option>
					<option value="19">JMSS</option>
					<option value="20">VCE</option>
				</select>
			</div>
		</div>
		<div class="form-row mt-3">
			<div class="col-md-5">
				<input type="text"
					class="form-control" id="formFirstName" name="formFirstName" placeholder="First Name">
			</div>
			<div class="col-md-4">
				<input type="text" class="form-control" id="formLastName" name="formLastName" placeholder="Last Name">
			</div>
			<div class="col-md-3">
				<select class="form-control" id="formGender" name="formGender">
					<option value="male">Male</option>
					<option value="female">Female</option>
				</select>
			</div>
		</div>
		<div class="form-row mt-3">
			<div class="col-md-12">
				<input type="text" class="form-control" id="formAddress" name="formAddress" placeholder="Address">
			</div>
			
		</div>
		<div class="form-row">
			<div class="col-md-12 mt-2">
				<section class="fieldset rounded" style="padding: 10px;">
					<header class="label-form" style="font-size: 0.9em!important;">Main Contact</header>
				<div class="row">
					<div class="col-md-8">
						<input type="text" class="form-control" id="formContact1" name="formContact1" placeholder="Contact No">
					</div>
					<div class="col-md-4">
						<select class="form-control" id="formRelation1" name="formRelation1">
							<option value="mother">Mother</option>
							<option value="father">Father</option>
							<option value="sibling">Sibling</option>
							<option value="other">Other</option>
						</select>
					</div>	
				</div>
					<div class="row mt-2">
						<div class="col-md-12">
							<input type="text" class="form-control" id="formEmail1" name="formEmail1" placeholder="Email">
						</div>
					</div>
				</section>
			</div>
		</div>
		<div class="form-row">
			<div class="col-md-12">
				<section class="fieldset rounded" style="padding: 10px;">
					<header class="label-form" style="font-size: 0.9em !important;">Sub Contact</header>
				<div class="row">
					<div class="col-md-8">
						<input type="text" class="form-control" id="formContact2" name="formContact2" placeholder="Contact No">
					</div>
					<div class="col-md-4">
						<select class="form-control" id="formRelation2" name="formRelation2">
							<option value="father">Father</option>
							<option value="mother">Mother</option>
							<option value="sibling">Sibling</option>
							<option value="other">Others</option>
						</select>
					</div>
				</div>
				<div class="row mt-2">
					<div class="col-md-12">
						<input type="text" class="form-control" id="formEmail2" name="formEmail2" placeholder="Email">
					</div>
				</div>
				</section>
			</div>
		</div>
		<div class="form-row mt-3">
			<div class="col-md-12">
				<textarea class="form-control" id="formMemo" name="formMemo" style="height: 185px;" placeholder="Memo"></textarea>
			</div>
		</div>
		<input type="hidden" id="formEndDate" name="formEndDate" />
		<input type="hidden" id="formActiveStatus" name="formActiveStatus" />
	</form>
</div>

<!-- Register Form Dialogue -->
<div class="modal fade" id="registerModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
				<header class="text-info font-weight-bold">Student Registration</header>
				<form id="studentRegister">
					<div class="form-row mt-1">
						<div class="col-md-4">
							<label for="addState" class="label-form">State</label> 
							<select class="form-control" id="addState" name="addState" disabled>
							</select>
						</div>
						<div class="col-md-5">
							<label for="addBranch" class="label-form">Branch</label> 
							<select class="form-control" id="addBranch" name="addBranch">
							</select>
						</div>
						<div class="col-md-3">
							<label for="addRegisterDate" class="label-form">Registration</label> 
							<input type="text" class="form-control datepicker" id="addRegisterDate" name="addRegisterDate" placeholder="dd/mm/yyyy">
						</div>
						<script>
							function setTodayDate() {
								var today = new Date();
								var day = today.getDate();
								var month = today.getMonth() + 1; // Note: January is 0
								var year = today.getFullYear();
								var formattedDate = (day < 10 ? '0' : '') + day + '/' + (month < 10 ? '0' : '') + month + '/' + year;
								document.getElementById('addRegisterDate').value = formattedDate;
							}
							// Assuming your modal has an id of 'myModal'
    						$('#registerModal').on('shown.bs.modal', function () {
								setTodayDate();
							});
						</script>
					</div>
					<div class="form-row mt-3">
						<div class="col-md-5">
							<label for="addFirstName" class="label-form">First Name:</label> <input type="text" class="form-control" id="addFirstName" name="addFirstName">
						</div>
						<div class="col-md-4">
							<label for="addLastName" class="label-form">Last Name:</label> <input type="text" class="form-control" id="addLastName" name="addLastName" required="">
						</div>
						<div class="col-md-3">
							<label for="addGrade" class="label-form">Grade</label> <select class="form-control" id="addGrade" name="addGrade"></select>
						</div>
					</div>
					<div class="form-row mt-3">
						<div class="col-md-3">
							<label for="addGender" class="label-form">Gender</label> <select class="form-control" id="addGender" name="addGender">
								<option value="male">Male</option>
								<option value="female">Female</option>
							</select>
						</div>
						<div class="col-md-9">
							<label for="addAddress" class="label-form">Address</label> <input type="text" class="form-control" id="addAddress" name="addAddress">
						</div>
					</div>
					<div class="form-row mt-3">
						<div class="col-md-12 mt-2">
							<section class="fieldset rounded" style="padding: 10px;">
								<header class="label-form" style="font-size: 0.9rem!important;">Main Contact</header>
							<div class="row">
								<div class="col-md-8">
									<input type="text" class="form-control" id="addContact1" name="addContact1" placeholder="Contact No">
								</div>
								<div class="col-md-4">
									<select class="form-control" id="addRelation1" name="addRelation1">
										<option value="mother">Mother</option>
										<option value="father">Father</option>
										<option value="sibling">Sibling</option>
										<option value="other">Other</option>
									</select>
								</div>	
							</div>
							<div class="row mt-2">
								<div class="col-md-12">
									<input type="text" class="form-control" id="addEmail1" name="addEmail1" placeholder="Email">
								</div>
							</div>
							</section>
						</div>
					</div>
					<div class="form-row">
						<div class="col-md-12">
							<section class="fieldset rounded" style="padding: 10px;">
								<header class="label-form" style="font-size: 0.9rem!important;">Sub Contact</header>
							<div class="row">
								<div class="col-md-8">
									<input type="text" class="form-control" id="addContact2" name="addContact2" placeholder="Contact No">
								</div>
								<div class="col-md-4">
									<select class="form-control" id="addRelation2" name="addRelation2">
										<option value="mother">Mother</option>
										<option value="father">Father</option>
										<option value="sibling">Sibling</option>
										<option value="other">Other</option>
									</select>
								</div>
							</div>
							<div class="row mt-2">
								<div class="col-md-12">
									<input type="text" class="form-control" id="addEmail2" name="addEmail2" placeholder="Email">
								</div>
							</div>
							</section>
						</div>
					</div>
					<div class="form-row mt-2">
						<div class="col-md-12">
							<label for="addMemo" class="label-form">Memo</label>
							<textarea class="form-control" style="height: 200px;" id="addMemo" name="addMemo"></textarea>
						</div>
					</div>
				</form>
				<div class="d-flex justify-content-end">
    				<button type="submit" class="btn btn-info" onclick="addStudent()">Register</button>&nbsp;&nbsp;
    				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				</div>	
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Password Reset Dialogue -->
<div class="modal fade" id="passwordModal" tabindex="-1" role="dialog" aria-labelledby="passwordModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
		<div class="modal-content jae-border-warning">
            <div class="modal-header bg-warning">
               <h4 class="modal-title text-white" id="passwordModal"><i class="bi bi-key-fill text-dark"></i>&nbsp;&nbsp;Student Password Reset</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <h5> Do you want to reset password for this student?</h5>
				<p>
					<div class="row mt-4">
						<div class="col-md-5">
							New Password
						</div>
						<div class="col-md-7">
							<input type="password" class="form-control" id="newPwd" name="newPwd"/>
						</div>
					</div>
					<div class="row mt-4">
						<div class="col-md-5">
							Confirm Password
						</div>
						<div class="col-md-7">
							<input type="password" class="form-control" id="confirmPwd" name="confirmPwd"/>
						</div>
					</div>
				</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-warning" onclick="updatePassword()"><i class="bi bi-check-circle"></i>&nbsp;Reset</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
            </div>
    	</div>
	</div>
</div>

<!-- Deactivate Dialogue -->
<div class="modal fade" id="deactivateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="myModalLabel"><i class="bi bi-pause"></i>&nbsp;&nbsp;Student Suspend</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Do you want to suspend this student?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" onclick="inactivateStudent()"><i class="bi bi-check-circle"></i> Suspend</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>

