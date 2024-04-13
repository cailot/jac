<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script>

var tableData =[];	
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

	var statDiv = document.getElementById("stats");
	statDiv.style.display = 'none';



});

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Search Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function searchStats() {
	var start = document.getElementById("fromDate").value;
	var end = document.getElementById("toDate").value;
	if (start == "" || end == "") {
		$('#warning-alert .modal-body').text('Please select date range beforel your search');
		$('#warning-alert').modal('toggle');
		return;
	}
	$.ajax({
		url: '${pageContext.request.contextPath}/stats/regSearch',
		type: 'POST',
		data: {
			fromDate: start,
			toDate: end
		},
		success: function (items) {
			var table = document.getElementById('regStatTable');
			// flush tbody
			var tbody = document.querySelector('#regStatTable tbody');
			tbody.innerHTML = "";
			// initialise tbody
			addRows();		
			$.each(items, function (index, item) {
				// console.log(item);
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
					var cell = $('#regStatTable tbody tr:nth-child(' + rowIndex + ') td:nth-child(' + (cellIndex+1) + ')');
					// Update the cell content
					cell.text(item.count);
					cell.addClass('text-primary');
					// cell.css('color', 'red');
				} else {
					console.error('No th element found with code ' + branchCode);
				}
			});
			// calculate totals
			populateTotals();
			// extract data for chartJs
			extractData();
			// update chart
			updateChart();
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	
	var statDiv = document.getElementById("stats");
	statDiv.style.display = 'block';
	var instDiv = document.getElementById("instruction");
	instDiv.style.display = 'none'
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
	var tbody = document.querySelector('#regStatTable tbody');
	tbody.innerHTML = "";
	// initialise tbody
	addRows();		
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

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate Total	
////////////////////////////////////////////////////////////////////////////////////////////////////
function populateTotals(){
	// Assuming you have a table with id 'regStatTable'
	var table = document.getElementById('regStatTable');
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
//		Extract Year Data	
////////////////////////////////////////////////////////////////////////////////////////////////////
function extractData() {
	var table = document.getElementById('regStatTable');
	var data = {
		p2Row: [],
		p3Row: [],
		p4Row: [],
		p5Row: [],
		p6Row: [],
		s7Row: [],
		s8Row: [],
		s9Row: [],
		s10Row: [],
		s10eRow: [],
		tt6Row: [],
		tt8Row: [],
		tt8eRow: [],
		srw4Row: [],
		srw5Row: [],
		srw6Row: [],
		srw7Row: [],
		srw8Row: [],
		jmssRow: [],
		vceRow: []
	};

	// Iterate over each row in the table, starting from the second row
	for (var i = 1; i < table.rows.length; i++) {
		var row = table.rows[i];

		// Check if the row's id is in the data object
		if (data.hasOwnProperty(row.id)) {
			// Iterate over each cell in the row, except the last one
			for (var j = 0; j < row.cells.length - 1; j++) {
				var cell = row.cells[j];

				// Check if the cell's content can be converted to a number
				var cellValue = Number(cell.textContent);
				if (!isNaN(cellValue)) {
					// Add the cell's numeric value to the corresponding array in the data object
					data[row.id].push(cellValue);
				}
			}
		}
	}

	tableData = data;
	console.log(tableData);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add <tr> to table	
////////////////////////////////////////////////////////////////////////////////////////////////////
function addRows(){
	// Define the rows data
	var rowsData = [
		{ id: 'p2Row', text: 'P2' },
		{ id: 'p3Row', text: 'P3' },
		{ id: 'p4Row', text: 'P4' },
		{ id: 'p5Row', text: 'P5' },
		{ id: 'p6Row', text: 'P6' },
		{ id: 's7Row', text: 'S7' },
		{ id: 's8Row', text: 'S8' },
		{ id: 's9Row', text: 'S9' },
		{ id: 's10Row', text: 'S10' },
		{ id: 's10eRow', text: 'S10E' },
		{ id: 'tt6Row', text: 'tt6' },
		{ id: 'tt8Row', text: 'tt8' },
		{ id: 'tt8eRow', text: 'tt8e' },
		{ id: 'srw4Row', text: 'SRW4' },
		{ id: 'srw5Row', text: 'SRW5' },
		{ id: 'srw6Row', text: 'SRW6' },
		{ id: 'srw7Row', text: 'SRW7' },
		{ id: 'srw8Row', text: 'SRW8' },
		{ id: 'jmssRow', text: 'JMSS' },
		{ id: 'vceRow', text: 'VCE' }
	];
	// Get the tbody element
	var tbody = document.querySelector('tbody');
	// Iterate over the rows data
	rowsData.forEach(function(rowData) {
		// Create a new row and cell
		var row = document.createElement('tr');
		var cell = document.createElement('td');
		// Set the row's id and the cell's text
		row.id = rowData.id;
		cell.textContent = rowData.text;
		cell.className = 'small align-middle text-center header font-weight-bold';
		// Add the cell to the row
		row.appendChild(cell);
		// Add the row to the tbody
		tbody.appendChild(row);
		// Add additional cells to the row using the generateTableCells function
		row.innerHTML += generateTableCells(23);
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update chart	
////////////////////////////////////////////////////////////////////////////////////////////////////
function updateChart(){
	// destroy the exisiting chart instance if it exists
	var exisiting = Chart.getChart('barChart');
	if(exisiting){
		exisiting.destroy();
	}
	// create new chart instance
	const bar = document.getElementById('barChart');
	new Chart(bar, {
	  type: 'bar',
	  data: {
		labels: ['Box Hill', 'Braybrook', 'Chadstone', 'Cranbourne', 'Epping', 'Glen Waverley', 'Narre Warren', 'Micham', 'Preston', 'Richmond', 'Springvale', 'St.Albans', 'Werribee', 'Balwyn', 'Rowville', 'Caroline Springs', 'Bayswater', 'Point Cook', 'Craigieburn', 'Mernda', 'Melton', 'Glenroy', 'Pakenham'],
		datasets: [
		 {
		  label: 'P2',
		  data: tableData.p2Row, 
		  backgroundColor: [
			'#89cce2'
		],
		  borderWidth: 1
		},
		{
		  label: 'P3',
		  data: tableData.p3Row,  
		  backgroundColor: [
			'#71c2dc'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'P4',
		  data: tableData.p4Row,  
		  backgroundColor: [
			'#5ab8d6'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'P5',
		  data: tableData.p5Row,  
		  backgroundColor: [
			'#42add1'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'P6',
		  data: tableData.p6Row,  
		  backgroundColor: [
			'#2ba3cb'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S7',
		  data: tableData.s7Row,  
		  backgroundColor: [
			'#e57771'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S8',
		  data: tableData.s8Row,  
		  backgroundColor: [
			'#e16059'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S9',
		  data: tableData.s9Row,  
		  backgroundColor: [
			'#dd4941'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S10',
		  data: tableData.s10Row,  
		  backgroundColor: [
			'#d8332a'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S10E',
		  data: tableData.s10eRow,  
		  backgroundColor: [
			'#d41c12'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'TT6',
		  data: tableData.tt6Row,  
		  backgroundColor: [
			'#fff700'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'TT8',
		  data: tableData.tt8Row,  
		  backgroundColor: [
			'#aaff00'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'TT8E',
		  data: tableData.tt8eRow,  
		  backgroundColor: [
			'#00ff88'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW4',
		  data: tableData.srw4Row,  
		  backgroundColor: [
			'#00b30a'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW5',
		  data: tableData.srw5Row,  
		  backgroundColor: [
			'#009908'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW6',
		  data: tableData.srw6Row,  
		  backgroundColor: [
			'#008007'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW7',
		  data: tableData.srw7Row,  
		  backgroundColor: [
			'#006606'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW8',
		  data: tableData.srw8Row,  
		  backgroundColor: [
			'#004c04'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'JMSS',
		  data: tableData.jmssRow,  
		  backgroundColor: [
			'#ff99fb'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'VCE',
		  data: tableData.vceRow,  
		  backgroundColor: [
			'#ff66fa'
		 ],
		  borderWidth: 1
		 }

	]
	  },
	  options: {
		responsive : true,
		interaction:{
			mode : 'index'
		}
	  }
	});


	
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

.header:hover::before {
    content: attr(title); /* Display the full content as a tooltip */
    position: absolute;
    background-color: rgba(0, 0, 0, 0.8);
    color: #fff;
    padding: 5px;
    border-radius: 3px;
    z-index: 999;
    white-space: normal;
    max-width: 200px; /* Adjust as needed */
    word-wrap: break-word;
    top: calc(100% + 5px);
    left: 50%;
    transform: translateX(-50%);
}

.graphBox {
	position: relative;
	width: 100%;
	display: grid;
	grid-template-columns: 1fr;
	grid-gap: 30px;
	padding-bottom: 50px;
	min-height: auto;
}

.graphBox .box {
	position: relative;
	background: #fff;
	display: grid;
}

/* make it responsive design */
@media (max-width: 768px) {
	.graphBox {
		grid-template-columns: 1fr;
		height: auto;
	}
}

</style>

<!-- List Body -->
<div class="row max-auto p-5" id="searchCriteria" style="width: 80%;">
	<div class="col-md-2">
		<label for="fromDate" class="label-form">From Date</label>
		<input type="text" class="form-control datepicker" id="fromDate" name="fromDate" placeholder="From" required>
	</div>
	<div class="col-md-2">
		<label for="toDate" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="toDate" name="toDate" placeholder="To" required>
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
<div class="container pt-5" id="instruction">
	<div class="alert alert-info" role="alert">
		<h5>
			<i class="bi bi-calendar-range-fill fa-lg"></i>&nbsp;&nbsp;Please choose <strong>Date Range</strong> and click <strong>Search</strong> button.
		</h5>
	</div>
</div>

<!-- stats chart & table -->
<div class="row max-auto" id="stats" style="width: 90%; overflow: auto;">
	<!-- chart -->
	<div class="graphBox">
		<div class="box">
			<canvas id="barChart"></canvas>
		</div>
	</div>
	<!-- table -->
	<div class="col-md-12">
		<table id="regStatTable" class="table table-bordered">
			<thead class="table-primary">
				<tr>
					<th class="header" title="" code="0"></th>
					<th class="header" title="Box Hill" code="12">Box Hill</th>
					<th class="header" title="Braybrook" code="13">Braybrook</th>
					<th class="header" title="Chadstone" code="14">Chadstone</th>
					<th class="header" title="Crandbourne" code="15">Crandbourne</th>
					<th class="header" title="Epping" code="16">Epping</th>
					<th class="header" title="Glen Waverley" code="17">Glen Waverley</th>
					<th class="header" title="Narre Warren" code="18">Narre Warren</th>
					<th class="header" title="Mitcham" code="19">Mitcham</th>
					<th class="header" title="Preston" code="20">Preston</th>
					<th class="header" title="Richmond" code="21">Richmond</th>
					<th class="header" title="Springvale" code="22">Springvale</th>
					<th class="header" title="St.Albans" code="23">St.Albans</th>
					<th class="header" title="Werribee" code="24">Werribee</th>
					<th class="header" title="Balwyn" code="25">Balwyn</th>
					<th class="header" title="Rowville" code="26">Rowville</th>
					<th class="header" title="Caroline Springs" code="27">Caroline Springs</th>
					<th class="header" title="Bayswater" code="28">Bayswater</th>
					<th class="header" title="Point Cook" code="29">Point Cook</th>
					<th class="header" title="Craigieburn" code="30">Craigieburn</th>
					<th class="header" title="Mernda" code="31">Mernda</th>
					<th class="header" title="Melton" code="32">Melton</th>
					<th class="header" title="Glenroy" code="33">Glenroy</th>
					<th class="header" title="Pakenham" code="34">Pakenham</th>
					<th class="header" title="Total" code="100">Total</th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
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

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
