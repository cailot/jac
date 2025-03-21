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

	// initialise table
	initialiseTable();
	
});


function initialiseTable(){
	$('#omrStatTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/omr/listBranch',
		type : 'GET',
		success : function(data) {
			$.each(data, function(index, value) {
				// console.log(value);
				if(value.value >= 90){ // skip branch with code 90, 99
					return;
				}
				var row = $("<tr code='" + value.value + "'>");		
				row.append($('<td class="">').text(value.name));
				row.append($('<td>'));
				row.append($('<td>'));
				row.append($('<td>'));
				row.append($('<td>'));
				row.append($('<td>'));
				row.append($('<td>'));
				$('#omrStatTable > tbody').append(row);
			});
			var totalRow = $("<tr>");
			totalRow.append($('<td class="text-center font-weight-bold">TOTAL</td>'));
			totalRow.append($('<td>'));
			totalRow.append($('<td>'));
			totalRow.append($('<td>'));
			totalRow.append($('<td>'));
			totalRow.append($('<td>'));
			totalRow.append($('<td>'));
			$('#omrStatTable > tbody').append(totalRow);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}



////////////////////////////////////////////////////////////////////////////////////////////////////
//		Search Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStats() {
	var start = document.getElementById("fromDate").value;
	var end = document.getElementById("toDate").value;
	if (start == "" || end == "") {
		$('#warning-alert .modal-body').text('Please select date range before your search');
		$('#warning-alert').modal('toggle');
		return;
	}
	$.ajax({
		url: '${pageContext.request.contextPath}/omr/branchStats',
		type: 'POST',
		data: {
			fromDate: start,
			toDate: end
		},
		success: function (items) {
			// initialise tbody
			initialiseTable();		
			$.each(items, function (index, item) {
				console.log(item);
				//  // get branch value for x axis
				//  var branchCode = item.branch;
				// // Find the th element with the corresponding code
				// var th = $('#omrStatTable th[code="' + branchCode + '"]');
				// if (th.length > 0) {
				// 	// Get the column index of the cell
				// 	var cellIndex = th.index();
				// 	// Get the row index (assuming it's stored in item.grade)
				// 	var rowIndex = item.grade;
				// 	// Get the corresponding cell in the table body
				// 	var cell = $('#omrStatTable tbody tr:nth-child(' + rowIndex + ') td:nth-child(' + (cellIndex+1) + ')');
				// 	// Update the cell content
				// 	cell.text(item.count);
				// 	cell.addClass('text-primary');
				// 	// Add branch and grade as attributes to the cell
				// 	cell.attr('branch', branchCode);
				// 	cell.attr('grade', rowIndex);
				// 	 // Add click event to call studentList function
				// 	cell.click(function() {
				// 		studentList(branchCode, rowIndex);
				// 	});
				// 	// Change cursor to hand pointer on hover
    			// 	cell.css('cursor', 'pointer');
    
				// } else {
				// 	console.error('No th element found with code ' + branchCode);
				// }
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
	document.getElementById("fromDate").value = "";
	document.getElementById("toDate").value = "";
	// Hide the stats div
	var statDiv = document.getElementById("stats");
	statDiv.style.display = 'none';
	var instDiv = document.getElementById("instruction");
	instDiv.style.display = 'block';

	// flush tbody
	var tbody = document.querySelector('#omrStatTable tbody');
	tbody.innerHTML = "";
	// initialise tbody
	addRows();		
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate Total	
////////////////////////////////////////////////////////////////////////////////////////////////////
function populateTotals(){
	// Assuming you have a table with id 'omrStatTable'
	var table = document.getElementById('omrStatTable');
	// Create an array to store the sum of each column
	var columnSums = Array(table.rows[0].cells.length).fill(0);
	// Iterate over each row in the table, starting from the second row
	for (var i = 1; i < table.rows.length; i++) {
		var row = table.rows[i];
		var rowSum = 0;
		// Iterate over each cell in the row
		for (var j = 0; j < row.cells.length; j++) { // j=0 is the first column
			var cell = row.cells[j];
			// Check if the cell's content can be converted to a number
			var cellValue = Number(cell.textContent);
			if (!isNaN(cellValue)) {
				// Add the cell's numeric value to the row sum and the column sum
				rowSum += cellValue;
				columnSums[j] += cellValue;
			}
		}
		// Create a new cell at the end of the row for the row sum
		var sumCell = row.insertCell(-1);
		sumCell.textContent = rowSum;
		sumCell.classList.add('small', 'align-middle', 'text-center', 'font-weight-bold');
	}
	// Create a new row at the bottom of the table
	var newRow = table.insertRow(-1);
	// Create a new cell in the new row for each column
	for (var j = 0; j < columnSums.length; j++) {
		var newCell = newRow.insertCell(-1);
		// Set the cell's text to the column sum, or 'Total' for the first column
		newCell.textContent = j === 0 ? 'Total' : columnSums[j];
		// Set the cell's text to bold and blue
		newCell.classList.add('small', 'align-middle', 'text-center', 'font-weight-bold');
		// newCell.style.fontWeight = 'bold';
		// newCell.style.color = 'blue';
	}
	// Iterate over each row in the table, starting from the second row
	var lastRow = table.rows[table.rows.length-1];
	var lastRowSum = 0;
	// Iterate over each cell in the row
	for (var j = 0; j < lastRow.cells.length; j++) { // j=0 is the first column
		var cell = lastRow.cells[j];
		// Check if the cell's content can be converted to a number
		var cellValue = Number(cell.textContent);
		if (!isNaN(cellValue)) {
			// Add the cell's numeric value to the row sum and the column sum
			lastRowSum += cellValue;
		}
	}
	//get first cell
	var firstCell = lastRow.cells[0];
	firstCell.classList.add("header");
	firstCell.style.color = 'black';
	// get last cell
	var sumCell = lastRow.cells[lastRow.cells.length-1];
	sumCell.textContent = lastRowSum;
	// sumCell.style.fontWeight = 'bold';
	// sumCell.style.color = 'red';
	sumCell.classList.add('small', 'align-middle', 'text-center', 'font-weight-bold', 'text-primary');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Export table data to Excel	
////////////////////////////////////////////////////////////////////////////////////////////////////
function export2Excel(){
  var table = document.getElementById('omrStatTable');
  var rows = table.querySelectorAll('tr');
  var csv = [];
  for (var i = 0; i < rows.length; i++) {
    var row = [], cols = rows[i].querySelectorAll('td, th');
    for (var j = 0; j < cols.length; j++) {
      	// Clean the cell content from new lines, extra spaces and tabs
      	var data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, '').replace(/(\s\s)/gm, ' ');
      	// Escape double-quote with double-double-quote (Excel)
      	data = data.replace(/"/g, '""');
      	// Wrap data in double quotes
      	row.push('"' + data + '"');
    }
    	csv.push(row.join(','));
	}
	// CSV file
	var csvFile = new Blob([csv.join('\n')], {type: "text/csv"});
	// Download link
	var downloadLink = document.createElement("a");
	// File name
	downloadLink.download = 'jac-statistics.csv';
	// Create a link to the file
	downloadLink.href = window.URL.createObjectURL(csvFile);
	// Hide download link
	downloadLink.style.display = "none";
	// Add the link to DOM
	document.body.appendChild(downloadLink);
	// Click download link
	downloadLink.click();
}

</script>

<style>
#omrStatTable tr {
	padding: 15px;
}

#omrStatTable tfoot tr th {
	border: none !important;
}

#omrStatTable th,
#omrStatTable td {
	white-space: nowrap;
	padding-left: 20px !important;
	padding-right: 10px !important;
}

.header {
    font-size: small;
    text-align: center;
    vertical-align: middle;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 80px; /* Adjust as needed */
    background-color: #a7c7ea !important;
    position: relative; /* Required for positioning the tooltip */
}

.header:hover {
    overflow: visible;
}
</style>

<!-- List Body -->
<div class="row max-auto p-5" id="searchCriteria" style="width: 80%;">
	<div class="col-md-2">
		<label for="fromDate" class="label-form">From Date</label>
		<input type="text" class="form-control datepicker" id="fromDate" name="fromDate" placeholder="From" autocomplete="off" required>
	</div>
	<div class="col-md-2">
		<label for="toDate" class="label-form">To Date</label> 
		<input type="text" class="form-control datepicker" id="toDate" name="toDate" placeholder="To" autocomplete="off" required>
	</div>
	<!-- put blank col-md-1 -->
	<div class="offset-md-5"></div>
	<div class="col max-auto">
		<label class="label-form-white">Search</label>
		<button type="button" class="btn btn-primary btn-block" onclick="searchStats()"><i class="bi bi-search"></i>&nbsp;&nbsp;Search</button>
	</div>
	<div class="col max-auto">
		<label class="label-form-white">Clear</label>
		<button type="button" class="btn btn-block btn-success" onclick="clearSearchCriteria()"><i class="bi bi-arrow-clockwise"></i>&nbsp;&nbsp;Clear</button>
	</div>
</div>

<!-- stats chart & table -->
<div class="row max-auto pr-5 pl-5" id="stats" style="width: 80%; overflow: auto;">
	<!-- table -->
	<div class="col-md-12">
		<div class="mt-3 mb-3 mr-10 text-right">
			<button id="exportToExcel" class="btn btn-info" onclick="export2Excel()">Export to Excel</button>
		</div>
		<table id="omrStatTable" class="table table-bordered">
			<thead class="table-primary">
				<tr>
					<th class="header">Branch</th>
					<th class="header">MEGA</th>
					<th class="header">Revision</th>
					<th class="header">Acer</th>
					<th class="header">Edu</th>
					<th class="header">SUM</th>
					<th class="header">Note</th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
</div>
	
