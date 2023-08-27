<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
    $('#classListTable').DataTable({
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

    // When the Grade dropdown changes, send an Ajax request to get the corresponding Type
	$('#addGrade').change(function() {
	var grade = $(this).val();
		getCoursesByGrade(grade, '#addCourse');
	});

	// When the Grade dropdown changes, send an Ajax request to get the corresponding Type
	$('#editGrade').change(function() {
	var grade = $(this).val();
		getCoursesByGrade(grade, '#editCourse');
	});


});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Class
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addClass() {
	// Get from form data
	var clazz = {
		state : $("#addState").val(),
		branch : $("#addBranch").val(),
		startDate : $("#addStartDate").val(),
		name : $("#addName").val(),
		grade : $("#addGrade").val(),
		courseId : $("#addCourse").val(),
		day : $("#addDay").val()
		//active : $("#addActive").val(),
		//fee : $("#addFee").val()
	}
//	console.log(clazz);
	
	// Send AJAX to server
	$.ajax({
		url : '${pageContext.request.contextPath}/class/registerClass',
		type : 'POST',
		dataType : 'json',
		data : JSON.stringify(clazz),
		contentType : 'application/json',
		success : function(student) {
			// Display the success alert
            $('#success-alert .modal-body').text(
                    'New Class is registered successfully.');
            $('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerClassModal').modal('hide');
	// flush all registered data
	document.getElementById("classRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Class
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveClassInfo(clazzId) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/get/class/' + clazzId,
		type : 'GET',
		success : async function(clazz) {
			//console.log(clazz);
			// firstly populate courses by grade then set the selected option
			await editInitialiseCourseByGrade(clazz.grade, clazz.courseId);
			$("#editId").val(clazz.id);
			$("#editState").val(clazz.state);
			$("#editBranch").val(clazz.branch);
			// Set date value
			var date = new Date(clazz.startDate); // Replace with your date value
			$("#editStartDate").datepicker('setDate', date);
			$("#editGrade").val(clazz.grade);
			$("#editDay").val(clazz.day);
			$("#editName").val(clazz.name);
			$("#editActive").val(clazz.active);
			// if clazz.active = true, tick the checkbox 'editActiveCheckbox'
			if(clazz.active == true){
				$("#editActiveCheckbox").prop('checked', true);
			}else{
				$("#editActiveCheckbox").prop('checked', false);
			}
			$('#editClassModal').modal('show');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Class
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateClassInfo(){
	var clazzId = $("#editId").val();
	// get from formData
	var clazz = {
		id : clazzId,
		state : $("#editState").val(),
		branch : $("#editBranch").val(),
		startDate : $("#editStartDate").val(),
		name : $("#editName").val(),
		grade : $("#editGrade").val(),
		courseId : $("#editCourse").val(),
		day : $("#editDay").val(),
		active : $("#editActive").val()
		// fee : $("#editFee").val()
	}
	
	console.log(clazz);
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/update/class',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify(clazz),
		contentType : 'application/json',
		success : function(value) {
			// Display success alert
			$('#success-alert .modal-body').text(
					'ID : ' + clazzId + ' is updated successfully.');
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
	clearClassForm("classEdit");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate courses by grade
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getCoursesByGrade(grade, toWhere){
	$.ajax({
		url: '${pageContext.request.contextPath}/class/listCoursesByGrade',
		method: 'GET',
		data: { grade: grade },
		success: function(data) {
			$(toWhere).empty(); // clear the previous options
			$.each(data, function(index, value) {
				const cleaned = cleanUpJson(value);
				//console.log(cleaned);
				$(toWhere).append($("<option value='" + value.id + "'>").text(value.description).val(value.id)); // add new option
				});
			},
			error: function(xhr, status, error) {
			console.error(xhr.responseText);
			}
	});
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear class register form
/////////////////////////////////////////////////////////////////////////////////////////////////////////	
function clearClassForm(elementId) {
	document.getElementById(elementId).reset();
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


// initialise courses by grade in edit dialog
function editInitialiseCourseByGrade(grade, courseId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/class/listCoursesByGrade',
        method: 'GET',
        data: { grade: grade },
        success: function(data) {
            $('#editCourse').empty(); // clear the previous options
            $.each(data, function(index, value) {
                const cleaned = cleanUpJson(value);
                console.log(cleaned);
                $('#editCourse').append($("<option value='" + value.id + "'>").text(value.description).val(value.id)); // add new option
            });
            // Set the selected option
            $("#editCourse").val(courseId);
        },
        error: function(xhr, status, error) {
            console.error(xhr.responseText);
        }
    });
}

</script>

<!-- List Body -->
<div class="row">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/class/listClass">
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
						<select class="form-control" id="listGrade" name="listGrade">
							<option value="All">All</option>
							<option value="p2">P2</option>
							<option value="p3">P3</option>
							<option value="p4">P4</option>
							<option value="p5">P5</option>
							<option value="p6">P6</option>
							<option value="s7">S7</option>
							<option value="s8">S8</option>
							<option value="s9">S9</option>
							<option value="s10">S10</option>
							<option value="s10e">S10E</option>
							<option value="tt6">TT6</option>
							<option value="tt8">TT8</option>
							<option value="tt8e">TT8E</option>
							<option value="srw4">SRW4</option>
							<option value="srw5">SRW5</option>
							<option value="srw6">SRW6</option>
							<option value="srw8">SRW8</option>
							<option value="jmss">JMSS</option>
							<option value="vce">VCE</option>
						</select>
					</div>
					<div class="col-md-2">
						<select class="form-control" id="listYear" name="listYear">
							<option value="All">All</option>
							<option value="2023">2023</option>
							<option value="2022">2022</option>
							<option value="2021">2021</option>
							<option value="2020">2020</option>
						</select>
					</div>
					<div class="col mx-auto">
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<button type="button" class="btn btn-block btn-success" data-toggle="modal" data-target="#registerClassModal" onclick="getCoursesByGrade('p2', '#addCourse')"><i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="classListTable" class="table table-striped table-bordered"><thead class="table-primary">
									<tr>
										<th>State</th>
										<th>Branch</th>
										<th>Grade</th>
										<th>Name</th>
										<th>Description</th>
										<th>Start Date</th>
										<th>Day</th>
										<th>Year</th>
										<th data-orderable="false">Activated</th>
										<th data-orderable="false">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
								<c:choose>
									<c:when test="${ClassList != null}">
										<c:forEach items="${ClassList}" var="clazz">
											<tr>
												<td class="small ellipsis"><span style="text-transform: capitalize;"><c:out value="${clazz.state}" /></span></td>
												<td class="small ellipsis"><span style="text-transform: capitalize;"><c:out value="${clazz.branch}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${fn:toUpperCase(clazz.grade)}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${clazz.name}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${clazz.description}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${clazz.startDate}" /></span></td>
												<td class="small ellipsis"><span><c:out value="${clazz.day}" /></span></td>
												<!-- <td class="small ellipsis"><span><c:out value="${clazz.year}" /></span></td> -->
												<td class="small ellipsis"><span>Academic Year <c:out value="${clazz.year%100}/${clazz.year%100+1}" /></span></td>


												<c:set var="active" value="${clazz.active}" />
												<c:choose>
													<c:when test="${active == true}">
														<td class="text-center">
															<i class="bi bi-check-circle text-success"></i>
														</td>
													</c:when>
													<c:otherwise>
														<td class="text-center">
															<i class="bi bi-check-circle text-secondary"></i>
														</td>
													</c:otherwise>
												</c:choose>		
												<td class="text-center">
													<i class="bi bi-pencil-square text-primary fa-lg" data-toggle="tooltip" title="Edit" onclick="retrieveClassInfo('${clazz.id}')"></i>&nbsp;
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
<div class="modal fade" id="registerClassModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Class Registration</header>
			
				<form id="classRegister">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-6">
								<label for="addState" class="label-form">State</label> <select class="form-control" id="addState" name="addState">
									<option value="vic">Victoria</option>
								</select>
							</div>
							<div class="col-md-6">
								<label for="addBranch" class="label-form">Branch</label> <select class="form-control" id="addBranch" name="addBranch">
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
							
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-3">
								<label for="addGrade" class="label-form">Grade</label>
								<select class="form-control" id="addGrade" name="addGrade">
									<option value="p2">P2</option>
									<option value="p3">P3</option>
									<option value="p4">P4</option>
									<option value="p5">P5</option>
									<option value="p6">P6</option>
									<option value="s7">S7</option>
									<option value="s8">S8</option>
									<option value="s9">S9</option>
									<option value="s10">S10</option>
									<option value="s10e">S10E</option>
									<option value="tt6">TT6</option>
									<option value="tt8">TT8</option>
									<option value="tt8e">TT8E</option>
									<option value="srw4">SRW4</option>
									<option value="srw5">SRW5</option>
									<option value="srw6">SRW6</option>
									<option value="srw8">SRW8</option>
									<option value="jmss">JMSS</option>
									<option value="vce">VCE</option>
								</select>
							</div>
							<div class="col-md-9">
								<label for="addCourse" class="label-form">Course</label> 
								<select class="form-control" id="addCourse" name="addCourse">
								</select>
							</div>
							
							<!-- <div class="col-md-4">
								<label for="addFee" class="label-form">Price</label> 
								<input type="text" class="form-control" id="addFee" name="addFee" placeholder="Fee" title="Please enter a valid fee amount (e.g. 100 or 100.50)">
						   	</div>
						   	<div class="input-group col-md-4">
								<div class="input-group-prepend">
								 	<div class="input-group-text">
								   	<input type="checkbox" id="addActiveCheckbox" name="addActiveCheckbox" onchange="updateAddActiveValue(this)">
								 	</div>
							   	</div>
								<input type="hidden" id="addActive" name="addActive" value="false">
							   	<input type="text" id="addActiveLabel" class="form-control" placeholder="Activate">
						   	</div> -->

						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-5">
								<label for="addName" class="label-form">Class Name</label>
								<input type="text" class="form-control" id="addName" name="addName" placeholder="Name" title="Please enter Class name">
							</div>
							<div class="col-md-4">
								<label for="addDay" class="label-form">Day</label>
								<select class="form-control" id="addDay" name="addDay">
									<option value="All">All</option>
									<option value="Monday">Monday</option>
									<option value="Tuesday">Tuesday</option>
									<option value="Wednesday">Wednesday</option>
									<option value="Thursday">Thursday</option>
									<option value="Friday">Friday</option>
									<option value="Saturday">Saturday</option>
									<option value="Sunday">Sunday</option>
								</select>
							</div>
							<div class="col-md-3">
								<label for="addStartDate" class="label-form">Start Date</label> 
								<input type="text" class="form-control datepicker" id="addStartDate" name="addStartDate" placeholder="dd/mm/yyyy">
							</div>
							<script>
								var today = new Date();
								var day = today.getDate();
								var month = today.getMonth() + 1; // Note: January is 0
								var year = today.getFullYear();
								var formattedDate = (day < 10 ? '0' : '') + day + '/' + (month < 10 ? '0' : '') + month + '/' + year;
								document.getElementById('addStartDate').value = formattedDate;
							</script>
							
						</div>
					</div>
				</form>
				<div class="d-flex justify-content-end">
					<button type="submit" class="btn btn-primary" onclick="addClass()">Create</button>&nbsp;&nbsp;
					<button type="button" class="btn btn-default btn-secondary" onclick="clearClassForm('classRegister')" data-dismiss="modal">Close</button>	
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
					<header class="text-primary font-weight-bold">Class Edit</header>
			
				<form id="classEdit">
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-4">
								<label for="editState" class="label-form">State</label> <select class="form-control" id="editState" name="editState">
									<option value="vic">Victoria</option>
									<!-- <option value="nsw">New South Wales</option>
									<option value="qld">Queensland</option>
									<option value="sa">South Australia</option>
									<option value="tas">Tasmania</option>
									<option value="wa">Western Australia</option>
									<option value="nt">Northern Territory</option>
									<option value="act">ACT</option> -->
								</select>
							</div>
							<div class="col-md-5">
								<label for="editBranch" class="label-form">Branch</label> <select class="form-control" id="editBranch" name="editBranch">
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
							<div class="col-md-3">
								<label for="editStartDate" class="label-form">Start Date</label> 
								<input type="text" class="form-control datepicker" id="editStartDate" name="editStartDate" placeholder="dd/mm/yyyy">
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-3">
								<label for="editGrade" class="label-form">Grade</label> <select class="form-control" id="editGrade" name="editGrade">
									<option value="p2">P2</option>
									<option value="p3">P3</option>
									<option value="p4">P4</option>
									<option value="p5">P5</option>
									<option value="p6">P6</option>
									<option value="s7">S7</option>
									<option value="s8">S8</option>
									<option value="s9">S9</option>
									<option value="s10">S10</option>
									<option value="s10e">S10E</option>
									<option value="tt6">TT6</option>
									<option value="tt8">TT8</option>
									<option value="tt8e">TT8E</option>
									<option value="srw4">SRW4</option>
									<option value="srw5">SRW5</option>
									<option value="srw6">SRW6</option>
									<option value="srw8">SRW8</option>
									<option value="jmss">JMSS</option>
									<option value="vce">VCE</option>
								</select>
							</div>
							<div class="col-md-5">
								<label for="editCourse" class="label-form">Course</label> 
								<select class="form-control" id="editCourse" name="editCourse">
								</select>
							</div>
							<div class="col-md-4">
								<label for="editDay" class="label-form">Day</label>
								<select class="form-control" id="editDay" name="editDay">
									<option value="All">All</option>
									<option value="Monday">Monday</option>
									<option value="Tuesday">Tuesday</option>
									<option value="Wednesday">Wednesday</option>
									<option value="Thursday">Thursday</option>
									<option value="Friday">Friday</option>
									<option value="Saturday">Saturday</option>
									<option value="Sunday">Sunday</option>
								</select>
							</div>
						</div>
					</div>
					<div class="form-group">
						<div class="form-row">
							<div class="col-md-8">
								<input type="text" class="form-control" id="editName" name="editName" placeholder="Name" title="Please enter Class name">
							</div>
							<div class="input-group col-md-4">
								<div class="input-group-prepend">
								  <div class="input-group-text">
									<input type="checkbox" id="editActiveCheckbox" name="editActiveCheckbox" onchange="updateEditActiveValue(this)">
								  </div>
								</div>
								<input type="hidden" id="editActive" name="editActive" value="false">
								<input type="text" id="editActiveLabel" class="form-control" placeholder="Activate">
							</div>
						</div>
					</div>
					<input type="hidden" id="editId" name="editId">
				</form>
				<div class="d-flex justify-content-end">
					<button type="submit" class="btn btn-primary" onclick="updateClassInfo()">Save</button>&nbsp;&nbsp;
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