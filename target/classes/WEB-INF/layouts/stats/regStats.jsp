<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script>
$(document).ready(function () {

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
//		Search Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStats() {
	var start = document.getElementById("fromDate").value;
	var end = document.getElementById("toDate").value;
	if (start == "" || end == "") {
		alert("Please select From Date and To Date.");
		return;
	}
	console.log(start + ' --  ' + end);
	$.ajax({
		url: '${pageContext.request.contextPath}/stats/regSearch',
		type: 'POST',
		data: {
			fromDate: start,
			toDate: end
		},
		success: function (items) {
			var table = document.getElementById('regStatTable');
			$.each(items, function (index, item) {
				console.log(item);
				 // get branch value for x axis
				 var branchCode = item.branch;
				// Find the th element with the corresponding code
				var th = $('#regStatTable th[code="' + branchCode + '"]');
				if (th.length > 0) {
					// Get the column index of the cell
					var cellIndex = th.index();
					// Get the row index (assuming it's stored in item.grade)
					var rowIndex = item.grade;
					// Get the corresponding cell in the table body
					var cell = $('#regStatTable tbody tr:nth-child(' + rowIndex + ') td:nth-child(' + (cellIndex+2) + ')');
					// Update the cell content
					cell.text(item.count);
					cell.css('color', 'red');
				} else {
					console.error('No th element found with code ' + branchCode);
				}
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}

	});
}

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
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Generate <td>	
////////////////////////////////////////////////////////////////////////////////////////////////////
function generateTableCells(numCells) {
	var cells = '';
	for (var i = 0; i < numCells; i++) {
		cells += '<td class="small align-middle text-center">0</td>';
	}
	return cells;
}

</script>

<style>
	#regStatTable tr {
		padding: 15px;
	}

	#regStatTable tfoot tr th {
		border: none !important;
	}

	#regStatTable th,
	#regStatTable td {
		white-space: nowrap;
		padding-left: 10px !important;
		padding-right: 10px !important;
	}

	#regStatTable .th-background {
		background-color: #007bff !important;
	}

</style>

<!-- List Body -->
<div class="row" style="min-width: 80%; max-width: 100%;">
	<div class="modal-body">
		<!-- <form id="listForm" method="get" action="${pageContext.request.contextPath}/stats/regSearch"> -->
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="fromDate" class="label-form">From Date</label>
						<input type="text" class="form-control datepicker" id="fromDate" name="fromDate" placeholder="From" required>
					</div>
					<div class="col-md-2">
						<label for="toDate" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="toDate" name="toDate" placeholder="To" required>
					</div>
					<!-- put blank col-md-1 -->
					<div class="offset-md-6"></div>
					<div class="col max-auto">
						<label class="label-form-white">Search</label>
						<button type="button" class="btn btn-primary btn-block" onclick="searchStats()"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
					</div>
					<div class="col max-auto">
						<label class="label-form-white">Clear</label>
						<button type="button" class="btn btn-block btn-success" onclick="clearSearchCriteria()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						
							
								<table id="regStatTable" class="table table-bordered" style="width: 100%;">
									<thead class="table-primary">
										<tr>
											<th class="small text-center align-middle" code="0"></th>
											<th class="small text-center align-middle" code="12">Box Hill</th>
											<th class="small text-center align-middle" code="13">Braybrook</th>
											<th class="small text-center align-middle" code="14">Chadstone</th>
											<th class="small text-center align-middle" code="15">Crandbourne</th>
											<th class="small text-center align-middle" code="16">Epping</th>
											<th class="small text-center align-middle" code="17">Glen Waverley</th>
											<th class="small text-center align-middle" code="18">Narre Warren</th>
											<th class="small text-center align-middle" code="19">Mitcham</th>
											<th class="small text-center align-middle" code="20">Preston</th>
											<th class="small text-center align-middle" code="21">Richmond</th>
											<th class="small text-center align-middle" code="22">Springvale</th>
											<th class="small text-center align-middle" code="23">St.Albans</th>
											<th class="small text-center align-middle" code="24">Werribee</th>
											<th class="small text-center align-middle" code="25">Balwyn</th>
											<th class="small text-center align-middle" code="26">Rowville</th>
											<th class="small text-center align-middle" code="27">Caroline Springs</th>
											<th class="small text-center align-middle" code="28">Bayswater</th>
											<th class="small text-center align-middle" code="29">Point Cook</th>
											<th class="small text-center align-middle" code="30">Craigieburn</th>
											<th class="small text-center align-middle" code="31">Mernda</th>
											<th class="small text-center align-middle" code="32">Melton</th>
											<th class="small text-center align-middle" code="33">Glenroy</th>
											<th class="small text-center align-middle" code="34">Pakenham</th>
											<th class="small text-center align-middle" code="100">Total</th>
										</tr>
									</thead>
									<tbody>
										<tr id="p2Row">
											<td class="small align-middle text-center">P2</td>
											<script>
												document.getElementById('p2Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="p3Row">
											<td class="small align-middle text-center">P3</td>
											<script>
												document.getElementById('p3Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="p4Row">
											<td class="small align-middle text-center">P4</td>
											<script>
												document.getElementById('p4Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="p5Row">
											<td class="small align-middle text-center">P5</td>
											<script>
												document.getElementById('p5Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="p6Row">
											<td class="small align-middle text-center">P6</td>
											<script>
												document.getElementById('p6Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="s7Row">
											<td class="small align-middle text-center">S7</td>
											<script>
												document.getElementById('s7Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="s8Row">
											<td class="small align-middle text-center">S8</td>
											<script>
												document.getElementById('s8Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="s9Row">
											<td class="small align-middle text-center">S9</td>
											<script>
												document.getElementById('s9Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="s10Row">
											<td class="small align-middle text-center">S10</td>
											<script>
												document.getElementById('s10Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="s10eRow">
											<td class="small align-middle text-center">S10E</td>
											<script>
												document.getElementById('s10eRow').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="tt6Row">
											<td class="small align-middle text-center">TT6</td>
											<script>
												document.getElementById('tt6Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="tt8Row">
											<td class="small align-middle text-center">TT8</td>
											<script>
												document.getElementById('tt8Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="tt8eRow">
											<td class="small align-middle text-center">TT8E</td>
											<script>
												document.getElementById('tt8eRow').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="srw4Row">
											<td class="small align-middle text-center">SRW4</td>
											<script>
												document.getElementById('srw4Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="srw5Row">
											<td class="small align-middle text-center">SRW5</td>
											<script>
												document.getElementById('srw5Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="srw6Row">
											<td class="small align-middle text-center">SRW6</td>
											<script>
												document.getElementById('srw6Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="srw7Row">
											<td class="small align-middle text-center">SRW7</td>
											<script>
												document.getElementById('srw7Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="srw8Row">
											<td class="small align-middle text-center">SRW8</td>
											<script>
												document.getElementById('srw8Row').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="jmssRow">
											<td class="small align-middle text-center">JMSS</td>
											<script>
												document.getElementById('jmssRow').innerHTML += generateTableCells(24);
											</script>
										</tr>
										<tr id="vceRow">
											<td class="small align-middle text-center">VCE</td>
											<script>
												document.getElementById('vceRow').innerHTML += generateTableCells(24);
											</script>
										</tr>
									</tbody>
								</table>
							
					</div>
				</div>
			</div>
		<!-- </form> -->
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