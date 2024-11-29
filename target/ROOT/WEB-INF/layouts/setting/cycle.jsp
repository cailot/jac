<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.Calendar" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/jquery.dataTables-1.13.4.min.css"></link>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/buttons.dataTables.min.css"></link>
<script src="${pageContext.request.contextPath}/js/jquery.dataTables-1.13.4.min.js"></script>
<script src="${pageContext.request.contextPath}/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/js/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/js/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/js/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/js/buttons.print.min.js"></script>
<script>
	$(document).ready(function () {

		$('#cycleListTable').DataTable({
			language: {
				search: 'Filter:'
			},
		});

		$("#addStartDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#addEndDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#addVacationStartDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#addVacationEndDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#editStartDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#editEndDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#editVacationStartDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});
		$("#editVacationEndDate").datepicker({
			dateFormat: 'dd/mm/yy'
		});

	});

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//		Register Cycle
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function addCycle() {

		var desc = document.getElementById('addDescription');
		if(desc.value== ""){
			$('#validation-alert .modal-body').text(
					'Please enter description');
			$('#validation-alert').modal('show');
			$('#validation-alert').on('hidden.bs.modal', function () {
       			 desc.focus();
    		});
			return false;
		}
		// Get from form data
		var cycle = {
			year: $("#addYear").val(),
			description: $("#addDescription").val(),
			startDate: $("#addStartDate").val(),
			endDate: $("#addEndDate").val(),
			vacationStartDate: $("#addVacationStartDate").val(),
			vacationEndDate: $("#addVacationEndDate").val()
		}
		// Send AJAX to server
		$.ajax({
			url: '${pageContext.request.contextPath}/class/registerCycle',
			type: 'POST',
			dataType: 'json',
			data: JSON.stringify(cycle),
			contentType: 'application/json',
			success: function (student) {
				// Display the success alert
				$('#success-alert .modal-body').text(
					'New Cycle is registered successfully.');
				$('#success-alert').modal('show');
				$('#success-alert').on('hidden.bs.modal', function (e) {
					location.reload();
				});
			},
			error: function (xhr, status, error) {
				console.log('Error : ' + error);
			}
		});
		$('#registerCycleModal').modal('hide');
		// flush all registered data
		document.getElementById("cycleRegister").reset();
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//		Retrieve Cycle
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function retrieveCycleInfo(cycleId) {
		// send query to controller
		$.ajax({
			url: '${pageContext.request.contextPath}/class/get/cycle/' + cycleId,
			type: 'GET',
			success: function (cycle) {
				//console.log(cycle);
				$("#editId").val(cycle.id);
				$("#editYear").val(cycle.year);
				$("#editDescription").val(cycle.description);
				// Set date value
				var startDate = new Date(cycle.startDate); // Replace with your date value
				$("#editStartDate").datepicker('setDate', startDate);
				var endDate = new Date(cycle.endDate); // Replace with your date value
				$("#editEndDate").datepicker('setDate', endDate);
				var vacationStartDate = new Date(cycle.vacationStartDate); // Replace with your date value
				$("#editVacationStartDate").datepicker('setDate', vacationStartDate);
				var vacationEndDate = new Date(cycle.vacationEndDate); // Replace with your date value
				$("#editVacationEndDate").datepicker('setDate', vacationEndDate);
				// show dialog
				$('#editCycleModal').modal('show');
			},
			error: function (xhr, status, error) {
				console.log('Error : ' + error);
			}
		});
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//		Update Cycle
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function updateCycleInfo() {
		var cycleId = $("#editId").val();

		var desc = document.getElementById('editDescription');
		if(desc.value== ""){
			$('#validation-alert .modal-body').text(
					'Please enter description');
			$('#validation-alert').modal('show');
			$('#validation-alert').on('hidden.bs.modal', function () {
       			 desc.focus();
    		});
			return false;
		}

		// get from formData
		var cycle = {
			id: cycleId,
			year: $("#editYear").val(),
			description: $("#editDescription").val(),
			startDate: $("#editStartDate").val(),
			endDate: $("#editEndDate").val(),
			vacationStartDate: $("#editVacationStartDate").val(),
			vacationEndDate: $("#editVacationEndDate").val()
		}

		//console.log(cycle);
		// send query to controller
		$.ajax({
			url: '${pageContext.request.contextPath}/class/update/cycle',
			type: 'PUT',
			dataType: 'json',
			data: JSON.stringify(cycle),
			contentType: 'application/json',
			success: function (value) {
				// Display success alert
				$('#success-alert .modal-body').text('Academic cycle is updated successfully.');
				$('#success-alert').modal('show');
				$('#success-alert').on('hidden.bs.modal', function (e) {
					location.reload();
				});
			},
			error: function (xhr, status, error) {
				console.log('Error : ' + error);
			}
		});

		$('#editCycleModal').modal('hide');
		// flush all registered data
		clearFormData("cycleEdit");
	}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Cycle
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function deleteCycle(id) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/class/deleteCycle/' + id,
		type : 'PUT',
		success : function(data) {
			// clear existing form
			$('#success-alert .modal-body').text('Cycle is now deleted');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function(e) {
				location.reload();
			});
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
	}); 
}

