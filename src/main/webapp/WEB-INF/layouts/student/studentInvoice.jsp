<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="hyung.jin.seo.jae.dto.StudentDTO"%>
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
    $('#invoiceTable').DataTable({
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
    
	// bring up selected invoice
	// $('#invoiceTable').on('click', 'a', function(e) {
	// 	e.preventDefault();
	// 	var invoiceId = $(this).closest('tr').find('td:eq(0)').text();
	// 	alert(invoiceId);
	// });

    // if student id is passed by url, retrieve student info
	var studentId = getParameterByName('studentId');
	//alert(studentId);
	if(studentId !==null && studentId !==''){
		$("#studentKeyword").val(studentId);
		getInvoice(studentId);
	}

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Bring all Invoice by Student
////////////////////////////////////////////////////////////////////////////////////////////////////
function getInvoice(studentId) {
	//warn if keyword is empty
	if (studentId == '') {
		$('#warning-alert .modal-body').text('Please fill in Student Info before search');
		$('#warning-alert').modal('toggle');
		return;
	}
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/enrolment/search/student/' + studentId,
		type : 'GET',
		success : function(data) {
			$.each(data, function(index, value){
				//console.log(cleanUpJson(value));
				// update studentListTable



				const cleaned = cleanUpJson(value);
				console.log(cleaned);
				var row = $("<tr>");


				row.append($('<td>').text(value.invoiceId)); // Invoice ID

				if(value.hasOwnProperty('bookId')){ // Book	
					row.append($('<td><i class="bi bi-book" data-toggle="tooltip" title="Book"></i>')); // Type
					row.append($('<td>').text(value.id)); // ID
					row.append($('<td>').text(value.name)); // Name
					row.append($('<td>').text(parseFloat(value.price).toFixed(2))); // Price
					row.append($('<td>').text(value.paymentDate)); // Payment Date
				}else if(value.hasOwnProperty('extra')){ // Enrolment
					row.append($('<td><i class="bi bi-mortarboard" data-toggle="tooltip" title="Class"></i>')); // Type
					row.append($('<td>').text(value.id)); // ID
					row.append($('<td>').text('[' + value.grade.toUpperCase() + '] ' + value.name)); // Name
					row.append($('<td>').text(parseFloat(value.price).toFixed(2))); // Price
					row.append($('<td>').text(value.paymentDate)); // Payment Date
				}else{ // Outstanding
					row.append($('<td><i class="bi bi-exclamation-circle" data-toggle="tooltip" title="Oustanding"></i>')); // Type
					row.append($('<td>').text(value.id)); // ID
					row.append($('<td>').text('Partial Payment')); // Name
					row.append($('<td>' + parseFloat(value.paid).toFixed(2) + '&nbsp;<i class="bi bi-check2-circle text-danger"data-toggle="tooltip" title="Paid"></i>')); // Paid		
					row.append($('<td>').text(value.registerDate)); // Payment Date
				}
				
				
				
				
				
				
				
				
				row.append($('<td><i class="bi bi-chat-square-text text-primary" data-toggle="tooltip" title="Note" onclick="alert(' + value.info + ')"></i>')); // Note
				row.append($('<td><i class="bi bi-calculator text-success" data-toggle="tooltip" title="Receipt" onclick="alert(' + value.invoiceId + ')"></i>')); // Receipt
				
				
				
				
				
				
				$('#studentListTable > tbody').prepend(row);


			});	
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		get Parameter from URL
////////////////////////////////////////////////////////////////////////////////////////////////////
// Function to get URL parameters by name
function getParameterByName(name) {
    var url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//			Search Student with Keyword	
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStudent() {
	//debugger;
	//warn if keyword is empty
	if ($("#studentKeyword").val() == '') {
		$('#warning-alert .modal-body').text('Please fill in Student Info before search');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$('#studentListResultTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/student/search',
		type : 'GET',
		data : {
			keyword : $("#studentKeyword").val()
		},
		success : function(data) {
			// console.log('search - ' + data);
			if (data == '') {
				$('#warning-alert .modal-body').html('No record found with <b>' + $("#studentKeyword").val() + '</b>');
				$('#warning-alert').modal('toggle');
				clearStudentInfo();
				return;
			}
			$.each(data, function(index, value) {
				const cleaned = cleanUpJson(value);
				var row = $("<tr onclick='displayStudentInvoice(" + cleaned + ")'>");		
				row.append($('<td>').text(value.id));
				row.append($('<td>').text(value.firstName));
				row.append($('<td>').text(value.lastName));
				row.append($('<td>').text(value.grade.toUpperCase()));
				row.append($('<td>').text((value.gender === "") ? "" : value.gender.slice(0, 1).toUpperCase() + value.gender.substring(1)));	
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

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Display Invoice by User's click	
////////////////////////////////////////////////////////////////////////////////////////////////////
function displayStudentInvoice(student) {
	$("#studentKeyword").val(student.id);
	console.log(student.firstName + " " + student.lastName);
	// $("#studentName").text(student.firstName + " " + student.lastName);
	$('#studentListResult').modal('hide');
	getInvoice(student.id);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Student Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearStudentInfo() {
	$("#studentKeyword").val('');
	// document.getElementById("studentInvoice").reset();
}

</script>

<style>
	#studentListTable th, tr {
		padding: 15px;
	}
	#studentList .form-row {
  		margin-top: 20px;
		margin-bottom: 20px;
	}
	div.dataTables_filter {
		padding-top: 35px;
		padding-bottom: 35px;
	}
	div.dt-buttons {
		padding-top: 35px;
		padding-bottom: 10px;
	}
	div.dataTables_length{
		padding-top: 40px;
		padding-bottom: 10px;
	}
	tr { height: 50px } 

</style>


<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<!-- <form id="studentInvoice"> -->
			<div id="studentInvoice">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listState" class="label-form">State</label> 
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
						<label for="listBranch" class="label-form">Branch</label> 
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
						<label for="studentKeyword" class="label-form">Student Info</label> 
						<input type="text" class="form-control" style="background-color: #FCF7CA;" id="studentKeyword" name="studentKeyword" placeholder="Name or ID">
					</div>
					<!-- put blank col-md-2 -->
					<div class="offset-md-2">
						<div id="studentName"></div>
					</div>
					<div class="col-md-2">
						<label class="label-form-white">Search</label> 
						<button type="submit" class="btn btn-primary btn-block" onclick="searchStudent()"> <i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col-md-2">
						<label class="label-form-white">Clear</label> 
						<button type="button" class="btn btn-block btn-success" onclick="clearStudentInfo()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
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
										<th>Invoice ID</th>
										<th>Type</th>
										<th>ID</th>
										<th>Name</th>
										<th>Price</th>
										<th>Payment Date</th>
										<th data-orderable="false">Note</th>
										<th data-orderable="false">Receipt</th>
									</tr>
								</thead>
								<tbody id="list-student-body">
								
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		<!-- </form>  -->
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

<!-- Warning Alert -->
<div id="warning-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-warning alert-dialog-display">
			<i class="bi bi-exclamation-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!-- Search Result Dialog -->
<div class="modal fade" id="studentListResult">
	<div class="modal-dialog modal-xl modal-dialog-centered">
	  <div class="modal-content">
		<div class="modal-header bg-primary text-white">
		  <h5 class="modal-title">&nbsp;<i class="bi bi-card-list"></i>&nbsp;&nbsp; Student List</h5>
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
