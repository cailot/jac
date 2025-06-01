<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<script src="${pageContext.request.contextPath}/js/moment-2.29.1.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/datetime-moment.js"></script>

<script>
const ATTENDANCE = 'attendance';
const daysOfWeek = ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'SAT Morning', 'SAT Afternoon', 'SUN Morning', 'SUN Afternoon'];
					

$(document).ready(function() {
    function adjustAttendanceTableHeight() {
        // Get the height of the course info section and add some extra space
        var courseTableHeight = $('#basketTable').height();
        var attendanceHeight = Math.max(courseTableHeight, 400); // Minimum height of 400px
        
        // Initialize DataTable with dynamic height
        if ($.fn.DataTable.isDataTable('#attendanceTable')) {
            $('#attendanceTable').DataTable().destroy();
        }
        
        $.fn.dataTable.moment('DD/MM/YYYY');
        $('#attendanceTable').DataTable({
            "scrollY": attendanceHeight + "px",
            "scrollCollapse": true,
            "lengthChange": false,
            "searching": false,
            "paging": false,
            "info": false,
            "ordering": false,
            "order": [[ 2, "asc" ]],
            "language": {
                "emptyTable": "",
                "zeroRecords": ""
            },
            "drawCallback": function(settings) {
                $('#attendanceTable tbody tr:first-child').css('border-top', '1px solid #dee2e6');
            }
        });
    }

    // Initial adjustment
    adjustAttendanceTableHeight();

    // Adjust height when window is resized
    $(window).on('resize', function() {
        adjustAttendanceTableHeight();
    });

    // Adjust height when course table content changes
    $('#basketTable').on('DOMSubtreeModified', function() {
        setTimeout(adjustAttendanceTableHeight, 100); // Add slight delay to ensure content is updated
    });
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
					// console.log(value.attendDate + '--' +value.clazzDay);
					var id = value.id;  
					var row = $("<tr class='d-flex'>");
					row.append($('<td>').addClass('hidden-column').addClass('data-type').text(ATTENDANCE + '|' + id));
					row.append($('<td class="small text-center" style="width: 35%;">').text(gradeName(value.clazzGrade) + '-' + value.week));
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
					}	
					row.append($('<td class="small text-center status-select" style="width: 15%;">').html(status));
			
					$('#attendanceTable > tbody').append(row);  
				});
			},
			error: function(xhr, status, error) {
				// Handle the error
				console.error(error);
			}
	});
}


//////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update attendace day
//////////////////////////////////////////////////////////////////////////////////////////////////////
function updateAttendanceDay(id, day) {
	// get the attendance list
	// console.log('updateAttendanceDay: ' + id + ' - ' + day);
	$.ajax({
			url: '${pageContext.request.contextPath}/attendance/updateDay/' + id + '/' + day,
			method: 'PUT',
			success: function(response) {
				// Handle the response
				console.log(response);
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

</script>


<div class="modal-body" style="padding-left: 0px; padding-right: 5px;">
	<form id="accetandanceForm">
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-12">
					<table class="table" id="attendanceTable" name="attendanceTable">
						<thead>
							<tr class="d-flex">
								<th class="hidden-column"></th>
								<th class="smaller-table-font text-center" style="width: 35%;">Week</th>
								<th class="smaller-table-font text-center" style="width: 50%;">Day</th>
								<th class="smaller-table-font text-left" style="width: 15%;">Status</th>
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


</style>
	