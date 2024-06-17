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

	

	});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Inactive Students
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateInactiveStudent() {

	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/batch/updateInactiveStudent',
		type: 'GET',
		success: function (count) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				count + ' students updated successfully.');
			$('#success-alert').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Confirm Update Inactive Student
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function confirmInactiveStudent() {
    // Show the warning modal
    $('#inactiveStudentModal').modal('show');

    // Attach the click event handler to the "I agree" button
    $('#agreeUpdate').one('click', function() {
        updateInactiveStudent();
        $('#inactiveStudentModal').modal('hide');
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
	<div class="row h-100 justify-content-center align-items-center" style="width: 50%; margin:0 auto;">
		<table class="table table-hover" id="detailTable">
		<thead>
			<tr height="10px">
				<span class="text-dark mt-5 mb-5 h3">Batch Jobs</span>
			</tr>
		</thead>
		<tr height="80px">
			<td class="left-cell" style="vertical-align: middle;"><b>Update Inactive Students</b></td>
			<td class="text-right" style="vertical-align: middle;">
				<button type="button" class="btn btn-success" style="width: 120px;" onclick="confirmInactiveStudent()"><i class="bi bi-arrow-up-circle"></i>&nbsp;&nbsp;Update</button>
			</td>
		</tr>
		</table> 
	</div>
</div>

<!-- Success Alert -->
<div id="success-alert" class="modal fade">
	<div class="modal-dialog">
		<div class="alert alert-block alert-success alert-dialog-display">
			<i class="bi bi-check-circle-fill fa-2x"></i>&nbsp;&nbsp;<div class="modal-body"></div>
			<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
		</div>
	</div>
</div>

<!--Inactive Student Modal -->
<div class="modal fade" id="inactiveStudentModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content" style="border: 2px solid #ffc107; border-radius: 10px;">
            <div class="modal-header bg-warning" style="display: block;">
                <p style="text-align: center; margin-bottom: 0;"><span style="font-size:18px"><strong>Update Inactive Student Batch</strong></span></p>
            </div>
            <div class="modal-body" style="background-color: #f8f9fa; border-radius: 5px; padding: 20px;">
                <div style="text-align: center; margin-bottom: 20px;">
                    <img src="${pageContext.request.contextPath}/image/inactive.png" style="width: 150px; height: 150px; border-radius: 5%;">
                </div>
                <span class="text-primary"><strong>Inactive Student</strong></span>
				The system will scan and update all students. If a student's most recent enrollment is more than 180 days old, their status will be updated to inactive.                
                <br><br><p class="text-center"><strong>Are you still want to proceed this ?</strong></p>      
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="agreeUpdate">Yes, I am sure</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">No, I don't want</button>
            </div>
        </div>
    </div>
</div>