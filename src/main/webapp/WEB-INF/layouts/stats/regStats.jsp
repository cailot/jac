<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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

	// Apply initial color on dropdown list when the page loads
	$('.custom-color-select').each(function() {
		var col = $(this).find('option:selected').attr('data-color');
		$(this).css('color', col);
    });

	// Change color when a new option is selected
	$('.custom-color-select').change(function() {
    	var selectedColor = $(this).find('option:selected').attr('data-color');
    	$(this).css('color', selectedColor);
  	});


	$('#regStatTable').DataTable({
		language: {
			search: 'Filter:'
		},
		ordering: false,
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
		columnDefs: [
			{ targets: 0, width: '10%' },
			{ targets: 1, width: '15%' },
			{ targets: 2, width: '15%' },
			{ targets: 3, width: '10%' },
			{ targets: 4, width: '45%' },
			{ targets: 5, width: '5%' }
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
		onClose: function (selectedDate) {
			$("#toDate").datepicker("option", "minDate", selectedDate);
		}
	});
	$("#toDate").datepicker({
		dateFormat: 'dd/mm/yy',
		onClose: function (selectedDate) {
			$("#fromDate").datepicker("option", "maxDate", selectedDate);
		}
	});

});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Search Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearSearchCriteria() {
	document.getElementById("listForm").reset();
	// Hide the studentInfo div
	var criteriaInfoDiv = document.getElementById("criteriaInfo");
	if (criteriaInfoDiv) {
		criteriaInfoDiv.innerHTML = '';
		criteriaInfoDiv.style.display = 'none';
	}
	//regStatTable all rows remove
	$('#regStatTable').DataTable().clear().draw();
}

</script>

<style>
	#regStatTable tr {
		padding: 15px;
	}

	#regStatTable tfoot tr th {
		border: none !important;
	}

	#listForm .form-row {
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

	div.dataTables_length {
		padding-top: 40px;
		padding-bottom: 10px;
	}

	#regStatTable th,
	#regStatTable td {
		white-space: nowrap;
		padding-left: 10px !important;
		padding-right: 10px !important;
	}

	div.dataTables_wrapper {
		width: 1200px;
		margin: 0 auto;
	}

	#regStatTable .roll {
		white-space: nowrap;
		padding: 0 !important;
		box-sizing: border-box;
		/* Include padding in the specified width */
		min-width: 50px;
		/* Set a fixed width, adjust as needed */
	}

	#regStatTable .no-gap {
		padding-top: 0px !important;
		padding-bottom: 0px !important;
		border-top-width: 0px !important;
		border-bottom-width: 0px !important;
		border-right-width: 0px !important;
		border-left-width: 0px !important;
	}

	#regStatTable .th-background {
		background-color: #007bff !important;
	}

</style>