window.showWarning = function(id) {
    // Show the warning modal
    $('#deleteModal').modal('show');
    // Attach the click event handler to the "Delete" button
    $('#agreeDelete').one('click', function() {
        deleteCycle(id);
        $('#deleteModal').modal('hide');
    });
}


</script>

<style>
	div.dataTables_length{
		padding-top: 40px;
		padding-bottom: 10px;
	}

	div.dataTables_filter {
		padding-top: 35px;
		padding-bottom: 35px;
	}

	#cycleListTable tr { 
		vertical-align: middle;
		height: 50px 	
	} 
</style>

<!-- List Body -->
<div class="row container-fluid m-5">
	<div class="modal-body">
		<form id="classList" method="get" action="${pageContext.request.contextPath}/class/listCycle">
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-2">
						<label for="listYear" class="label-form">Academic Year</label>
						<select class="form-control" id="listYear" name="listYear">
							<%
								Calendar now = Calendar.getInstance();
								int currentYear = now.get(Calendar.YEAR);
								int nextYear = currentYear + 1;
							%>
							<option value="0">All</option>
							<option value="<%= currentYear %>">Academic Year <%= (currentYear%100) %>/<%= (currentYear%100)+1 %></option>
							<%
								// Adding the last five years
								for (int i = currentYear - 1; i >= currentYear - 5; i--) {
							%>
								<option value="<%= i %>">Academic Year <%= (i%100) %>/<%= (i%100)+1 %></option>
							<%
							}
							%>
						</select>
					</div>
					<div class="offset-md-7"></div>
					<div class="col mx-auto">
						<label class="label-form text-white">0</label>
						<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
					</div>
					<div class="col mx-auto">
						<label class="label-form text-white">0</label>
						<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerCycleModal">
							<i class="bi bi-plus"></i>&nbsp;New</button>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="form-row">
					<div class="col-md-12">
						<div class="table-wrap">
							<table id="cycleListTable" class="table table-striped table-bordered">
								<thead class="table-primary">
									<tr>
										<th class="text-center align-middle" style="width: 10%">Start Year</th>
										<th class="text-center align-middle" style="width: 40%">Description</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Start Date</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">End Date</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Vacation Start</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Vacation End</th>
										<th class="text-center align-middle" data-orderable="false" style="width: 10%">Action</th>
									</tr>
								</thead>
								<tbody id="list-class-body">
									<c:choose>
										<c:when test="${CycleList != null}">
											<c:forEach items="${CycleList}" var="cycle">
												<tr>
													<td class="small align-middle text-center">
														<c:out value="${cycle.year}" />
													</td>
													<td class="small align-middle"><span
															style="text-transform: capitalize;">
															<c:out value="${cycle.description}" />
														</span></td>
													<td class="small align-middle text-center">
														<fmt:parseDate var="cycleStartDate" value="${cycle.startDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${cycleStartDate}" pattern="dd/MM/yyyy" />
													</td>
													<td class="small align-middle text-center">
														<fmt:parseDate var="cycleEndDate" value="${cycle.endDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${cycleEndDate}" pattern="dd/MM/yyyy" />
													</td>
													<td class="small align-middle text-center">
														<fmt:parseDate var="cycleVacationStartDate" value="${cycle.vacationStartDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${cycleVacationStartDate}" pattern="dd/MM/yyyy" />
													</td>
													<td class="small align-middle text-center">
														<fmt:parseDate var="cycleVactionEndDate" value="${cycle.vacationEndDate}" pattern="yyyy-MM-dd" />
														<fmt:formatDate value="${cycleVactionEndDate}" pattern="dd/MM/yyyy" />
													</td>
													<td class="text-center align-middle">
														<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveCycleInfo('${cycle.id}')"></i>&nbsp;
														<i class="bi bi-trash text-danger hand-cursor" data-toggle="tooltip" title="Delete" onclick="showWarning('${cycle.id}')"></i>
													</td>
												</tr>
											</c:forEach>

										</c:when>
									</c:choose>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>

		</form>
	</div>
</div>

