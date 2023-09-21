<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables.min.js"></script>

<script>
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
</script>
<div class="modal-body" style="padding-left: 0px; padding-right: 5px;">
	<form id="accetandanceForm">
		<div class="form-group">
			<div class="form-row">
				<div class="col-md-12">
					<table class="table" id="attendanceTable" name="attendanceTable" >
						<thead>
							<tr>
								<th class="smaller-table-font text-center">Week</th>
								<th class="smaller-table-font text-center">Date</th>
								<th class="smaller-table-font text-center">Status</th>
								<th class="smaller-table-font text-center">Class</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
							<tr>
								<td class="small">P2-15</td>
								<td class="small">20/09/2023</td>
								<td class="small">A</td>
								<td class="small">Tuesday</td>
							</tr>
						</tbody>
					</table> 
					
				</div>
			</div>
		</div>
	</form>
</div>
	