<!-- List Body -->
<div class="row" style="max-width: 80%;">
	<div class="modal-body">
		<form id="listForm" method="get" action="${pageContext.request.contextPath}/stats/regSearch">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-3">
						<label for="fromDate" class="label-form">From Date</label>
						<input type="text" class="form-control datepicker" id="fromDate" name="fromDate" placeholder="From" required>
					</div>
					<div class="col-md-3">
						<label for="toDate" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="toDate" name="toDate" placeholder="To" required>
					</div>
					<!-- put blank col-md-1 -->
					<div class="offset-md-1"></div>
					<div class="col max-auto">
						<label class="label-form-white">Search</label>
						<button type="submit" class="btn btn-primary btn-block"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col max-auto">
						<label class="label-form-white">Clear</label>
						<button type="button" class="btn btn-block btn-success" onclick="clearSearchCriteria()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
					</div>
				</div>
			</div>
			<!-- Search Criteria Info-->
			<c:if test="${criteriaInfo != null}">
				<div id="criteriaInfo" class="alert alert-info">
					<c:set var="criteria" value="${criteriaInfo}" />
					<c:set var="criteriaFrom" value="${criteria.fromDate}" />
					<c:set var="criteriaTo" value="${criteria.toDate}" />
					<table style="width: 100%;">
						<tr>
							<td class="text-right pr-1">
								<span class="font-weight-bold">
									Registration Statistics between 
								</span>
							</td>
							<td class="text-left pl-1">
								<span class="font-weight-bold text-primary">
									<c:out value="${criteriaFrom}" /> 
								</span>
								<span class="font-weight-bold">and</span>
								<span class="font-weight-bold text-primary">
									<c:out value="${criteriaTo}" />
								</span>
							</td>
						</tr>
					</table>
				</div>
			</c:if>



			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<c:choose>
							<c:when test="${attendanceInfo == null}">
								Please fill Search Criteria and click Search button.
							</c:when>
							<c:otherwise>
								<c:set var="weekSize" value="${fn:length(weekHeader)}" />

								<table id="regStatTable" class="table table-bordered"
									style="width: 100%;">
									<thead class="table-primary">
										<tr>
											<th class="small text-center align-middle" rowspan="2"
												style="background-color: #b8daff !important;">ID</th>
											<th class="small text-center align-middle" rowspan="2"
												style="background-color: #b8daff !important;">Student Name
											</th>
											<th class="small text-center align-middle" rowspan="2"
												style="background-color: #b8daff !important;">Class Name
											</th>
											<th class="small text-center align-middle" rowspan="2"
												style="background-color: #b8daff !important;">Day</th>
											<th class="small text-center align-middle"
												colspan="${weekSize}">Week</th>
											<th class="small text-center align-middle th-background"
												rowspan="2" style="background-color: #b8daff !important;">
												Update</th>
										</tr>
										<tr class="week-sub-columns">
											<c:forEach items="${weekHeader}" var="week">
												<th data-orderable="false"
													class="small text-center align-middle"
													style="min-width: 60px !important; max-width: 65px !important;">
													<c:out value="${week}" />
												</th>
											</c:forEach>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="attend" items="${attendanceInfo}">
											<tr data-row-id="${attend.clazzId}-${attend.studentId}">
												<td class="small align-middle text-center">
													${attend.studentId}</td>
												<td class="small align-middle text-left">
													${attend.studentName}</td>
												<td class="small align-middle text-left">
													<span class="text-uppercase">
														[<c:out value="${attend.clazzGrade}" />]
													</span>
													<c:out value="${attend.clazzName}" />
												</td>
												<td class="small align-middle text-center">
													<c:out value="${attend.clazzDay}" />
												</td>
												<c:forEach items="${attend.status}" var="status" varStatus="loop">
													<td class="small text-center align-middle roll" title="${attend.attendDate[loop.index]}">
														<input type="hidden" name="week" value="${attend.week[loop.index]}" />
														<c:choose>
															<c:when test="${status eq 'Y'}">
																<select name="statusDropdown" class="custom-select custom-select-sm no-gap custom-color-select">
																	<option value="Y" data-color="green" selected>Attended</option>
																	<option value="N" data-color="red">Absent</option>
																	<option value="P" data-color="orange">Pause</option>
																</select>
															</c:when>
															<c:when test="${status eq 'N'}">
																<select name="statusDropdown"
																	class="custom-select custom-select-sm no-gap custom-color-select">
																	<option value="Y" data-color="green">Attended</option>
																	<option value="N" selected data-color="red">Absent</option>
																	<option value="P" data-color="orange">Pause</option>
																</select>
															</c:when>
															<c:when test="${status eq 'P'}">
																<select name="statusDropdown" class="custom-select custom-select-sm no-gap custom-color-select">
																	<option value="Y" data-color="green">Attended</option>
																	<option value="N" data-color="red">Absent</option>
																	<option value="P" selected data-color="orange">Pause</option>
																</select>
															</c:when>
															<%-- when registered for the first time --%>
															<c:when test="${status eq 'O'}">
																<select name="statusDropdown" class="custom-select custom-select-sm no-gap custom-color-select">
																	<option value="Y" data-color="green">Attended</option>
																	<option value="N" data-color="red">Absent</option>
																	<option value="P" data-color="orange">Pause</option>
																	<option value="O" selected data-color="black">Enrol</option>
																</select>
															</c:when>
															<c:otherwise>
															</c:otherwise>
														</c:choose>
													</td>
												</c:forEach>
												<td class="text-center align-middle">
													<i class="bi bi-person-check text-primary"
														title="Update attendance" style="font-size: 150%;"
														onclick="updateAttendanceInfo('${attend.clazzId}', '${attend.studentId}', ${attend.week}, '${attend.clazzId}-${attend.studentId}')"></i>
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

<!-- Delete Alert -->
<div id="confirm-alert" class="modal fade">
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