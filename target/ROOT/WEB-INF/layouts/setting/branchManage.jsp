<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

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
	// initialise state list when loading
	// only for Admin
	if(JSON.parse(window.isAdmin)){
		listState('#listState');
		listState('#addState');
	}
	listState('#editState');


	// only for Admin
	if(JSON.parse(window.isAdmin)){
		// send diabled select value via <form>
		document.getElementById("branchList").addEventListener("submit", function() {
        	document.getElementById("listState").disabled = false;
   		});
	}

});

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Register Branch
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function addBranch() {
	//cd, email, name, phone validation
	var cd = document.getElementById('addCode');
	if(cd.value== ""){
		$('#validation-alert .modal-body').text(
		'Please choose code');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			cd.focus();
		});
		return false;
	}
	if(cd.value.length !== 2){
		$('#validation-alert .modal-body').text(
		'Code shouble be 2 digits');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			cd.focus();
		});
		return false;
	}
	var phone = document.getElementById('addPhone');
	if(phone.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter phone');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			phone.focus();
		});
		return false;
	}
	var email = document.getElementById('addEmail');
	if(email.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	let regex = new RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
	if(!regex.test(email.value)){
		$('#validation-alert .modal-body').text(
		'Please enter valid email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}

	// Get from form data
	var branch = {
		stateId: $("#addState").val(),
		code: $("#addCode").val(),
		name: $("#addName").val(),
		phone: $("#addPhone").val(),
		email: $("#addEmail").val(),
		address: $("#addAddress").val(),
		abn: $("#addAbn").val(),
		bank: $("#addBank").val(),
		bsb: $("#addBsb").val(),
		accountNumber: $("#addAccountNumber").val(),
		accountName: $("#addAccountName").val(),
		info: $("#addInfo").val()
	}
	// Send AJAX to server
	$.ajax({
		url: '${pageContext.request.contextPath}/code/registerBranch',
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(branch),
		contentType: 'application/json',
		success: function (student) {
			// Display the success alert
			$('#success-alert .modal-body').text(
				'New Branch is registered successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
	$('#registerBranchModal').modal('hide');
	// flush all registered data
	document.getElementById("branchRegister").reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Retrieve Branch
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveBranch(branchId) {

	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/code/getBranch/' + branchId,
		type: 'GET',
		success: function (branch) {
			// console.log(branch);
			$("#editId").val(branch.id);
			$("#editState").val(branch.stateId);
			$("#editState").prop('disabled', true);
			$("#editCode").val(branch.code);
			$("#editCode").prop('disabled', true);
			$("#editName").val(branch.name);
			$("#editPhone").val(branch.phone);
			$("#editEmail").val(branch.email);
			$("#editAddress").val(branch.address);
			$("#editAbn").val(branch.abn);
			$("#editBank").val(branch.bank);
			$("#editBsb").val(branch.bsb);
			$("#editAccountNumber").val(branch.accountNumber);
			$("#editAccountName").val(branch.accountName);
			$("#editInfo").val(branch.info);

			// show dialog
			$('#editBranchModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Show Branch with branch code
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function retrieveBranchCode(code) {
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/code/getBranchByCode/' + code,
		type: 'GET',
		success: function (branch) {
			// console.log(branch);
			$("#editId").val(branch.id);
			$("#editState").val(branch.stateId);
			$("#editState").prop('disabled', true);
			$("#editCode").val(branch.code);
			$("#editCode").prop('disabled', true);
			$("#editName").val(branch.name);
			$("#editPhone").val(branch.phone);
			$("#editEmail").val(branch.email);
			$("#editAddress").val(branch.address);
			$("#editAbn").val(branch.abn);
			$("#editBank").val(branch.bank);
			$("#editBsb").val(branch.bsb);
			$("#editAccountNumber").val(branch.accountNumber);
			$("#editAccountName").val(branch.accountName);
			$("#editInfo").val(branch.info);

			// show dialog
			$('#editBranchModal').modal('show');
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Update Branch
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function updateBranchInfo() {

	//cd, email, name, phone validation
	var cd = document.getElementById('editCode');
	if(cd.value== ""){
		$('#validation-alert .modal-body').text(
		'Please choose code');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			cd.focus();
		});
		return false;
	}
	if(cd.value.length !== 2){
		$('#validation-alert .modal-body').text(
		'Code shouble be 2 digits');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			cd.focus();
		});
		return false;
	}
	var phone = document.getElementById('editPhone');
	if(phone.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter phone');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			phone.focus();
		});
		return false;
	}
	var email = document.getElementById('editEmail');
	if(email.value== ""){
		$('#validation-alert .modal-body').text(
		'Please enter email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}
	//let regex = new RegExp("([!#-'*+/-9=?A-Z^-~-]+(\.[!#-'*+/-9=?A-Z^-~-]+)*|\"\(\[\]!#-[^-~ \t]|(\\[\t -~]))+\")@([!#-'*+/-9=?A-Z^-~-]+(\.[!#-'*+/-9=?A-Z^-~-]+)*|\[[\t -Z^-~]*])");
	let regex = new RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
	if(!regex.test(email.value)){
		$('#validation-alert .modal-body').text(
		'Please enter valid email');
		$('#validation-alert').modal('show');
		$('#validation-alert').on('hidden.bs.modal', function () {
			email.focus();
		});
		return false;
	}

	var branchId = $("#editId").val();
	var branchName = $("#editName").val();
	// get from formData
	var branch = {
		id: branchId,
		stateId: $("#editState").val(),
		code: $("#editCode").val(),
		name: branchName,
		phone: $("#editPhone").val(),
		email: $("#editEmail").val(),
		address: $("#editAddress").val(),
		abn: $("#editAbn").val(),
		bank: $("#editBank").val(),
		bsb: $("#editBsb").val(),
		accountNumber: $("#editAccountNumber").val(),
		accountName: $("#editAccountName").val(),
		info: $("#editInfo").val()
	}

	//console.log(cycle);
	// send query to controller
	$.ajax({
		url: '${pageContext.request.contextPath}/code/updateBranch',
		type: 'PUT',
		dataType: 'json',
		data: JSON.stringify(branch),
		contentType: 'application/json',
		success: function (value) {
			// Display success alert
			$('#success-alert .modal-body').text(
				'Branch is updated successfully.');
			$('#success-alert').modal('show');
			$('#success-alert').on('hidden.bs.modal', function (e) {
				location.reload();
			});
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});

	$('#editBranchModal').modal('hide');
	// flush all registered data
	clearFormData("branchEdit");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Delete Branch
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function deleteBranch(id) {
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/code/deleteBranch/' + id,
		type : 'PUT',
		success : function(data) {
			// clear existing form
			$('#success-alert .modal-body').text('Branch is now deleted');
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
    $('#agreeDelete').off('click').on('click', function() {
        deleteBranch(id);
        $('#deleteModal').modal('hide');
    });
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		Show Branch Info
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function showBranchInfo(state, branch){
	$.ajax({
		url: '${pageContext.request.contextPath}/code/showBranch/' + state + '/' + branch,
		type: 'GET',
		success: function (branch) {
			$('#detailTable #name').html(branch.name);
			$('#detailTable #phone').html(branch.phone);
			$('#detailTable #email').html(branch.email);
			$('#detailTable #address').html(branch.address);
			$('#detailTable #abn').html(branch.abn);
			$('#detailTable #bank').html(branch.bank);
			$('#detailTable #bsb').html(branch.bsb);
			$('#detailTable #accountNumber').html(branch.accountNumber);
			$('#detailTable #accountName').html(branch.accountName);
			$('#detailTable #infoTextArea').val(branch.info);
			// Convert markdown to HTML for display
			var formattedInfo = convertMarkdownToHtml(branch.info);
			$('#detailTable #information').html(formattedInfo);
			$('#detailTable #branchId').html(branch.id);
		},
		error: function (xhr, status, error) {
			console.log('Error : ' + error);
		}
	});
}

function convertMarkdownToHtml(text) {
    if (!text) return '';
    
    // Convert markdown to HTML
    return text
        // Bold
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        // Italic
        .replace(/_(.*?)_/g, '<em>$1</em>')
        // Underline
        .replace(/__(.*?)__/g, '<u>$1</u>')
        // Links
        .replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2">$1</a>')
        // Unordered lists
        .replace(/^\- (.*)/gm, '<li>$1</li>').replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
        // Ordered lists
        .replace(/^\d+\. (.*)/gm, '<li>$1</li>').replace(/(<li>.*<\/li>)/s, '<ol>$1</ol>')
        // Subscript
        .replace(/~(.*?)~/g, '<sub>$1</sub>')
        // Line breaks
        .replace(/\n/g, '<br>');
}

// Update the formatText function to also update the display
function formatText(command) {
    var textarea = document.getElementById('editInfo');
    var start = textarea.selectionStart;
    var end = textarea.selectionEnd;
    var selectedText = textarea.value.substring(start, end);
    var replacement = '';
    
    switch(command) {
        case 'bold':
            replacement = '**' + selectedText + '**';
            break;
        case 'italic':
            replacement = '_' + selectedText + '_';
            break;
        case 'underline':
            replacement = '__' + selectedText + '__';
            break;
        case 'link':
            var url = prompt('Enter URL:', 'http://');
            if (url) {
                replacement = '[' + selectedText + '](' + url + ')';
            }
            break;
        case 'list-ul':
            replacement = '\n- ' + selectedText.split('\n').join('\n- ');
            break;
        case 'list-ol':
            var lines = selectedText.split('\n');
            replacement = '\n' + lines.map((line, i) => `${i + 1}. ${line}`).join('\n');
            break;
        case 'subscript':
            replacement = '~' + selectedText + '~';
            break;
    }
    
    if (replacement) {
        textarea.value = textarea.value.substring(0, start) + replacement + textarea.value.substring(end);
        // Update preview if needed
        if ($('#previewInfo').length) {
            $('#previewInfo').html(convertMarkdownToHtml(textarea.value));
        }
        textarea.focus();
        textarea.selectionStart = start;
        textarea.selectionEnd = start + replacement.length;
    }
}

// Add preview functionality to the edit modal
$(document).ready(function() {
    $('#editInfo').on('input', function() {
        var formattedText = convertMarkdownToHtml($(this).val());
        // If you want to show preview in edit modal
        if ($('#previewInfo').length) {
            $('#previewInfo').html(formattedText);
        }
    });
});

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// 			Update password
////////////////////////////////////////////////////////////////////////////////////////////////////////
function updatePassword() {
	var id = $("#passwordId").val();
	var newPwd = $("#newPwd").val();
	var confirmPwd = $("#confirmPwd").val();
	//warn if Id is empty
	if (id == '') {
		$('#warning-alert .modal-body').text('Please search branch before password reset');
		$('#warning-alert').modal('toggle');
		return;
	}
	// warn if newPwd or confirmPwd is empty
	if (newPwd == '' || confirmPwd == '') {
		$('#warning-alert .modal-body').text('Please enter new password and confirm password');
		$('#warning-alert').modal('toggle');
		return;
	}
	//warn if newPwd is not same as confirmPwd
	if(newPwd != confirmPwd){
		$('#warning-alert .modal-body').text('New password and confirm password are not the same');
		$('#warning-alert').modal('toggle');
		return;
	}
	// send query to controller
	$.ajax({
		url : '${pageContext.request.contextPath}/code/updateEmailPassword/' + id + '/' + confirmPwd,
		type : 'PUT',
		success : function(data) {
			console.log(data);
			$('#success-alert .modal-body').html('<b>Password</b> is now updated');
			$('#success-alert').modal('toggle');
			// clear fields
			clearPassword();
			// close modal
			$('#passwordModal').modal('toggle');
		},
		error : function(xhr, status, error) {
			console.log('Error : ' + error);
		}
		
	}); 
}

</script>

<style>

	tr { 
		vertical-align: middle;
		height: 50px 	
	} 

	.editor-toolbar {
		background-color: #f8f9fa;
		padding: 5px;
		border: 1px solid #ced4da;
		border-bottom: none;
		border-radius: 4px 4px 0 0;
	}

	.editor-toolbar button {
		padding: 4px 8px;
	}

	.editor-toolbar button:hover {
		background-color: #e9ecef;
	}

	#editInfo {
		border-top-left-radius: 0;
		border-top-right-radius: 0;
	}

	.preview-section {
		margin-top: 15px;
		border: 1px solid #ced4da;
		border-radius: 4px;
		padding: 10px;
		background-color: #f8f9fa;
	}

	#previewInfo {
		background-color: white;
		padding: 10px;
		border: 1px solid #ced4da;
		border-radius: 4px;
	}

	#previewInfo strong {
		font-weight: bold;
	}

	#previewInfo em {
		font-style: italic;
	}

	#previewInfo u {
		text-decoration: underline;
	}

	#previewInfo ul, #previewInfo ol {
		margin-left: 20px;
		margin-bottom: 10px;
	}

	#previewInfo li {
		margin-bottom: 5px;
	}

	#previewInfo a {
		color: #007bff;
		text-decoration: underline;
	}

	#previewInfo a:hover {
		color: #0056b3;
	}

</style>

<sec:authorize access="isAuthenticated()">
<sec:authentication var="role" property='principal.authorities'/>
<sec:authentication var="state" property="principal.state"/>
<sec:authentication var="branch" property="principal.branch"/>
	<c:choose>
		<c:when test="${role == '[Administrator]'}">
			<!-- List Body -->
			<div class="row container-fluid m-5">
				<div class="modal-body">
					<form id="branchList" method="get" action="${pageContext.request.contextPath}/code/listBranch">
						<div class="form-group">
							<div class="form-row mb-5">
								<div class="col-md-2">
									<label for="listState" class="label-form">State</label>
									<select class="form-control" id="listState" name="listState" disabled>
									</select>
								</div>
								<div class="offset-md-7"></div>
								<div class="col mx-auto">
									<label class="label-form"><span style="color: white;">0</span></label>
									<button type="submit" class="btn btn-primary btn-block"> <i class="bi bi-search"></i>&nbsp;Search</button>
								</div>
								<div class="col mx-auto">
									<label class="label-form"><span style="color: white;">0</span></label>
									<button type="button" class="btn btn-block btn-info" data-toggle="modal" data-target="#registerBranchModal"><i class="bi bi-plus"></i>&nbsp;New</button>
								</div>
							</div>
						</div>
						<div class="form-group">
							<div class="form-row">
								<div class="col-md-12">
									<div class="table-wrap">
										<table id="branchListTable" class="table table-striped table-bordered">
											<thead class="table-primary">
												<tr>
													<th class="text-center align-middle">Code</th>
													<th class="text-center align-middle">State</th>
													<th class="text-center align-middle">Name</th>
													<th class="text-center align-middle">Phone</th>
													<th class="text-center align-middle">Email</th>
													<th class="text-center align-middle">Address</th>
													<th class="text-center align-middle">ABN</th>
													<th class="text-center align-middle" data-orderable="false">Action</th>
												</tr>
											</thead>
											<tbody id="list-class-body">
												<c:choose>
													<c:when test="${BranchList != null}">
														<c:forEach items="${BranchList}" var="branch">
															<tr>
																<td class="small align-middle text-center">
																	<c:out value="${branch.code}" />
																</td>
																<td class="small align-middle">
																	<span style="text-transform: capitalize;">
																		<c:choose>
																		<c:when test="${branch.stateId eq '1'}">Victoria</c:when>
																		<c:when test="${branch.stateId eq '2'}">New South Wales</c:when>
																		<c:when test="${branch.stateId eq '3'}">Queensland</c:when>
																		<c:when test="${branch.stateId eq '4'}">South Australia</c:when>
																		<c:when test="${branch.stateId eq '5'}">Tasmania</c:when>
																		<c:when test="${branch.stateId eq '6'}">Western Australia</c:when>
																		<c:when test="${branch.stateId eq '7'}">Northern Territory</c:when>
																		<c:when test="${branch.stateId eq '8'}">Australian Capital Territory</c:when>
																		<c:otherwise>Unknown State</c:otherwise>
																		</c:choose>
																	</span>
																</td>
																<td class="small align-middle">
																	<span style="text-transform: capitalize;">
																		<c:out value="${branch.name}" />
																	</span>
																</td>
																<td class="small align-middle">
																	<c:out value="${branch.phone}" />
																</td>
																<td class="small align-middle">
																	<c:out value="${branch.email}" />
																</td>
																<td class="small align-middle">
																	<c:out value="${branch.address}" />
																</td>
																<td class="small align-middle">
																	<c:out value="${branch.abn}" />
																</td>
																<td class="text-center align-middle">
																	<i class="bi bi-pencil-square text-primary fa-lg hand-cursor" data-toggle="tooltip" title="Edit" onclick="retrieveBranch('${branch.id}')"></i>&nbsp;
																	<i class="bi bi-trash text-danger hand-cursor" data-toggle="tooltip" title="Delete" onclick="showWarning('${branch.id}')"></i>
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
		</c:when>
		<c:otherwise>
			<div class="row h-100 justify-content-center align-items-center" style="width: 50%; margin:0 auto;">
				<table class="table table-hover" id="detailTable">
				<thead>
					<tr height="10px">
						<span class="text-dark mt-5 mb-5 h3">Branch Information</span>
					</tr>
				</thead>
				<tr height="80px">
					<td class="left-cell text-primary" style="vertical-align: middle;"><b>State </b></td>
					<td id="state" class="left-cell" style="vertical-align: middle;">Victoria</td>
					<td class="text-center text-primary" style="vertical-align: middle;"><b>Code</b></td>
					<td class="left-cell" style="vertical-align: middle;">${branch}</td>
					<td class="text-center text-primary" style="vertical-align: middle;"><b>Name</b></td>
					<td id="name" class="left-cell" style="vertical-align: middle;" colspan="2"></td>
				</tr>
				<tr height="80px">
					<td class="left-cell text-primary" style="vertical-align: middle;"><b>Phone</b></td>
					<td id="phone" class="left-cell" colspan="2" style="vertical-align: middle;"></td>
					<td class="text-center text-primary" style="vertical-align: middle;"><b>Email</b></td>
					<td id="email" class="left-cell" colspan="2" style="vertical-align: middle;"></td>
				</tr>
				<tr height="80px">
					<td class="left-cell text-primary" style="vertical-align: middle;"><b>Address</b></td>
					<td id="address" class="left-cell" colspan="5" style="vertical-align: middle;"></td>
				</tr>
				<tr height="80px">
					<td class="left-cell text-primary" style="vertical-align: middle; width: 15%;"><b>ABN</b></td>
					<td id="abn" class="left-cell" style="vertical-align: middle; width: 25%;"></td>
					<td class="text-center text-primary" style="vertical-align: middle; width: 15%;"><b>Brank</b></td>
					<td id="bank" class="left-cell" style="vertical-align: middle; width: 15%;"></td>
					<td class="text-center text-primary" style="vertical-align: middle; width: 15%;"><b>BSB</b></td>
					<td id="bsb" class="left-cell" style="vertical-align: middle; width: 15%;"></td>
				</tr>
				<tr height="80px">
					<td class="left-cell text-primary" colspan="1" style="vertical-align: middle; width: 15%;"><b>Account #</b></td>
					<td id="accountNumber" colspan="1" style="vertical-align: middle; width: 20%;"></td>
					<td class="left-cell text-primary" style="vertical-align: middle; width: 20%;"><b>Account Name</b></td>
					<td id="accountName" colspan="3" class="left-cell" style="vertical-align: middle; width: 45%;"></td>
				</tr>
				<tr height="80px">
					<td class="left-cell text-primary" style="vertical-align: middle;">
						<b>Information</b>
						<br><br>
						<span class="text-muted small" style="display: block; margin-top: 5px; font-style: italic; border-left: 3px solid #ccc; padding-left: 8px; line-height: 1.4;">
							The information provided here may be included in official documents such as receipts and invoices.
						</span>
					</td>
					<td id="information" class="left-cell p-5" colspan="5" style="line-height: 1.8;"></td>
				</tr>
				<tr height="80px" style="display: none;">
					<td class="left-cell"><b>Id</b></td>
					<td id="branchId" class="left-cell" colspan="5"></td>
				</tr>
				<tr height="80px">
					<td colspan="8" style="text-align: right;">
						<button type="button" class="btn btn-primary" style="width: 120px;" onclick="retrieveBranchCode('${branch}')"><i class="bi bi-pencil-square"></i>&nbsp;&nbsp;Edit</button>&nbsp;
					</td>
				</tr>
				</table> 
			</div>
			<script>
				showBranchInfo('${state}', '${branch}');
			</script>
		</c:otherwise>
	</c:choose>
</sec:authorize>


<!-- Add Form Dialogue -->
<div class="modal fade" id="registerBranchModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-info">
			<div class="modal-body">
				<section class="fieldset rounded border-info">
					<header class="text-info font-weight-bold">Branch Registration</header>
					<form id="branchRegister">
						<div class="form-row mt-4">
							<div class="col-md-3">
								<label for="addState" class="label-form">State</label>
								<select class="form-control" id="addState" name="addState">
								</select>
							</div>
							<div class="col-md-2">
								<label for="addCode" class="label-form">Code</label>
								<input type="number" class="form-control" id="addCode" name="addCode">
								</select>
							</div>
							<div class="col-md-7">
								<label for="addName" class="label-form">Name</label>
								<input type="text" class="form-control" id="addName" name="addName">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-6">
								<label for="addPhone" class="label-form">Phone</label>
								<input type="text" class="form-control" id="addPhone" name="addPhone">
							</div>
							<div class="col-md-6">
								<label for="addEmail" class="label-form">Email</label>
								<input type="text" class="form-control" id="addEmail" name="addEmail">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-12">
								<label for="addAddress" class="label-form">Address</label>
								<input type="text" class="form-control" id="addAddress" name="addAddress">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-4">
								<label for="addAbn" class="label-form">ABN</label>
								<input type="number" class="form-control" id="addAbn" name="addAbn">
							</div>
							<div class="col-md-4">
								<label for="addBank" class="label-form">Bank</label>
								<input type="text" class="form-control" id="addBank" name="addBank">
							</div>
							<div class="col-md-4">
								<label for="addBsb" class="label-form">Bsb</label>
								<input type="text" class="form-control" id="addBsb" name="addBsb">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-6">
								<label for="addAccountNumber" class="label-form">Account Number</label>
								<input type="number" class="form-control" id="addAccountNumber" name="addAccountNumber">
							</div>
							<div class="col-md-6">
								<label for="addAccountName" class="label-form">Account Name</label>
								<input type="text" class="form-control" id="addAccountName" name="addAccountName">
							</div>
						</div>
						<div class="form-row mt-2 mb-4">
							<div class="col-md-12">
								<label for="addInfo" class="label-form">Information</label>
								<textarea class="form-control" id="addInfo" name="addInfo" rows="5"></textarea>
							</div>
						</div>
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-info" onclick="addBranch()">Register</button>&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="clearFormData('branchRegister')">Close</button>
					</div>
				</section>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>

<!-- Edit Form Dialogue -->
<div class="modal fade" id="editBranchModal" tabindex="-1" role="dialog" aria-labelledby="modalEditLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content jae-border-primary">
			<div class="modal-body">
				<section class="fieldset rounded border-primary">
					<header class="text-primary font-weight-bold">Branch Edit</header>
					<form id="branchEdit">	
						<div class="form-row mt-4">
							<div class="col-md-3">
								<label for="editState" class="label-form">State</label>
								<select class="form-control" id="editState" name="editState">
								</select>
							</div>
							<div class="col-md-2">
								<label for="editCode" class="label-form">Code</label>
								<input type="text" class="form-control" id="editCode" name="editCode">
								</select>
							</div>
							<div class="col-md-7">
								<label for="editName" class="label-form">Name</label>
								<input type="text" class="form-control" id="editName" name="editName">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-6">
								<label for="editPhone" class="label-form">Phone</label>
								<input type="text" class="form-control" id="editPhone" name="editPhone">
							</div>
							<div class="col-md-6">
								<label for="editEmail" class="label-form">Email</label>
								<input type="text" class="form-control" id="editEmail" name="editEmail">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-12">
								<label for="editAddress" class="label-form">Address</label>
								<input type="text" class="form-control" id="editAddress" name="editAddress">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-4">
								<label for="editAbn" class="label-form">ABN</label>
								<input type="text" class="form-control" id="editAbn" name="editAbn">
							</div>
							<div class="col-md-4">
								<label for="editBank" class="label-form">Bank</label>
								<input type="text" class="form-control" id="editBank" name="editBank">
							</div>
							<div class="col-md-4">
								<label for="editBsb" class="label-form">Bsb</label>
								<input type="text" class="form-control" id="editBsb" name="editBsb">
							</div>
						</div>
						<div class="form-row mt-2">
							<div class="col-md-6">
								<label for="editAccountNumber" class="label-form">Account Number</label>
								<input type="text" class="form-control" id="editAccountNumber" name="editAccountNumber">
							</div>
							<div class="col-md-6">
								<label for="editAccountName" class="label-form">Account Name</label>
								<input type="text" class="form-control" id="editAccountName" name="editAccountName">
							</div>
						</div>
						<div class="form-row mt-2 mb-4">
							<div class="col-md-12">
								<label for="editInfo" class="label-form">Information</label>
								<div class="editor-toolbar mb-1">
									<select class="btn btn-sm btn-light border mr-1">
										<option>Normal</option>
										<option>Heading 1</option>
										<option>Heading 2</option>
									</select>
									<button type="button" class="btn btn-sm btn-light border mr-1" onclick="formatText('bold')"><i class="bi bi-type-bold"></i></button>
									<button type="button" class="btn btn-sm btn-light border mr-1" onclick="formatText('italic')"><i class="bi bi-type-italic"></i></button>
									<button type="button" class="btn btn-sm btn-light border mr-1" onclick="formatText('underline')"><i class="bi bi-type-underline"></i></button>
									<button type="button" class="btn btn-sm btn-light border mr-1" onclick="formatText('link')"><i class="bi bi-link"></i></button>
									<button type="button" class="btn btn-sm btn-light border mr-1" onclick="formatText('list-ul')"><i class="bi bi-list-ul"></i></button>
									<button type="button" class="btn btn-sm btn-light border mr-1" onclick="formatText('list-ol')"><i class="bi bi-list-ol"></i></button>
									<button type="button" class="btn btn-sm btn-light border" onclick="formatText('subscript')"><i class="bi bi-subscript"></i></button>
								</div>
								<textarea class="form-control mb-2" id="editInfo" name="editInfo" rows="5"></textarea>
								<div class="preview-section">
									<label class="label-form">Preview</label>
									<div id="previewInfo" class="form-control" style="min-height: 100px; max-height: 200px; overflow-y: auto;"></div>
								</div>
							</div>
						</div>
						<input type="hidden" id="editId" name="editId">
					</form>
					<div class="d-flex justify-content-end">
						<button type="submit" class="btn btn-primary" onclick="updateBranchInfo()">Save</button>&nbsp;&nbsp;
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
               <h4 class="modal-title text-white" id="deleteModalLabel"><i class="bi bi-exclamation-circle"></i>&nbsp;&nbsp;Branch Delete</h4>
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
            <div class="modal-body">
                <p> Do you want to delete this branch ?</p>	
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-danger" id="agreeDelete"><i class="bi bi-check-circle"></i>&nbsp;Delete</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div>
    	</div>
	</div>
</div>