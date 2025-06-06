<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<script src="${pageContext.request.contextPath}/js/moment-2.29.1.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/datetime-moment.js"></script>

<script>
const ATTENDANCE = 'attendance';
const daysOfWeek = ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'SAT Morning', 'SAT Afternoon', 'SUN Morning', 'SUN Afternoon'];

// Fallback gradeName function in case jae.js is not loaded
function gradeName(value) {
	var gradeText = '';
	switch(value) {
		case '1': gradeText = 'P2'; break;
		case '2': gradeText = 'P3'; break;
		case '3': gradeText = 'P4'; break;
		case '4': gradeText = 'P5'; break;
		case '5': gradeText = 'P6'; break;
		case '6': gradeText = 'S7'; break;
		case '7': gradeText = 'S8'; break;
		case '8': gradeText = 'S9'; break;
		case '9': gradeText = 'S10'; break;
		case '10': gradeText = 'S10E'; break;
		case '11': gradeText = 'TT6'; break;
		case '12': gradeText = 'TT8'; break;
		case '13': gradeText = 'TT8E'; break;
		case '14': gradeText = 'SRW4'; break;
		case '15': gradeText = 'SRW5'; break;
		case '16': gradeText = 'SRW6'; break;
		case '17': gradeText = 'SRW7'; break;
		case '18': gradeText = 'SRW8'; break;
		case '19': gradeText = 'JMSS'; break;
		case '20': gradeText = 'VCE'; break;
		default: gradeText = 'Grade ' + value; 
	}
	return gradeText;
}

$(document).ready(function() {
    function adjustAttendanceTableHeight() {
        // Get the height of the course info section and add some extra space
        var courseTableHeight = $('#basketTable').height();
        var attendanceHeight = Math.max(courseTableHeight, 400); // Minimum height of 400px
        
        // Set a fixed height for the attendance table container instead of using DataTables
        $('#attendanceTable').closest('.col-md-12').css({
            'max-height': attendanceHeight + 'px',
            'overflow-y': 'auto'
        });
        
        // Don't initialize DataTables - just use a regular table
        // The DataTables plugin was interfering with manually added rows
    }

    // Initial adjustment
    adjustAttendanceTableHeight();

    // Adjust height when window is resized
    $(window).on('resize', function() {
        adjustAttendanceTableHeight();
    });

    // Adjust height when course table content changes
    var basketTable = document.getElementById('basketTable');
    if (basketTable) {
        var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.type === 'childList' || mutation.type === 'subtree') {
                    setTimeout(adjustAttendanceTableHeight, 100);
                }
            });
        });
        
        observer.observe(basketTable, {
            childList: true,
            subtree: true,
            attributes: false
        });
    }
});


