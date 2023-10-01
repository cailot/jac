<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>

<script>
const ATTENDANCE = 'attendance';

$(document).ready(function() {
    var windowHeight = $(window).height();
    var scrollHeight = windowHeight * 0.35; // Adjust the percentage as needed

    $('#attendanceTable').DataTable({
        "scrollY": scrollHeight + "px",
        "scrollCollapse": true,
		"lengthChange": false,
		"searching": false,
		"paging": false,
		"info": false,
		"ordering": false
    });

    $('.dataTables_length').addClass('bs-select');
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
				//debugger;
				$.each(response, function(index, value){
					// console.log(index + ' - ' + value.id);  
					var row = $("<tr class='d-flex'>");
					row.append($('<td>').addClass('hidden-column').addClass('data-type').text(ATTENDANCE + '|' + value.id));
					row.append($('<td class="small" style="width: 20%;">').text(value.clazzGrade.toUpperCase() + '-' + value.week));
					row.append($('<td class="small" style="width: 35%;">').text(value.attendDate));
					row.append($('<td class="small" style="width: 15%;">').text(value.status));
					row.append($('<td class="small text-right mr-2" style="width: 30%;">').text(value.clazzDay));
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
					<table class="table" id="attendanceTable" name="attendanceTable" >
						<thead>
							<tr class="d-flex">
								<th class="hidden-column"></th>
								<th class="smaller-table-font text-center" style="width: 20%;">Week</th>
								<th class="smaller-table-font text-center" style="width: 35%;">Date</th>
								<th class="smaller-table-font text-center" style="width: 15%;">Status</th>
								<th class="smaller-table-font text-center" style="width: 30%;">Class</th>
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
	
