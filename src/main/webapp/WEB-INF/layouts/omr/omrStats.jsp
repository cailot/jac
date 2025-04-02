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
			// Initialise the table
			clearTableColumnsExceptBranch();
			// Keep track of branches that have been updated
			const updatedBranches = new Set();
			$.each(items, function (index, item) {
				console.log(item);
				// Skip branches with code >= 90
				if (item.branch >= 90) {
					return;
				}
				// Convert branch to string and trim whitespace
				var branchCode = item.branch;
				// Search for the <tr> with the matching code attribute
				var row = $('#omrStatTable > tbody tr[code="' + branchCode + '"]');		
				if (row.length > 0) {
					// Update the row's cells
					row.find('td').eq(1).text(item.mega);
					row.find('td').eq(2).text(item.revision);
					row.find('td').eq(3).text(item.tt6);
					row.find('td').eq(4).text(item.tt8);
					row.find('td').eq(5).text(item.jmss);
					row.find('td').eq(6).text(item.mega + item.revision + item.tt6 + item.tt8 + item.jmss).addClass('text-primary');
					// Mark this branch as updated
					updatedBranches.add(branchCode);
				} else {
					console.log('Row with branch code ' + branchCode + ' does not exist.');
				}
			});

			// Fill rows with 0 for branches that were not updated
			$('#omrStatTable > tbody tr').each(function () {
                var branchCode = $(this).attr('code');
                if (branchCode !== 'total' && !updatedBranches.has(branchCode)) {
                    $(this).find('td').eq(1).text(0); // Mega
                    $(this).find('td').eq(2).text(0); // Revision
                    $(this).find('td').eq(3).text(0); // TT6
                    $(this).find('td').eq(4).text(0); // TT8
					$(this).find('td').eq(5).text(0); // JMSS
                    $(this).find('td').eq(6).text(0).addClass('text-primary'); // Sum
                }
            });
			// Update the TOTAL row
			populateTotals();
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Initialise omrStatTable	
////////////////////////////////////////////////////////////////////////////////////////////////////
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
				row.append($('<td class="text-center">'));
				row.append($('<td class="text-center">'));
				row.append($('<td class="text-center">'));
				row.append($('<td class="text-center">'));
				row.append($('<td class="text-center">'));
				row.append($('<td class="text-center">'));
				row.append($('<td>'));
				$('#omrStatTable > tbody').append(row);
			});
			var totalRow = $("<tr class='header' code='total'>");
			totalRow.append($('<td class="text-center font-weight-bold">TOTAL</td>'));
			totalRow.append($('<td class="font-weight-bold text-center">'));
			totalRow.append($('<td class="font-weight-bold text-center">'));
			totalRow.append($('<td class="font-weight-bold text-center">'));
			totalRow.append($('<td class="font-weight-bold text-center">'));
			totalRow.append($('<td class="font-weight-bold text-center">'));
			totalRow.append($('<td class="font-weight-bold text-center">'));
			totalRow.append($('<td>'));
			$('#omrStatTable > tbody').append(totalRow);
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear exisiting values in omrStatTable	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearTableColumnsExceptBranch() {
    // Select all rows in the table body
    $('#omrStatTable > tbody tr').each(function () {
        // Iterate through all <td> elements in the row
        $(this).find('td').each(function (index) {
            // Skip the first column (branch column)
            if (index !== 0) {
                $(this).text(''); // Clear the content of the cell
            }
        });
    });
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clear Search Info	
////////////////////////////////////////////////////////////////////////////////////////////////////
function clearSearchCriteria() {
	document.getElementById("fromDate").value = "";
	document.getElementById("toDate").value = "";	
	// flush tbody
	clearTableColumnsExceptBranch();		
}


////////////////////////////////////////////////////////////////////////////////////////////////////
//		Populate Total	
////////////////////////////////////////////////////////////////////////////////////////////////////
function populateTotals() {
    // Initialize totals for each column
    let megaTotal = 0;
    let revisionTotal = 0;
	let tt6Total = 0;
	let tt8Total = 0;
	let jmssTotal = 0;

    // Iterate through all rows in the table body (excluding the TOTAL row)
    $('#omrStatTable > tbody tr').each(function () {
        // Skip the TOTAL row (if it has a specific identifier or class)
        if ($(this).attr('code') === 'total') {
            return;
        }

        // Parse and sum up the values for each column
        megaTotal += parseInt($(this).find('td').eq(1).text()) || 0;
        revisionTotal += parseInt($(this).find('td').eq(2).text()) || 0;
        tt6Total += parseInt($(this).find('td').eq(3).text()) || 0;
        tt8Total += parseInt($(this).find('td').eq(4).text()) || 0;
		jmssTotal += parseInt($(this).find('td').eq(5).text()) || 0;
    });

    // Calculate the total sum of all columns
    const totalSum = megaTotal + revisionTotal + tt6Total + tt8Total + jmssTotal;

    // Find or create the TOTAL row
    let totalRow = $('#omrStatTable > tbody tr[code="total"]');
    if (totalRow.length === 0) {
        // If the TOTAL row doesn't exist, create it
        totalRow = $('<tr code="total" class="font-weight-bold text-center">');
        totalRow.append('<td class="text-center">TOTAL</td>'); // First column for "TOTAL" label
        totalRow.append('<td></td>'); // Placeholder for mega total
        totalRow.append('<td></td>'); // Placeholder for revision total
        totalRow.append('<td></td>'); // Placeholder for tt6 total
        totalRow.append('<td></td>'); // Placeholder for tt8 total
		totalRow.append('<td></td>'); // Placeholder for jmss total
        totalRow.append('<td></td>'); // Placeholder for total sum
        $('#omrStatTable > tbody').append(totalRow);
    }

    // Update the TOTAL row with calculated values
    totalRow.find('td').eq(1).text(megaTotal); // Mega total
    totalRow.find('td').eq(2).text(revisionTotal); // Revision total
    totalRow.find('td').eq(3).text(tt6Total); // TT6 total
    totalRow.find('td').eq(4).text(tt8Total); // TT8 total
	totalRow.find('td').eq(5).text(jmssTotal); // JMSS total
    totalRow.find('td').eq(6).text(totalSum).addClass('text-primary'); // Total sum
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
	downloadLink.download = 'omr-statistics.csv';
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
    font-size: large;
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
					<th class="header">Mega</th>
					<th class="header">Revision</th>
					<th class="header">TT6</th>
					<th class="header">TT8</th>
					<th class="header">JMSS</th>
					<th class="header">SUM</th>
					<th class="header">Note</th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
</div>
	