//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve attendace list
//////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveAttendance(studentId) {
	// clear the attendance list
	clearAttendanceTable();
	
	// get the attendance list
	$.ajax({
			url: '${pageContext.request.contextPath}/attendance/list/student/' + studentId,
			method: 'GET',
			success: function(response) {
				// Handle the response
				$.each(response, function(index, value){
					try {
						var id = value.id;  
						var row = $("<tr>");
						row.append($('<td>').addClass('hidden-column').addClass('data-type').text(ATTENDANCE + '|' + id));
						
						// Use a fallback for gradeName function if it's not available
						var gradeDisplay = '';
						try {
							gradeDisplay = typeof gradeName === 'function' ? gradeName(value.clazzGrade) : 'Grade ' + value.clazzGrade;
						} catch (e) {
							console.error('Error calling gradeName:', e);
							gradeDisplay = 'Grade ' + value.clazzGrade;
						}
						
						row.append($('<td class="small text-center" style="width: 35%;">').text(gradeDisplay + '-' + value.week));
						
						var dayDropdown = $('<select class="small text-center dayChoice" style="width: 100%; border: none;" data-toggle="tooltip" title="' + value.attendDate + '">');
						// Loop through the daysOfWeek array
						for (var i = 0; i < daysOfWeek.length; i++) {
							var option = $("<option value='" + i + "'>").text(daysOfWeek[i]);
							dayDropdown.append(option);
							// Adjusted to match clazzDay with array index
							if (value.clazzDay == i) {
								option.attr('selected', 'selected');
							}
						}
						// Attach an event listener to the element
						dayDropdown.on('change', function() {
							var selectedValue = $(this).val();
							updateAttendanceDay(id, selectedValue);
							// update status-select column with <i class="bi bi-check-circle text-success" title="Attended"></i>
							var row = $(this).closest('tr'); // Get the closest <tr> element
							var statusSelect = row.find('.status-select');		
							statusSelect.html('<i class="bi bi-check-circle text-success" data-toggle="tooltip" title="Attended"></i>');								
						});
						row.append($('<td class="day-select" style="width: 50%;">').append(dayDropdown));
						
						var status = '';	
						if(value.status === 'Y'){
							status = '<i class="bi bi-check-circle text-success" data-toggle="tooltip" title="Attended"></i>';
						}else if(value.status === 'N'){
							status = '<i class="bi bi-x-circle text-danger" data-toggle="tooltip" title="Absent"></i>';
						}else if(value.status === 'P'){
							status = '<i class="bi bi-pause-circle text-warning" data-toggle="tooltip" title="Pause"></i>';
						}else if(value.status === 'O'){
							status = '<i class="bi bi-circle text-secondary" data-toggle="tooltip" title="Not Set"></i>';
						}else{
							status = '<i class="bi bi-question-circle text-muted" data-toggle="tooltip" title="Unknown Status: ' + value.status + '"></i>';
						}	
						row.append($('<td class="small text-center status-select" style="width: 15%;">').html(status));
				
						$('#attendanceTable > tbody').append(row);
					} catch (e) {
						console.error('Error processing attendance record:', e, value);
					}
				});
				
				// Force table refresh and make sure rows are visible
				$('#attendanceTable').show();
				$('#attendanceTable tbody').show();
				$('#attendanceTable tbody tr').show();
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error('Error fetching attendance:', error);
				console.error('Response text:', xhr.responseText);
			}
	});
}


//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update attendace day
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateAttendanceDay(id, day) {
	$.ajax({
			url: '${pageContext.request.contextPath}/attendance/updateDay/' + id + '/' + day,
			method: 'PUT',
			success: function(response) {
				// Success - no need for console log
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
	});
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Clean attendace list
//////////////////////////////////////////////////////////////////////////////////////////////////////
function clearAttendanceTable() {
	$('#attendanceTable > tbody').empty();
}

// Make the functions available globally for debugging
window.retrieveAttendance = retrieveAttendance;
window.clearAttendanceTable = clearAttendanceTable;
</script>


<div class="modal-body" style="padding-left: 0px; padding-right: 5px;">
	<form id="accetandanceForm">
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-12">
					<table class="table table-striped table-bordered" id="attendanceTable" name="attendanceTable">
						<thead class="table-light">
							<tr>
								<th class="hidden-column"></th>
								<th class="smaller-table-font text-center" style="width: 35%;">Week</th>
								<th class="smaller-table-font text-center" style="width: 50%;">Day</th>
								<th class="smaller-table-font text-center" style="width: 15%;">Status</th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table> 
				</div>
			</div>
		</div>
	</form>
</div>
	
<style>
#attendanceTable thead th {
    border-top: 1px solid #dee2e6; /* Adjust color to match your theme */
    border-bottom: 1px solid #dee2e6; /* Add bottom border for header consistency */
}

#attendanceTable tbody tr:first-child td {
    border-top: 1px solid #dee2e6; /* Ensure the first row's top cells have a border */
}

#attendanceTable tbody tr {
    padding: 0; /* Remove any padding from the rows */
    margin: 0; /* Remove any margin from the rows */
}

#attendanceTable tbody tr td {
    padding: 8px; /* Add some padding for better readability */
    margin: 0; /* Remove any margin from the cells */
    border-bottom: 1px solid #dee2e6; /* Ensure consistent borders between rows */
}

.dataTables_empty {
    display: none; /* Ensure the empty table message is hidden */
}

/* Remove background color from attendance dropdown */
.dayChoice {
    background-color: transparent !important;
    background: none !important;
}

</style>
	