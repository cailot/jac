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

// var branch = window.branch;
var academicYear = '';
var academicWeek = '';
var listActive = 0;

var listTable = null;

$(document).ready(function () {
    // $('#studentListTable').DataTable({
	listTable = $('#studentListTable').DataTable({
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
		columns: [
			{ title: "ID", className: "align-middle text-center" },
			{ title: "First Name", className: "align-middle text-left" },
			{ title: "Last Name", className: "align-middle text-left" },
			{ title: "Grade", className: "align-middle text-center" },
			{ title: "Class", className: "align-middle text-left" },
			{ title: "Start", className: "align-middle text-center" },
			{ title: "End", className: "align-middle text-center" },
			{ title: "Email", className: "align-middle text-left" },
			{ title: "Contact", className: "align-middle text-left" },
			{ title: "Action", className: "align-middle text-center", orderable: false }
		]
		//pageLength: 20
    });
    
	$('table .password').on('click', function(){
		var username = $(this).parent().find('#username').val();
		$('#passwordModal #usernamepassword').val(username);
	});
	
	$("#addRegisterDate").datepicker({
		dateFormat: 'dd/mm/yy'
	});
	$("#editRegisterDate").datepicker({
		dateFormat: 'dd/mm/yy'
	});
	// initialise state list when loading
	listState('#listState');
	listState('#editState');
	listBranch('#listBranch');
	listBranch('#editBranch');
	listGrade('#editGrade');

	// only for Staff
	if(!JSON.parse(window.isAdmin)){
		// avoid execute several times
		//var hiddenInput = false;
		$(document).ajaxComplete(function(event, xhr, settings) {
			// Check if the request URL matches the one in listBranch
			if (settings.url === '/code/branch') {
				$("#listBranch").val(window.branch);
				// $("#addBranch").val(window.branch);
				// Disable #listBranch and #addBranch
				$("#listBranch").prop('disabled', true);
				// $("#addBranch").prop('disabled', true);
				$("#editBranch").prop('disabled', true);
			}
		});
	}

<c:if test="${empty sessionScope.GradeList}">

	// first loading, set current year & week
	$.ajax({
		url : '${pageContext.request.contextPath}/class/academy',
		method: "GET",
		success: function(response) {
			// save the response into the variable
			academicYear = response[0];
			academicWeek = response[1];
			$("#listYear").val(academicYear);
			$("#listWeek").val(academicWeek);
			// display grade summary
			displayGradeSummary(window.branch, academicYear, academicWeek, "0");

		},
		error: function(jqXHR, textStatus, errorThrown) {
			console.log('Error : ' + errorThrown);
		}
	});

</c:if>

});


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Grade Summary Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function displayGradeSummary(branch, year, week, active) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/gradeList?listState=1&listBranch=' + branch + '&listYear=' + year + '&listWeek=' + week + '&listActive=' + active,
		type : 'GET',
		success : function(items) {
			academicYear = year;
			academicWeek = week;
			listActive = active;
			// console.log('Year : ' + academicYear + ' Week : ' + academicWeek + ' Active : ' + listActive);
			// save the response into the variable
			updateSummaryTable(items);			
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Search Summary Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function searchSummaryInfo() {
	var branch = $("#listBranch").val();
	var year = $("#listYear").val();
	var week = $("#listWeek").val();
	var active = $("#listActive").val();
	// display grade summary
	displayGradeSummary(branch, year, week, active);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Summary Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateSummaryTable(items) {	
    var table = document.getElementById('statTable');
    // Flush tbody
    var thead = document.querySelector('#statTable thead');    
	var tbody = document.querySelector('#statTable tbody');
	thead.innerHTML = "";
    tbody.innerHTML = "";
    // Initialise tbody
    var total = 0;
	var thRow = document.createElement('tr');
    var tdRow = document.createElement('tr');
	// Calculate the percentage width for each column
    var columnWidth = 100 / (items.length + 1); // +1 for the total column

    $.each(items, function(index, item) {
		// Create a <th> cell
		var thCell = document.createElement('th');
		thCell.className = 'small text-center vertical-gap';
		thCell.style.width = columnWidth + '%';
		thCell.textContent = gradeName(item.name);		

        // Create a <td> cell
        var tdCell = document.createElement('td');
        tdCell.className = 'small text-center vertical-gap text-primary';
        tdCell.style.cursor = 'pointer';
        tdCell.setAttribute('grade', item.name);
        tdCell.onclick = function() {
            showStudentList(item.name);
        };
        tdCell.textContent = item.value;
        tdRow.appendChild(tdCell);
        // Update the total
        total += parseInt(item.value);

		thRow.appendChild(thCell);
    });

	var thTotalCell = document.createElement('th');
	thTotalCell.className = 'small text-center vertical-gap';
	thTotalCell.style.fontWeight = 'bold';
	thTotalCell.textContent = 'Total';
	thRow.appendChild(thTotalCell);

    // Add the total cell
    var tdTotalCell = document.createElement('td');
    tdTotalCell.className = 'small text-center vertical-gap text-primary';
    tdTotalCell.style.cursor = 'pointer';
    tdTotalCell.style.fontWeight = 'bold';
    tdTotalCell.setAttribute('grade', '0');
    tdTotalCell.onclick = function() {
        showStudentList('0');
    };
    tdTotalCell.textContent = total;
    tdRow.appendChild(tdTotalCell);

	// Append the row to the thead
	thead.appendChild(thRow);
    // Append the row to the tbody
    tbody.appendChild(tdRow);

	listTable.clear().draw(); // Clear table if no data
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate Student List	
////////////////////////////////////////////////////////////////////////////////////////////////////
function showStudentList(grade) {
    var branch = $("#listBranch").val();
    var year = $("#listYear").val();
    var week = $("#listWeek").val();
    var active = $("#listActive").val();
    $.ajax({
        url: '${pageContext.request.contextPath}/student/listByCondition?listState=1&listBranch=' + branch + '&listYear=' + year + '&listWeek=' + week + '&listActive=' + active + '&listGrade=' + grade,
        type: 'GET',
        success: function(items) {
            if (items.length > 0) {
                var rows = items.map(function(item) {
                    return [
                        '<td><span class="small hand-cursor" data-toggle="tooltip" title="Link to Student Information" id="studentId" name="studentId" onclick="linkToStudent(\'' + item.id + '\')">' + item.id + '</span></td>',
                        '<td><span class="small ellipsis text-truncate ml-1" style="max-width: 0; overflow: hidden;">' + item.firstName + '</span></td>',
                        '<td><span class="small ellipsis text-truncate ml-1" style="max-width: 0; overflow: hidden;">' + item.lastName + '</span></td>',
                        '<td><span class="small text-center">' + gradeName(item.grade) + '</span></td>',
                        '<td><span class="small">' + item.className + '</span></td>',
                        '<td><span class="small text-center">' + item.startWeek + '</span></td>',
                        '<td><span class="small text-center">' + item.endWeek + '</span></td>',
                        '<td><span class="small text-center">' + item.email1 + '</span></td>',
                        '<td><span class="small text-center">' + item.contactNo1 + '</span></td>',
                        '<td class="small text-center"><i class="bi bi-clock-history text-success fa-lg hand-cursor" data-toggle="tooltip" title="Payment History" onclick="displayFullHistory(' + item.id + ')"></i>' +
							'<i class="ml-2 bi bi-pencil-square text-primary hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveStudentInfo(' + item.id + ')"></i>' +
							'<i class="ml-2 bi bi-key text-warning hand-cursor" data-toggle="tooltip" title="Change Password" onclick="showPasswordModal(' + item.id + ')"></i>' +
							// '<i class="ml-2 bi bi-globe text-danger hand-cursor" data-toggle="tooltip" title="Go to JAC eLearning" onclick="openJACeLearning(' + item.id + ')"></i>' +
						'</td>'
                    ];
                });
                listTable.clear(); // Clear old data
                listTable.rows.add(rows).draw(); // Add new data

                // Initialize tooltips for dynamically added elements
				$('[data-toggle="tooltip"]').tooltip();

            } else {
                console.log("No data available");
                listTable.clear().draw(); // Clear table if no data
            }
        },
        error: function(xhr, status, error) {
            console.log('Error: ' + error);
        }
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateStudentInfo(){

	// lastName, email validation
	var last = document.getElementById('editLastName');
	if(last.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter last name');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			last.focus();
		});
		return false;
	}
	var email = document.getElementById('editEmail1');
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
	
	// get from formData
	var std = {
		id : $('#editId').val(),
		firstName : $("#editFirstName").val(),
		lastName : $("#editLastName").val(),
		email1 : $("#editEmail1").val(),
		email2 : $("#editEmail2").val(),
		address : $("#editAddress").val(),
		contactNo1 : $("#editContact1").val(),
		contactNo2 : $("#editContact2").val(),
		relation1 : $("#editRelation1").val(),
		relation2 : $("#editRelation2").val(),
		memo : $("#editMemo").val(),
		state : $("#editState").val(),
		branch : $("#editBranch").val(),
		grade : $("#editGrade").val(),
		gender : $("#editGender").val(),
		registerDate : $("#editRegisterDate").val()
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
			$('#success-alert .modal-body').html('ID : <b>' + std.id + '</b> is updated successfully.');
			$('#success-alert').modal('show');
			// fetch data again
			// $('#success-alert').on('hidden.bs.modal', function(e) {
				// location.reload();
			// });
			
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
	$('#editStudentModal').modal('hide');
	// flush all registered data
	document.getElementById("studentEdit").reset();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Student by User's click	
////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveStudentInfo(std) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/student/get/' + std,
		type : 'GET',
		success : function(student) {
			$('#editStudentModal').modal('show');
			// Update display info
			// console.log(student);
			$("#editId").val(student.id);
			$("#editFirstName").val(student.firstName);
			$("#editLastName").val(student.lastName);
			$("#editEmail1").val(student.email1);
			$("#editEmail2").val(student.email2);
			$("#editRelation1").val(student.relation1);
			$("#editRelation2").val(student.relation2);
			$("#editAddress").val(student.address);
			$("#editContact1").val(student.contactNo1);
			$("#editContact2").val(student.contactNo2);
			$("#editMemo").val(student.memo);
			$("#editState").val(student.state);
			$("#editBranch").val(student.branch);
			$("#editGrade").val(student.grade);
			$("#editGender").val(student.gender);
			// Set date value
			var date = new Date(student.registerDate); // Replace with your date value
			$("#editRegisterDate").datepicker('setDate', date);
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
	var id = $("#pwdId").val();
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
// 			Show password dialogue
////////////////////////////////////////////////////////////////////////////////////////////////////////
function showPasswordModal(id) {
	clearPassword();
	$("#pwdId").val(id);
	$('#passwordModal').modal('show');
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Clear password fields
////////////////////////////////////////////////////////////////////////////////////////////////////////
function clearPassword() {
	$("pwdId").val('');
	$("#newPwd").val('');
	$("#confirmPwd").val('');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Inactivate Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function inactiveStudent(id) {
    // Show the warning modal
    $('#deactivateModal').modal('show');
    // Attach the click event handler to the "I agree" button
    $('#agreeInactive').off('click').on('click', function() {
        inactivateStudent(id);
        $('#deactivateModal').modal('hide');
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		De-activate Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function inactivateStudent(id) {
	$.ajax({
		url : '${pageContext.request.contextPath}/student/inactivate/' + id,
		type : 'PUT',
		success : function(data) {
			// clear existing form
			$('#success-alert .modal-body').html('ID : <b>' + id + '</b> is now suspended');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	}); 
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		De-activate Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function activateStudent(id) {
	if(confirm("Are you sure you want to re-activate this student?")){
		// send query to controller
		$.ajax({
			url : '${pageContext.request.contextPath}/student/activate/' + id,
			type : 'PUT',
			success : function(data) {
				// clear existing form
				$('#success-alert .modal-body').text(
						'ID : ' + id + ' is now re-activated');
				$('#success-alert').modal('show');
				$('#success-alert').on('hidden.bs.modal', function(e) {
					location.reload();
				});
			},
			error : function(xhr, status, error) {
				console.log('Error : ' + error);
			}
		}); 
	}else{
		return;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Link To Student Admin
////////////////////////////////////////////////////////////////////////////////////////////////////
function linkToStudent(studentId) {
    //window.location.href = '/studentAdmin?id=' + studentId;
	var url = '/studentAdmin?id=' + studentId;  
	var win = window.open(url, '_blank');
	win.focus();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Payment History
////////////////////////////////////////////////////////////////////////////////////////////////////
function displayFullHistory(studentId) {
	var url = '/invoice/history?studentKeyword=' + studentId;  
	var win = window.open(url, '_blank');
	win.focus();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Open JAC eLearning Platform
////////////////////////////////////////////////////////////////////////////////////////////////////
function openJACeLearning(studentId) {
    // get student password by id
	var password = "";
	$.ajax({
		url: '${pageContext.request.contextPath}/student/getPassword/' + studentId,
		type: 'GET',
		async: false,
		success: function(data) {
			password = data;
			var url = 'http://localhost:8085/online/urlLoginEncrypted?id=' + studentId + '&encPassword=' + password;	
			var win = window.open(url, '_blank');
			win.focus();
		},
		error: function(xhr, status, error) {
			console.log('Error getting password: ' + error);
		}
	});
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

	.vertical-gap{
		padding-top: 10px;
		padding-bottom: 10px;
	}

	#studentListTable tr { 
		vertical-align: middle;
		height: 45px 	
	}
</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-1">
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
				<div class="col-md-2">
					<label for="listYear" class="label-form">Academic Year</label> 
					<select class="form-control" id="listYear" name="listYear">
						<%
							Calendar now = Calendar.getInstance();
							int currentYear = now.get(Calendar.YEAR);
						%>
						<option value="<%= currentYear %>"><%= (currentYear%100) %>/<%= (currentYear%100)+1 %> Academic Year</option>
						<%
							// Adding the last five years
							for (int i = currentYear - 1; i >= currentYear - 4; i--) {
						%>
							<option value="<%= i %>"><%= (i%100) %>/<%= (i%100)+1 %> Academic Year</option>
						<%
						}
						%>
					</select>
				</div>
				
				<div class="col-md-1">
					<label for="listWeek" class="label-form">Week</label>
					<select class="form-control" id="listWeek" name="listWeek">
					</select>
					<script>
						// Get a reference to the select element
						var selectElement = document.getElementById("listWeek");
						// Create a new option element for 'All'
						var allOption = document.createElement("option");
						for (var i = 1; i <= 50; i++) {
							// Create a new option element
							var option = document.createElement("option");
							// Set the value and text content for the option
							option.value = i;
							option.textContent = i;
							// Append the option to the select element
							selectElement.appendChild(option);
						}
					</script>
				</div>
				<div class="col-md-2">
					<label for="listActive" class="label-form">Student Condition</label> 
					<select class="form-control" id="listActive" name="listActive">
						<option value="0">All Students</option>
						<option value="1">Current Students</option>
						<option value="2">Stopped Students</option>
					</select>
				</div>
				<div class="offset-md-2"></div>
				<div class="col mx-auto">
					<label class="label-form-white">Search</label> 
					<button type="submit" class="btn btn-primary btn-block" onclick="searchSummaryInfo()"> <i class="bi bi-search"></i>&nbsp;Search</button>
				</div>
			</div>
		</div>

		<!-- Summary Table -->
		<div class="form-group pt-3">
			<div id="summaryInfo" class="alert alert-info mt-2 jae-border-primary">
				<table id="statTable" style="width: 100%;">
					<thead></thead>
					<tbody></tbody>
				</table>
			</div>	
		</div>

		<div class="form-group">
			<div class="form-row">
				<div class="col-md-12">
					<div class="table-wrap">
						<table id="studentListTable" class="table table-striped table-bordered" style="width: 100%;">
							<thead class="table-primary">
							</thead>
							<tbody id="list-student-body">
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editStudentModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Student Edit</header>
						<form id="studentEdit">
						<div class="form-row mt-3">
							<div class="col-md-4">
								<label for="editState" class="label-form">State</label> 
								<select class="form-control" id="editState" name="editState" disabled>
								</select>
							</div>
							<div class="col-md-5">
								<label for="editBranch" class="label-form">Branch</label> 
								<select class="form-control" id="editBranch" name="editBranch">
								</select>
							</div>
							<div class="col-md-3">
								<label for="editRegisterDate" class="label-form">Registration</label> 
								<input type="text" class="form-control datepicker" id="editRegisterDate" name="editRegisterDate" placeholder="dd/mm/yyyy">
							</div>
						</div>	
						<div class="form-row mt-3">
							<div class="col-md-3">
								<label for="editId" class="label-form">ID:</label> <input type="text" class="form-control" id="editId" name="editId" readonly>
							</div>
							<div class="col-md-4">
								<label for="editFirstName" class="label-form">First Name:</label> <input type="text" class="form-control" id="editFirstName" name="editFirstName">
							</div>
							<div class="col-md-3">
								<label for="editLastName" class="label-form">Last Name:</label> <input type="text" class="form-control" id="editLastName" name="editLastName">
							</div>
							<div class="col-md-2">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
								</select>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-3">
								<label for="editGender" class="label-form">Gender</label> <select class="form-control" id="editGender" name="editGender">
									<option value="male">Male</option>
									<option value="female">Female</option>
								</select>
							</div>
							<div class="col-md-9">
								<label for="editAddress" class="label-form">Address</label> <input type="text" class="form-control" id="editAddress" name="editAddress">
							</div>
						</div>
					
						<div class="form-row">
							<div class="col-md-12">
								<div class="fieldset">
									<header>Main Contact</header>
									<div class="row">
										<div class="col-md-8">
											<input type="text" class="form-control" id="editContact1" name="editContact1" placeholder="Contact No">
										</div>
										<div class="col-md-4">
											<select class="form-control" id="editRelation1" name="editRelation1">
												<option value="mother">Mother</option>
												<option value="father">Father</option>
												<option value="sibling">Sibling</option>
												<option value="other">Other</option>
											</select>
										</div>	
									</div>
									<div class="row mt-2">
										<div class="col-md-12">
											<input type="text" class="form-control" id="editEmail1" name="editEmail1" placeholder="Email">
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="form-row">
							<div class="col-md-12">
								<div class="fieldset">
									<header>Sub Contact</header>
									<div class="row">
										<div class="col-md-8">
											<input type="text" class="form-control" id="editContact2" name="editContact2" placeholder="Contact No">
										</div>
										<div class="col-md-4">
											<select class="form-control" id="editRelation2" name="editRelation2">
												<option value="mother">Mother</option>
												<option value="father">Father</option>
												<option value="sibling">Sibling</option>
												<option value="other">Other</option>
											</select>
										</div>	
									</div>
									<div class="row mt-2">
										<div class="col-md-12">
											<input type="text" class="form-control" id="editEmail2" name="editEmail2" placeholder="Email">
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="form-row mt-3">
							<div class="col-md-12">
								<label for="editMemo" class="label-form">Memo</label>
								<textarea class="form-control" style="height: 200px;" id="editMemo" name="editMemo"></textarea>
							</div>
						</div>
					</form>					
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateStudentInfo()">Save</button>&nbsp;&nbsp;
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
				<input type="hidden" id="pwdId" name="pwdId"/>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-warning" onclick="updatePassword()"><i class="bi bi-check-circle"></i>&nbsp;Reset</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i>&nbsp;Close</button>
            </div>
    	</div>
	</div>
</div>


<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display jae-border-success">
			<i class="bi bi-check-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display jae-border-warning">
			<i class="bi bi-exclamation-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
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
                <button type="submit" class="btn btn-danger" id="agreeInactive" name="agreeInactive"><i class="bi bi-check-circle"></i> Suspend</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>