<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<script src="${pageContext.request.contextPath}/js/moment-2.29.1.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/datetime-moment.js"></script>

<script>
const ATTENDANCE = 'attendance';
const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
					

$(document).ready(function() {


    var windowHeight = $(window).height();
    var scrollHeight = windowHeight * 0.35; // Adjust the percentage as needed

	$.fn.dataTable.moment('DD/MM/YYYY');
    $('#attendanceTable').DataTable({
        "scrollY": scrollHeight + "px",
        "scrollCollapse": true,
		"lengthChange": false,
		"searching": false,
		"paging": false,
		"info": false,
		"ordering": false,
		"order": [[ 2, "asc" ]]
    });

    // $('.dataTables_length').addClass('bs-select');
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
					// console.log(index + ' - ' + value);
					var id = value.id;  
					var row = $("<tr class='d-flex'>");
					row.append($('<td>').addClass('hidden-column').addClass('data-type').text(ATTENDANCE + '|' + id));
					row.append($('<td class="small text-center" style="width: 35%;">').text(value.clazzGrade.toUpperCase() + '-' + value.week));
					var dropdown = $('<select class="small text-center" style="width: 100%; border: none;" title="' + value.attendDate + '">');
					// var daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
					// Loop through the daysOfWeek array
					for (var i = 0; i < daysOfWeek.length; i++) {
  						var option = $('<option>').text(daysOfWeek[i]);
						// Set the selected attribute for the corresponding day
						if (value.clazzDay === daysOfWeek[i]) {
							option.attr('selected', 'selected');
						}
  						dropdown.append(option);
					}
					// Attach an event listener to the element
					dropdown.on('change', function() {
						var selectedValue = $(this).val();
						updateAttendanceDay(id, selectedValue);
					});
					row.append($('<td class="day-select">').append(dropdown));
					var status = '';	
					if(value.status === 'Y'){
						status = '<i class="bi bi-check-circle text-success" title="Attended"></i>';
					}else if(value.status === 'N'){
						status = '<i class="bi bi-x-circle text-danger" title="Absent"></i>';
					}else if(value.status === 'P'){
						status = '<i class="bi bi-pause-circle text-warning" title="Pause"></i>';
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
	console.log('updateAttendanceDay: ' + id + ' - ' + day);
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
								<th class="smaller-table-font text-center" style="width: 15%;">Status</th>
								<!-- <th class="smaller-table-font text-center" style="width: 30%;">Class</th> -->
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
	
