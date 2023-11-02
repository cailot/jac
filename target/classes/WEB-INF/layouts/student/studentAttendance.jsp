<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fixedColumns.dataTables.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.fixedColumns.min.js"></script>

<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
 

<script>
$(document).ready(function () {
    $('#attendanceTable').DataTable({
    	language: {
    		search: 'Filter:'
    	},
		ordering : false,
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
		// fixedColumns: true,
		columnDefs : [
			{ targets: 0, width: '10%' },
			{ targets: 1, width: '15%' },
			{ targets: 2, width: '15%' },
			{ targets: 3, width: '10%' },
			{ targets: 4, width: '45%' },
			{ targets: 5, width: '5%'}
		],
		fixedColumns: {
			leftColumns: 4,
			rightColumns: 1
		},
		paging: true,
		scrollX: true
    });

	$("#fromDate").datepicker({
		dateFormat: 'dd/mm/yy',
		onClose : function(selectedDate) {
				$("#toDate").datepicker("option", "minDate", selectedDate);
		}
	});
	$("#toDate").datepicker({
		dateFormat: 'dd/mm/yy',
		onClose : function(selectedDate) {
			$("#fromDate").datepicker("option", "maxDate", selectedDate);
		}
	});
	
});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		fetch dropdown list options
////////////////////////////////////////////////////////////////////////////////////////////////////
function fetchOptions() {
	var stateVal = $("#listState").val();
	var branchVal = $("#listBranch").val();
	var gradeVal = $("#listGrade").val();
	// clear all options for listClass
	$('#listClass').empty();
	// ajax call to get options for listClass
	$.ajax({
        url : '${pageContext.request.contextPath}/class/filterClass?listState=' + stateVal + '&listBranch=' + branchVal + '&listGrade=' + gradeVal,
        type : 'GET',
        success : function(data) {
			$('#listClass').append($('<option>').text('All').attr('value', 'All'));
			$.each(data, function(index, value) {
				$('#listClass').append($('<option>').text(value.name).attr('value', value.id));
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
    });
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Attendance	
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateAttendanceInfo(clazzId, studentId, weeks, rowId) {


	var row = document.querySelector('tr[data-row-id="' + rowId + '"]');
	if(!row) {
		console.log('row not found');
		return;
	}
	
  	var rollValues = [];
	var rollElements = row.querySelectorAll('td.roll');

	rollElements.forEach(function (element) {
		var select = element.querySelector('select[name="statusDropdown"]');
		if (select) {
			rollValues.push(select.value);
		} else {
			rollValues.push('');
		}
	});

	console.log('rollValues : ' + rollValues);

	var attend = {
		studentId: studentId,
		clazzId: clazzId,
		week: weeks,
		status: rollValues
	};
    
	// console.log(attend);

	$.ajax({
		url : '${pageContext.request.contextPath}/attendance/updateList',
		type : 'PUT',
		dataType : 'json',
		data : JSON.stringify(attend),
		contentType : 'application/json',
		success : function(data) {
			$('#success-alert .modal-body').html('ID : <b>' + studentId + '</b> attendance updated successfully');
			$('#success-alert').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Attendance Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearAttendanceInfo() {
	document.getElementById("studentAttend").reset();
	// Hide the studentInfo div
	var criteriaInfoDiv = document.getElementById("criteriaInfo");
	if (criteriaInfoDiv) {
  		criteriaInfoDiv.innerHTML = '';
		criteriaInfoDiv.style.display = 'none';
	}
	//attendanceTable all rows remove
	$('#attendanceTable').DataTable().clear().draw();
}

</script>

<style>
	#attendanceTable tr {
		padding: 15px;
	}
	#attendanceTable tfoot tr th {
    	border: none !important;
	}
	#studentAttend .form-row {
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

	#attendanceTable th,
	#attendanceTable td {
  		white-space: nowrap;
  		padding-left: 10px !important;
  		padding-right: 10px !important;
	}

/* 
	#attendanceTable thead>tr>th.sorting,
#attendanceTable thead>tr>th.sorting_asc,
#attendanceTable thead>tr>th.sorting_desc {
	white-space: nowrap;	
  background-color: #ea0f0f; 
  padding-right: 0 !important; 
} */


	/* #attendanceTable th,
    #attendanceTable td {
        white-space: nowrap;
        padding: 0 !important;
        box-sizing: border-box; 
        width: 10%;
    } */

    div.dataTables_wrapper {
        width: 1200px;
        margin: 0 auto;
    }

	#attendanceTable .roll {
        white-space: nowrap;
        padding: 0 !important;
        box-sizing: border-box; /* Include padding in the specified width */
        min-width: 50px; /* Set a fixed width, adjust as needed */
    }

	#attendanceTable .no-gap{
		padding-top: 0px !important;
		padding-bottom: 0px !important;
		border-top-width: 0px !important;
		border-bottom-width: 0px !important;
		border-right-width: 0px !important;
		border-left-width: 0px !important;
	}

	#attendanceTable .th-background{
		background-color: #007bff !important;
	}
	
	</style>

<!-- List Body -->
<div class="row" style="max-width: 80%;">
	<div class="modal-body">
		<form id="studentAttend" method="get" action="${pageContext.request.contextPath}/attendance/search">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-1">
						<label for="listState" class="label-form">State</label> 
						<select class="form-control" id="listState" name="listState" onchange="fetchOptions()">
							<option value="All">All</option>
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
						<select class="form-control" id="listBranch" name="listBranch" onchange="fetchOptions()">
							<option value="All">All</option>
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
					<div class="col-md-1">
						<label for="listGrade" class="label-form">Grade</label> 
						<select class="form-control" id="listGrade" name="listGrade" onchange="fetchOptions()">
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
						<label for="listClass" class="label-form">Class</label> 
						<select class="form-control" id="listClass" name="listClass">
							<option value="All">All</option>
						</select>
					</div>
					<div class="col-md-1">
						<label for="fromDate" class="label-form">From Date</label> <input type="text" class="form-control datepicker" id="fromDate" name="fromDate" placeholder="From" required>
					</div>
					<div class="col-md-1">
						<label for="toDate" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="toDate" name="toDate" placeholder="To" required>
					</div>
					<!-- put blank col-md-1 -->
					<div class="offset-md-1"></div>
					<div class="col max-auto">
						<label class="label-form-white">Search</label> 
						<!-- <button type="button" class="btn btn-primary btn-block" onclick="searchAttendance()"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button> -->
						<button type="submit" class="btn btn-primary btn-block"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col max-auto">
						<label class="label-form-white">Clear</label> 
						<button type="button" class="btn btn-block btn-success" onclick="clearAttendanceInfo()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
					</div>
				</div>
			</div>
			<!-- Search Criteria Info-->
			<c:if test="${not empty sessionScope.criteriaInfo}">
				<div id="criteriaInfo" class="alert alert-info">
					<c:set var="criteria" value="${sessionScope.criteriaInfo}" />
					<c:set var="criteriaState" value="${criteria.state}" />
					<c:choose>
						<c:when test="${criteriaState eq 'vic'}">
							<c:set var="criteriaState" value="Victoria" />
						</c:when>
						<c:when test="${criteriaState eq 'nsw'}">
							<c:set var="criteriaState" value="New South Wales" />
						</c:when>
						<c:when test="${criteriaState eq 'qld'}">
							<c:set var="criteriaState" value="Queensland" />
						</c:when>
						<c:when test="${criteriaState eq 'sa'}">
							<c:set var="criteriaState" value="South Australia" />
						</c:when>
						<c:when test="${criteriaState eq 'tas'}">
							<c:set var="criteriaState" value="Tasmania" />
						</c:when>
						<c:when test="${criteriaState eq 'wa'}">
							<c:set var="criteriaState" value="Western Australia" />
						</c:when>
						<c:when test="${criteriaState eq 'nt'}">
							<c:set var="criteriaState" value="Northern Territory" />
						</c:when>
						<c:when test="${criteriaState eq 'act'}">
							<c:set var="criteriaState" value="ACT" />
						</c:when>
					</c:choose>
					<c:set var="criteriaBranch" value="${criteria.branch}" />
					<c:choose>
						<c:when test="${criteriaBranch eq 'braybrook'}">
							<c:set var="criteriaBranch" value="Braybrook" />
						</c:when>
						<c:when test="${criteriaBranch eq 'epping'}">
							<c:set var="criteriaBranch" value="Epping" />
						</c:when>
						<c:when test="${criteriaBranch eq 'balwyn'}">
							<c:set var="criteriaBranch" value="Balwyn" />
						</c:when>
						<c:when test="${criteriaBranch eq 'bayswater'}">
							<c:set var="criteriaBranch" value="Bayswater" />
						</c:when>
						<c:when test="${criteriaBranch eq 'boxhill'}">
							<c:set var="criteriaBranch" value="Box Hill" />
						</c:when>
						<c:when test="${criteriaBranch eq 'carolinesprings'}">
							<c:set var="criteriaBranch" value="Caroline Springs" />
						</c:when>
						<c:when test="${criteriaBranch eq 'chadstone'}">
							<c:set var="criteriaBranch" value="Chadstone" />
						</c:when>
						<c:when test="${criteriaBranch eq 'craigieburn'}">
							<c:set var="criteriaBranch" value="Craigieburn" />
						</c:when>
						<c:when test="${criteriaBranch eq 'cranbourne'}">
							<c:set var="criteriaBranch" value="Cranbourne" />
						</c:when>
						<c:when test="${criteriaBranch eq 'glenwaverley'}">
							<c:set var="criteriaBranch" value="Glen Waverley" />
						</c:when>
						<c:when test="${criteriaBranch eq 'mitcham'}">
							<c:set var="criteriaBranch" value="Mitcham" />
						</c:when>
						<c:when test="${criteriaBranch eq 'narrewarren'}">
							<c:set var="criteriaBranch" value="Narre Warren" />
						</c:when>
						<c:when test="${criteriaBranch eq 'ormond'}">
							<c:set var="criteriaBranch" value="Ormond" />
						</c:when>
						<c:when test="${criteriaBranch eq 'pointcook'}">
							<c:set var="criteriaBranch" value="Point Cook" />
						</c:when>
						<c:when test="${criteriaBranch eq 'preston'}">
							<c:set var="criteriaBranch" value="Preston" />
						</c:when>
						<c:when test="${criteriaBranch eq 'springvale'}">
							<c:set var="criteriaBranch" value="Springvale" />
						</c:when>
						<c:when test="${criteriaBranch eq 'stalbans'}">
							<c:set var="criteriaBranch" value="St Albans" />
						</c:when>
						<c:when test="${criteriaBranch eq 'werribee'}">
							<c:set var="criteriaBranch" value="Werribee" />
						</c:when>
						<c:when test="${criteriaBranch eq 'mernda'}">
							<c:set var="criteriaBranch" value="Mernda" />
						</c:when>
						<c:when test="${criteriaBranch eq 'melton'}">
							<c:set var="criteriaBranch" value="Melton" />
						</c:when>
						<c:when test="${criteriaBranch eq 'glenroy'}">
							<c:set var="criteriaBranch" value="Glenroy" />
						</c:when>
						<c:when test="${criteriaBranch eq 'packenham'}">
							<c:set var="criteriaBranch" value="Packenham" />
						</c:when>
					</c:choose>
					<c:set var="criteriaGrade" value="${criteria.grade}" />
					<c:set var="criteriaClazz" value="${criteria.clazzName}" />
					<c:set var="criteriaFrom" value="${criteria.fromDate}" />
					<c:set var="criteriaTo" value="${criteria.toDate}" />
					<table style="width: 100%;">
						<colgroup>
							<col style="width: 20%;" />
							<col style="width: 20%;" />
							<col style="width: 10%;" />
							<col style="width: 20%;" />
							<col style="width: 30%;" />
						</colgroup>
						<tr>
							<td class="text-right">State : <span class="font-weight-bold"><c:out value="${criteriaState}" /></span></td>
							<td class="text-center">Branch : <span class="font-weight-bold"><c:out value="${criteriaBranch}" /></span></td>
							<td class="text-left">Grade : <span class="font-weight-bold text-uppercase"><c:out value="${criteriaGrade}" /></span></td>
							<td class="text-left">Class : <span class="font-weight-bold text-capitalize"><c:out value="${criteriaClazz}" /></span></td>
							<td class="text-center"><span class="font-weight-bold"><c:out value="${criteriaFrom}" />  ~  <c:out value="${criteriaTo}" /></span></td>							
						</tr>
					</table>						
				</div>
			</c:if>
			<div class="form-group">
				<div class="form-row">
				<div class="col-md-12">
				<c:choose>
					<c:when test="${empty sessionScope.attendanceInfo}">
						No attendance data is available.
					</c:when>
					<c:otherwise>
						<c:set var="weekSize" value="${fn:length(weekHeader)}" />
						
							<table id="attendanceTable" class="table table-bordered" style="width: 100%;">
								<thead class="table-primary">
									<tr>
										<th class="small text-center align-middle" rowspan="2" style="background-color: #b8daff !important;">ID</th>
										<th class="small text-center align-middle" rowspan="2" style="background-color: #b8daff !important;">Student Name</th>
										<th class="small text-center align-middle" rowspan="2" style="background-color: #b8daff !important;">Class Name</th>
										<th class="small text-center align-middle" rowspan="2" style="background-color: #b8daff !important;">Day</th>
										<th class="small text-center align-middle" colspan="${weekSize}" >Week</th>
										<th class="small text-center align-middle th-background" rowspan="2" style="background-color: #b8daff !important;">Update</th>
									</tr>
									<tr class="week-sub-columns">
										<c:forEach items="${weekHeader}" var="week">
											<th data-orderable="false" class="small text-center align-middle" style="min-width: 60px !important; max-width: 65px !important;"><c:out value="${week}" /></th>
										</c:forEach>	
									</tr>
								</thead>	
								<tbody>
									<c:forEach var="attend" items="${sessionScope.attendanceInfo}">
										<tr data-row-id="${attend.clazzId}-${attend.studentId}">
											<td class="small align-middle text-center">${attend.studentId}</td> 
											<td class="small align-middle text-left">${attend.studentName}</td>
											<td class="small align-middle text-left">
												<span class="text-uppercase">[<c:out value="${attend.clazzGrade}"/>]</span> <c:out value="${attend.clazzName}" />
											</td>
											<td class="small align-middle text-center">
												<c:out value="${attend.clazzDay}" />
											</td>
											<c:forEach items="${attend.status}" var="status" varStatus="loop">
												<td class="small text-center align-middle roll" title="${attend.attendDate[loop.index]}">
													<input type="hidden" name="week" value="${attend.week[loop.index]}" />
													<c:choose>
														<c:when test="${status eq 'Y'}">
															<select name="statusDropdown" class="custom-select custom-select-sm no-gap">
																<option value="Y" selected>Attended</option>
																<option value="N">Absent</option>
																<option value="P">Pause</option>
																<!-- <option value="O">Other</option> -->
															</select>
														</c:when>
														<c:when test="${status eq 'N'}">
															<select name="statusDropdown" class="custom-select custom-select-sm no-gap">
																<option value="Y">Attended</option>
																<option value="N" selected>Absent</option>
																<option value="P">Pause</option>
																<!-- <option value="O">Other</option> -->
															</select>
														</c:when>
														<c:when test="${status eq 'P'}">
															<select name="statusDropdown" class="custom-select custom-select-sm no-gap">
																<option value="Y">Attended</option>
																<option value="N">Absent</option>
																<option value="P" selected>Pause</option>
																<!-- <option value="O">Other</option> -->
															</select>
														</c:when>
														<%-- <c:when test="${status eq 'O'}">
															<select name="statusDropdown" class="custom-select custom-select-sm no-gap">
																<option value="Y">Yes</option>
																<option value="N">No</option>
																<option value="P">Pause</option>
																<option value="O" selected>Other</option>
															</select>
														</c:when> --%>
														<c:otherwise>
														</c:otherwise>
													</c:choose>
												</td>
											</c:forEach>
											<td class="text-center align-middle">
												<i class="bi bi-person-check text-primary" title="Update attendance" style="font-size: 150%;" onclick="updateAttendanceInfo('${attend.clazzId}', '${attend.studentId}', ${attend.week}, '${attend.clazzId}-${attend.studentId}')"></i>  
											</td>
										</tr>
									</c:forEach>
								</tbody>
							</table>
						
					</c:otherwise>
					</c:choose>
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

<!-- Delete Alert -->
<div id="confirm-alert" class="modal fade" >
    <div class="modal-dialog">
    	<div class="alert alert-block alert-danger">
    		<div class="alert-dialog-display">
    			<i class="fa fa-minus-circle fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
    		</div>
			<div style="text-align: right;">
				<button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">Cancel</button>
				<button type="button" class="btn btn-sm btn-danger" id="deactivateAction">Delete</button>
			</div>
		</div>
    </div>
</div>