<!-- Add Form Dialogue -->
<div class="modal fade" id="registerCycleModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Adademic Cycle Registration</header>
					<form id="cycleRegister">
						<div class="form-row mt-4">
							<div class="offset-md-1"></div>
							<div class="col-md-3">
								<label for="addYear" class="label-form">Academic Year</label> 
								<select class="form-control" id="addYear" name="addYear">
								<option value="<%= nextYear %>"><%= nextYear %></option>
								<option value="<%= currentYear %>"><%= currentYear %></option>
								<%
									for (int i = currentYear - 1; i >= currentYear - 3; i--) {
								%>
								<option value="<%= i %>"><%= i %></option>
								<%
									}
								%>
								</select>
							</div>
							<div class="col-md-7">
								<label for="addDescription" class="label-form">Description</label> 
								<input type="text" class="form-control" id="addDescription" name="addDescription" placeholder="Description" title="Please enter cycle description">
							</div>
							<div class="offset-md-1"></div>
						</div>
						<div class="form-row mt-3">
							<div class="offset-md-1"></div>
							<div class="col-md-4">
								<label for="addStartDate" class="label-form">Start Date</label>
								<input type="text" class="form-control datepicker" id="addStartDate" name="addStartDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-2"></div>
							<div class="col-md-4">
								<label for="addEndDate" class="label-form">End Date</label>
								<input type="text" class="form-control datepicker" id="addEndDate" name="addEndDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-1"></div>
						</div>
						<div class="form-row mt-3 mb-4">
							<div class="offset-md-1"></div>
							<div class="col-md-4">
								<label for="addVacationStartDate" class="label-form">Vacation Start</label>
								<input type="text" class="form-control datepicker" id="addVacationStartDate" name="addVacationStartDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-2"></div>
							<div class="col-md-4">
								<label for="addVacationEndDate" class="label-form">Vacation End</label>
								<input type="text" class="form-control datepicker" id="addVacationEndDate" name="addVacationEndDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-1"></div>
						</div>
						<script>
							var today = new Date();
							var day = today.getDate();
							var month = today.getMonth() + 1; // Note: January is 0
							var year = today.getFullYear();
							var formattedDate = (day < 10 ? '0' : '') + day + '/' + (month < 10 ? '0' : '') + month + '/' + year;
							document.getElementById('addStartDate').value = formattedDate;
							document.getElementById('addEndDate').value = formattedDate;
							document.getElementById('addVacationStartDate').value = formattedDate;
							document.getElementById('addVacationEndDate').value = formattedDate;
						</script>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addCycle()">Create</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" onclick="clearFormData('cycleRegister')" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editCycleModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Academic Cycle Edit</header>
					<form id="cycleEdit">
						<div class="form-row mt-4">
							<div class="offset-md-1"></div>
							<div class="col-md-3">
								<label for="editYear" class="label-form">Academic Year</label> 
								<select class="form-control" id="editYear" name="editYear">
								<option value="<%= nextYear %>"><%= nextYear %></option>
								<option value="<%= currentYear %>"><%= currentYear %></option>
								<%
									for (int i = currentYear - 1; i >= currentYear - 5; i--) {
								%>
								<option value="<%= i %>"><%= i %></option>
								<%
									}
								%>
								</select>
							</div>
							<div class="col-md-7">
								<label for="editDescription" class="label-form">Description</label> 
								<input type="text" class="form-control" id="editDescription" name="editDescription" placeholder="Description" title="Please enter cycle description">
							</div>
							<div class="offset-md-1"></div>
						</div>
						<div class="form-row mt-3">
							<div class="offset-md-1"></div>
							<div class="col-md-4">
								<label for="editStartDate" class="label-form">Start Date</label>
								<input type="text" class="form-control datepicker" id="editStartDate" name="editStartDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-2"></div>
							<div class="col-md-4">
								<label for="editEndDate" class="label-form">End Date</label>
								<input type="text" class="form-control datepicker" id="editEndDate" name="editEndDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-1"></div>
						</div>
						<div class="form-row mt-3 mb-4">
							<div class="offset-md-1"></div>
							<div class="col-md-4">
								<label for="editVacationStartDate" class="label-form">Vacation Start</label>
								<input type="text" class="form-control datepicker" id="editVacationStartDate" name="editVacationStartDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-2"></div>
							<div class="col-md-4">
								<label for="editVacationEndDate" class="label-form">Vacation End</label>
								<input type="text" class="form-control datepicker" id="editVacationEndDate" name="editVacationEndDate" placeholder="dd/mm/yyyy">
							</div>
							<div class="offset-md-1"></div>
						</div>
						<input type="hidden" id="editId" name="editId">
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateCycleInfo()">Save</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-default btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</section>
			</div>
		</div>
	</div>
</div>

<!-- Delete Dialogue -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content jae-border-danger">
            <div class="modal-header btn-danger">
               <h4 class="modal-title text-white" id="deleteModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Cycle Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Do you want to delete this cycle ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeDelete"><i class="bi bi-check-circle"></i>&nbsp;Delete</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>