<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script>
var branch = window.branch;
var branchName = '';
	
var tableData = '';	
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

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/code/getBranchByCode/' + branch,
		type: 'GET',
		success: function (data) {
			console.log('Branch data received:', data);
			branchName = data.name;
		},
		error: function (xhr, status, error) {
			console.log('Error fetching branch: ' + error);
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
		$('#warning-alert .modal-body').text('Please select date range before your search');
		$('#warning-alert').modal('toggle');
		return;
	}
	
	console.log('Searching for branch stats with date range:', start, 'to', end);
	
	$.ajax({
        url: '${pageContext.request.contextPath}/stats/branchActive',
        type: 'POST',
        data: {
            fromDate: start,
            toDate: end,
            branch: branch
        },
        success: function (items) {
			console.log('Received stats data:', items);
			
			// Sort the items array by grade
			items.sort(function(a, b) {
				return a.grade - b.grade;
			});
			
			console.log('Sorted items:', items);

            var table = document.getElementById('regStatTable');
            // flush tbody
            var tbody = document.querySelector('#regStatTable tbody');
            tbody.innerHTML = "";
            // initialise tbody
            addRows();
            
            $.each(items, function (index, item) {
                // Find the td element with the corresponding grade in the first row
                var cell = $('#regStatTable tbody tr:first-child td[grade="' + item.grade + '"]');
                console.log('Looking for grade', item.grade, 'Found cell:', cell.length > 0);
                
                if (cell.length > 0) {
                    // Update the cell content
                    cell.text(item.count);
                    cell.addClass('text-primary');
                    // Add branch and grade as attributes to the cell
                    cell.attr('branch', branch);
                    // Add click event to call studentList function
                    cell.off('click').on('click', function() {
                        studentList(branch, item.grade);
                    });
                    // Change cursor to hand pointer on hover
                    cell.css('cursor', 'pointer');
                } else {
                    console.error('No cell found with grade ' + item.grade);
                }
            });

            // Calculate the total for the row
            var row = $('#regStatTable tbody tr:nth-child(1)');
            var totalCell = row.find('td:last');
            var total = 0;
            row.find('td[grade]').each(function() {
                var cellValue = Number($(this).text());
                if (!isNaN(cellValue)) {
                    total += cellValue;
                }
            });
            totalCell.text(total);
            totalCell.addClass('text-primary font-weight-bold');
        
            // extract data for chartJs
            extractData();
            // update chart
            updateChart();
        },
        error: function (xhr, status, error) {
            console.log('Error fetching stats: ' + error);
            console.log('Response:', xhr.responseText);
        }
    });
    
    var statDiv = document.getElementById("stats");
    statDiv.style.display = 'block';
    var instDiv = document.getElementById("instruction");
    instDiv.style.display = 'none'
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Bring up Students	
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function studentList(branch, grade){
	//warn if keyword is empty
	var start = document.getElementById("fromDate").value;
	var end = document.getElementById("toDate").value;
	if (start == "" || end == "") {
		$('#warning-alert .modal-body').text('Please select date range before your search');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$('#studentListResultTable tbody').empty();
	$.ajax({
		url : '${pageContext.request.contextPath}/stats/activeStudent',
		type : 'GET',
		data : {
			start : $("#fromDate").val(),
			end : $("#toDate").val(),
			branch : branch,
			grade : grade
		},
		success : function(data) {
			//console.log('search - ' + data);
			if (data == '') {
				$('#warning-alert .modal-body').html('No student record found');
				$('#warning-alert').modal('toggle');
				return;
			}
			$.each(data, function(index, value) {
				var row = $("<tr>");		
				// Make student ID clickable
				var idCell = $('<td>').html('<span class="hand-cursor" onclick="linkToStudent(\'' + value.id + '\')" data-toggle="tooltip" title="Link to Student Information">' + value.id + '</span>');
				row.append(idCell);
				row.append($('<td>').text(value.firstName));
				row.append($('<td>').text(value.lastName));
				var gradeText = gradeName(value.grade);
				row.append($('<td>').text(gradeText));
				row.append($('<td class="text-capitalize">').text((value.gender === "") ? "" : value.gender));	
				row.append($('<td>').text(formatDate(value.registerDate)));
				row.append($('<td>').text(formatDate(value.endDate)));
				
				// Add title attribute to email cell for tooltip
				var emailCell = $('<td>').text(value.email1);
				emailCell.attr('title', value.email1);
				row.append(emailCell);
				
				// Add title attribute to contact cell for tooltip
				var contactCell = $('<td>').text(value.contactNo1);
				contactCell.attr('title', value.contactNo1);
				row.append(contactCell);
				
				$('#studentListResultTable > tbody').append(row);
			});
			
			// Initialize Bootstrap tooltips after loading data
			$('#studentListResultTable td').tooltip({
				container: 'body',
				placement: 'top'
			});
			
			$('#studentListResult').modal('show');
		},
		error : function(xhr, status, error) {
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
//		Extract Year Data	
////////////////////////////////////////////////////////////////////////////////////////////////////
function extractData() {
    var table = document.getElementById('regStatTable');
    var data = {
        p2Row: 0,
        p3Row: 0,
        p4Row: 0,
        p5Row: 0,
        p6Row: 0,
        s7Row: 0,
        s8Row: 0,
        s9Row: 0,
        s10Row: 0,
        s10eRow: 0,
        tt6Row: 0,
        tt8Row: 0,
        tt8eRow: 0,
        srw4Row: 0,
        srw5Row: 0,
        srw6Row: 0,
        srw7Row: 0,
        srw8Row: 0,
        jmssRow: 0,
        vceRow: 0
    };
    
    // Map grade attributes to data object properties
    var gradeMap = {
        1: 'p2Row',
        2: 'p3Row',
        3: 'p4Row',
        4: 'p5Row',
        5: 'p6Row',
        6: 's7Row',
        7: 's8Row',
        8: 's9Row',
        9: 's10Row',
        10: 's10eRow',
        11: 'tt6Row',
        12: 'tt8Row',
        13: 'tt8eRow',
        14: 'srw4Row',
        15: 'srw5Row',
        16: 'srw6Row',
        17: 'srw7Row',
        18: 'srw8Row',
        19: 'jmssRow',
        20: 'vceRow'
    };
    
    // Find all cells with grade attributes in the first row
    $('#regStatTable tbody tr:first-child td[grade]').each(function() {
        var grade = $(this).attr('grade');
        var cellValue = Number($(this).text());
        
        if (!isNaN(cellValue) && gradeMap[grade]) {
            data[gradeMap[grade]] = cellValue;
        }
    });
    
    tableData = data;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Add <tr> to table	
////////////////////////////////////////////////////////////////////////////////////////////////////
function addRows(){
    // Get the tbody element
    var tbody = document.querySelector('#regStatTable tbody');
    // Create a new row and cell
    var row = document.createElement('tr');
    var cell = document.createElement('td');
    // Set the row's id and the cell's text
    cell.textContent = branchName;
    cell.className = 'small align-middle text-center header font-weight-bold';
    // Add the cell to the row
    row.appendChild(cell);
    // Add the row to the tbody
    tbody.appendChild(row);
    
    // Create and add cells with proper grade attributes
    for (var i = 1; i <= 20; i++) {
        var tdCell = document.createElement('td');
        tdCell.className = 'small align-middle text-center';
        tdCell.textContent = '0';
        tdCell.setAttribute('grade', i);
        row.appendChild(tdCell);
    }
    
    // Add the total cell
    var totalCell = document.createElement('td');
    totalCell.className = 'small align-middle text-center';
    totalCell.textContent = '0';
    row.appendChild(totalCell);
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
		labels: [branchName],
		datasets: [
		 {
		  label: 'P2',
		  data: [tableData.p2Row], 
		  backgroundColor: [
			'#89cce2'
		],
		  borderWidth: 1
		},
		{
		  label: 'P3',
		  data: [tableData.p3Row],  
		  backgroundColor: [
			'#71c2dc'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'P4',
		  data: [tableData.p4Row],  
		  backgroundColor: [
			'#5ab8d6'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'P5',
		  data: [tableData.p5Row],  
		  backgroundColor: [
			'#42add1'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'P6',
		  data: [tableData.p6Row],  
		  backgroundColor: [
			'#2ba3cb'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S7',
		  data: [tableData.s7Row],  
		  backgroundColor: [
			'#e57771'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S8',
		  data: [tableData.s8Row],  
		  backgroundColor: [
			'#e16059'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S9',
		  data: [tableData.s9Row],  
		  backgroundColor: [
			'#dd4941'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S10',
		  data: [tableData.s10Row],  
		  backgroundColor: [
			'#d8332a'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'S10E',
		  data: [tableData.s10eRow],  
		  backgroundColor: [
			'#d41c12'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'TT6',
		  data: [tableData.tt6Row],  
		  backgroundColor: [
			'#fff700'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'TT8',
		  data: [tableData.tt8Row],  
		  backgroundColor: [
			'#aaff00'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'TT8E',
		  data: [tableData.tt8eRow],  
		  backgroundColor: [
			'#00ff88'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW4',
		  data: [tableData.srw4Row],  
		  backgroundColor: [
			'#00b30a'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW5',
		  data: [tableData.srw5Row],  
		  backgroundColor: [
			'#009908'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW6',
		  data: [tableData.srw6Row],  
		  backgroundColor: [
			'#008007'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW7',
		  data: [tableData.srw7Row],  
		  backgroundColor: [
			'#006606'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'SRW8',
		  data: [tableData.srw8Row],  
		  backgroundColor: [
			'#004c04'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'JMSS',
		  data: [tableData.jmssRow],  
		  backgroundColor: [
			'#ff99fb'
		 ],
		  borderWidth: 1
		 },
		 {
		  label: 'VCE',
		  data: [tableData.vceRow],  
		  backgroundColor: [
			'#ff66fa'
		 ],
		  borderWidth: 1
		 }

		]
	  },

		options: {
			plugins:{
				legend: {
					display: false
				}
			},
			scales: {
				y: {
					ticks: {
						beginAtZero: true, // Start the y-axis at 0
						stepSize: 1, // Set the interval between ticks to 1
					}
				}
			},
			responsive: true,
			animation: {
				duration: 2000, // Animation duration in milliseconds
				easing: 'linear' // Animation easing function
        	},
			interaction: {
				mode: 'index'
			}
		}
	});	
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Toggle legend in chart	
////////////////////////////////////////////////////////////////////////////////////////////////////
function toggleLegend(dataset){
	var index = dataset.value;
	//console.log(index);
	var chart = Chart.getChart('barChart');
	const isDataShown = chart.isDatasetVisible(dataset.value);
	if(isDataShown){
		chart.hide(dataset.value);
	}else{
		chart.show(dataset.value);
	}
	// update All/None checkbox
	checkboxAllChecker()
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Toggle all/none legend in chart	
////////////////////////////////////////////////////////////////////////////////////////////////////
function toggleLegendAll(dataset){
	const selectAll = document.getElementById('selectAllLegend');
	let checkboxes = document.querySelectorAll('.dataCheckbox');
	var chart = Chart.getChart('barChart');
	checkboxes.forEach(function(checkbox){
		checkbox.checked = selectAll.checked;
		if(selectAll.checked){
			chart.show(checkbox.value);
		}else{
			chart.hide(checkbox.value);
		}
	});
	chart.update();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Sync all/none checkbox with others	
////////////////////////////////////////////////////////////////////////////////////////////////////
function checkboxAllChecker(){
	let selectAll = document.getElementById('selectAllLegend');
	let checkboxes = document.querySelectorAll('.dataCheckbox');
	let total = 0;
	for(let i=0; i < checkboxes.length; i++){
		if(checkboxes[i].checked){
			total++;
		}
	}
	if(total == checkboxes.length){
		selectAll.checked = true;
	}else{
		selectAll.checked = false;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Export table data to Excel	
////////////////////////////////////////////////////////////////////////////////////////////////////
function export2Excel(){
  var table = document.getElementById('regStatTable');
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

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Link To Student Admin
////////////////////////////////////////////////////////////////////////////////////////////////////
function linkToStudent(studentId) {
    //window.location.href = '/studentAdmin?id=' + studentId;
	var url = '/studentAdmin?id=' + studentId;  
	var win = window.open(url, '_blank');
	win.focus();
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

.legendArea {
	display: inline-block;
}

/* make it responsive design */
@media (max-width: 768px) {
	.graphBox {
		grid-template-columns: 1fr;
		height: auto;
	}
}

.table-wrap {
  overflow-x: auto;
  max-width: 100%;
}

#studentListResultTable {
  table-layout: fixed;
}

#studentListResultTable th, 
#studentListResultTable td { 
  white-space: nowrap; 
  overflow: hidden; 
  text-overflow: ellipsis;
  max-width: 150px;
}

/* Specific widths for email and contact columns */
.email-column,
#studentListResultTable td:nth-child(8) {
  max-width: 180px;
  width: 180px;
}

.contact-column,
#studentListResultTable td:nth-child(9) {
  max-width: 120px;
  width: 120px;
}

/* Other columns with specific widths */
#studentListResultTable th:first-child,
#studentListResultTable td:first-child {
  width: 80px;
}

#studentListResultTable th:nth-child(2),
#studentListResultTable td:nth-child(2),
#studentListResultTable th:nth-child(3),
#studentListResultTable td:nth-child(3) {
  width: 100px;
}

#studentListResultTable th:nth-child(4),
#studentListResultTable td:nth-child(4),
#studentListResultTable th:nth-child(5),
#studentListResultTable td:nth-child(5) {
  width: 70px;
}

#studentListResultTable th:nth-child(6),
#studentListResultTable td:nth-child(6),
#studentListResultTable th:nth-child(7),
#studentListResultTable td:nth-child(7) {
  width: 90px;
}

.form-group {
    margin-bottom: 30px;
}

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

#studentListTable tr { 
	vertical-align: middle;
	height: 45px 	
}
	
.hand-cursor {
    cursor: pointer;
}
</style>

<!-- List Body -->
<div class="row max-auto p-5" id="searchCriteria" style="width: 80%;">
	<div class="col-md-2">
		<label for="fromDate" class="label-form">From Date</label>
		<input type="text" class="form-control datepicker" id="fromDate" name="fromDate" autocomplete="off" placeholder="From" required>
	</div>
	<div class="col-md-2">
		<label for="toDate" class="label-form">To Date</label> <input type="text" class="form-control datepicker" id="toDate" name="toDate" autocomplete="off" placeholder="To" required>
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
	<div class="alert alert-info p-4" role="alert">
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
			<div id="legendArea" class="text-center mt-5 mb-2">
				<input type="checkbox" id="selectAllLegend"onclick="toggleLegendAll(this)"checked><span class="ml-1 mr-3">All/None</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="0"><span class="mr-2 ml-1" style="color : #89cce2;">P2</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="1"><span class="mr-2 ml-1" style="color : #71c2dc;">P3</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="2"><span class="mr-2 ml-1" style="color : #5ab8d6;">P4</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="3"><span class="mr-2 ml-1" style="color : #42add1;">P5</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="4"><span class="mr-2 ml-1" style="color : #2ba3cb;">P6</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="5"><span class="mr-2 ml-1" style="color : #e57771;">S7</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="6"><span class="mr-2 ml-1" style="color : #e16059;">S8</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="7"><span class="mr-2 ml-1" style="color : #dd4941;">S9</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="8"><span class="mr-2 ml-1" style="color : #d8332a;">S10</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="9"><span class="mr-2 ml-1" style="color : #d41c12;">S10E</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="10"><span class="mr-2 ml-1" style="color : #fff700;">TT6</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="11"><span class="mr-2 ml-1" style="color : #aaff00;">TT8</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="12"><span class="mr-2 ml-1" style="color : #00ff88;">TT8E</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="13"><span class="mr-2 ml-1" style="color : #00b30a;">SRW4</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="14"><span class="mr-2 ml-1" style="color : #009908;">SRW5</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="15"><span class="mr-2 ml-1" style="color : #008007;">SRW6</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="16"><span class="mr-2 ml-1" style="color : #006606;">SRW7</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="17"><span class="mr-2 ml-1" style="color : #004c04;">SRW8</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="18"><span class="mr-2 ml-1" style="color : #ff99fb;">JMSS</span>
				<input type="checkbox" class="dataCheckbox" onclick="toggleLegend(this)" checked value="19"><span class="mr-2 ml-1" style="color : #ff66fa;">VCE</span>
			</div>
			<canvas id="barChart"></canvas>
        </div>
    </div>
    <!-- table -->
    <div class="col-md-12">
        <!-- <div class="mt-3 mb-3 mr-5 text-right">
            <button id="exportToExcel" class="btn btn-primary" onclick="export2Excel()">Export to Excel</button>
        </div> -->
        <table id="regStatTable" class="table table-bordered">
            <thead class="table-primary">
                <tr>
                    <th class="header" data-toggle="tooltip" grade="0"></th>
                    <th class="header" data-toggle="tooltip" grade="1">P2</th>
                    <th class="header" data-toggle="tooltip" grade="2">P3</th>
                    <th class="header" data-toggle="tooltip" grade="3">P4</th>
                    <th class="header" data-toggle="tooltip" grade="4">P5</th>
                    <th class="header" data-toggle="tooltip" grade="5">P6</th>
                    <th class="header" data-toggle="tooltip" grade="6">S7</th>
                    <th class="header" data-toggle="tooltip" grade="7">S8</th>
                    <th class="header" data-toggle="tooltip" grade="8">S9</th>
                    <th class="header" data-toggle="tooltip" grade="9">S10</th>
                    <th class="header" data-toggle="tooltip" grade="10">S10E</th>
                    <th class="header" data-toggle="tooltip" grade="11">TT6</th>
                    <th class="header" data-toggle="tooltip" grade="12">TT8</th>
                    <th class="header" data-toggle="tooltip" grade="13">TT8E</th>
                    <th class="header" data-toggle="tooltip" grade="14">SRW4</th>
                    <th class="header" data-toggle="tooltip" grade="15">SRW5</th>
                    <th class="header" data-toggle="tooltip" grade="16">SRW6</th>
                    <th class="header" data-toggle="tooltip" grade="17">SRW7</th>
                    <th class="header" data-toggle="tooltip" grade="18">SRW8</th>
                    <th class="header" data-toggle="tooltip" grade="19">JMSS</th>
                    <th class="header" data-toggle="tooltip" grade="20">VCE</th>
                    <th class="header" data-toggle="tooltip" grade="100">Total</th>
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
        <div class="alert alert-block alert-warning alert-dialog-display jae-border-warning">
            <i class="bi bi-exclamation-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
            <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
        </div>
    </div>
</div>

<!-- Search Result Dialog -->
<div class="modal fade" id="studentListResult">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content jae-border-primary">
        <div class="modal-header bg-primary text-white rounded-top">
          <h5 class="modal-title">&nbsp;<i class="bi bi-card-list"></i>&nbsp;&nbsp; Student List</h5>
          <button type="button" class="close" data-dismiss="modal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body table-wrap">
          <table class="table table-striped table-bordered table-responsive-sm" id="studentListResultTable" data-header-style="headerStyle" style="font-size: smaller; width: 100%;">
            <thead class="thead-light">
              <tr>
                <th data-field="id">ID</th>
                <th data-field="firstname">First Name</th>
                <th data-field="lastname">Last Name</th>
                <th data-field="grade">Grade</th>
                <th data-field="gender">Gender</th>
                <th data-field="startdate">Start Date</th>
                <th data-field="enddate">End Date</th>
                <th data-field="email" class="email-column">Main Email</th>
                <th data-field="contact1" class="contact-column">Main Contact</th>
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
    #studentListResultTable th, #studentListResultTable td { 
      white-space: nowrap; 
      overflow: hidden; 
      text-overflow: ellipsis;
      max-width: 150px; /* Set a reasonable max width for all cells */
    }
    
    /* Specific widths for email and contact columns */
    #studentListResultTable th:nth-child(8),
    #studentListResultTable td:nth-child(8) {
      max-width: 180px;
    }
    
    #studentListResultTable th:nth-child(9),
    #studentListResultTable td:nth-child(9) {
      max-width: 120px;
    }
    
    .form-group {
        margin-bottom: 30px;
    }
</style>


<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>